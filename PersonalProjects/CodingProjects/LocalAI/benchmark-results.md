# Llama.cpp Benchmark Results
Model: `./models/Qwen2.5-7B-Instruct-Q4_K_M.gguf`
Generated: Sun Jun 21 16:47:33 EDT 2026

# Baseline Tests

## Command 1 - Generic CPU

**Started:** Sun Jun 21 16:47:33 EDT 2026

**Finished:** Sun Jun 21 16:54:10 EDT 2026

**Elapsed:** 397 seconds

**pp512:** ± t/s

**tg128:** ± t/s

### Raw Output

```
| model                          |       size |     params | backend    | ngl | threads |            test |                  t/s |
| ------------------------------ | ---------: | ---------: | ---------- | --: | ------: | --------------: | -------------------: |
| qwen2 7B Q4_K - Medium         |   4.36 GiB |     7.62 B | CUDA       |   0 |       8 |           pp512 |        145.32 ± 0.13 |
| qwen2 7B Q4_K - Medium         |   4.36 GiB |     7.62 B | CUDA       |   0 |       8 |           tg128 |          1.72 ± 0.00 |

build: b4c0549a4 (9352)
```


## Command 2 - NUMA Node 1

**Started:** Sun Jun 21 16:54:10 EDT 2026

**Finished:** Sun Jun 21 17:03:28 EDT 2026

**Elapsed:** 558 seconds

**pp512:** ± t/s

**tg128:** ± t/s

### Raw Output

```
| model                          |       size |     params | backend    | ngl | threads |            test |                  t/s |
| ------------------------------ | ---------: | ---------: | ---------- | --: | ------: | --------------: | -------------------: |
| qwen2 7B Q4_K - Medium         |   4.36 GiB |     7.62 B | CUDA       |   0 |       8 |           pp512 |        145.50 ± 0.04 |
| qwen2 7B Q4_K - Medium         |   4.36 GiB |     7.62 B | CUDA       |   0 |       8 |           tg128 |          1.20 ± 0.00 |

build: b4c0549a4 (9352)
```


## Command 3 - Interleave All

**Started:** Sun Jun 21 17:03:28 EDT 2026

**Finished:** Sun Jun 21 17:11:59 EDT 2026

**Elapsed:** 511 seconds

**pp512:** ± t/s

**tg128:** ± t/s

### Raw Output

```
| model                          |       size |     params | backend    | ngl | threads |            test |                  t/s |
| ------------------------------ | ---------: | ---------: | ---------- | --: | ------: | --------------: | -------------------: |
| qwen2 7B Q4_K - Medium         |   4.36 GiB |     7.62 B | CUDA       |   0 |      32 |           pp512 |        144.94 ± 0.18 |
| qwen2 7B Q4_K - Medium         |   4.36 GiB |     7.62 B | CUDA       |   0 |      32 |           tg128 |          1.32 ± 0.01 |

build: b4c0549a4 (9352)
```


# NUMA Node Sweep

| Node | pp512 | tg128 | Elapsed (s) |
|------|-------|-------|-------------|

## NUMA Node 0

**Started:** Sun Jun 21 17:11:59 EDT 2026

**Finished:** Sun Jun 21 17:18:22 EDT 2026

**Elapsed:** 383 seconds

**pp512:** ± t/s

**tg128:** ± t/s

### Raw Output

```
| model                          |       size |     params | backend    | ngl | threads |            test |                  t/s |
| ------------------------------ | ---------: | ---------: | ---------- | --: | ------: | --------------: | -------------------: |
| qwen2 7B Q4_K - Medium         |   4.36 GiB |     7.62 B | CUDA       |   0 |       8 |           pp512 |        149.52 ± 0.23 |
| qwen2 7B Q4_K - Medium         |   4.36 GiB |     7.62 B | CUDA       |   0 |       8 |           tg128 |          1.78 ± 0.00 |

build: b4c0549a4 (9352)
```

| 0 | ± | ± | 383 |

## NUMA Node 1

**Started:** Sun Jun 21 17:18:22 EDT 2026

**Finished:** Sun Jun 21 17:27:40 EDT 2026

**Elapsed:** 558 seconds

**pp512:** ± t/s

**tg128:** ± t/s

### Raw Output

```
| model                          |       size |     params | backend    | ngl | threads |            test |                  t/s |
| ------------------------------ | ---------: | ---------: | ---------- | --: | ------: | --------------: | -------------------: |
| qwen2 7B Q4_K - Medium         |   4.36 GiB |     7.62 B | CUDA       |   0 |       8 |           pp512 |        145.33 ± 0.24 |
| qwen2 7B Q4_K - Medium         |   4.36 GiB |     7.62 B | CUDA       |   0 |       8 |           tg128 |          1.20 ± 0.00 |

build: b4c0549a4 (9352)
```

| 1 | ± | ± | 558 |

## NUMA Node 2

**Started:** Sun Jun 21 17:27:40 EDT 2026

**Finished:** Sun Jun 21 17:39:29 EDT 2026

**Elapsed:** 709 seconds

**pp512:** ± t/s

**tg128:** ± t/s

### Raw Output

```
| model                          |       size |     params | backend    | ngl | threads |            test |                  t/s |
| ------------------------------ | ---------: | ---------: | ---------- | --: | ------: | --------------: | -------------------: |
| qwen2 7B Q4_K - Medium         |   4.36 GiB |     7.62 B | CUDA       |   0 |       8 |           pp512 |        142.41 ± 0.07 |
| qwen2 7B Q4_K - Medium         |   4.36 GiB |     7.62 B | CUDA       |   0 |       8 |           tg128 |          0.94 ± 0.00 |

build: b4c0549a4 (9352)
```

| 2 | ± | ± | 709 |

## NUMA Node 3

**Started:** Sun Jun 21 17:39:29 EDT 2026

**Finished:** Sun Jun 21 17:48:59 EDT 2026

**Elapsed:** 570 seconds

**pp512:** ± t/s

**tg128:** ± t/s

### Raw Output

```
| model                          |       size |     params | backend    | ngl | threads |            test |                  t/s |
| ------------------------------ | ---------: | ---------: | ---------- | --: | ------: | --------------: | -------------------: |
| qwen2 7B Q4_K - Medium         |   4.36 GiB |     7.62 B | CUDA       |   0 |       8 |           pp512 |        145.24 ± 0.07 |
| qwen2 7B Q4_K - Medium         |   4.36 GiB |     7.62 B | CUDA       |   0 |       8 |           tg128 |          1.17 ± 0.00 |

build: b4c0549a4 (9352)
```

| 3 | ± | ± | 570 |

# Thread Scaling Sweep

| Threads | pp512 | tg128 | Elapsed (s) |
|---------|-------|-------|-------------|

## Threads 2

**Started:** Sun Jun 21 17:48:59 EDT 2026

**Finished:** Sun Jun 21 18:04:00 EDT 2026

**Elapsed:** 901 seconds

**pp512:** ± t/s

**tg128:** ± t/s

### Raw Output

```
| model                          |       size |     params | backend    | ngl | threads |            test |                  t/s |
| ------------------------------ | ---------: | ---------: | ---------- | --: | ------: | --------------: | -------------------: |
| qwen2 7B Q4_K - Medium         |   4.36 GiB |     7.62 B | CUDA       |   0 |       2 |           pp512 |        146.33 ± 0.10 |
| qwen2 7B Q4_K - Medium         |   4.36 GiB |     7.62 B | CUDA       |   0 |       2 |           tg128 |          0.73 ± 0.00 |

build: b4c0549a4 (9352)
```

| 2 | ± | ± | 901 |

## Threads 4

**Started:** Sun Jun 21 18:04:00 EDT 2026

**Finished:** Sun Jun 21 18:12:11 EDT 2026

**Elapsed:** 491 seconds

**pp512:** ± t/s

**tg128:** ± t/s

### Raw Output

```
| model                          |       size |     params | backend    | ngl | threads |            test |                  t/s |
| ------------------------------ | ---------: | ---------: | ---------- | --: | ------: | --------------: | -------------------: |
| qwen2 7B Q4_K - Medium         |   4.36 GiB |     7.62 B | CUDA       |   0 |       4 |           pp512 |        149.05 ± 0.04 |
| qwen2 7B Q4_K - Medium         |   4.36 GiB |     7.62 B | CUDA       |   0 |       4 |           tg128 |          1.37 ± 0.00 |

build: b4c0549a4 (9352)
```

| 4 | ± | ± | 491 |

## Threads 6

**Started:** Sun Jun 21 18:12:11 EDT 2026

**Finished:** Sun Jun 21 18:19:18 EDT 2026

**Elapsed:** 427 seconds

**pp512:** ± t/s

**tg128:** ± t/s

### Raw Output

```
| model                          |       size |     params | backend    | ngl | threads |            test |                  t/s |
| ------------------------------ | ---------: | ---------: | ---------- | --: | ------: | --------------: | -------------------: |
| qwen2 7B Q4_K - Medium         |   4.36 GiB |     7.62 B | CUDA       |   0 |       6 |           pp512 |        149.44 ± 0.05 |
| qwen2 7B Q4_K - Medium         |   4.36 GiB |     7.62 B | CUDA       |   0 |       6 |           tg128 |          1.59 ± 0.00 |

build: b4c0549a4 (9352)
```

| 6 | ± | ± | 427 |

## Threads 8

**Started:** Sun Jun 21 18:19:18 EDT 2026

**Finished:** Sun Jun 21 18:25:37 EDT 2026

**Elapsed:** 379 seconds

**pp512:** ± t/s

**tg128:** ± t/s

### Raw Output

```
| model                          |       size |     params | backend    | ngl | threads |            test |                  t/s |
| ------------------------------ | ---------: | ---------: | ---------- | --: | ------: | --------------: | -------------------: |
| qwen2 7B Q4_K - Medium         |   4.36 GiB |     7.62 B | CUDA       |   0 |       8 |           pp512 |        149.66 ± 0.01 |
| qwen2 7B Q4_K - Medium         |   4.36 GiB |     7.62 B | CUDA       |   0 |       8 |           tg128 |          1.80 ± 0.00 |

build: b4c0549a4 (9352)
```

| 8 | ± | ± | 379 |

## Threads 12

**Started:** Sun Jun 21 18:25:37 EDT 2026

**Finished:** Sun Jun 21 18:32:37 EDT 2026

**Elapsed:** 420 seconds

**pp512:** ± t/s

**tg128:** ± t/s

### Raw Output

```
| model                          |       size |     params | backend    | ngl | threads |            test |                  t/s |
| ------------------------------ | ---------: | ---------: | ---------- | --: | ------: | --------------: | -------------------: |
| qwen2 7B Q4_K - Medium         |   4.36 GiB |     7.62 B | CUDA       |   0 |      12 |           pp512 |        149.51 ± 0.09 |
| qwen2 7B Q4_K - Medium         |   4.36 GiB |     7.62 B | CUDA       |   0 |      12 |           tg128 |          1.61 ± 0.00 |

build: b4c0549a4 (9352)
```

| 12 | ± | ± | 420 |

## Threads 16

**Started:** Sun Jun 21 18:32:37 EDT 2026

**Finished:** Sun Jun 21 18:39:28 EDT 2026

**Elapsed:** 411 seconds

**pp512:** ± t/s

**tg128:** ± t/s

### Raw Output

```
| model                          |       size |     params | backend    | ngl |            test |                  t/s |
| ------------------------------ | ---------: | ---------: | ---------- | --: | --------------: | -------------------: |
| qwen2 7B Q4_K - Medium         |   4.36 GiB |     7.62 B | CUDA       |   0 |           pp512 |        149.52 ± 0.05 |
| qwen2 7B Q4_K - Medium         |   4.36 GiB |     7.62 B | CUDA       |   0 |           tg128 |          1.66 ± 0.01 |

build: b4c0549a4 (9352)
```

| 16 | ± | ± | 411 |

## Threads 24

**Started:** Sun Jun 21 18:39:28 EDT 2026

**Finished:** Sun Jun 21 18:46:34 EDT 2026

**Elapsed:** 426 seconds

**pp512:** ± t/s

**tg128:** ± t/s

### Raw Output

```
| model                          |       size |     params | backend    | ngl | threads |            test |                  t/s |
| ------------------------------ | ---------: | ---------: | ---------- | --: | ------: | --------------: | -------------------: |
| qwen2 7B Q4_K - Medium         |   4.36 GiB |     7.62 B | CUDA       |   0 |      24 |           pp512 |        149.47 ± 0.06 |
| qwen2 7B Q4_K - Medium         |   4.36 GiB |     7.62 B | CUDA       |   0 |      24 |           tg128 |          1.60 ± 0.00 |

build: b4c0549a4 (9352)
```

| 24 | ± | ± | 426 |

## Threads 32

**Started:** Sun Jun 21 18:46:34 EDT 2026

**Finished:** Sun Jun 21 18:53:57 EDT 2026

**Elapsed:** 443 seconds

**pp512:** ± t/s

**tg128:** ± t/s

### Raw Output

```
| model                          |       size |     params | backend    | ngl | threads |            test |                  t/s |
| ------------------------------ | ---------: | ---------: | ---------- | --: | ------: | --------------: | -------------------: |
| qwen2 7B Q4_K - Medium         |   4.36 GiB |     7.62 B | CUDA       |   0 |      32 |           pp512 |        149.54 ± 0.05 |
| qwen2 7B Q4_K - Medium         |   4.36 GiB |     7.62 B | CUDA       |   0 |      32 |           tg128 |          1.53 ± 0.00 |

build: b4c0549a4 (9352)
```

| 32 | ± | ± | 443 |

# GPU Offload Sweep (Tesla P4)

GPU NUMA node used for host-side pinning: 1

| -ngl | pp512 | tg128 | Elapsed (s) |
|------|-------|-------|-------------|

## GPU Offload -ngl 0

**Started:** Sun Jun 21 18:53:57 EDT 2026

**Finished:** Sun Jun 21 19:03:16 EDT 2026

**Elapsed:** 559 seconds

**pp512:** ± t/s

**tg128:** ± t/s

### Raw Output

```
| model                          |       size |     params | backend    | ngl | threads |            test |                  t/s |
| ------------------------------ | ---------: | ---------: | ---------- | --: | ------: | --------------: | -------------------: |
| qwen2 7B Q4_K - Medium         |   4.36 GiB |     7.62 B | CUDA       |   0 |       8 |           pp512 |        145.56 ± 0.03 |
| qwen2 7B Q4_K - Medium         |   4.36 GiB |     7.62 B | CUDA       |   0 |       8 |           tg128 |          1.20 ± 0.00 |

build: b4c0549a4 (9352)
```

| 0 | ± | ± | 559 |

## GPU Offload -ngl 4

**Started:** Sun Jun 21 19:03:16 EDT 2026

**Finished:** Sun Jun 21 19:10:54 EDT 2026

**Elapsed:** 458 seconds

**pp512:** ± t/s

**tg128:** ± t/s

### Raw Output

```
| model                          |       size |     params | backend    | ngl | threads |            test |                  t/s |
| ------------------------------ | ---------: | ---------: | ---------- | --: | ------: | --------------: | -------------------: |
| qwen2 7B Q4_K - Medium         |   4.36 GiB |     7.62 B | CUDA       |   4 |       8 |           pp512 |        159.00 ± 0.08 |
| qwen2 7B Q4_K - Medium         |   4.36 GiB |     7.62 B | CUDA       |   4 |       8 |           tg128 |          1.47 ± 0.00 |

build: b4c0549a4 (9352)
```

| 4 | ± | ± | 458 |

## GPU Offload -ngl 8

**Started:** Sun Jun 21 19:10:54 EDT 2026

**Finished:** Sun Jun 21 19:17:24 EDT 2026

**Elapsed:** 390 seconds

**pp512:** ± t/s

**tg128:** ± t/s

### Raw Output

```
| model                          |       size |     params | backend    | ngl | threads |            test |                  t/s |
| ------------------------------ | ---------: | ---------: | ---------- | --: | ------: | --------------: | -------------------: |
| qwen2 7B Q4_K - Medium         |   4.36 GiB |     7.62 B | CUDA       |   8 |       8 |           pp512 |        178.26 ± 0.18 |
| qwen2 7B Q4_K - Medium         |   4.36 GiB |     7.62 B | CUDA       |   8 |       8 |           tg128 |          1.74 ± 0.00 |

build: b4c0549a4 (9352)
```

| 8 | ± | ± | 390 |

## GPU Offload -ngl 12

**Started:** Sun Jun 21 19:17:24 EDT 2026

**Finished:** Sun Jun 21 19:22:48 EDT 2026

**Elapsed:** 324 seconds

**pp512:** ± t/s

**tg128:** ± t/s

### Raw Output

```
| model                          |       size |     params | backend    | ngl | threads |            test |                  t/s |
| ------------------------------ | ---------: | ---------: | ---------- | --: | ------: | --------------: | -------------------: |
| qwen2 7B Q4_K - Medium         |   4.36 GiB |     7.62 B | CUDA       |  12 |       8 |           pp512 |        202.66 ± 0.41 |
| qwen2 7B Q4_K - Medium         |   4.36 GiB |     7.62 B | CUDA       |  12 |       8 |           tg128 |          2.11 ± 0.00 |

build: b4c0549a4 (9352)
```

| 12 | ± | ± | 324 |

## GPU Offload -ngl 16

**Started:** Sun Jun 21 19:22:48 EDT 2026

**Finished:** Sun Jun 21 19:27:06 EDT 2026

**Elapsed:** 258 seconds

**pp512:** ± t/s

**tg128:** ± t/s

### Raw Output

```
| model                          |       size |     params | backend    | ngl | threads |            test |                  t/s |
| ------------------------------ | ---------: | ---------: | ---------- | --: | ------: | --------------: | -------------------: |
| qwen2 7B Q4_K - Medium         |   4.36 GiB |     7.62 B | CUDA       |  16 |       8 |           pp512 |        233.66 ± 0.32 |
| qwen2 7B Q4_K - Medium         |   4.36 GiB |     7.62 B | CUDA       |  16 |       8 |           tg128 |          2.67 ± 0.00 |

build: b4c0549a4 (9352)
```

| 16 | ± | ± | 258 |

## GPU Offload -ngl 20

**Started:** Sun Jun 21 19:27:06 EDT 2026

**Finished:** Sun Jun 21 19:30:18 EDT 2026

**Elapsed:** 192 seconds

**pp512:** ± t/s

**tg128:** ± t/s

### Raw Output

```
| model                          |       size |     params | backend    | ngl | threads |            test |                  t/s |
| ------------------------------ | ---------: | ---------: | ---------- | --: | ------: | --------------: | -------------------: |
| qwen2 7B Q4_K - Medium         |   4.36 GiB |     7.62 B | CUDA       |  20 |       8 |           pp512 |        276.24 ± 0.25 |
| qwen2 7B Q4_K - Medium         |   4.36 GiB |     7.62 B | CUDA       |  20 |       8 |           tg128 |          3.65 ± 0.01 |

build: b4c0549a4 (9352)
```

| 20 | ± | ± | 192 |

## GPU Offload -ngl 24

**Started:** Sun Jun 21 19:30:18 EDT 2026

**Finished:** Sun Jun 21 19:32:22 EDT 2026

**Elapsed:** 124 seconds

**pp512:** ± t/s

**tg128:** ± t/s

### Raw Output

```
| model                          |       size |     params | backend    | ngl | threads |            test |                  t/s |
| ------------------------------ | ---------: | ---------: | ---------- | --: | ------: | --------------: | -------------------: |
| qwen2 7B Q4_K - Medium         |   4.36 GiB |     7.62 B | CUDA       |  24 |       8 |           pp512 |        340.71 ± 1.15 |
| qwen2 7B Q4_K - Medium         |   4.36 GiB |     7.62 B | CUDA       |  24 |       8 |           tg128 |          5.81 ± 0.01 |

build: b4c0549a4 (9352)
```

| 24 | ± | ± | 124 |

## GPU Offload -ngl 28

**Started:** Sun Jun 21 19:32:22 EDT 2026

**Finished:** Sun Jun 21 19:33:17 EDT 2026

**Elapsed:** 55 seconds

**pp512:** ± t/s

**tg128:** ± t/s

### Raw Output

```
| model                          |       size |     params | backend    | ngl | threads |            test |                  t/s |
| ------------------------------ | ---------: | ---------: | ---------- | --: | ------: | --------------: | -------------------: |
| qwen2 7B Q4_K - Medium         |   4.36 GiB |     7.62 B | CUDA       |  28 |       8 |           pp512 |        442.22 ± 2.86 |
| qwen2 7B Q4_K - Medium         |   4.36 GiB |     7.62 B | CUDA       |  28 |       8 |           tg128 |         15.05 ± 0.01 |

build: b4c0549a4 (9352)
```

| 28 | ± | ± | 55 |

## GPU Offload -ngl 99

**Started:** Sun Jun 21 19:33:17 EDT 2026

**Finished:** Sun Jun 21 19:33:55 EDT 2026

**Elapsed:** 38 seconds

**pp512:** ± t/s

**tg128:** ± t/s

### Raw Output

```
| model                          |       size |     params | backend    | ngl | threads |            test |                  t/s |
| ------------------------------ | ---------: | ---------: | ---------- | --: | ------: | --------------: | -------------------: |
| qwen2 7B Q4_K - Medium         |   4.36 GiB |     7.62 B | CUDA       |  99 |       8 |           pp512 |        477.02 ± 2.24 |
| qwen2 7B Q4_K - Medium         |   4.36 GiB |     7.62 B | CUDA       |  99 |       8 |           tg128 |         25.49 ± 0.02 |

build: b4c0549a4 (9352)
```

| 99 | ± | ± | 38 |

# GPU Batch Size Sweep (full offload, -ngl 99)

| -b / -ub | pp512 | tg128 | Elapsed (s) |
|----------|-------|-------|-------------|

## Batch 128

**Started:** Sun Jun 21 19:33:55 EDT 2026

**Finished:** Sun Jun 21 19:34:32 EDT 2026

**Elapsed:** 37 seconds

**pp512:** ± t/s

**tg128:** ± t/s

### Raw Output

```
| model                          |       size |     params | backend    | ngl | threads | n_batch | n_ubatch |            test |                  t/s |
| ------------------------------ | ---------: | ---------: | ---------- | --: | ------: | ------: | -------: | --------------: | -------------------: |
| qwen2 7B Q4_K - Medium         |   4.36 GiB |     7.62 B | CUDA       |  99 |       8 |     128 |      128 |           pp512 |        453.09 ± 1.19 |
| qwen2 7B Q4_K - Medium         |   4.36 GiB |     7.62 B | CUDA       |  99 |       8 |     128 |      128 |           tg128 |         25.44 ± 0.00 |

build: b4c0549a4 (9352)
```

| 128 | ± | ± | 37 |

## Batch 256

**Started:** Sun Jun 21 19:34:32 EDT 2026

**Finished:** Sun Jun 21 19:35:10 EDT 2026

**Elapsed:** 38 seconds

**pp512:** ± t/s

**tg128:** ± t/s

### Raw Output

```
| model                          |       size |     params | backend    | ngl | threads | n_batch | n_ubatch |            test |                  t/s |
| ------------------------------ | ---------: | ---------: | ---------- | --: | ------: | ------: | -------: | --------------: | -------------------: |
| qwen2 7B Q4_K - Medium         |   4.36 GiB |     7.62 B | CUDA       |  99 |       8 |     256 |      256 |           pp512 |        474.98 ± 2.26 |
| qwen2 7B Q4_K - Medium         |   4.36 GiB |     7.62 B | CUDA       |  99 |       8 |     256 |      256 |           tg128 |         25.43 ± 0.00 |

build: b4c0549a4 (9352)
```

| 256 | ± | ± | 38 |

## Batch 512

**Started:** Sun Jun 21 19:35:10 EDT 2026

**Finished:** Sun Jun 21 19:35:47 EDT 2026

**Elapsed:** 37 seconds

**pp512:** ± t/s

**tg128:** ± t/s

### Raw Output

```
| model                          |       size |     params | backend    | ngl | threads | n_batch |            test |                  t/s |
| ------------------------------ | ---------: | ---------: | ---------- | --: | ------: | ------: | --------------: | -------------------: |
| qwen2 7B Q4_K - Medium         |   4.36 GiB |     7.62 B | CUDA       |  99 |       8 |     512 |           pp512 |        472.24 ± 2.49 |
| qwen2 7B Q4_K - Medium         |   4.36 GiB |     7.62 B | CUDA       |  99 |       8 |     512 |           tg128 |         25.42 ± 0.01 |

build: b4c0549a4 (9352)
```

| 512 | ± | ± | 37 |

## Batch 1024

**Started:** Sun Jun 21 19:35:47 EDT 2026

**Finished:** Sun Jun 21 19:36:24 EDT 2026

**Elapsed:** 37 seconds

**pp512:** ± t/s

**tg128:** ± t/s

### Raw Output

```
| model                          |       size |     params | backend    | ngl | threads | n_batch | n_ubatch |            test |                  t/s |
| ------------------------------ | ---------: | ---------: | ---------- | --: | ------: | ------: | -------: | --------------: | -------------------: |
| qwen2 7B Q4_K - Medium         |   4.36 GiB |     7.62 B | CUDA       |  99 |       8 |    1024 |     1024 |           pp512 |        469.91 ± 2.11 |
| qwen2 7B Q4_K - Medium         |   4.36 GiB |     7.62 B | CUDA       |  99 |       8 |    1024 |     1024 |           tg128 |         25.41 ± 0.00 |

build: b4c0549a4 (9352)
```

| 1024 | ± | ± | 37 |

## Batch 2048

**Started:** Sun Jun 21 19:36:24 EDT 2026

**Finished:** Sun Jun 21 19:37:02 EDT 2026

**Elapsed:** 38 seconds

**pp512:** ± t/s

**tg128:** ± t/s

### Raw Output

```
| model                          |       size |     params | backend    | ngl | threads | n_ubatch |            test |                  t/s |
| ------------------------------ | ---------: | ---------: | ---------- | --: | ------: | -------: | --------------: | -------------------: |
| qwen2 7B Q4_K - Medium         |   4.36 GiB |     7.62 B | CUDA       |  99 |       8 |     2048 |           pp512 |        469.15 ± 1.07 |
| qwen2 7B Q4_K - Medium         |   4.36 GiB |     7.62 B | CUDA       |  99 |       8 |     2048 |           tg128 |         25.41 ± 0.01 |

build: b4c0549a4 (9352)
```

| 2048 | ± | ± | 38 |

# KV Cache Quantization Sweep

| Cache Type (K/V) | pp512 | tg128 | Elapsed (s) |
|------------------|-------|-------|-------------|

## KV Cache f16

**Started:** Sun Jun 21 19:37:02 EDT 2026

**Finished:** Sun Jun 21 19:37:39 EDT 2026

**Elapsed:** 37 seconds

**pp512:** ± t/s

**tg128:** ± t/s

### Raw Output

```
| model                          |       size |     params | backend    | ngl | threads |            test |                  t/s |
| ------------------------------ | ---------: | ---------: | ---------- | --: | ------: | --------------: | -------------------: |
| qwen2 7B Q4_K - Medium         |   4.36 GiB |     7.62 B | CUDA       |  99 |       8 |           pp512 |        467.73 ± 2.30 |
| qwen2 7B Q4_K - Medium         |   4.36 GiB |     7.62 B | CUDA       |  99 |       8 |           tg128 |         25.40 ± 0.02 |

build: b4c0549a4 (9352)
```

| f16 | ± | ± | 37 |