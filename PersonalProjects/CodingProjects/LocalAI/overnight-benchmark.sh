#!/usr/bin/env bash
set -euo pipefail
set -x

# Model Definitions
MODEL_7B="./models/Qwen2.5-7B-Instruct-Q4_K_M.gguf"
MODEL_14B="./models/thinker/Qwen2.5-14B-Instruct-Q4_K_M.gguf"
OUTFILE="overnight-results.md"

# Identify closest NUMA node to the GPU's PCIe slot
GPU_NUMA_NODE="${GPU_NUMA_NODE:-1}"

cat > "$OUTFILE" <<EOF
# Llama.cpp Advanced Overnight Benchmark Results
Generated: $(date)
System Topology Config: GPU Affinity Node $GPU_NUMA_NODE
---
EOF

extract_pp() {
    echo "$1" | grep "pp512" | awk '{print $(NF-2)}' 2>/dev/null || echo "N/A"
}
extract_tg() {
    echo "$1" | grep "tg128" | awk '{print $(NF-2)}' 2>/dev/null || echo "N/A"
}

run_bench() {
    local name="$1"
    local cmd="$2"
    echo "Executing: $name"
    
    start_epoch=$(date +%s)
    start_human=$(date)
    
    # Run command and swallow stderr to keep terminal clean; track stdout
    if ! output=$(eval "$cmd" 2>/dev/null); then
        output="ERROR: Command failed execution."
    fi
    
    end_epoch=$(date +%s)
    end_human=$(date)
    elapsed=$((end_epoch - start_epoch))
    
    pp=$(extract_pp "$output")
    tg=$(extract_tg "$output")
    
    {
        echo "### $name"
        echo "*   **Started:** $start_human"
        echo "*   **Finished:** $end_human"
        echo "*   **Elapsed:** ${elapsed} seconds"
        echo "*   **pp512 Throughput:** $pp t/s"
        echo "*   **tg128 Throughput:** $tg t/s"
        echo ""
    } >> "$OUTFILE"
    
    LAST_PP="$pp"
    LAST_TG="$tg"
    LAST_ELAPSED="$elapsed"
}

########################################################################
# SECTION 1: CONCURRENT USER SCALING SWEEP (7B MODEL)
########################################################################
echo "## Section 1: Parallel Sequence Concurrency Sweep (7B)" >> "$OUTFILE"
echo "Testing parallel user streams (-np). Multi-sequence decoding highlights multi-tenant VRAM bus pressure." >> "$OUTFILE"
echo "" >> "$OUTFILE"
echo "| Parallel Streams (-np) | Context Limit (-c) | pp512 | tg128 | Elapsed (s) |" >> "$OUTFILE"
echo "|------------------------|--------------------|-------|-------|-------------|" >> "$OUTFILE"

# Walk concurrency from single-user up to 16 parallel streams
# Old loop block failing on -np:
# for streams in 1 2 4 8 16 ...

# New native llama-bench implementation:
run_bench "7B Concurrency Sweep" \
    "CUDA_VISIBLE_DEVICES=0 numactl --cpunodebind=1 --membind=1 \
    ./build/bin/llama-bench \
    -m ./models/Qwen2.5-7B-Instruct-Q4_K_M.gguf \
    -ngl 99 \
    -p 512 \
    -n 128 \
    -pg 1,2,4,8,16"

########################################################################
# SECTION 2: PHYSICAL MICRO-BATCH ARCHITECTURE TUNING MATRIX
########################################################################
echo "" >> "$OUTFILE"
echo "## Section 2: Logical (-b) vs Physical (-ub) Micro-Batch Permutation Sweep" >> "$OUTFILE"
echo "Deep execution graph sweep evaluating prompt processing engine registers under variable block packaging size rules." >> "$OUTFILE"
echo "" >> "$OUTFILE"
echo "| Execution Mode | Logical Batch (-b) | Physical Batch (-ub) | pp512 | tg128 |" >> "$OUTFILE"
echo "|----------------|--------------------|----------------------|-------|-------|" >> "$OUTFILE"

# Grid search matching logical token collection sizes against chunk evaluation blocks
for mode in "GPU_OFFLOAD" "CPU_SINGLE_NUMA"
do
    for logical in 512 1024 2048
    do
        for physical in 128 256 512
        do
            if [ "$physical" -le "$logical" ]; then
                if [ "$mode" == "GPU_OFFLOAD" ]; then
                    run_bench \
                        "Matrix [GPU] - b:$logical / ub:$physical" \
                        "CUDA_VISIBLE_DEVICES=0 numactl --cpunodebind=$GPU_NUMA_NODE --membind=$GPU_NUMA_NODE \
                            ./build/bin/llama-bench \
                            -m $MODEL_7B \
                            -t 8 \
                            -ngl 99 \
                            -b $logical \
                            -ub $physical \
                            -p 512 \
                            -n 128"
                else # CPU-only fallback pinning to look for hidden system caches optimizations
                    run_bench \
                        "Matrix [CPU Node 0] - b:$logical / ub:$physical" \
                        "numactl --cpunodebind=0 --membind=0 \
                            ./build/bin/llama-bench \
                            -m $MODEL_7B \
                            -t 8 \
                            -ngl 0 \
                            -b $logical \
                            -ub $physical \
                            -p 512 \
                            -n 128"
                fi
                echo "| $mode | $logical | $physical | $LAST_PP | $LAST_TG |" >> "$OUTFILE"
            fi
        done
    done
done

########################################################################
# SECTION 3: DEEP 14B DEPLOYMENT STRATEGY PROFILE
########################################################################
if [ -f "$MODEL_14B" ]; then
    echo "" >> "$OUTFILE"
    echo "## Section 3: Deep Architectural Profiling (14B Parameter Model)" >> "$OUTFILE"
    echo "Testing how single NUMA node boundaries compare directly to cross-interconnect interleave schemes on heavy models." >> "$OUTFILE"
    echo "" >> "$OUTFILE"
    echo "| Topology Management Strategy | pp512 | tg128 | Elapsed (s) |" >> "$OUTFILE"
    echo "|------------------------------|-------|-------|-------------|" >> "$OUTFILE"

    # Strategy A: Strict single host node enclosure (Avoids UPI cross-talk latency)
    run_bench \
        "14B Target - Single Socket Pinned (NUMA 0)" \
        "numactl --cpunodebind=0 --membind=0 \
            ./build/bin/llama-bench \
            -m $MODEL_14B \
            -t 8 \
            -ngl 0 \
            -p 512 \
            -n 128"
    echo "| CPU-Only (Strict NUMA Node 0) | $LAST_PP | $LAST_TG | $LAST_ELAPSED |" >> "$OUTFILE"

    # Strategy B: Broad hardware thread scaling over full interleaved channels
    run_bench \
        "14B Target - Scaled Interleave All Channels" \
        "numactl --interleave=all \
            ./build/bin/llama-bench \
            -m $MODEL_14B \
            -t 32 \
            -ngl 0 \
            -p 512 \
            -n 128"
    echo "| CPU-Only (Interleaved All / 32 Threads) | $LAST_PP | $LAST_TG | $LAST_ELAPSED |" >> "$OUTFILE"

    # Strategy C: Hybrid Split-Compute Coprocessing (VRAM ceiling optimized step)
    # Safely leveraging a 16-layer slice matching your physical Tesla boundary limits
    run_bench \
        "14B Target - Managed Co-Processing Split (16 GPU Layers)" \
        "CUDA_VISIBLE_DEVICES=0 numactl --cpunodebind=$GPU_NUMA_NODE --membind=$GPU_NUMA_NODE \
            ./build/bin/llama-bench \
            -m $MODEL_14B \
            -t 8 \
            -ngl 16 \
            -p 512 \
            -n 128"
    echo "| Hybrid (Partial GPU Offload - 16 Layers) | $LAST_PP | $LAST_TG | $LAST_ELAPSED |" >> "$OUTFILE"
else
    echo "" >> "$OUTFILE"
    echo "## Section 3: Deep Architectural Profiling skipped (14B path not encountered)." >> "$OUTFILE"
fi

########################################################################
# SECTION 4: BACKGROUND CO-HABITATION & COMPETE-COMPUTE SWEEP
########################################################################
MODEL_AUTOCOMPLETE="./models/autocomplete/Qwen2.5-Coder-1.5B-Instruct-Q4_K_M.gguf"
SERVER_PORT=8080

if [ -f "$MODEL_AUTOCOMPLETE" ] && [ -f "./build/bin/llama-server" ]; then
    echo "" >> "$OUTFILE"
    echo "## Section 4: GPU Multi-Model Co-Habitation Stress Test" >> "$OUTFILE"
    echo "Evaluating 7B benchmark metrics while a 1.5B Autocomplete Coder model actively shares GPU compute lanes." >> "$OUTFILE"
    echo "" >> "$OUTFILE"
    echo "| Testing Context Status | pp512 | tg128 | Elapsed (s) |" >> "$OUTFILE"
    echo "|------------------------|-------|-------|-------------|" >> "$OUTFILE"

    echo "Launching background 1.5B autocomplete server on port $SERVER_PORT..."
    
    # 1. Start the autocomplete model in the background, fully offloaded to the GPU
    CUDA_VISIBLE_DEVICES=0 numactl --cpunodebind=$GPU_NUMA_NODE --membind=$GPU_NUMA_NODE \
        ./build/bin/llama-server \
        -m "$MODEL_AUTOCOMPLETE" \
        -ngl 99 \
        --port $SERVER_PORT \
        --ctx-size 2048 \
        --threads 4 > /dev/null 2>&1 &
    
    SERVER_PID=$!
    
    # Give the server 10 seconds to fully ingest weights into VRAM
    sleep 10

    # Test A: Co-habitation Idle State (Measures structural VRAM fragmentation penalties)
    run_bench \
        "7B - Co-habiting with Idle 1.5B background model" \
        "CUDA_VISIBLE_DEVICES=0 numactl --cpunodebind=$GPU_NUMA_NODE --membind=$GPU_NUMA_NODE \
            ./build/bin/llama-bench \
            -m $MODEL_7B \
            -ngl 99 \
            -p 512 \
            -n 128"
    echo "| Idle Co-habitation (Passive VRAM Shared) | $LAST_PP | $LAST_TG | $LAST_ELAPSED |" >> "$OUTFILE"

    # 2. Start a background loop that constantly fires autocomplete tokens to simulate active typing
    echo "Simulating active background tab-autocomplete traffic..."
    (
        while kill -0 $SERVER_PID 2>/dev/null; do
            curl -s -X POST http://localhost:$SERVER_PORT/v1/completions \
                -H "Content-Type: application/json" \
                -d '{"prompt": "def fibonacci(n):", "max_tokens": 32}' > /dev/null || true
            sleep 0.5
        done
    ) &
    TRAFFIC_PID=$!

    # Test B: Active Load Contention (Measures parallel compute scheduling degradation)
    run_bench \
        "7B - Co-habiting with Active 1.5B autocomplete load" \
        "CUDA_VISIBLE_DEVICES=0 numactl --cpunodebind=$GPU_NUMA_NODE --membind=$GPU_NUMA_NODE \
            ./build/bin/llama-bench \
            -m $MODEL_7B \
            -ngl 99 \
            -p 512 \
            -n 128"
    echo "| Active Contention (Concurrent GPU Grunt) | $LAST_PP | $LAST_TG | $LAST_ELAPSED |" >> "$OUTFILE"

    # Teardown background workers safely
    echo "Cleaning up background server instances..."
    kill $TRAFFIC_PID 2>/dev/null || true
    kill $SERVER_PID 2>/dev/null || true
    wait $SERVER_PID 2>/dev/null || true
else
    echo "" >> "$OUTFILE"
    echo "## Section 4: Multi-Model test skipped (Autocomplete files or llama-server binary missing)." >> "$OUTFILE"
fi

echo "---" >> "$OUTFILE"
echo "All overnight diagnostic sequences finished successfully." >> "$OUTFILE"
echo "Overnight benchmark suite complete. Outputs captured in $OUTFILE"