#!/usr/bin/env bash
set -euo pipefail

# This launcher is intended for a dual-socket NUMA host with a single CUDA GPU
# (Tesla P4, 8GB VRAM) shared across the three engines below.
#
# Hardware notes:
# - 2x Opteron 6274: each physical socket is internally two NUMA nodes
#   (two 8-core dies per package), so this host presents as 4 NUMA nodes.
# - Tesla P4 has only 8GB VRAM. Since router_engine, autocomplete_engine, and
#   thinker_engine can all be running at once, that 8GB is SPLIT across all
#   three via the *_NGL (n-gpu-layers) values below, not given wholly to one.
#   Tune these against `nvidia-smi` after first boot -- if you see OOM errors
#   in the logs, lower the relevant _NGL value; if there's headroom, raise it.
#
# Recommended node placement for this server:
# - node 0: leave empty for the OS and ssh services
# - node 1: router_engine
# - node 2: autocomplete_engine
# - node 3: thinker_engine (14B + 70B models, swapped on demand)
#
# Services:
# - router_engine: public router on port 8085, backend on 18085
#     Serves whichever model is requested from MODEL_DIR (models-max 1 loaded
#     at a time). Holds the mid-size models: gemma-2-9b, Llama-3.1-8B,
#     Mistral-7B, Phi-3.5-mini, Qwen2.5-7B, openhermes-2.5-7b. NOTE: the 14B
#     model is intentionally NOT placed in MODEL_DIR -- it lives in
#     THINKER_MODEL_DIR instead (see thinker_engine below). Since the
#     largest model the router now serves is ~9B, ROUTER_NGL defaults to a
#     near-full offload.
# - autocomplete_engine: public autocomplete on port 8086, backend on 18086
#     Dedicated to Qwen2.5-Coder-1.5B-Instruct -- small enough to fully
#     offload to GPU, which matters most here since this is the
#     latency-sensitive path.
# - thinker_engine: port 8087, backend on 18087
#     Uses --models-dir (like router_engine) over THINKER_MODEL_DIR, which
#     should contain ONLY Qwen2.5-14B-Instruct and Meta-Llama-3.1-70B-Instruct.
#     Only one of the two is loaded into memory at a time (models-max 1) and
#     llama-server swaps on demand -- they "share" the engine/port rather than
#     running concurrently. NUMA placement, thread count, and GPU offload
#     (THINKER_NGL) are unchanged from the single-model setup.
#
# Logging (no Python required):
# - start: relays each public port through `socat -v`, which mirrors both
#   directions of raw HTTP traffic (requests + responses) into a per-engine
#   log file under LOG_DIR (e.g. router_engine.traffic.log). This replaces
#   the old transcript-proxy.py, which needed Python 3.7+ for
#   ThreadingHTTPServer and isn't usable on Python 3.6.8 hosts.
#   Caveat: this is raw traffic, not parsed/trimmed JSON -- there's no
#   "last 5 exchanges" trimming anymore. Use `grep`/`jq` on the log file to
#   pull out specific exchanges, and consider logrotate or a cron job with
#   `find ... -mtime +N -delete` to keep the files from growing unbounded.
#   Requires `socat` to be installed (apt install socat); if it's missing,
#   the engine still starts but traffic won't be logged.
# - quiet-start: start the same models directly on the public ports, no
#   socat relay, no logging.
# - stop: stop tracked processes and then prompt for any remaining llama-server instances
# - force-stop: stop everything and clear the traffic logs

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LLAMA_CPP_DIR="${LLAMA_CPP_DIR:-$HOME/llama.cpp}"
MODEL_DIR="${MODEL_DIR:-$ROOT_DIR/models}"
AUTOCOMPLETE_DIR="${MODEL_DIR}/autocomplete"
LOG_DIR="${LOG_DIR:-$ROOT_DIR/logs}"
BIND_HOST="${BIND_HOST:-0.0.0.0}"
ACTION="${1:-start}"
API_KEY_FILE="${LLAMA_API_KEY_FILE:-}"
LAUNCH_LOG="$LOG_DIR/launcher.log"
SOCAT_BIN="$(command -v socat || true)"
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

# --- GPU offload settings -----------------------------------------------
# Single Tesla P4 (8GB) shared across all three engines. These are starting
# points, not gospel -- watch `nvidia-smi` while all three are running and
# adjust. Set any of these to 0 to keep that engine CPU-only.
GPU_DEVICE_ID="${GPU_DEVICE_ID:-0}"
ROUTER_NGL="${ROUTER_NGL:-99}"         # router now serves max ~9B models -- offload (near-)fully
AUTOCOMPLETE_NGL="${AUTOCOMPLETE_NGL:-99}"  # 1.5B model -- fully offload, it's tiny
THINKER_NGL="${THINKER_NGL:-6}"       # 14B/70B -- only a few layers fit in leftover VRAM
# NOTE: router (~6GB) + autocomplete (~2GB) + thinker (~1GB) is already close
# to the P4's 8GB ceiling when all three are loaded simultaneously. If you
# see OOM/CUDA alloc failures in the logs once the thinker_engine swaps in
# a model while router and autocomplete are also warm, lower ROUTER_NGL
# first since it has the most headroom to give back.
# --------------------------------------------------------------------------

# Thinker now hosts TWO models (14B and 70B) that take turns via
# --models-dir/--models-max 1, the same swap-on-demand mechanism the router
# uses. THINKER_MODEL_DIR should contain ONLY these two .gguf files.
THINKER_MODEL_DIR="${THINKER_MODEL_DIR:-$MODEL_DIR/thinker}"

# Hardware detection for threading and NUMA alignment
TOTAL_CORES=$(nproc)
NUM_NODES=$(ls -d /sys/devices/system/node/node[0-9]* 2>/dev/null | wc -l || echo 1)
MAX_NUMA_NODE=$(( NUM_NODES > 0 ? NUM_NODES - 1 : 0 ))
THREADS_PER_NODE=$(( TOTAL_CORES / (MAX_NUMA_NODE + 1) ))

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

clear_traffic_logs() {
  : > "$LOG_DIR/router_engine.traffic.log" 2>/dev/null || true
  : > "$LOG_DIR/autocomplete_engine.traffic.log" 2>/dev/null || true
  : > "$LOG_DIR/thinker_engine.traffic.log" 2>/dev/null || true
  log "Cleared traffic logs in $LOG_DIR"
}

kill_lingering_proxy_processes() {
  pkill -f "socat .*TCP-LISTEN:$PUBLIC_ROUTER_PORT" || true
  pkill -f "socat .*TCP-LISTEN:$PUBLIC_AUTOCOMPLETE_PORT" || true
  pkill -f "socat .*TCP-LISTEN:$PUBLIC_THINKER_PORT" || true
}

directory_has_gguf() {
  local dir="$1"
  [[ -d "$dir" ]] && find "$dir" -maxdepth 1 -name '*.gguf' -print -quit 2>/dev/null | grep -q .
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
    nohup env CUDA_VISIBLE_DEVICES="$GPU_DEVICE_ID" "${numa_prefix[@]}" "$SERVER_BIN" --api-key-file "$API_KEY_FILE" "$@" > "$log_file" 2>&1 &
  else
    nohup env CUDA_VISIBLE_DEVICES="$GPU_DEVICE_ID" "${numa_prefix[@]}" "$SERVER_BIN" "$@" > "$log_file" 2>&1 &
  fi
  echo $! > "$pid_file"
  log "  pid: $(cat "$pid_file")"
}

start_traffic_logger_on_node() {
  local label="$1"
  local pid_file="$2"
  local socat_stderr_log="$3"
  local node="$4"
  local listen_port="$5"
  local upstream_port="$6"
  local traffic_log="$LOG_DIR/${label}.traffic.log"
  local -a numa_prefix=()

  if [[ -z "$SOCAT_BIN" ]]; then
    log "socat not found -- skipping traffic logging for $label (engine itself is unaffected; install socat to enable logging)"
    return
  fi

  if [[ -n "$NUMACTL_BIN" ]]; then
    numa_prefix=($NUMACTL_BIN --cpunodebind="$node" --membind="$node")
  fi

  log "Starting $label traffic logger (socat)"
  log "  NUMA node: $node"
  log "  traffic log: $traffic_log"
  log "  listen: http://$BIND_HOST:$listen_port"
  log "  upstream: http://127.0.0.1:$upstream_port"
  if [[ -n "$NUMACTL_BIN" ]]; then
    log "  NUMA wrapper: $NUMACTL_BIN --cpunodebind=$node --membind=$node"
  else
    log "  NUMA wrapper: <none; numactl not installed>"
  fi

  # -v mirrors both directions of traffic (prefixed with > and <) into the
  # log set by -lf. fork handles each connection in its own subprocess so
  # concurrent requests don't block each other.
  nohup "${numa_prefix[@]}" "$SOCAT_BIN" \
    -v -lf "$traffic_log" \
    TCP-LISTEN:"$listen_port",bind="$BIND_HOST",fork,reuseaddr \
    TCP:127.0.0.1:"$upstream_port" \
    > "$socat_stderr_log" 2>&1 &
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
      -ngl "$ROUTER_NGL" \
      -c 8192

    start_traffic_logger_on_node "router_engine" "$LOG_DIR/router_engine.pid" "$LOG_DIR/router_engine.proxy.log" "$NUMA_ROUTER_NODE" "$PUBLIC_ROUTER_PORT" "$ROUTER_BACKEND_PORT"

    start_instance_on_node "autocomplete_engine.backend" "$LOG_DIR/autocomplete_engine.backend.pid" "$NUMA_AUTOCOMPLETE_NODE" \
      --host 127.0.0.1 \
      --port "$AUTOCOMPLETE_BACKEND_PORT" \
      -m "$AUTOCOMPLETE_DIR/Qwen2.5-Coder-1.5B-Instruct-Q4_K_M.gguf" \
      -t "$THREADS_PER_NODE" \
      -c 8192 \
      -ngl "$AUTOCOMPLETE_NGL" \
      --slots

    start_traffic_logger_on_node "autocomplete_engine" "$LOG_DIR/autocomplete_engine.pid" "$LOG_DIR/autocomplete_engine.proxy.log" "$NUMA_AUTOCOMPLETE_NODE" "$PUBLIC_AUTOCOMPLETE_PORT" "$AUTOCOMPLETE_BACKEND_PORT"

    if directory_has_gguf "$THINKER_MODEL_DIR"; then
      start_instance_on_node "thinker_engine.backend" "$LOG_DIR/thinker_engine.backend.pid" "$NUMA_THINKER_NODE" \
        --host 127.0.0.1 \
        --port "$THINKER_BACKEND_PORT" \
        --models-dir "$THINKER_MODEL_DIR" \
        --models-max 1 \
        --sleep-idle-seconds 1800 \
        -t "$TOTAL_CORES" \
        --timeout 1800000 \
        -ngl "$THINKER_NGL" \
        -c 8192

      start_traffic_logger_on_node "thinker_engine" "$LOG_DIR/thinker_engine.pid" "$LOG_DIR/thinker_engine.proxy.log" "$NUMA_THINKER_NODE" "$PUBLIC_THINKER_PORT" "$THINKER_BACKEND_PORT"
    else
      log "Skipping thinker_engine: no .gguf files found in $THINKER_MODEL_DIR"
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
      --timeout 600000 \
      -ngl "$ROUTER_NGL"

    start_instance_on_node "autocomplete_engine" "$LOG_DIR/autocomplete_engine.pid" "$NUMA_AUTOCOMPLETE_NODE" \
      --host "$BIND_HOST" \
      --port "$PUBLIC_AUTOCOMPLETE_PORT" \
      -m "$AUTOCOMPLETE_DIR/Qwen2.5-Coder-1.5B-Instruct-Q4_K_M.gguf" \
      -t "$THREADS_PER_NODE" \
      -c 8192 \
      -ngl "$AUTOCOMPLETE_NGL" \
      --slots

    if directory_has_gguf "$THINKER_MODEL_DIR"; then
      start_instance_on_node "thinker_engine" "$LOG_DIR/thinker_engine.pid" "$NUMA_THINKER_NODE" \
        --host "$BIND_HOST" \
        --port "$PUBLIC_THINKER_PORT" \
        --models-dir "$THINKER_MODEL_DIR" \
        --models-max 1 \
        --sleep-idle-seconds 1800 \
        -t "$(nproc)" \
        --timeout 600000 \
        -ngl "$THINKER_NGL"
    else
      log "Skipping thinker_engine for quiet-start: no .gguf files found in $THINKER_MODEL_DIR"
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
    clear_traffic_logs
    log "Force-stop sequence complete"
    ;;
  *)
    echo "Usage: $0 [start|quiet-start|stop|force-stop]" >&2
    exit 1
    ;;
esac