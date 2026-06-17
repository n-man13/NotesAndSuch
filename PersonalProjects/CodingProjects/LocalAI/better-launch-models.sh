#!/usr/bin/env bash
set -euo pipefail

# This launcher is intended for a dual-socket NUMA host.
# Keep each llama-server stack local to one socket to avoid cross-node memory traffic.
#
# Recommended node placement for this server:
# - node 0: leave empty for the OS and ssh services
# - node 1: router_engine
# - node 2: autocomplete_engine
# - node 3: thinker_engine (70B model)
#
# Services:
# - router_engine: public router on port 8085, backend on 18085
# - autocomplete_engine: public autocomplete on port 8086, backend on 18086
# - thinker_engine: optional 70B model on port 8087, backend on 18087
#
# Launch modes:
# - start: route the public ports through the transcript proxy and log the last 5 exchanges
# - quiet-start: start the same models without the transcript proxy/logger
# - stop: stop tracked processes and then prompt for any remaining llama-server instances
# - force-stop: stop everything and clear the transcript log

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LLAMA_CPP_DIR="${LLAMA_CPP_DIR:-$HOME/llama.cpp}"
MODEL_DIR="${MODEL_DIR:-$ROOT_DIR/models}"
AUTOCOMPLETE_DIR="${MODEL_DIR}/autocomplete"
LOG_DIR="${LOG_DIR:-$ROOT_DIR/logs}"
BIND_HOST="${BIND_HOST:-0.0.0.0}"
ACTION="${1:-start}"
API_KEY_FILE="${LLAMA_API_KEY_FILE:-}"
LAUNCH_LOG="$LOG_DIR/launcher.log"
TRANSCRIPT_LOG="$LOG_DIR/transcript.jsonl"
PROXY_HELPER="$ROOT_DIR/transcript-proxy.py"
PUBLIC_ROUTER_PORT=8085
PUBLIC_AUTOCOMPLETE_PORT=8086
PUBLIC_THINKER_PORT=8087
ROUTER_BACKEND_PORT=18085
AUTOCOMPLETE_BACKEND_PORT=18086
THINKER_BACKEND_PORT=18087
NUMA_ROUTER_NODE="${NUMA_ROUTER_NODE:-1}"
NUMA_AUTOCOMPLETE_NODE="${NUMA_AUTOCOMPLETE_NODE:-2}"
NUMA_THINKER_NODE="${NUMA_THINKER_NODE:-3}"
NUMACTL_BIN="$(command -v numactl || true)"
#THINKER_MODEL_DIR="${THINKER_MODEL_DIR:-$LLAMA_CPP_DIR/models/thinker}"

# Hardware detection for threading and NUMA alignment
TOTAL_CORES=$(nproc)
NUM_NODES=$(ls -d /sys/devices/system/node/node[0-9]* 2>/dev/null | wc -l || echo 1)
MAX_NUMA_NODE=$(( NUM_NODES > 0 ? NUM_NODES - 1 : 0 ))
THREADS_PER_NODE=$(( TOTAL_CORES / (MAX_NUMA_NODE + 1) ))

#THINKER_MODEL_PATH="${THINKER_MODEL_PATH:-$THINKER_MODEL_DIR/Meta-Llama-3.1-70B-Instruct-Q4_K_M.gguf}"


# Locate the binary
SERVER_BIN=""
if [[ -x "$LLAMA_CPP_DIR/llama-server" ]]; then
  SERVER_BIN="$LLAMA_CPP_DIR/llama-server"
elif [[ -x "$LLAMA_CPP_DIR/build/bin/llama-server" ]]; then
  SERVER_BIN="$LLAMA_CPP_DIR/build/bin/llama-server"
else
  echo "Could not find llama-server" >&2
  exit 1
fi

mkdir -p "$LOG_DIR"

log() {
  local message="$1"
  local timestamp

  timestamp="$(date '+%Y-%m-%d %H:%M:%S')"
  printf '%s %s\n' "$timestamp" "$message" | tee -a "$LAUNCH_LOG"
}

clear_transcript_log() {
  : > "$TRANSCRIPT_LOG"
  log "Cleared transcript log at $TRANSCRIPT_LOG"
}

kill_lingering_proxy_processes() {
  pkill -f "transcript-proxy.py" || true
}

stop_instance() {
  local label="$1"
  local pid_file="$2"

  if [[ -f "$pid_file" ]]; then
    local pid
    pid="$(cat "$pid_file")"
    if kill "$pid" 2>/dev/null; then
      echo "Stopped $label (pid $pid)"
      rm -f "$pid_file"
      return
    fi
  fi

  echo "No running pid file found for $label" >&2
}

prompt_stop_process() {
  local pid="$1"
  local command_line="$2"
  local reply

  read -r -p "Stop remaining process $pid: $command_line ? [y/N] " reply
  case "$reply" in
    y|Y|yes|YES)
      if kill "$pid" 2>/dev/null; then
        echo "Stopped pid $pid"
      else
        echo "Failed to stop pid $pid" >&2
      fi
      ;;
    *)
      echo "Left pid $pid running"
      ;;
  esac
}

handle_remaining_processes() {
  local force_stop="${1:-false}"
  local pids
  local pid
  local command_line

  pids="$(pgrep -x llama-server || true)"
  if [[ -z "$pids" ]]; then
    echo "No additional llama-server processes found."
    return
  fi

  if [[ "$force_stop" == "true" ]]; then
    echo "Force-stopping remaining llama-server processes..."
    for pid in $pids; do
      if kill "$pid" 2>/dev/null; then
        echo "Stopped pid $pid"
      else
        echo "Failed to stop pid $pid" >&2
      fi
    done
    return
  fi

  echo "Remaining llama-server processes:"
  for pid in $pids; do
    command_line="$(ps -p "$pid" -o args= 2>/dev/null || true)"
    echo "  $pid: $command_line"
  done

  for pid in $pids; do
    command_line="$(ps -p "$pid" -o args= 2>/dev/null || true)"
    prompt_stop_process "$pid" "$command_line"
  done
}

start_instance() {
  local label="$1"
  local pid_file="$2"
  shift 2
  local log_file="$LOG_DIR/${label}.log"

  log "Starting $label"
  log "  log file: $log_file"
  log "  server binary: $SERVER_BIN"
  log "  API key file: ${API_KEY_FILE:-<none>}"
  log "  command: $SERVER_BIN ${API_KEY_FILE:+--api-key-file \"$API_KEY_FILE\" }$*"
  if [[ -n "$API_KEY_FILE" ]]; then
    nohup "$SERVER_BIN" --api-key-file "$API_KEY_FILE" "$@" > "$log_file" 2>&1 &
  else
    nohup "$SERVER_BIN" "$@" > "$log_file" 2>&1 &
  fi
  echo $! > "$pid_file"
  log "  pid: $(cat "$pid_file")"
}

build_numa_prefix() {
  local node="$1"

  if [[ -n "$NUMACTL_BIN" ]]; then
    printf '%s\n' "$NUMACTL_BIN --cpunodebind=$node --preferred=$node"
  fi
}

start_instance_on_node() {
  local label="$1"
  local pid_file="$2"
  local node="$3"
  shift 3
  local log_file="$LOG_DIR/${label}.log"
  local -a numa_prefix=()

  if [[ -n "$NUMACTL_BIN" ]]; then
    numa_prefix=($NUMACTL_BIN --cpunodebind="$node" --preferred="$node")
  fi

  log "Starting $label"
  log "  NUMA node: $node"
  log "  log file: $log_file"
  log "  server binary: $SERVER_BIN"
  log "  API key file: ${API_KEY_FILE:-<none>}"
  if [[ -n "$NUMACTL_BIN" ]]; then
    log "  NUMA wrapper: $NUMACTL_BIN --cpunodebind=$node --preferred=$node"
  else
    log "  NUMA wrapper: <none; numactl not installed>"
  fi
  log "  command: ${numa_prefix[*]} $SERVER_BIN ${API_KEY_FILE:+--api-key-file \"$API_KEY_FILE\" }$*"

  if [[ -n "$API_KEY_FILE" ]]; then
    nohup "${numa_prefix[@]}" "$SERVER_BIN" --api-key-file "$API_KEY_FILE" "$@" > "$log_file" 2>&1 &
  else
    nohup "${numa_prefix[@]}" "$SERVER_BIN" "$@" > "$log_file" 2>&1 &
  fi
  echo $! > "$pid_file"
  log "  pid: $(cat "$pid_file")"
}

start_proxy_instance() {
  local label="$1"
  local pid_file="$2"
  local log_file="$3"
  local listen_port="$4"
  local upstream_port="$5"

  log "Starting $label proxy"
  log "  log file: $log_file"
  log "  transcript file: $TRANSCRIPT_LOG"
  log "  listen: http://$BIND_HOST:$listen_port"
  log "  upstream: http://127.0.0.1:$upstream_port"
  nohup python3 "$PROXY_HELPER" \
    --label "$label" \
    --listen-host "$BIND_HOST" \
    --listen-port "$listen_port" \
    --upstream-host 127.0.0.1 \
    --upstream-port "$upstream_port" \
    --transcript-file "$TRANSCRIPT_LOG" \
    --max-entries 5 \
    > "$log_file" 2>&1 &
  echo $! > "$pid_file"
  log "  pid: $(cat "$pid_file")"
}

start_proxy_instance_on_node() {
  local label="$1"
  local pid_file="$2"
  local log_file="$3"
  local node="$4"
  local listen_port="$5"
  local upstream_port="$6"
  local -a numa_prefix=()

  if [[ -n "$NUMACTL_BIN" ]]; then
    numa_prefix=($NUMACTL_BIN --cpunodebind="$node" --membind="$node")
  fi

  log "Starting $label proxy"
  log "  NUMA node: $node"
  log "  log file: $log_file"
  log "  transcript file: $TRANSCRIPT_LOG"
  log "  listen: http://$BIND_HOST:$listen_port"
  log "  upstream: http://127.0.0.1:$upstream_port"
  if [[ -n "$NUMACTL_BIN" ]]; then
    log "  NUMA wrapper: $NUMACTL_BIN --cpunodebind=$node --membind=$node"
  else
    log "  NUMA wrapper: <none; numactl not installed>"
  fi
  nohup "${numa_prefix[@]}" python3 "$PROXY_HELPER" \
    --label "$label" \
    --listen-host "$BIND_HOST" \
    --listen-port "$listen_port" \
    --upstream-host 127.0.0.1 \
    --upstream-port "$upstream_port" \
    --transcript-file "$TRANSCRIPT_LOG" \
    --max-entries 5 \
    > "$log_file" 2>&1 &
  echo $! > "$pid_file"
  log "  pid: $(cat "$pid_file")"
}

case "$ACTION" in
  start)
    # Kill any lingering instances first so the new ports come up cleanly.
    log "Cleaning up any pre-existing llama-server processes before start"
    pkill llama-server || true
    kill_lingering_proxy_processes

    start_instance_on_node "router_engine.backend" "$LOG_DIR/router_engine.backend.pid" "$NUMA_ROUTER_NODE" \
      --host 127.0.0.1 \
      --port "$ROUTER_BACKEND_PORT" \
      --models-dir "$MODEL_DIR" \
      --models-max 1 \
      --sleep-idle-seconds 1800 \
      -t "$THREADS_PER_NODE" \
      --timeout 1800000 \
      -c 8192

    start_proxy_instance_on_node "router_engine" "$LOG_DIR/router_engine.pid" "$LOG_DIR/router_engine.proxy.log" "$NUMA_ROUTER_NODE" "$PUBLIC_ROUTER_PORT" "$ROUTER_BACKEND_PORT"

    start_instance_on_node "autocomplete_engine.backend" "$LOG_DIR/autocomplete_engine.backend.pid" "$NUMA_AUTOCOMPLETE_NODE" \
      --host 127.0.0.1 \
      --port "$AUTOCOMPLETE_BACKEND_PORT" \
      -m "$AUTOCOMPLETE_DIR/Qwen2.5-Coder-1.5B-Instruct-Q4_K_M.gguf" \
      -t "$THREADS_PER_NODE" \
      -c 8192 \
      --slots

    start_proxy_instance_on_node "autocomplete_engine" "$LOG_DIR/autocomplete_engine.pid" "$LOG_DIR/autocomplete_engine.proxy.log" "$NUMA_AUTOCOMPLETE_NODE" "$PUBLIC_AUTOCOMPLETE_PORT" "$AUTOCOMPLETE_BACKEND_PORT"

    if [[ -f "$THINKER_MODEL_PATH" ]]; then
      start_instance_on_node "thinker_engine.backend" "$LOG_DIR/thinker_engine.backend.pid" "$NUMA_THINKER_NODE" \
        --host 127.0.0.1 \
        --port "$THINKER_BACKEND_PORT" \
        -m "$THINKER_MODEL_PATH" \
        -t "$TOTAL_CORES" \
        --timeout 1800000 \
        -c 8192

      start_proxy_instance_on_node "thinker_engine" "$LOG_DIR/thinker_engine.pid" "$LOG_DIR/thinker_engine.proxy.log" "$NUMA_THINKER_NODE" "$PUBLIC_THINKER_PORT" "$THINKER_BACKEND_PORT"
    else
      log "Skipping thinker_engine: missing model file $THINKER_MODEL_PATH"
    fi

    echo "All systems initialized cleanly!"
    log "Start sequence complete"
    ;;
  quiet-start)
    log "Cleaning up any pre-existing llama-server processes before quiet-start"
    pkill llama-server || true
    kill_lingering_proxy_processes

    start_instance_on_node "router_engine" "$LOG_DIR/router_engine.pid" "$NUMA_ROUTER_NODE" \
      --host "$BIND_HOST" \
      --port "$PUBLIC_ROUTER_PORT" \
      --models-dir "$MODEL_DIR" \
      --models-max 1 \
      --sleep-idle-seconds 1800 \
      -t "$THREADS_PER_NODE" \
      --timeout 600000

    start_instance_on_node "autocomplete_engine" "$LOG_DIR/autocomplete_engine.pid" "$NUMA_AUTOCOMPLETE_NODE" \
      --host "$BIND_HOST" \
      --port "$PUBLIC_AUTOCOMPLETE_PORT" \
      -m "$AUTOCOMPLETE_DIR/Qwen2.5-Coder-1.5B-Instruct-Q4_K_M.gguf" \
      -t "$THREADS_PER_NODE" \
      -c 8192 \
      --slots

    if [[ -f "$THINKER_MODEL_PATH" ]]; then
      start_instance_on_node "thinker_engine" "$LOG_DIR/thinker_engine.pid" "$NUMA_THINKER_NODE" \
        --host "$BIND_HOST" \
        --port "$PUBLIC_THINKER_PORT" \
        -m "$THINKER_MODEL_PATH" \
        -t "$(nproc)" \
        --timeout 600000
    else
      log "Skipping thinker_engine for quiet-start: missing model file $THINKER_MODEL_PATH"
    fi

    echo "All systems initialized cleanly!"
    log "Quiet-start sequence complete"
    ;;
  stop)
    log "Stopping tracked instances and then checking for any remaining llama-server processes"
    stop_instance "Dynamic Router Engine" "$LOG_DIR/router_engine.pid"
    stop_instance "Dynamic Router Backend" "$LOG_DIR/router_engine.backend.pid"
    stop_instance "Dedicated Autocomplete Daemon" "$LOG_DIR/autocomplete_engine.pid"
    stop_instance "Dedicated Autocomplete Backend" "$LOG_DIR/autocomplete_engine.backend.pid"
    stop_instance "Thinker Engine" "$LOG_DIR/thinker_engine.pid"
    stop_instance "Thinker Engine Backend" "$LOG_DIR/thinker_engine.backend.pid"
    handle_remaining_processes false
    log "Stop sequence complete"
    ;;
  force-stop)
    log "Force-stopping tracked instances and any remaining llama-server processes"
    stop_instance "Dynamic Router Engine" "$LOG_DIR/router_engine.pid"
    stop_instance "Dynamic Router Backend" "$LOG_DIR/router_engine.backend.pid"
    stop_instance "Dedicated Autocomplete Daemon" "$LOG_DIR/autocomplete_engine.pid"
    stop_instance "Dedicated Autocomplete Backend" "$LOG_DIR/autocomplete_engine.backend.pid"
    stop_instance "Thinker Engine" "$LOG_DIR/thinker_engine.pid"
    stop_instance "Thinker Engine Backend" "$LOG_DIR/thinker_engine.backend.pid"
    handle_remaining_processes true
    kill_lingering_proxy_processes
    clear_transcript_log
    log "Force-stop sequence complete"
    ;;
  *)
    echo "Usage: $0 [start|quiet-start|stop|force-stop]" >&2
    exit 1
    ;;
esac