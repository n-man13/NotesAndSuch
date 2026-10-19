
#!/usr/bin/env bash
set -euo pipefail

# ==========================================================================
# Hardware: Dual AMD Opteron 6274, 4 NUMA nodes, Tesla P4 (8 GB VRAM)
#
# Modes:
#   start                 Start router + thinker (default; no autocomplete)
#   quiet-start           Start router + thinker without socat proxies
#   start-autocomplete    Start autocomplete only (CPU by default)
#   stop                  Stop all tracked services
#   force-stop            Force-stop all llama-server processes
#   stop-only router      Stop router only
#   stop-only thinker     Stop thinker only
#   stop-only autocomplete Stop autocomplete only
# ==========================================================================

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LLAMA_CPP_DIR="${LLAMA_CPP_DIR:-$HOME/llama.cpp}"
MODEL_DIR="${MODEL_DIR:-$ROOT_DIR/models}"
AUTOCOMPLETE_DIR="${AUTOCOMPLETE_DIR:-$MODEL_DIR/autocomplete}"
THINKER_MODEL_DIR="${THINKER_MODEL_DIR:-$MODEL_DIR/thinker}"
LOG_DIR="${LOG_DIR:-$ROOT_DIR/logs}"
BIND_HOST="${BIND_HOST:-0.0.0.0}"
ACTION="${1:-start}"
API_KEY_FILE="${LLAMA_API_KEY_FILE:-}"

LAUNCH_LOG="$LOG_DIR/launcher.log"
SOCAT_BIN="$(command -v socat || true)"
NUMACTL_BIN="$(command -v numactl || true)"

PUBLIC_ROUTER_PORT=8085
PUBLIC_AUTOCOMPLETE_PORT=8086
PUBLIC_THINKER_PORT=8087

ROUTER_BACKEND_PORT=18085
AUTOCOMPLETE_BACKEND_PORT=18086
THINKER_BACKEND_PORT=18087

NUMA_ROUTER_NODE="${NUMA_ROUTER_NODE:-1}"
NUMA_AUTOCOMPLETE_NODE="${NUMA_AUTOCOMPLETE_NODE:-2}"

GPU_DEVICE_ID="${GPU_DEVICE_ID:-0}"
ROUTER_NGL="${ROUTER_NGL:-99}"
# Autocomplete is opt-in and runs on CPU by default.
# Override with AUTOCOMPLETE_NGL=99 to use the GPU intentionally.
AUTOCOMPLETE_NGL="${AUTOCOMPLETE_NGL:-0}"
THINKER_NGL=0

TOTAL_CORES="$(nproc)"
NUM_NODES="$(find /sys/devices/system/node -maxdepth 1 \
  -type d -name 'node[0-9]*' 2>/dev/null | wc -l)"
NUM_NODES=$(( NUM_NODES > 0 ? NUM_NODES : 1 ))
THREADS_PER_NODE=$(( TOTAL_CORES / NUM_NODES ))
THREADS_PER_NODE=$(( THREADS_PER_NODE > 0 ? THREADS_PER_NODE : 1 ))

if [[ -x "$LLAMA_CPP_DIR/llama-server" ]]; then
  SERVER_BIN="$LLAMA_CPP_DIR/llama-server"
elif [[ -x "$LLAMA_CPP_DIR/build/bin/llama-server" ]]; then
  SERVER_BIN="$LLAMA_CPP_DIR/build/bin/llama-server"
else
  echo "Could not find llama-server in $LLAMA_CPP_DIR" >&2
  exit 1
fi

mkdir -p "$LOG_DIR"

log() {
  printf '%s %s\n' "$(date '+%F %T')" "$*" | tee -a "$LAUNCH_LOG"
}

directory_has_gguf() {
  [[ -d "$1" ]] &&
    find "$1" -maxdepth 1 -name '*.gguf' -print -quit 2>/dev/null |
      grep -q .
}

# Stop a tracked PID and remove its PID file.
stop_instance() {
  local label="$1"
  local pid_file="$2"
  local pid

  if [[ ! -f "$pid_file" ]]; then
    log "$label: no PID file"
    return 0
  fi

  pid="$(cat "$pid_file")"
  if [[ "$pid" =~ ^[0-9]+$ ]] && kill -0 "$pid" 2>/dev/null; then
    log "Stopping $label (PID $pid)"
    kill "$pid" 2>/dev/null || true

    # Allow graceful exit before escalating.
    for _ in {1..30}; do
      kill -0 "$pid" 2>/dev/null || break
      sleep 0.2
    done

    if kill -0 "$pid" 2>/dev/null; then
      log "$label did not exit; sending SIGKILL"
      kill -9 "$pid" 2>/dev/null || true
    fi
  else
    log "$label: PID is no longer running"
  fi

  rm -f "$pid_file"
}

stop_autocomplete() {
  stop_instance "Autocomplete proxy" "$LOG_DIR/autocomplete_engine.pid"
  stop_instance "Autocomplete backend" "$LOG_DIR/autocomplete_engine.backend.pid"

  # Also clean up an untracked proxy from an earlier script version.
  pkill -f "socat .*TCP-LISTEN:$PUBLIC_AUTOCOMPLETE_PORT" 2>/dev/null || true
}

stop_router() {
  stop_instance "Router proxy" "$LOG_DIR/router_engine.pid"
  stop_instance "Router backend" "$LOG_DIR/router_engine.backend.pid"
  pkill -f "socat .*TCP-LISTEN:$PUBLIC_ROUTER_PORT" 2>/dev/null || true
}

stop_thinker() {
  stop_instance "Thinker proxy" "$LOG_DIR/thinker_engine.pid"
  stop_instance "Thinker backend" "$LOG_DIR/thinker_engine.backend.pid"
  pkill -f "socat .*TCP-LISTEN:$PUBLIC_THINKER_PORT" 2>/dev/null || true
}

start_instance_on_node() {
  local label="$1"
  local pid_file="$2"
  local mode="$3"       # node or interleave
  local node_val="$4"
  shift 4

  local log_file="$LOG_DIR/${label}.log"
  local -a numa_prefix=()

  if [[ -n "$NUMACTL_BIN" ]]; then
    if [[ "$mode" == "interleave" ]]; then
      numa_prefix=("$NUMACTL_BIN" --interleave=all)
    else
      numa_prefix=("$NUMACTL_BIN" \
        --cpunodebind="$node_val" --preferred="$node_val")
    fi
  fi

  log "Starting $label"
  log "  Log: $log_file"
  log "  NUMA policy: $mode ($node_val)"

  if [[ -n "$API_KEY_FILE" ]]; then
    nohup env CUDA_VISIBLE_DEVICES="$GPU_DEVICE_ID" \
      "${numa_prefix[@]}" "$SERVER_BIN" \
      --api-key-file "$API_KEY_FILE" "$@" \
      > "$log_file" 2>&1 &
  else
    nohup env CUDA_VISIBLE_DEVICES="$GPU_DEVICE_ID" \
      "${numa_prefix[@]}" "$SERVER_BIN" "$@" \
      > "$log_file" 2>&1 &
  fi

  echo "$!" > "$pid_file"
  log "  PID: $(cat "$pid_file")"
}

start_proxy() {
  local label="$1"
  local pid_file="$2"
  local stderr_log="$3"
  local mode="$4"
  local node_val="$5"
  local listen_port="$6"
  local upstream_port="$7"

  if [[ -z "$SOCAT_BIN" ]]; then
    log "ERROR: socat not found; cannot expose $label on port $listen_port"
    return 1
  fi

  local -a numa_prefix=()
  if [[ -n "$NUMACTL_BIN" ]]; then
    if [[ "$mode" == "interleave" ]]; then
      numa_prefix=("$NUMACTL_BIN" --interleave=all)
    else
      numa_prefix=("$NUMACTL_BIN" \
        --cpunodebind="$node_val" --membind="$node_val")
    fi
  fi

  nohup "${numa_prefix[@]}" "$SOCAT_BIN" \
    -v -lf "$LOG_DIR/${label}.traffic.log" \
    "TCP-LISTEN:${listen_port},bind=${BIND_HOST},fork,reuseaddr" \
    "TCP:127.0.0.1:${upstream_port}" \
    > "$stderr_log" 2>&1 &

  echo "$!" > "$pid_file"
  log "Started $label proxy on $BIND_HOST:$listen_port (PID $!)"
}

start_router() {
  start_instance_on_node "router_engine.backend" \
    "$LOG_DIR/router_engine.backend.pid" node "$NUMA_ROUTER_NODE" \
    --host 127.0.0.1 \
    --port "$ROUTER_BACKEND_PORT" \
    --models-dir "$MODEL_DIR" \
    --models-max 1 \
    --sleep-idle-seconds 1800 \
    -t "$THREADS_PER_NODE" \
    --timeout 1800000 \
    -ngl "$ROUTER_NGL" \
    -c 32000

  start_proxy "router_engine" "$LOG_DIR/router_engine.pid" \
    "$LOG_DIR/router_engine.proxy.log" node "$NUMA_ROUTER_NODE" \
    "$PUBLIC_ROUTER_PORT" "$ROUTER_BACKEND_PORT"
}

start_thinker() {
  if ! directory_has_gguf "$THINKER_MODEL_DIR"; then
    log "Skipping thinker: no GGUF files in $THINKER_MODEL_DIR"
    return 0
  fi

  start_instance_on_node "thinker_engine.backend" \
    "$LOG_DIR/thinker_engine.backend.pid" interleave all \
    --host 127.0.0.1 \
    --port "$THINKER_BACKEND_PORT" \
    --models-dir "$THINKER_MODEL_DIR" \
    --models-max 1 \
    --sleep-idle-seconds 1800 \
    -t "$TOTAL_CORES" \
    --timeout 1800000 \
    -ngl "$THINKER_NGL" \
    -c 36000

  start_proxy "thinker_engine" "$LOG_DIR/thinker_engine.pid" \
    "$LOG_DIR/thinker_engine.proxy.log" interleave all \
    "$PUBLIC_THINKER_PORT" "$THINKER_BACKEND_PORT"
}

start_autocomplete() {
  local model="$AUTOCOMPLETE_DIR/Qwen2.5-Coder-1.5B-Instruct-Q4_K_M.gguf"

  if [[ ! -f "$model" ]]; then
    log "ERROR: Autocomplete model not found: $model"
    return 1
  fi

  if [[ -f "$LOG_DIR/autocomplete_engine.backend.pid" ]] &&
     kill -0 "$(cat "$LOG_DIR/autocomplete_engine.backend.pid")" 2>/dev/null; then
    log "Autocomplete backend already running; not starting a duplicate"
    return 0
  fi

  # Clean up any old autocomplete proxy/backend only.
  stop_autocomplete

  log "Starting optional autocomplete engine (GPU layers: $AUTOCOMPLETE_NGL)"

  start_instance_on_node "autocomplete_engine.backend" \
    "$LOG_DIR/autocomplete_engine.backend.pid" node "$NUMA_AUTOCOMPLETE_NODE" \
    --host 127.0.0.1 \
    --port "$AUTOCOMPLETE_BACKEND_PORT" \
    -m "$model" \
    -t "$THREADS_PER_NODE" \
    -c 8192 \
    -ngl "$AUTOCOMPLETE_NGL" \
    --slots

  start_proxy "autocomplete_engine" "$LOG_DIR/autocomplete_engine.pid" \
    "$LOG_DIR/autocomplete_engine.proxy.log" node "$NUMA_AUTOCOMPLETE_NODE" \
    "$PUBLIC_AUTOCOMPLETE_PORT" "$AUTOCOMPLETE_BACKEND_PORT"
}

case "$ACTION" in
  start)
    log "Starting router and thinker; autocomplete is disabled by default"

    # This mode intentionally performs a full restart.
    pkill -x llama-server 2>/dev/null || true
    pkill -f "socat .*TCP-LISTEN:$PUBLIC_ROUTER_PORT" 2>/dev/null || true
    pkill -f "socat .*TCP-LISTEN:$PUBLIC_AUTOCOMPLETE_PORT" 2>/dev/null || true
    pkill -f "socat .*TCP-LISTEN:$PUBLIC_THINKER_PORT" 2>/dev/null || true

    rm -f "$LOG_DIR/router_engine.pid" \
      "$LOG_DIR/router_engine.backend.pid" \
      "$LOG_DIR/autocomplete_engine.pid" \
      "$LOG_DIR/autocomplete_engine.backend.pid" \
      "$LOG_DIR/thinker_engine.pid" \
      "$LOG_DIR/thinker_engine.backend.pid"

    start_router
    start_thinker
    log "Start sequence complete (autocomplete not started)"
    ;;

  quiet-start)
    log "Starting router and thinker without socat proxies"
    pkill -x llama-server 2>/dev/null || true

    start_instance_on_node "router_engine" \
      "$LOG_DIR/router_engine.pid" node "$NUMA_ROUTER_NODE" \
      --host "$BIND_HOST" \
      --port "$PUBLIC_ROUTER_PORT" \
      --models-dir "$MODEL_DIR" \
      --models-max 1 \
      --sleep-idle-seconds 1800 \
      -t "$THREADS_PER_NODE" \
      --timeout 600000 \
      -ngl "$ROUTER_NGL" \
      -c 32000

    if directory_has_gguf "$THINKER_MODEL_DIR"; then
      start_instance_on_node "thinker_engine" \
        "$LOG_DIR/thinker_engine.pid" interleave all \
        --host "$BIND_HOST" \
        --port "$PUBLIC_THINKER_PORT" \
        --models-dir "$THINKER_MODEL_DIR" \
        --models-max 1 \
        --sleep-idle-seconds 1800 \
        -t "$TOTAL_CORES" \
        --timeout 600000 \
        -ngl "$THINKER_NGL" \
        -c 36000
    fi

    log "Quiet-start complete (autocomplete not started)"
    ;;

  start-autocomplete)
    # Does not stop or restart the router or thinker.
    start_autocomplete
    ;;

  stop)
    log "Stopping all tracked services"
    stop_autocomplete
    stop_router
    stop_thinker
    log "Stop sequence complete"
    ;;

  force-stop)
    log "Force-stopping all llama-server processes"
    stop_autocomplete
    stop_router
    stop_thinker
    pkill -x llama-server 2>/dev/null || true
    pkill -f "socat .*TCP-LISTEN:$PUBLIC_ROUTER_PORT" 2>/dev/null || true
    pkill -f "socat .*TCP-LISTEN:$PUBLIC_AUTOCOMPLETE_PORT" 2>/dev/null || true
    pkill -f "socat .*TCP-LISTEN:$PUBLIC_THINKER_PORT" 2>/dev/null || true
    log "Force-stop sequence complete"
    ;;

  stop-only)
    case "${2:-}" in
      autocomplete) stop_autocomplete ;;
      router)       stop_router ;;
      thinker)      stop_thinker ;;
      *)
        echo "Usage: $0 stop-only [autocomplete|router|thinker]" >&2
        exit 1
        ;;
    esac
    ;;

  *)
    echo "Usage: $0 [start|quiet-start|start-autocomplete|stop|force-stop]" >&2
    echo "       $0 stop-only [autocomplete|router|thinker]" >&2
    exit 1
    ;;
esac