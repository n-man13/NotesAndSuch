#!/usr/bin/env bash
set -euo pipefail

# ==========================================================================
# HARDWARE-OPTIMIZED LAUNCHER BASED ON OVERNIGHT EMPIRICAL PROFILING DATA
# ==========================================================================
# Host Architecture: Dual Opteron 6274 (4 Physical NUMA Nodes total)
# GPU: Tesla P4 (8GB VRAM)
#
# Overnight Benchmark Proven Discoveries Applied:
# 1. Broad interleaved channel memory distribution (--interleave=all) scales 
#    large parameter models (14B/70B+) significantly faster than strict single-node
#    pinning by saturating the full 8-channel host DDR3 bandwidth.
# 2. Partial GPU offloading on large models introduces a massive PCIe synchronization 
#    bottleneck. Leaving the thinker engine purely CPU-only and interleaved optimizes 
#    throughput and completely isolates the GPU for low-latency routing/autocomplete tasks.
# ==========================================================================

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

# Specialized Topology Mappings
NUMA_ROUTER_NODE="${NUMA_ROUTER_NODE:-1}"       # Node nearest to GPU PCIe path
NUMA_AUTOCOMPLETE_NODE="${NUMA_AUTOCOMPLETE_NODE:-2}"
NUMACTL_BIN="$(command -v numactl || true)"

# --- Optimized GPU Offload Layout ---
GPU_DEVICE_ID="${GPU_DEVICE_ID:-0}"
ROUTER_NGL="${ROUTER_NGL:-99}"       # Offload mid-size models fully to the P4
AUTOCOMPLETE_NGL="${AUTOCOMPLETE_NGL:-99}"  # 1.5B model remains fully pinned to VRAM for instant latency
THINKER_NGL=0                        # CRITICAL: 14B/70B are now CPU-only to avoid PCIe bottlenecks

THINKER_MODEL_DIR="${THINKER_MODEL_DIR:-$MODEL_DIR/thinker}"

# Hardware Calculation Properties
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

start_instance_on_node() {
  local label="$1"
  local pid_file="$2"
  local mode="$3" # Accepts "node" or "interleave"
  local node_val="$4"
  shift 4
  local log_file="$LOG_DIR/${label}.log"
  local -a numa_prefix=()

  if [[ -n "$NUMACTL_BIN" ]]; then
    if [[ "$mode" == "interleave" ]]; then
      numa_prefix=($NUMACTL_BIN --interleave=all)
    else
      numa_prefix=($NUMACTL_BIN --cpunodebind="$node_val" --preferred="$node_val")
    fi
  fi

  log "Starting $label"
  log "  Memory Policy Strategy: $mode ($node_val)"
  log "  log file: $log_file"
  log "  server binary: $SERVER_BIN"
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
  local mode="$4"
  local node_val="$5"
  local listen_port="$6"
  local upstream_port="$7"
  local traffic_log="$LOG_DIR/${label}.traffic.log"
  local -a numa_prefix=()

  if [[ -z "$SOCAT_BIN" ]]; then
    log "socat not found -- skipping traffic logging for $label"
    return
  fi

  if [[ -n "$NUMACTL_BIN" ]]; then
    if [[ "$mode" == "interleave" ]]; then
      numa_prefix=($NUMACTL_BIN --interleave=all)
    else
      numa_prefix=($NUMACTL_BIN --cpunodebind="$node_val" --membind="$node_val")
    fi
  fi

  nohup "${numa_prefix[@]}" "$SOCAT_BIN" \
    -v -lf "$traffic_log" \
    TCP-LISTEN:"$listen_port",bind="$BIND_HOST",fork,reuseaddr \
    TCP:127.0.0.1:"$upstream_port" \
    > "$socat_stderr_log" 2>&1 &
  echo $! > "$pid_file"
}

case "$ACTION" in
  start)
    log "Cleaning up any pre-existing llama-server processes before start"
    pkill llama-server || true
    kill_lingering_proxy_processes

    # 1. Router Engine Backend Setup (Pinned local to GPU Node 1)
    start_instance_on_node "router_engine.backend" "$LOG_DIR/router_engine.backend.pid" "node" "$NUMA_ROUTER_NODE" \
      --host 127.0.0.1 \
      --port "$ROUTER_BACKEND_PORT" \
      --models-dir "$MODEL_DIR" \
      --models-max 1 \
      --sleep-idle-seconds 1800 \
      -t "$THREADS_PER_NODE" \
      --timeout 1800000 \
      -ngl "$ROUTER_NGL" \
      -c 8192

    start_traffic_logger_on_node "router_engine" "$LOG_DIR/router_engine.pid" "$LOG_DIR/router_engine.proxy.log" "node" "$NUMA_ROUTER_NODE" "$PUBLIC_ROUTER_PORT" "$ROUTER_BACKEND_PORT"

    # 2. Autocomplete Engine Backend Setup (Pinned to Node 2)
    start_instance_on_node "autocomplete_engine.backend" "$LOG_DIR/autocomplete_engine.backend.pid" "node" "$NUMA_AUTOCOMPLETE_NODE" \
      --host 127.0.0.1 \
      --port "$AUTOCOMPLETE_BACKEND_PORT" \
      -m "$AUTOCOMPLETE_DIR/Qwen2.5-Coder-1.5B-Instruct-Q4_K_M.gguf" \
      -t "$THREADS_PER_NODE" \
      -c 8192 \
      -ngl "$AUTOCOMPLETE_NGL" \
      --slots

    start_traffic_logger_on_node "autocomplete_engine" "$LOG_DIR/autocomplete_engine.pid" "$LOG_DIR/autocomplete_engine.proxy.log" "node" "$NUMA_AUTOCOMPLETE_NODE" "$PUBLIC_AUTOCOMPLETE_PORT" "$AUTOCOMPLETE_BACKEND_PORT"

    # 3. Thinker Engine Backend Setup (Optimized Interleaved Global Memory Bus)
    if directory_has_gguf "$THINKER_MODEL_DIR"; then
      start_instance_on_node "thinker_engine.backend" "$LOG_DIR/thinker_engine.backend.pid" "interleave" "all" \
        --host 127.0.0.1 \
        --port "$THINKER_BACKEND_PORT" \
        --models-dir "$THINKER_MODEL_DIR" \
        --models-max 1 \
        --sleep-idle-seconds 1800 \
        -t "$TOTAL_CORES" \
        --timeout 1800000 \
        -ngl "$THINKER_NGL" \
        -c 8192

      start_traffic_logger_on_node "thinker_engine" "$LOG_DIR/thinker_engine.pid" "$LOG_DIR/thinker_engine.proxy.log" "interleave" "all" "$PUBLIC_THINKER_PORT" "$THINKER_BACKEND_PORT"
    else
      log "Skipping thinker_engine: no .gguf files found in $THINKER_MODEL_DIR"
    fi

    echo "All systems initialized cleanly with optimized topology layouts!"
    log "Start sequence complete"
    ;;

  quiet-start)
    log "Cleaning up any pre-existing llama-server processes before quiet-start"
    pkill llama-server || true
    kill_lingering_proxy_processes

    start_instance_on_node "router_engine" "$LOG_DIR/router_engine.pid" "node" "$NUMA_ROUTER_NODE" \
      --host "$BIND_HOST" \
      --port "$PUBLIC_ROUTER_PORT" \
      --models-dir "$MODEL_DIR" \
      --models-max 1 \
      --sleep-idle-seconds 1800 \
      -t "$THREADS_PER_NODE" \
      --timeout 600000 \
      -ngl "$ROUTER_NGL"

    start_instance_on_node "autocomplete_engine" "$LOG_DIR/autocomplete_engine.pid" "node" "$NUMA_AUTOCOMPLETE_NODE" \
      --host "$BIND_HOST" \
      --port "$PUBLIC_AUTOCOMPLETE_PORT" \
      -m "$AUTOCOMPLETE_DIR/Qwen2.5-Coder-1.5B-Instruct-Q4_K_M.gguf" \
      -t "$THREADS_PER_NODE" \
      -c 8192 \
      -ngl "$AUTOCOMPLETE_NGL" \
      --slots

    if directory_has_gguf "$THINKER_MODEL_DIR"; then
      start_instance_on_node "thinker_engine" "$LOG_DIR/thinker_engine.pid" "interleave" "all" \
        --host "$BIND_HOST" \
        --port "$PUBLIC_THINKER_PORT" \
        --models-dir "$THINKER_MODEL_DIR" \
        --models-max 1 \
        --sleep-idle-seconds 1800 \
        -t "$TOTAL_CORES" \
        --timeout 600000 \
        -ngl "$THINKER_NGL"
    else
      log "Skipping thinker_engine for quiet-start: no .gguf files found in $THINKER_MODEL_DIR"
    fi

    echo "All systems initialized cleanly!"
    log "Quiet-start sequence complete"
    ;;

  stop)
    log "Stopping tracked instances..."
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
    log "Force-stopping tracked instances..."
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

  stop-only)
    TARGET="${2:-}"
    if [[ -z "$TARGET" ]]; then
      echo "Error: stop-only requires a target component name." >&2
      echo "Usage: $0 stop-only [autocomplete|router|thinker]" >&2
      exit 1
    fi

    case "$TARGET" in
      autocomplete)
        log "Gracefully spinning down Autocomplete Services..."
        stop_instance "Dedicated Autocomplete Daemon (Proxy)" "$LOG_DIR/autocomplete_engine.pid"
        stop_instance "Dedicated Autocomplete Backend Engine" "$LOG_DIR/autocomplete_engine.backend.pid"
        pkill -f "socat .*TCP-LISTEN:$PUBLIC_AUTOCOMPLETE_PORT" || true
        ;;
      router)
        log "Gracefully spinning down Router Services..."
        stop_instance "Dynamic Router Engine (Proxy)" "$LOG_DIR/router_engine.pid"
        stop_instance "Dynamic Router Backend Engine" "$LOG_DIR/router_engine.backend.pid"
        pkill -f "socat .*TCP-LISTEN:$PUBLIC_ROUTER_PORT" || true
        ;;
      thinker)
        log "Gracefully spinning down Thinker Services..."
        stop_instance "Thinker Engine (Proxy)" "$LOG_DIR/thinker_engine.pid"
        stop_instance "Thinker Engine Backend Engine" "$LOG_DIR/thinker_engine.backend.pid"
        pkill -f "socat .*TCP-LISTEN:$PUBLIC_THINKER_PORT" || true
        ;;
      *)
        echo "Unknown target: '$TARGET'. Valid components are: autocomplete, router, thinker" >&2
        exit 1
        ;;
    esac
    log "Selective stop sequence complete for target: $TARGET"
    ;;

  *)
    echo "Usage: $0 [start|quiet-start|stop|force-stop|stop-only]" >&2
    echo "       $0 stop-only [autocomplete|router|thinker]" >&2
    exit 1
    ;;
esac