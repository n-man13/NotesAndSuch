#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LLAMA_CPP_DIR="${LLAMA_CPP_DIR:-$HOME/llama.cpp}"
MODEL_DIR="${MODEL_DIR:-$ROOT_DIR/models}"
LOG_DIR="${LOG_DIR:-$ROOT_DIR/logs}"
BIND_HOST="${BIND_HOST:-0.0.0.0}"
ACTION="${1:-start}"

# Start these models on separate ports.
# The 70B model is intentionally excluded.
MODELS=(
  "Llama 3.1 8B|Meta-Llama-3.1-8B-Instruct-Q4_K_M.gguf|8080"
  "Qwen 2.5 7B|Qwen2.5-7B-Instruct-Q4_K_M.gguf|8081"
  "Phi-3.5 Mini|Phi-3.5-mini-instruct-Q4_K_M.gguf|8082"
  "Gemma 2 9B|gemma-2-9b-it-Q4_K_M.gguf|8083"
  "Mistral 7B Instruct|Mistral-7B-Instruct-v0.3-Q4_K_M.gguf|8084"
  "Qwen 2.5 Coder 1.5B|Qwen2.5-Coder-1.5B-Instruct-Q4_K_M.gguf|8085"
  "Hermes 2.5 7B|openhermes-2.5-mistral-7b.Q4_K_M.gguf|8086"
)

SERVER_BIN=""
if [[ -x "$LLAMA_CPP_DIR/llama-server" ]]; then
  SERVER_BIN="$LLAMA_CPP_DIR/llama-server"
elif [[ -x "$LLAMA_CPP_DIR/build/bin/llama-server" ]]; then
  SERVER_BIN="$LLAMA_CPP_DIR/build/bin/llama-server"
else
  echo "Could not find llama-server in $LLAMA_CPP_DIR or $LLAMA_CPP_DIR/build/bin" >&2
  exit 1
fi

mkdir -p "$LOG_DIR"

stop_model() {
  local label="$1"
  local port="$2"
  local pid_file="$LOG_DIR/${port}.pid"

  if [[ -f "$pid_file" ]]; then
    local pid
    pid="$(cat "$pid_file")"
    if kill "$pid" 2>/dev/null; then
      echo "Stopped $label (pid $pid)"
      rm -f "$pid_file"
      return
    fi
  fi

  echo "No running pid file found for $label on port $port" >&2
}

start_model() {
  local label="$1"
  local filename="$2"
  local port="$3"
  local model_path="$MODEL_DIR/$filename"
  local log_file="$LOG_DIR/${port}-$(echo "$filename" | sed 's/\.gguf$//').log"

  if [[ ! -f "$model_path" ]]; then
    echo "Skipping $label: missing model file $model_path" >&2
    return
  fi

  if ss -ltn | awk '{print $4}' | grep -q ":${port}$"; then
    echo "Skipping $label: port $port is already in use" >&2
    return
  fi

  echo "Starting $label on http://$BIND_HOST:$port using $(basename "$model_path")"
  nohup "$SERVER_BIN" \
    -m "$model_path" \
    --host "$BIND_HOST" \
    --port "$port" \
    -c 8192 \
    > "$log_file" 2>&1 &
  echo $! > "$LOG_DIR/${port}.pid"
  sleep 1
}

case "$ACTION" in
  start)
    for entry in "${MODELS[@]}"; do
      IFS='|' read -r label filename port <<< "$entry"
      start_model "$label" "$filename" "$port"
    done
    echo "Done. Logs are in $LOG_DIR"
    ;;
  stop)
    for entry in "${MODELS[@]}"; do
      IFS='|' read -r label filename port <<< "$entry"
      stop_model "$label" "$port"
    done
    ;;
  *)
    echo "Usage: $0 [start|stop]" >&2
    exit 1
    ;;
esac
