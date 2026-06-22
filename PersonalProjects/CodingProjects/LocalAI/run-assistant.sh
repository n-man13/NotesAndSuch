#!/usr/bin/env bash
# A simple async worker for your 70B model

MODEL_70B="./models/thinker/Qwen2.5--72B-Instruct-Q4_K_M.gguf"
INBOX_DIR="./assistant/inbox"
OUTBOX_DIR="./assistant/outbox"

SYSTEM_ROLE="You are a Principal Software Engineer and Graduate Computer Science Professor. Analyze the following request. Provide concrete time and space complexities (O(n)) for all solutions. Prioritize cache-friendly memory access patterns, avoid unnecessary allocations, and ensure absolute thread safety. Output detailed architectural explanations alongside the implementation. Avoid using python unless explicitly requested."

mkdir -p "$INBOX_DIR" "$OUTBOX_DIR"

echo "Assistant listening for files in $INBOX_DIR..."

while true; do
    # Find the oldest text file in the inbox
    FIRST_JOB=$(find "$INBOX_DIR" -maxdepth 1 -name "*.txt" | sort | head -n 1)

    if [ -n "$FIRST_JOB" ]; then
        BASE_NAME=$(basename "$FIRST_JOB")
        echo "Processing $BASE_NAME at $(date)..."
        
        # Run across all 4 NUMA nodes to maximize DDR3 memory bandwidth
        numactl --interleave=all ./build/bin/llama-cli \
            -m "$MODEL_70B" \
            --system-prompt "$SYSTEM_ROLE" \
            -f "$FIRST_JOB" \
            -c 4096 \
            -ngl 0 \
            --threads 32 > "$OUTBOX_DIR/response_$BASE_NAME" 2>&1
            
        # Clean up the job so it doesn't re-run
        rm "$FIRST_JOB"
        echo "Finished $BASE_NAME. Response written to outbox."
    fi
    
    # Check for new jobs every 10 seconds
    sleep 10
done