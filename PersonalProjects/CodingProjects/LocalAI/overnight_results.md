# Llama.cpp Advanced Overnight Benchmark Results
Generated: Sun Jun 21 23:37:08 EDT 2026
System Topology Config: GPU Affinity Node 1
---
## Section 1: Parallel Sequence Concurrency Sweep (7B)
Testing parallel user streams (-np). Multi-sequence decoding highlights multi-tenant VRAM bus pressure.

| Parallel Streams (-np) | Context Limit (-c) | pp512 | tg128 | Elapsed (s) |
|------------------------|--------------------|-------|-------|-------------|
### 7B Concurrency - 1 Users
*   **Started:** Sun Jun 21 23:37:08 EDT 2026
*   **Finished:** Sun Jun 21 23:37:09 EDT 2026
*   **Elapsed:** 1 seconds
*   **pp512 Throughput:** N/A t/s
*   **tg128 Throughput:** N/A t/s

| 1 | 1024 | N/A | N/A | 1 |
### 7B Concurrency - 2 Users
*   **Started:** Sun Jun 21 23:37:09 EDT 2026
*   **Finished:** Sun Jun 21 23:37:10 EDT 2026
*   **Elapsed:** 1 seconds
*   **pp512 Throughput:** N/A t/s
*   **tg128 Throughput:** N/A t/s

| 2 | 2048 | N/A | N/A | 1 |
### 7B Concurrency - 4 Users
*   **Started:** Sun Jun 21 23:37:10 EDT 2026
*   **Finished:** Sun Jun 21 23:37:11 EDT 2026
*   **Elapsed:** 1 seconds
*   **pp512 Throughput:** N/A t/s
*   **tg128 Throughput:** N/A t/s

| 4 | 4096 | N/A | N/A | 1 |
### 7B Concurrency - 8 Users
*   **Started:** Sun Jun 21 23:37:11 EDT 2026
*   **Finished:** Sun Jun 21 23:37:12 EDT 2026
*   **Elapsed:** 1 seconds
*   **pp512 Throughput:** N/A t/s
*   **tg128 Throughput:** N/A t/s

| 8 | 8192 | N/A | N/A | 1 |
### 7B Concurrency - 16 Users
*   **Started:** Sun Jun 21 23:37:12 EDT 2026
*   **Finished:** Sun Jun 21 23:37:13 EDT 2026
*   **Elapsed:** 1 seconds
*   **pp512 Throughput:** N/A t/s
*   **tg128 Throughput:** N/A t/s

| 16 | 16384 | N/A | N/A | 1 |

## Section 2: Logical (-b) vs Physical (-ub) Micro-Batch Permutation Sweep
Deep execution graph sweep evaluating prompt processing engine registers under variable block packaging size rules.

| Execution Mode | Logical Batch (-b) | Physical Batch (-ub) | pp512 | tg128 |
|----------------|--------------------|----------------------|-------|-------|
### Matrix [GPU] - b:512 / ub:128
*   **Started:** Sun Jun 21 23:37:13 EDT 2026
*   **Finished:** Sun Jun 21 23:37:50 EDT 2026
*   **Elapsed:** 37 seconds
*   **pp512 Throughput:** ± t/s
*   **tg128 Throughput:** ± t/s

| GPU_OFFLOAD | 512 | 128 | ± | ± |
### Matrix [GPU] - b:512 / ub:256
*   **Started:** Sun Jun 21 23:37:50 EDT 2026
*   **Finished:** Sun Jun 21 23:38:27 EDT 2026
*   **Elapsed:** 37 seconds
*   **pp512 Throughput:** ± t/s
*   **tg128 Throughput:** ± t/s

| GPU_OFFLOAD | 512 | 256 | ± | ± |
### Matrix [GPU] - b:512 / ub:512
*   **Started:** Sun Jun 21 23:38:27 EDT 2026
*   **Finished:** Sun Jun 21 23:39:04 EDT 2026
*   **Elapsed:** 37 seconds
*   **pp512 Throughput:** ± t/s
*   **tg128 Throughput:** ± t/s

| GPU_OFFLOAD | 512 | 512 | ± | ± |
### Matrix [GPU] - b:1024 / ub:128
*   **Started:** Sun Jun 21 23:39:04 EDT 2026
*   **Finished:** Sun Jun 21 23:39:42 EDT 2026
*   **Elapsed:** 38 seconds
*   **pp512 Throughput:** ± t/s
*   **tg128 Throughput:** ± t/s

| GPU_OFFLOAD | 1024 | 128 | ± | ± |
### Matrix [GPU] - b:1024 / ub:256
*   **Started:** Sun Jun 21 23:39:42 EDT 2026
*   **Finished:** Sun Jun 21 23:40:19 EDT 2026
*   **Elapsed:** 37 seconds
*   **pp512 Throughput:** ± t/s
*   **tg128 Throughput:** ± t/s

| GPU_OFFLOAD | 1024 | 256 | ± | ± |
### Matrix [GPU] - b:1024 / ub:512
*   **Started:** Sun Jun 21 23:40:19 EDT 2026
*   **Finished:** Sun Jun 21 23:40:56 EDT 2026
*   **Elapsed:** 37 seconds
*   **pp512 Throughput:** ± t/s
*   **tg128 Throughput:** ± t/s

| GPU_OFFLOAD | 1024 | 512 | ± | ± |
### Matrix [GPU] - b:2048 / ub:128
*   **Started:** Sun Jun 21 23:40:56 EDT 2026
*   **Finished:** Sun Jun 21 23:41:34 EDT 2026
*   **Elapsed:** 38 seconds
*   **pp512 Throughput:** ± t/s
*   **tg128 Throughput:** ± t/s

| GPU_OFFLOAD | 2048 | 128 | ± | ± |
### Matrix [GPU] - b:2048 / ub:256
*   **Started:** Sun Jun 21 23:41:34 EDT 2026
*   **Finished:** Sun Jun 21 23:42:11 EDT 2026
*   **Elapsed:** 37 seconds
*   **pp512 Throughput:** ± t/s
*   **tg128 Throughput:** ± t/s

| GPU_OFFLOAD | 2048 | 256 | ± | ± |
### Matrix [GPU] - b:2048 / ub:512
*   **Started:** Sun Jun 21 23:42:11 EDT 2026
*   **Finished:** Sun Jun 21 23:42:49 EDT 2026
*   **Elapsed:** 38 seconds
*   **pp512 Throughput:** ± t/s
*   **tg128 Throughput:** ± t/s

| GPU_OFFLOAD | 2048 | 512 | ± | ± |
### Matrix [CPU Node 0] - b:512 / ub:128
*   **Started:** Sun Jun 21 23:42:49 EDT 2026
*   **Finished:** Sun Jun 21 23:49:47 EDT 2026
*   **Elapsed:** 418 seconds
*   **pp512 Throughput:** ± t/s
*   **tg128 Throughput:** ± t/s

| CPU_SINGLE_NUMA | 512 | 128 | ± | ± |
### Matrix [CPU Node 0] - b:512 / ub:256
*   **Started:** Sun Jun 21 23:49:47 EDT 2026
*   **Finished:** Sun Jun 21 23:56:17 EDT 2026
*   **Elapsed:** 390 seconds
*   **pp512 Throughput:** ± t/s
*   **tg128 Throughput:** ± t/s

| CPU_SINGLE_NUMA | 512 | 256 | ± | ± |
### Matrix [CPU Node 0] - b:512 / ub:512
*   **Started:** Sun Jun 21 23:56:17 EDT 2026
*   **Finished:** Mon Jun 22 00:02:35 EDT 2026
*   **Elapsed:** 378 seconds
*   **pp512 Throughput:** ± t/s
*   **tg128 Throughput:** ± t/s

| CPU_SINGLE_NUMA | 512 | 512 | ± | ± |
### Matrix [CPU Node 0] - b:1024 / ub:128
*   **Started:** Mon Jun 22 00:02:35 EDT 2026
*   **Finished:** Mon Jun 22 00:09:30 EDT 2026
*   **Elapsed:** 415 seconds
*   **pp512 Throughput:** ± t/s
*   **tg128 Throughput:** ± t/s

| CPU_SINGLE_NUMA | 1024 | 128 | ± | ± |
### Matrix [CPU Node 0] - b:1024 / ub:256
*   **Started:** Mon Jun 22 00:09:30 EDT 2026
*   **Finished:** Mon Jun 22 00:16:02 EDT 2026
*   **Elapsed:** 392 seconds
*   **pp512 Throughput:** ± t/s
*   **tg128 Throughput:** ± t/s

| CPU_SINGLE_NUMA | 1024 | 256 | ± | ± |
### Matrix [CPU Node 0] - b:1024 / ub:512
*   **Started:** Mon Jun 22 00:16:02 EDT 2026
*   **Finished:** Mon Jun 22 00:22:21 EDT 2026
*   **Elapsed:** 379 seconds
*   **pp512 Throughput:** ± t/s
*   **tg128 Throughput:** ± t/s

| CPU_SINGLE_NUMA | 1024 | 512 | ± | ± |
### Matrix [CPU Node 0] - b:2048 / ub:128
*   **Started:** Mon Jun 22 00:22:22 EDT 2026
*   **Finished:** Mon Jun 22 00:29:17 EDT 2026
*   **Elapsed:** 415 seconds
*   **pp512 Throughput:** ± t/s
*   **tg128 Throughput:** ± t/s

| CPU_SINGLE_NUMA | 2048 | 128 | ± | ± |
### Matrix [CPU Node 0] - b:2048 / ub:256
*   **Started:** Mon Jun 22 00:29:17 EDT 2026
*   **Finished:** Mon Jun 22 00:35:51 EDT 2026
*   **Elapsed:** 394 seconds
*   **pp512 Throughput:** ± t/s
*   **tg128 Throughput:** ± t/s

| CPU_SINGLE_NUMA | 2048 | 256 | ± | ± |
### Matrix [CPU Node 0] - b:2048 / ub:512
*   **Started:** Mon Jun 22 00:35:51 EDT 2026
*   **Finished:** Mon Jun 22 00:42:10 EDT 2026
*   **Elapsed:** 379 seconds
*   **pp512 Throughput:** ± t/s
*   **tg128 Throughput:** ± t/s

| CPU_SINGLE_NUMA | 2048 | 512 | ± | ± |

## Section 3: Deep Architectural Profiling (14B Parameter Model)
Testing how single NUMA node boundaries compare directly to cross-interconnect interleave schemes on heavy models.

| Topology Management Strategy | pp512 | tg128 | Elapsed (s) |
|------------------------------|-------|-------|-------------|
### 14B Target - Single Socket Pinned (NUMA 0)
*   **Started:** Mon Jun 22 00:42:10 EDT 2026
*   **Finished:** Mon Jun 22 01:00:54 EDT 2026
*   **Elapsed:** 1124 seconds
*   **pp512 Throughput:** ± t/s
*   **tg128 Throughput:** ± t/s

| CPU-Only (Strict NUMA Node 0) | ± | ± | 1124 |
### 14B Target - Scaled Interleave All Channels
*   **Started:** Mon Jun 22 01:00:54 EDT 2026
*   **Finished:** Mon Jun 22 01:15:59 EDT 2026
*   **Elapsed:** 905 seconds
*   **pp512 Throughput:** ± t/s
*   **tg128 Throughput:** ± t/s

| CPU-Only (Interleaved All / 32 Threads) | ± | ± | 905 |
### 14B Target - Managed Co-Processing Split (16 GPU Layers)
*   **Started:** Mon Jun 22 01:15:59 EDT 2026
*   **Finished:** Mon Jun 22 01:31:17 EDT 2026
*   **Elapsed:** 918 seconds
*   **pp512 Throughput:** ± t/s
*   **tg128 Throughput:** ± t/s

| Hybrid (Partial GPU Offload - 16 Layers) | ± | ± | 918 |

## Section 4: GPU Multi-Model Co-Habitation Stress Test
Evaluating 7B benchmark metrics while a 1.5B Autocomplete Coder model actively shares GPU compute lanes.

| Testing Context Status | pp512 | tg128 | Elapsed (s) |
|------------------------|-------|-------|-------------|
### 7B - Co-habiting with Idle 1.5B background model
*   **Started:** Mon Jun 22 01:31:27 EDT 2026
*   **Finished:** Mon Jun 22 01:32:04 EDT 2026
*   **Elapsed:** 37 seconds
*   **pp512 Throughput:** ± t/s
*   **tg128 Throughput:** ± t/s

| Idle Co-habitation (Passive VRAM Shared) | ± | ± | 37 |
### 7B - Co-habiting with Active 1.5B autocomplete load
*   **Started:** Mon Jun 22 01:32:04 EDT 2026
*   **Finished:** Mon Jun 22 01:32:53 EDT 2026
*   **Elapsed:** 49 seconds
*   **pp512 Throughput:** ± t/s
*   **tg128 Throughput:** ± t/s

| Active Contention (Concurrent GPU Grunt) | ± | ± | 49 |
