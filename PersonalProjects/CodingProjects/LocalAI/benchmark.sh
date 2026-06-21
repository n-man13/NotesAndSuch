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