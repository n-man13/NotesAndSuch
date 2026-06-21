# Llama.cpp Benchmark Results
Model: `./models/Qwen2.5-7B-Instruct-Q4_K_M.gguf`
Generated: Sun Jun 21 00:13:43 EDT 2026

# Baseline Tests

## Command 1 - Generic CPU

**Started:** Sun Jun 21 00:13:43 EDT 2026

**Finished:** Sun Jun 21 00:20:17 EDT 2026

**Elapsed:** 394 seconds

**pp512:** ± t/s

**tg128:** ± t/s

### Raw Output

```
| model                          |       size |     params | backend    | ngl | threads |            test |                  t/s |
| ------------------------------ | ---------: | ---------: | ---------- | --: | ------: | --------------: | -------------------: |
| qwen2 7B Q4_K - Medium         |   4.36 GiB |     7.62 B | CUDA       |   0 |       8 |           pp512 |        146.70 ± 0.07 |
| qwen2 7B Q4_K - Medium         |   4.36 GiB |     7.62 B | CUDA       |   0 |       8 |           tg128 |          1.74 ± 0.00 |

build: b4c0549a4 (9352)
```


## Command 2 - NUMA Node 1

**Started:** Sun Jun 21 00:20:17 EDT 2026

**Finished:** Sun Jun 21 00:29:34 EDT 2026

**Elapsed:** 557 seconds

**pp512:** ± t/s

**tg128:** ± t/s

### Raw Output

```
| model                          |       size |     params | backend    | ngl | threads |            test |                  t/s |
| ------------------------------ | ---------: | ---------: | ---------- | --: | ------: | --------------: | -------------------: |
| qwen2 7B Q4_K - Medium         |   4.36 GiB |     7.62 B | CUDA       |   0 |       8 |           pp512 |        145.55 ± 0.03 |
| qwen2 7B Q4_K - Medium         |   4.36 GiB |     7.62 B | CUDA       |   0 |       8 |           tg128 |          1.20 ± 0.00 |

build: b4c0549a4 (9352)
```


## Command 3 - Interleave All

**Started:** Sun Jun 21 00:29:34 EDT 2026

**Finished:** Sun Jun 21 00:38:02 EDT 2026

**Elapsed:** 508 seconds

**pp512:** ± t/s

**tg128:** ± t/s

### Raw Output

```
| model                          |       size |     params | backend    | ngl | threads |            test |                  t/s |
| ------------------------------ | ---------: | ---------: | ---------- | --: | ------: | --------------: | -------------------: |
| qwen2 7B Q4_K - Medium         |   4.36 GiB |     7.62 B | CUDA       |   0 |      32 |           pp512 |        146.84 ± 0.08 |
| qwen2 7B Q4_K - Medium         |   4.36 GiB |     7.62 B | CUDA       |   0 |      32 |           tg128 |          1.32 ± 0.02 |

build: b4c0549a4 (9352)
```


# NUMA Node Sweep

| Node | pp512 | tg128 | Elapsed (s) |
|------|-------|-------|-------------|

## NUMA Node 0

**Started:** Sun Jun 21 00:38:02 EDT 2026

**Finished:** Sun Jun 21 00:44:21 EDT 2026

**Elapsed:** 379 seconds

**pp512:** ± t/s

**tg128:** ± t/s

### Raw Output

```
| model                          |       size |     params | backend    | ngl | threads |            test |                  t/s |
| ------------------------------ | ---------: | ---------: | ---------- | --: | ------: | --------------: | -------------------: |
| qwen2 7B Q4_K - Medium         |   4.36 GiB |     7.62 B | CUDA       |   0 |       8 |           pp512 |        149.65 ± 0.18 |
| qwen2 7B Q4_K - Medium         |   4.36 GiB |     7.62 B | CUDA       |   0 |       8 |           tg128 |          1.80 ± 0.00 |

build: b4c0549a4 (9352)
```

| 0 | ± | ± | 379 |

## NUMA Node 1

**Started:** Sun Jun 21 00:44:21 EDT 2026

**Finished:** Sun Jun 21 00:53:39 EDT 2026

**Elapsed:** 558 seconds

**pp512:** ± t/s

**tg128:** ± t/s

### Raw Output

```
| model                          |       size |     params | backend    | ngl | threads |            test |                  t/s |
| ------------------------------ | ---------: | ---------: | ---------- | --: | ------: | --------------: | -------------------: |
| qwen2 7B Q4_K - Medium         |   4.36 GiB |     7.62 B | CUDA       |   0 |       8 |           pp512 |        145.44 ± 0.14 |
| qwen2 7B Q4_K - Medium         |   4.36 GiB |     7.62 B | CUDA       |   0 |       8 |           tg128 |          1.20 ± 0.00 |

build: b4c0549a4 (9352)
```

| 1 | ± | ± | 558 |

## NUMA Node 2

**Started:** Sun Jun 21 00:53:39 EDT 2026

**Finished:** Sun Jun 21 01:05:28 EDT 2026

**Elapsed:** 709 seconds

**pp512:** ± t/s

**tg128:** ± t/s

### Raw Output

```
| model                          |       size |     params | backend    | ngl | threads |            test |                  t/s |
| ------------------------------ | ---------: | ---------: | ---------- | --: | ------: | --------------: | -------------------: |
| qwen2 7B Q4_K - Medium         |   4.36 GiB |     7.62 B | CUDA       |   0 |       8 |           pp512 |        143.72 ± 0.09 |
| qwen2 7B Q4_K - Medium         |   4.36 GiB |     7.62 B | CUDA       |   0 |       8 |           tg128 |          0.94 ± 0.00 |

build: b4c0549a4 (9352)
```

| 2 | ± | ± | 709 |

## NUMA Node 3

**Started:** Sun Jun 21 01:05:28 EDT 2026

**Finished:** Sun Jun 21 01:14:59 EDT 2026

**Elapsed:** 571 seconds

**pp512:** ± t/s

**tg128:** ± t/s

### Raw Output

```
| model                          |       size |     params | backend    | ngl | threads |            test |                  t/s |
| ------------------------------ | ---------: | ---------: | ---------- | --: | ------: | --------------: | -------------------: |
| qwen2 7B Q4_K - Medium         |   4.36 GiB |     7.62 B | CUDA       |   0 |       8 |           pp512 |        144.45 ± 0.07 |
| qwen2 7B Q4_K - Medium         |   4.36 GiB |     7.62 B | CUDA       |   0 |       8 |           tg128 |          1.17 ± 0.00 |

build: b4c0549a4 (9352)
```

| 3 | ± | ± | 571 |

# Thread Scaling Sweep

| Threads | pp512 | tg128 | Elapsed (s) |
|---------|-------|-------|-------------|

## Threads 2

**Started:** Sun Jun 21 01:14:59 EDT 2026

**Finished:** Sun Jun 21 01:29:57 EDT 2026

**Elapsed:** 898 seconds

**pp512:** ± t/s

**tg128:** ± t/s

### Raw Output

```
| model                          |       size |     params | backend    | ngl | threads |            test |                  t/s |
| ------------------------------ | ---------: | ---------: | ---------- | --: | ------: | --------------: | -------------------: |
| qwen2 7B Q4_K - Medium         |   4.36 GiB |     7.62 B | CUDA       |   0 |       2 |           pp512 |        146.42 ± 0.06 |
| qwen2 7B Q4_K - Medium         |   4.36 GiB |     7.62 B | CUDA       |   0 |       2 |           tg128 |          0.73 ± 0.00 |

build: b4c0549a4 (9352)
```

| 2 | ± | ± | 898 |

## Threads 4

**Started:** Sun Jun 21 01:29:57 EDT 2026

**Finished:** Sun Jun 21 01:38:11 EDT 2026

**Elapsed:** 494 seconds

**pp512:** ± t/s

**tg128:** ± t/s

### Raw Output

```
| model                          |       size |     params | backend    | ngl | threads |            test |                  t/s |
| ------------------------------ | ---------: | ---------: | ---------- | --: | ------: | --------------: | -------------------: |
| qwen2 7B Q4_K - Medium         |   4.36 GiB |     7.62 B | CUDA       |   0 |       4 |           pp512 |        149.11 ± 0.13 |
| qwen2 7B Q4_K - Medium         |   4.36 GiB |     7.62 B | CUDA       |   0 |       4 |           tg128 |          1.36 ± 0.00 |

build: b4c0549a4 (9352)
```

| 4 | ± | ± | 494 |

## Threads 6

**Started:** Sun Jun 21 01:38:11 EDT 2026

**Finished:** Sun Jun 21 01:45:18 EDT 2026

**Elapsed:** 427 seconds

**pp512:** ± t/s

**tg128:** ± t/s

### Raw Output

```
| model                          |       size |     params | backend    | ngl | threads |            test |                  t/s |
| ------------------------------ | ---------: | ---------: | ---------- | --: | ------: | --------------: | -------------------: |
| qwen2 7B Q4_K - Medium         |   4.36 GiB |     7.62 B | CUDA       |   0 |       6 |           pp512 |        149.16 ± 0.16 |
| qwen2 7B Q4_K - Medium         |   4.36 GiB |     7.62 B | CUDA       |   0 |       6 |           tg128 |          1.59 ± 0.00 |

build: b4c0549a4 (9352)
```

| 6 | ± | ± | 427 |

## Threads 8

**Started:** Sun Jun 21 01:45:18 EDT 2026

**Finished:** Sun Jun 21 01:51:37 EDT 2026

**Elapsed:** 379 seconds

**pp512:** ± t/s

**tg128:** ± t/s

### Raw Output

```
| model                          |       size |     params | backend    | ngl | threads |            test |                  t/s |
| ------------------------------ | ---------: | ---------: | ---------- | --: | ------: | --------------: | -------------------: |
| qwen2 7B Q4_K - Medium         |   4.36 GiB |     7.62 B | CUDA       |   0 |       8 |           pp512 |        149.62 ± 0.14 |
| qwen2 7B Q4_K - Medium         |   4.36 GiB |     7.62 B | CUDA       |   0 |       8 |           tg128 |          1.80 ± 0.01 |

build: b4c0549a4 (9352)
```

| 8 | ± | ± | 379 |

## Threads 12

**Started:** Sun Jun 21 01:51:37 EDT 2026

**Finished:** Sun Jun 21 01:58:37 EDT 2026

**Elapsed:** 420 seconds

**pp512:** ± t/s

**tg128:** ± t/s

### Raw Output

```
| model                          |       size |     params | backend    | ngl | threads |            test |                  t/s |
| ------------------------------ | ---------: | ---------: | ---------- | --: | ------: | --------------: | -------------------: |
| qwen2 7B Q4_K - Medium         |   4.36 GiB |     7.62 B | CUDA       |   0 |      12 |           pp512 |        149.55 ± 0.25 |
| qwen2 7B Q4_K - Medium         |   4.36 GiB |     7.62 B | CUDA       |   0 |      12 |           tg128 |          1.62 ± 0.00 |

build: b4c0549a4 (9352)
```

| 12 | ± | ± | 420 |

## Threads 16

**Started:** Sun Jun 21 01:58:37 EDT 2026

**Finished:** Sun Jun 21 02:05:27 EDT 2026

**Elapsed:** 410 seconds

**pp512:** ± t/s

**tg128:** ± t/s

### Raw Output

```
| model                          |       size |     params | backend    | ngl |            test |                  t/s |
| ------------------------------ | ---------: | ---------: | ---------- | --: | --------------: | -------------------: |
| qwen2 7B Q4_K - Medium         |   4.36 GiB |     7.62 B | CUDA       |   0 |           pp512 |        149.53 ± 0.14 |
| qwen2 7B Q4_K - Medium         |   4.36 GiB |     7.62 B | CUDA       |   0 |           tg128 |          1.66 ± 0.00 |

build: b4c0549a4 (9352)
```

| 16 | ± | ± | 410 |

## Threads 24

**Started:** Sun Jun 21 02:05:27 EDT 2026

**Finished:** Sun Jun 21 02:12:34 EDT 2026

**Elapsed:** 427 seconds

**pp512:** ± t/s

**tg128:** ± t/s

### Raw Output

```
| model                          |       size |     params | backend    | ngl | threads |            test |                  t/s |
| ------------------------------ | ---------: | ---------: | ---------- | --: | ------: | --------------: | -------------------: |
| qwen2 7B Q4_K - Medium         |   4.36 GiB |     7.62 B | CUDA       |   0 |      24 |           pp512 |        149.52 ± 0.08 |
| qwen2 7B Q4_K - Medium         |   4.36 GiB |     7.62 B | CUDA       |   0 |      24 |           tg128 |          1.59 ± 0.00 |

build: b4c0549a4 (9352)
```

| 24 | ± | ± | 427 |

## Threads 32

**Started:** Sun Jun 21 02:12:34 EDT 2026

**Finished:** Sun Jun 21 02:20:00 EDT 2026

**Elapsed:** 446 seconds

**pp512:** ± t/s

**tg128:** ± t/s

### Raw Output

```
| model                          |       size |     params | backend    | ngl | threads |            test |                  t/s |
| ------------------------------ | ---------: | ---------: | ---------- | --: | ------: | --------------: | -------------------: |
| qwen2 7B Q4_K - Medium         |   4.36 GiB |     7.62 B | CUDA       |   0 |      32 |           pp512 |        149.60 ± 0.05 |
| qwen2 7B Q4_K - Medium         |   4.36 GiB |     7.62 B | CUDA       |   0 |      32 |           tg128 |          1.52 ± 0.00 |

build: b4c0549a4 (9352)
```

| 32 | ± | ± | 446 |

# GPU Offload Sweep (Tesla P4)

GPU NUMA node used for host-side pinning: 1

| -ngl | pp512 | tg128 | Elapsed (s) |
|------|-------|-------|-------------|

## GPU Offload -ngl 0

**Started:** Sun Jun 21 02:20:01 EDT 2026

**Finished:** Sun Jun 21 02:29:19 EDT 2026

**Elapsed:** 558 seconds

**pp512:** ± t/s

**tg128:** ± t/s

### Raw Output

```
| model                          |       size |     params | backend    | ngl | threads |            test |                  t/s |
| ------------------------------ | ---------: | ---------: | ---------- | --: | ------: | --------------: | -------------------: |
| qwen2 7B Q4_K - Medium         |   4.36 GiB |     7.62 B | CUDA       |   0 |       8 |           pp512 |        144.46 ± 0.08 |
| qwen2 7B Q4_K - Medium         |   4.36 GiB |     7.62 B | CUDA       |   0 |       8 |           tg128 |          1.20 ± 0.00 |

build: b4c0549a4 (9352)
```

| 0 | ± | ± | 558 |

## GPU Offload -ngl 4

**Started:** Sun Jun 21 02:29:19 EDT 2026

**Finished:** Sun Jun 21 02:36:56 EDT 2026

**Elapsed:** 457 seconds

**pp512:** ± t/s

**tg128:** ± t/s

### Raw Output

```
| model                          |       size |     params | backend    | ngl | threads |            test |                  t/s |
| ------------------------------ | ---------: | ---------: | ---------- | --: | ------: | --------------: | -------------------: |
| qwen2 7B Q4_K - Medium         |   4.36 GiB |     7.62 B | CUDA       |   4 |       8 |           pp512 |        159.10 ± 0.15 |
| qwen2 7B Q4_K - Medium         |   4.36 GiB |     7.62 B | CUDA       |   4 |       8 |           tg128 |          1.47 ± 0.00 |

build: b4c0549a4 (9352)
```

| 4 | ± | ± | 457 |

## GPU Offload -ngl 8

**Started:** Sun Jun 21 02:36:56 EDT 2026

**Finished:** Sun Jun 21 02:43:27 EDT 2026

**Elapsed:** 391 seconds

**pp512:** ± t/s

**tg128:** ± t/s

### Raw Output

```
| model                          |       size |     params | backend    | ngl | threads |            test |                  t/s |
| ------------------------------ | ---------: | ---------: | ---------- | --: | ------: | --------------: | -------------------: |
| qwen2 7B Q4_K - Medium         |   4.36 GiB |     7.62 B | CUDA       |   8 |       8 |           pp512 |        177.51 ± 0.32 |
| qwen2 7B Q4_K - Medium         |   4.36 GiB |     7.62 B | CUDA       |   8 |       8 |           tg128 |          1.73 ± 0.00 |

build: b4c0549a4 (9352)
```

| 8 | ± | ± | 391 |

## GPU Offload -ngl 12

**Started:** Sun Jun 21 02:43:27 EDT 2026

**Finished:** Sun Jun 21 02:48:50 EDT 2026

**Elapsed:** 323 seconds

**pp512:** ± t/s

**tg128:** ± t/s

### Raw Output

```
| model                          |       size |     params | backend    | ngl | threads |            test |                  t/s |
| ------------------------------ | ---------: | ---------: | ---------- | --: | ------: | --------------: | -------------------: |
| qwen2 7B Q4_K - Medium         |   4.36 GiB |     7.62 B | CUDA       |  12 |       8 |           pp512 |        202.92 ± 0.33 |
| qwen2 7B Q4_K - Medium         |   4.36 GiB |     7.62 B | CUDA       |  12 |       8 |           tg128 |          2.11 ± 0.00 |

build: b4c0549a4 (9352)
```

| 12 | ± | ± | 323 |

## GPU Offload -ngl 16

**Started:** Sun Jun 21 02:48:50 EDT 2026

**Finished:** Sun Jun 21 02:53:08 EDT 2026

**Elapsed:** 258 seconds

**pp512:** ± t/s

**tg128:** ± t/s

### Raw Output

```
| model                          |       size |     params | backend    | ngl | threads |            test |                  t/s |
| ------------------------------ | ---------: | ---------: | ---------- | --: | ------: | --------------: | -------------------: |
| qwen2 7B Q4_K - Medium         |   4.36 GiB |     7.62 B | CUDA       |  16 |       8 |           pp512 |        234.45 ± 0.18 |
| qwen2 7B Q4_K - Medium         |   4.36 GiB |     7.62 B | CUDA       |  16 |       8 |           tg128 |          2.67 ± 0.00 |

build: b4c0549a4 (9352)
```

| 16 | ± | ± | 258 |

## GPU Offload -ngl 20

**Started:** Sun Jun 21 02:53:08 EDT 2026

**Finished:** Sun Jun 21 02:56:20 EDT 2026

**Elapsed:** 192 seconds

**pp512:** ± t/s

**tg128:** ± t/s

### Raw Output

```
| model                          |       size |     params | backend    | ngl | threads |            test |                  t/s |
| ------------------------------ | ---------: | ---------: | ---------- | --: | ------: | --------------: | -------------------: |
| qwen2 7B Q4_K - Medium         |   4.36 GiB |     7.62 B | CUDA       |  20 |       8 |           pp512 |        277.66 ± 0.66 |
| qwen2 7B Q4_K - Medium         |   4.36 GiB |     7.62 B | CUDA       |  20 |       8 |           tg128 |          3.64 ± 0.01 |

build: b4c0549a4 (9352)
```

| 20 | ± | ± | 192 |

## GPU Offload -ngl 24

**Started:** Sun Jun 21 02:56:20 EDT 2026

**Finished:** Sun Jun 21 02:58:24 EDT 2026

**Elapsed:** 124 seconds

**pp512:** ± t/s

**tg128:** ± t/s

### Raw Output

```
| model                          |       size |     params | backend    | ngl | threads |            test |                  t/s |
| ------------------------------ | ---------: | ---------: | ---------- | --: | ------: | --------------: | -------------------: |
| qwen2 7B Q4_K - Medium         |   4.36 GiB |     7.62 B | CUDA       |  24 |       8 |           pp512 |        341.57 ± 0.36 |
| qwen2 7B Q4_K - Medium         |   4.36 GiB |     7.62 B | CUDA       |  24 |       8 |           tg128 |          5.82 ± 0.01 |

build: b4c0549a4 (9352)
```

| 24 | ± | ± | 124 |

## GPU Offload -ngl 28

**Started:** Sun Jun 21 02:58:24 EDT 2026

**Finished:** Sun Jun 21 02:59:19 EDT 2026

**Elapsed:** 55 seconds

**pp512:** ± t/s

**tg128:** ± t/s

### Raw Output

```
| model                          |       size |     params | backend    | ngl | threads |            test |                  t/s |
| ------------------------------ | ---------: | ---------: | ---------- | --: | ------: | --------------: | -------------------: |
| qwen2 7B Q4_K - Medium         |   4.36 GiB |     7.62 B | CUDA       |  28 |       8 |           pp512 |        443.95 ± 1.25 |
| qwen2 7B Q4_K - Medium         |   4.36 GiB |     7.62 B | CUDA       |  28 |       8 |           tg128 |         15.09 ± 0.00 |

build: b4c0549a4 (9352)
```

| 28 | ± | ± | 55 |

## GPU Offload -ngl 99

**Started:** Sun Jun 21 02:59:19 EDT 2026

**Finished:** Sun Jun 21 02:59:56 EDT 2026

**Elapsed:** 37 seconds

**pp512:** ± t/s

**tg128:** ± t/s

### Raw Output

```
| model                          |       size |     params | backend    | ngl | threads |            test |                  t/s |
| ------------------------------ | ---------: | ---------: | ---------- | --: | ------: | --------------: | -------------------: |
| qwen2 7B Q4_K - Medium         |   4.36 GiB |     7.62 B | CUDA       |  99 |       8 |           pp512 |        478.11 ± 1.16 |
| qwen2 7B Q4_K - Medium         |   4.36 GiB |     7.62 B | CUDA       |  99 |       8 |           tg128 |         25.51 ± 0.01 |

build: b4c0549a4 (9352)
```

| 99 | ± | ± | 37 |

# GPU Batch Size Sweep (full offload, -ngl 99)

| -b / -ub | pp512 | tg128 | Elapsed (s) |
|----------|-------|-------|-------------|

## Batch 128

**Started:** Sun Jun 21 02:59:56 EDT 2026

**Finished:** Sun Jun 21 03:00:34 EDT 2026

**Elapsed:** 38 seconds

**pp512:** ± t/s

**tg128:** ± t/s

### Raw Output

```
| model                          |       size |     params | backend    | ngl | threads | n_batch | n_ubatch |            test |                  t/s |
| ------------------------------ | ---------: | ---------: | ---------- | --: | ------: | ------: | -------: | --------------: | -------------------: |
| qwen2 7B Q4_K - Medium         |   4.36 GiB |     7.62 B | CUDA       |  99 |       8 |     128 |      128 |           pp512 |        451.99 ± 2.37 |
| qwen2 7B Q4_K - Medium         |   4.36 GiB |     7.62 B | CUDA       |  99 |       8 |     128 |      128 |           tg128 |         25.44 ± 0.00 |

build: b4c0549a4 (9352)
```

| 128 | ± | ± | 38 |

## Batch 256

**Started:** Sun Jun 21 03:00:34 EDT 2026

**Finished:** Sun Jun 21 03:01:11 EDT 2026

**Elapsed:** 37 seconds

**pp512:** ± t/s

**tg128:** ± t/s

### Raw Output

```
| model                          |       size |     params | backend    | ngl | threads | n_batch | n_ubatch |            test |                  t/s |
| ------------------------------ | ---------: | ---------: | ---------- | --: | ------: | ------: | -------: | --------------: | -------------------: |
| qwen2 7B Q4_K - Medium         |   4.36 GiB |     7.62 B | CUDA       |  99 |       8 |     256 |      256 |           pp512 |        473.62 ± 3.52 |
| qwen2 7B Q4_K - Medium         |   4.36 GiB |     7.62 B | CUDA       |  99 |       8 |     256 |      256 |           tg128 |         25.43 ± 0.02 |

build: b4c0549a4 (9352)
```

| 256 | ± | ± | 37 |

## Batch 512

**Started:** Sun Jun 21 03:01:11 EDT 2026

**Finished:** Sun Jun 21 03:01:48 EDT 2026

**Elapsed:** 37 seconds

**pp512:** ± t/s

**tg128:** ± t/s

### Raw Output

```
| model                          |       size |     params | backend    | ngl | threads | n_batch |            test |                  t/s |
| ------------------------------ | ---------: | ---------: | ---------- | --: | ------: | ------: | --------------: | -------------------: |
| qwen2 7B Q4_K - Medium         |   4.36 GiB |     7.62 B | CUDA       |  99 |       8 |     512 |           pp512 |        469.20 ± 2.19 |
| qwen2 7B Q4_K - Medium         |   4.36 GiB |     7.62 B | CUDA       |  99 |       8 |     512 |           tg128 |         25.40 ± 0.03 |

build: b4c0549a4 (9352)
```

| 512 | ± | ± | 37 |

## Batch 1024

**Started:** Sun Jun 21 03:01:48 EDT 2026

**Finished:** Sun Jun 21 03:02:26 EDT 2026

**Elapsed:** 38 seconds

**pp512:** ± t/s

**tg128:** ± t/s

### Raw Output

```
| model                          |       size |     params | backend    | ngl | threads | n_batch | n_ubatch |            test |                  t/s |
| ------------------------------ | ---------: | ---------: | ---------- | --: | ------: | ------: | -------: | --------------: | -------------------: |
| qwen2 7B Q4_K - Medium         |   4.36 GiB |     7.62 B | CUDA       |  99 |       8 |    1024 |     1024 |           pp512 |        470.04 ± 1.09 |
| qwen2 7B Q4_K - Medium         |   4.36 GiB |     7.62 B | CUDA       |  99 |       8 |    1024 |     1024 |           tg128 |         25.39 ± 0.03 |

build: b4c0549a4 (9352)
```

| 1024 | ± | ± | 38 |

## Batch 2048

**Started:** Sun Jun 21 03:02:26 EDT 2026

**Finished:** Sun Jun 21 03:03:03 EDT 2026

**Elapsed:** 37 seconds

**pp512:** ± t/s

**tg128:** ± t/s

### Raw Output

```
| model                          |       size |     params | backend    | ngl | threads | n_ubatch |            test |                  t/s |
| ------------------------------ | ---------: | ---------: | ---------- | --: | ------: | -------: | --------------: | -------------------: |
| qwen2 7B Q4_K - Medium         |   4.36 GiB |     7.62 B | CUDA       |  99 |       8 |     2048 |           pp512 |        467.47 ± 1.49 |
| qwen2 7B Q4_K - Medium         |   4.36 GiB |     7.62 B | CUDA       |  99 |       8 |     2048 |           tg128 |         25.40 ± 0.02 |

build: b4c0549a4 (9352)
```

| 2048 | ± | ± | 37 |

# Notes

- NUMA sweep uses node-local memory via --membind.
- Thread sweep uses NUMA node 0 only.
- GPU offload sweep walks -ngl from 0 (CPU-only) to 99 (full offload);
  watch for the point where adding more offloaded layers stops helping
  or starts hurting tg128, which signals PCIe-transfer-bound behavior
  rather than compute-bound.
- GPU batch sweep only matters once -ngl is high enough that the GPU
  is actually doing most of the work; raise -ub cautiously since it
  trades VRAM for pp512 throughput and the P4 only has 8GB total.
- Compare tg128 for real-world inference performance.
- Compare pp512 for prompt ingestion performance.