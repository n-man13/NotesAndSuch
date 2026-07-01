#!/usr/bin/env bash
set -euo pipefail
MODEL="./models/Qwen2.5-7B-Instruct-Q4_K_M.gguf"
OUTFILE="results.md"
GPU_NUMA_NODE="${GPU_NUMA_NODE:-1}"  # NUMA node nearest the GPU's PCIe slot -- check `nvidia-smi topo -m` and set if different
cat > "$OUTFILE" <<EOF
# Llama.cpp Benchmark Results
Model: \`$MODEL\`
Generated: $(date)
EOF
extract_pp() {
    echo "$1" | grep "pp512" | awk '{print $(NF-2)}'
}
extract_tg() {
    echo "$1" | grep "tg128" | awk '{print $(NF-2)}'
}
run_bench() {
    local name="$1"
    local cmd="$2"
    echo "Running: $name"
    start_epoch=$(date +%s)
    start_human=$(date)
    output=$(eval "$cmd")
    end_epoch=$(date +%s)
    end_human=$(date)
    elapsed=$((end_epoch - start_epoch))
    pp=$(extract_pp "$output")
    tg=$(extract_tg "$output")
    {
        echo ""
        echo "## $name"
        echo ""
        echo "**Started:** $start_human"
        echo ""
        echo "**Finished:** $end_human"
        echo ""
        echo "**Elapsed:** ${elapsed} seconds"
        echo ""
        echo "**pp512:** $pp t/s"
        echo ""
        echo "**tg128:** $tg t/s"
        echo ""
        echo "### Raw Output"
        echo ""
        echo '```'
        echo "$output"
        echo '```'
        echo ""
    } >> "$OUTFILE"
    LAST_PP="$pp"
    LAST_TG="$tg"
    LAST_ELAPSED="$elapsed"
}
########################################################################
# BASELINE TESTS
########################################################################
echo "" >> "$OUTFILE"
echo "# Baseline Tests" >> "$OUTFILE"
run_bench \
    "Command 1 - Generic CPU" \
    "./build/bin/llama-bench \
        -m $MODEL \
        -t 8 \
        -ngl 0 \
        -p 512 \
        -n 128"
run_bench \
    "Command 2 - NUMA Node 1" \
    "numactl --cpunodebind=1 --preferred=1 \
        ./build/bin/llama-bench \
        -m $MODEL \
        -t 8 \
        -ngl 0 \
        -p 512 \
        -n 128"
run_bench \
    "Command 3 - Interleave All" \
    "numactl --interleave=all \
        ./build/bin/llama-bench \
        -m $MODEL \
        -t 32 \
        -ngl 0 \
        -p 512 \
        -n 128"
########################################################################
# NUMA NODE SWEEP
########################################################################
echo "" >> "$OUTFILE"
echo "# NUMA Node Sweep" >> "$OUTFILE"
echo "" >> "$OUTFILE"
echo "| Node | pp512 | tg128 | Elapsed (s) |" >> "$OUTFILE"
echo "|------|-------|-------|-------------|" >> "$OUTFILE"
for node in 0 1 2 3
do
    run_bench \
        "NUMA Node $node" \
        "numactl --cpunodebind=$node --membind=$node \
            ./build/bin/llama-bench \
            -m $MODEL \
            -t 8 \
            -ngl 0 \
            -p 512 \
            -n 128"
    echo "| $node | $LAST_PP | $LAST_TG | $LAST_ELAPSED |" >> "$OUTFILE"
done
########################################################################
# THREAD SCALING SWEEP
########################################################################
echo "" >> "$OUTFILE"
echo "# Thread Scaling Sweep" >> "$OUTFILE"
echo "" >> "$OUTFILE"
echo "| Threads | pp512 | tg128 | Elapsed (s) |" >> "$OUTFILE"
echo "|---------|-------|-------|-------------|" >> "$OUTFILE"
for threads in 2 4 6 8 12 16 24 32
do
    run_bench \
        "Threads $threads" \
        "numactl --cpunodebind=0 --membind=0 \
            ./build/bin/llama-bench \
            -m $MODEL \
            -t $threads \
            -ngl 0 \
            -p 512 \
            -n 128"
    echo "| $threads | $LAST_PP | $LAST_TG | $LAST_ELAPSED |" >> "$OUTFILE"
done
########################################################################
# GPU OFFLOAD SWEEP
########################################################################
# Qwen2.5-7B-Instruct has 28 transformer layers, so -ngl 28 is "all layers"
# offloaded; anything >=28 (e.g. 99) is equivalent and just means "offload
# everything, llama.cpp will clamp to the actual layer count". The sweep
# below walks from CPU-only up to full offload so you can see where
# diminishing/negative returns kick in (PCIe transfer overhead can make
# partial offload *worse* than CPU-only on some setups -- that's a real
# result, not a bug, if you see it).
#
# CUDA_VISIBLE_DEVICES=0 pins llama-bench to the first (and presumably only)
# GPU. -sm none / -mg 0 aren't needed here since there's a single device.
# GPU_NUMA_NODE binds the host-side threads/memory to whichever NUMA node is
# physically closest to the GPU's PCIe slot, minimizing cross-node traffic
# for the CPU<->GPU transfers that still happen during partial offload.
# Check actual placement with `nvidia-smi topo -m` and override via
# GPU_NUMA_NODE=<n> if it's not node 1 on your board.
echo "" >> "$OUTFILE"
echo "# GPU Offload Sweep (Tesla P4)" >> "$OUTFILE"
echo "" >> "$OUTFILE"
echo "GPU NUMA node used for host-side pinning: $GPU_NUMA_NODE" >> "$OUTFILE"
echo "" >> "$OUTFILE"
echo "| -ngl | pp512 | tg128 | Elapsed (s) |" >> "$OUTFILE"
echo "|------|-------|-------|-------------|" >> "$OUTFILE"
for ngl in 0 4 8 12 16 20 24 28 99
do
    run_bench \
        "GPU Offload -ngl $ngl" \
        "CUDA_VISIBLE_DEVICES=0 numactl --cpunodebind=$GPU_NUMA_NODE --membind=$GPU_NUMA_NODE \
            ./build/bin/llama-bench \
            -m $MODEL \
            -t 8 \
            -ngl $ngl \
            -p 512 \
            -n 128"
    echo "| $ngl | $LAST_PP | $LAST_TG | $LAST_ELAPSED |" >> "$OUTFILE"
done
########################################################################
# GPU BATCH SIZE SWEEP (full offload)
########################################################################
# With the model fully on the GPU, prompt-processing throughput (pp512) is
# often batch-size sensitive. -b is the logical batch size, -ub the physical
# (micro-)batch size actually submitted to CUDA at once. Larger -ub uses
# more VRAM but can raise pp512 throughput until you hit a wall (compute-
# bound) or run out of VRAM (the P4 only has 8GB, so a 7B Q4_K_M model with
# a large -ub plus full KV cache can get tight).
echo "" >> "$OUTFILE"
echo "# GPU Batch Size Sweep (full offload, -ngl 99)" >> "$OUTFILE"
echo "" >> "$OUTFILE"
echo "| -b / -ub | pp512 | tg128 | Elapsed (s) |" >> "$OUTFILE"
echo "|----------|-------|-------|-------------|" >> "$OUTFILE"
for batch in 128 256 512 1024 2048
do
    run_bench \
        "Batch $batch" \
        "CUDA_VISIBLE_DEVICES=0 numactl --cpunodebind=$GPU_NUMA_NODE --membind=$GPU_NUMA_NODE \
            ./build/bin/llama-bench \
            -m $MODEL \
            -t 8 \
            -ngl 99 \
            -b $batch \
            -ub $batch \
            -p 512 \
            -n 128"
    echo "| $batch | $LAST_PP | $LAST_TG | $LAST_ELAPSED |" >> "$OUTFILE"
done

########################################################################
# KV CACHE QUANTIZATION SWEEP (full offload, -ngl 99)
########################################################################
echo "" >> "$OUTFILE"
echo "# KV Cache Quantization Sweep" >> "$OUTFILE"
echo "" >> "$OUTFILE"
echo "| Cache Type (K/V) | pp512 | tg128 | Elapsed (s) |" >> "$OUTFILE"
echo "|------------------|-------|-------|-------------|" >> "$OUTFILE"

# Test standard f16 cache vs 8-bit / 4-bit alternatives
for cache_type in "f16" "q8_0" "q4_0"
do
    run_bench \
        "KV Cache $cache_type" \
        "CUDA_VISIBLE_DEVICES=0 numactl --cpunodebind=$GPU_NUMA_NODE --membind=$GPU_NUMA_NODE \
            ./build/bin/llama-bench \
            -m $MODEL \
            -t 8 \
            -ngl 99 \
            -b 512 \
            -ub 512 \
            -ctk $cache_type \
            -ctv $cache_type \
            -p 512 \
            -n 128"
    echo "| $cache_type | $LAST_PP | $LAST_TG | $LAST_ELAPSED |" >> "$OUTFILE"
done

########################################################################
# CONTEXT LENGTH SCALING SWEEP (full offload, -ngl 99)
########################################################################
echo "" >> "$OUTFILE"
echo "# Context Length Scaling Sweep" >> "$OUTFILE"
echo "" >> "$OUTFILE"
echo "| Context (Prompt) | pp | tg128 | Elapsed (s) |" >> "$OUTFILE"
echo "|------------------|----|-------|-------------|" >> "$OUTFILE"

for ctx in 512 1024 2048 4096 8192
do
    run_bench \
        "Context Size $ctx" \
        "CUDA_VISIBLE_DEVICES=0 numactl --cpunodebind=$GPU_NUMA_NODE --membind=$GPU_NUMA_NODE \
            ./build/bin/llama-bench \
            -m $MODEL \
            -t 8 \
            -ngl 99 \
            -p $ctx \
            -n 128"
    echo "| $ctx | $LAST_PP | $LAST_TG | $LAST_ELAPSED |" >> "$OUTFILE"
done

########################################################################
# FLASH ATTENTION SWEEP (full offload, -ngl 99)
########################################################################
echo "" >> "$OUTFILE"
echo "# Flash Attention Sweep" >> "$OUTFILE"
echo "" >> "$OUTFILE"
echo "| Flash Attention | pp512 | tg128 | Elapsed (s) |" >> "$OUTFILE"
echo "|-----------------|-------|-------|-------------|" >> "$OUTFILE"

for fa in 0 1
do
    run_bench \
        "Flash Attention Enable: $fa" \
        "CUDA_VISIBLE_DEVICES=0 numactl --cpunodebind=$GPU_NUMA_NODE --membind=$GPU_NUMA_NODE \
            ./build/bin/llama-bench \
            -m $MODEL \
            -t 8 \
            -ngl 99 \
            -fa $fa \
            -p 512 \
            -n 128"
    echo "| $fa | $LAST_PP | $LAST_TG | $LAST_ELAPSED |" >> "$OUTFILE"
done

# Add this straight into your initial BASELINE TESTS block:
run_bench \
    "Command 4 - Anti-Optimized Cross-NUMA" \
    "numactl --cpunodebind=2 --membind=2 \
        ./build/bin/llama-bench \
        -m $MODEL \
        -t 8 \
        -ngl 14 \
        -p 512 \
        -n 128"

########################################################################
# 14B MODEL ARCHITECTURAL ARCHETYPE BENCHMARK
########################################################################
MODEL_14B="models/thinker/Qwen2.5-14B-Instruct-Q4_K_M.gguf"

if [ -f "$MODEL_14B" ]; then
    echo "" >> "$OUTFILE"
    echo "# 14B Architectural Target Comparison" >> "$OUTFILE"
    echo "" >> "$OUTFILE"
    echo "Testing optimal deployment strategies for a 14B model on system architecture." >> "$OUTFILE"
    echo "" >> "$OUTFILE"
    echo "| Strategy | pp512 | tg128 | Elapsed (s) |" >> "$OUTFILE"
    echo "|----------|-------|-------|-------------|" >> "$OUTFILE"

    # Save original 7B model context
    TEMP_MODEL_HOLD="$MODEL"
    MODEL="$MODEL_14B"

    # Strategy A: Pure CPU, strictly pinned to a single NUMA Node (Node 0)
    # Minimizes inter-socket communication overhead.
    run_bench \
        "14B - CPU Only (Single NUMA Node 0)" \
        "numactl --cpunodebind=0 --membind=0 \
            ./build/bin/llama-bench \
            -m $MODEL \
            -t 8 \
            -ngl 0 \
            -p 512 \
            -n 128"
    echo "| CPU (1 NUMA Node 0) | $LAST_PP | $LAST_TG | $LAST_ELAPSED |" >> "$OUTFILE"

    # Strategy B: Pure CPU, Interleaved across all nodes
    # Maximizes raw memory channels/bandwidth but scales thread counts up.
    run_bench \
        "14B - CPU Only (Interleave All)" \
        "numactl --interleave=all \
            ./build/bin/llama-bench \
            -m $MODEL \
            -t 32 \
            -ngl 0 \
            -p 512 \
            -n 128"
    echo "| CPU (Interleave All) | $LAST_PP | $LAST_TG | $LAST_ELAPSED |" >> "$OUTFILE"

    # Strategy C: Partial GPU Offload (Split-Compute)
    # Pins host threads to the GPU's closest PCIe root lane node. 
    # Qwen 2.5 14B has 48 transformer layers. At ~9GB, an 8GB GPU can roughly hold 
    # 18-22 layers before VRAM allocation crashes. Let's step safely at 16 layers.
    run_bench \
        "14B - Partial GPU Offload (16 Layers)" \
        "CUDA_VISIBLE_DEVICES=0 numactl --cpunodebind=$GPU_NUMA_NODE --membind=$GPU_NUMA_NODE \
            ./build/bin/llama-bench \
            -m $MODEL \
            -t 8 \
            -ngl 16 \
            -p 512 \
            -n 128"
    echo "| Partial GPU Offload (16 layers) | $LAST_PP | $LAST_TG | $LAST_ELAPSED |" >> "$OUTFILE"

    # Restore baseline model definitions
    MODEL="$TEMP_MODEL_HOLD"
else
    echo "Warning: $MODEL_14B not found. Skipping 14B specific sweeps."
fi
########################################################################
# BEST RESULTS SUMMARY
########################################################################
{
    echo ""
    echo "# Notes"
    echo ""
    echo "- NUMA sweep uses node-local memory via --membind."
    echo "- Thread sweep uses NUMA node 0 only."
    echo "- GPU offload sweep walks -ngl from 0 (CPU-only) to 99 (full offload);"
    echo "  watch for the point where adding more offloaded layers stops helping"
    echo "  or starts hurting tg128, which signals PCIe-transfer-bound behavior"
    echo "  rather than compute-bound."
    echo "- GPU batch sweep only matters once -ngl is high enough that the GPU"
    echo "  is actually doing most of the work; raise -ub cautiously since it"
    echo "  trades VRAM for pp512 throughput and the P4 only has 8GB total."
    echo "- Compare tg128 for real-world inference performance."
    echo "- Compare pp512 for prompt ingestion performance."
} >> "$OUTFILE"
echo ""
echo "Benchmark complete."
echo "Results written to: $OUTFILE"