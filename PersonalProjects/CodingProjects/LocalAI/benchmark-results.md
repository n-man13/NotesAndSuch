# Llama.cpp Benchmark Results

Model: `./models/Qwen2.5-7B-Instruct-Q4_K_M.gguf`

Generated: Sat Jun 20 00:19:35 EDT 2026


# Baseline Tests

## Command 1 - Generic CPU

**Started:** Sat Jun 20 00:19:35 EDT 2026

**Finished:** Sat Jun 20 00:39:33 EDT 2026

**Elapsed:** 1198 seconds

**pp512:** ± t/s

**tg128:** ± t/s

### Raw Output

```
| model                          |       size |     params | backend    | threads |            test |                  t/s |
| ------------------------------ | ---------: | ---------: | ---------- | ------: | --------------: | -------------------: |
| qwen2 7B Q4_K - Medium         |   4.36 GiB |     7.62 B | CPU        |       8 |           pp512 |          3.74 ± 0.00 |
| qwen2 7B Q4_K - Medium         |   4.36 GiB |     7.62 B | CPU        |       8 |           tg128 |          1.71 ± 0.00 |

build: b4c0549a4 (9352)
```


## Command 2 - NUMA Node 1

**Started:** Sat Jun 20 00:39:33 EDT 2026

**Finished:** Sat Jun 20 01:04:06 EDT 2026

**Elapsed:** 1473 seconds

**pp512:** ± t/s

**tg128:** ± t/s

### Raw Output

```
| model                          |       size |     params | backend    | threads |            test |                  t/s |
| ------------------------------ | ---------: | ---------: | ---------- | ------: | --------------: | -------------------: |
| qwen2 7B Q4_K - Medium         |   4.36 GiB |     7.62 B | CPU        |       8 |           pp512 |          2.76 ± 0.00 |
| qwen2 7B Q4_K - Medium         |   4.36 GiB |     7.62 B | CPU        |       8 |           tg128 |          1.79 ± 0.00 |

build: b4c0549a4 (9352)
```


## Command 3 - Interleave All

**Started:** Sat Jun 20 01:04:06 EDT 2026

**Finished:** Sat Jun 20 01:16:48 EDT 2026

**Elapsed:** 762 seconds

**pp512:** ± t/s

**tg128:** ± t/s

### Raw Output

```
| model                          |       size |     params | backend    | threads |            test |                  t/s |
| ------------------------------ | ---------: | ---------: | ---------- | ------: | --------------: | -------------------: |
| qwen2 7B Q4_K - Medium         |   4.36 GiB |     7.62 B | CPU        |      32 |           pp512 |         10.39 ± 0.02 |
| qwen2 7B Q4_K - Medium         |   4.36 GiB |     7.62 B | CPU        |      32 |           tg128 |          1.38 ± 0.01 |

build: b4c0549a4 (9352)
```


# NUMA Node Sweep

| Node | pp512 | tg128 | Elapsed (s) |
|------|-------|-------|-------------|

## NUMA Node 0

**Started:** Sat Jun 20 01:16:48 EDT 2026

**Finished:** Sat Jun 20 01:44:12 EDT 2026

**Elapsed:** 1644 seconds

**pp512:** ± t/s

**tg128:** ± t/s

### Raw Output

```
| model                          |       size |     params | backend    | threads |            test |                  t/s |
| ------------------------------ | ---------: | ---------: | ---------- | ------: | --------------: | -------------------: |
| qwen2 7B Q4_K - Medium         |   4.36 GiB |     7.62 B | CPU        |       8 |           pp512 |          2.76 ± 0.00 |
| qwen2 7B Q4_K - Medium         |   4.36 GiB |     7.62 B | CPU        |       8 |           tg128 |          1.21 ± 0.00 |

build: b4c0549a4 (9352)
```

| 0 | ± | ± | 1644 |

## NUMA Node 1

**Started:** Sat Jun 20 01:44:12 EDT 2026

**Finished:** Sat Jun 20 02:08:49 EDT 2026

**Elapsed:** 1477 seconds

**pp512:** ± t/s

**tg128:** ± t/s

### Raw Output

```
| model                          |       size |     params | backend    | threads |            test |                  t/s |
| ------------------------------ | ---------: | ---------: | ---------- | ------: | --------------: | -------------------: |
| qwen2 7B Q4_K - Medium         |   4.36 GiB |     7.62 B | CPU        |       8 |           pp512 |          2.75 ± 0.00 |
| qwen2 7B Q4_K - Medium         |   4.36 GiB |     7.62 B | CPU        |       8 |           tg128 |          1.79 ± 0.00 |

build: b4c0549a4 (9352)
```

| 1 | ± | ± | 1477 |

## NUMA Node 2

**Started:** Sat Jun 20 02:08:49 EDT 2026

**Finished:** Sat Jun 20 02:36:33 EDT 2026

**Elapsed:** 1664 seconds

**pp512:** ± t/s

**tg128:** ± t/s

### Raw Output

```
| model                          |       size |     params | backend    | threads |            test |                  t/s |
| ------------------------------ | ---------: | ---------: | ---------- | ------: | --------------: | -------------------: |
| qwen2 7B Q4_K - Medium         |   4.36 GiB |     7.62 B | CPU        |       8 |           pp512 |          2.74 ± 0.00 |
| qwen2 7B Q4_K - Medium         |   4.36 GiB |     7.62 B | CPU        |       8 |           tg128 |          1.18 ± 0.00 |

build: b4c0549a4 (9352)
```

| 2 | ± | ± | 1664 |

## NUMA Node 3

**Started:** Sat Jun 20 02:36:33 EDT 2026

**Finished:** Sat Jun 20 03:07:19 EDT 2026

**Elapsed:** 1846 seconds

**pp512:** ± t/s

**tg128:** ± t/s

### Raw Output

```
| model                          |       size |     params | backend    | threads |            test |                  t/s |
| ------------------------------ | ---------: | ---------: | ---------- | ------: | --------------: | -------------------: |
| qwen2 7B Q4_K - Medium         |   4.36 GiB |     7.62 B | CPU        |       8 |           pp512 |          2.66 ± 0.00 |
| qwen2 7B Q4_K - Medium         |   4.36 GiB |     7.62 B | CPU        |       8 |           tg128 |          0.93 ± 0.00 |

build: b4c0549a4 (9352)
```

| 3 | ± | ± | 1846 |

# Thread Scaling Sweep

| Threads | pp512 | tg128 | Elapsed (s) |
|---------|-------|-------|-------------|

## Threads 2

**Started:** Sat Jun 20 03:07:19 EDT 2026

**Finished:** Sat Jun 20 04:19:06 EDT 2026

**Elapsed:** 4307 seconds

**pp512:** ± t/s

**tg128:** ± t/s

### Raw Output

```
| model                          |       size |     params | backend    | threads |            test |                  t/s |
| ------------------------------ | ---------: | ---------: | ---------- | ------: | --------------: | -------------------: |
| qwen2 7B Q4_K - Medium         |   4.36 GiB |     7.62 B | CPU        |       2 |           pp512 |          0.94 ± 0.00 |
| qwen2 7B Q4_K - Medium         |   4.36 GiB |     7.62 B | CPU        |       2 |           tg128 |          0.61 ± 0.00 |

build: b4c0549a4 (9352)
```

| 2 | ± | ± | 4307 |

## Threads 4

**Started:** Sat Jun 20 04:19:06 EDT 2026

**Finished:** Sat Jun 20 04:56:35 EDT 2026

**Elapsed:** 2249 seconds

**pp512:** ± t/s

**tg128:** ± t/s

### Raw Output

```
| model                          |       size |     params | backend    | threads |            test |                  t/s |
| ------------------------------ | ---------: | ---------: | ---------- | ------: | --------------: | -------------------: |
| qwen2 7B Q4_K - Medium         |   4.36 GiB |     7.62 B | CPU        |       4 |           pp512 |          1.89 ± 0.00 |
| qwen2 7B Q4_K - Medium         |   4.36 GiB |     7.62 B | CPU        |       4 |           tg128 |          1.03 ± 0.00 |

build: b4c0549a4 (9352)
```

| 4 | ± | ± | 2249 |

## Threads 6

**Started:** Sat Jun 20 04:56:35 EDT 2026

**Finished:** Sat Jun 20 05:28:56 EDT 2026

**Elapsed:** 1941 seconds

**pp512:** ± t/s

**tg128:** ± t/s

### Raw Output

```
| model                          |       size |     params | backend    | threads |            test |                  t/s |
| ------------------------------ | ---------: | ---------: | ---------- | ------: | --------------: | -------------------: |
| qwen2 7B Q4_K - Medium         |   4.36 GiB |     7.62 B | CPU        |       6 |           pp512 |          2.24 ± 0.00 |
| qwen2 7B Q4_K - Medium         |   4.36 GiB |     7.62 B | CPU        |       6 |           tg128 |          1.13 ± 0.00 |

build: b4c0549a4 (9352)
```

| 6 | ± | ± | 1941 |

## Threads 8

**Started:** Sat Jun 20 05:28:56 EDT 2026

**Finished:** Sat Jun 20 05:56:25 EDT 2026

**Elapsed:** 1649 seconds

**pp512:** ± t/s

**tg128:** ± t/s

### Raw Output

```
| model                          |       size |     params | backend    | threads |            test |                  t/s |
| ------------------------------ | ---------: | ---------: | ---------- | ------: | --------------: | -------------------: |
| qwen2 7B Q4_K - Medium         |   4.36 GiB |     7.62 B | CPU        |       8 |           pp512 |          2.75 ± 0.00 |
| qwen2 7B Q4_K - Medium         |   4.36 GiB |     7.62 B | CPU        |       8 |           tg128 |          1.21 ± 0.00 |

build: b4c0549a4 (9352)
```

| 8 | ± | ± | 1649 |

## Threads 12

**Started:** Sat Jun 20 05:56:25 EDT 2026

**Finished:** Sat Jun 20 06:24:37 EDT 2026

**Elapsed:** 1692 seconds

**pp512:** ± t/s

**tg128:** ± t/s

### Raw Output

```
| model                          |       size |     params | backend    | threads |            test |                  t/s |
| ------------------------------ | ---------: | ---------: | ---------- | ------: | --------------: | -------------------: |
| qwen2 7B Q4_K - Medium         |   4.36 GiB |     7.62 B | CPU        |      12 |           pp512 |          2.74 ± 0.00 |
| qwen2 7B Q4_K - Medium         |   4.36 GiB |     7.62 B | CPU        |      12 |           tg128 |          1.12 ± 0.00 |

build: b4c0549a4 (9352)
```

| 12 | ± | ± | 1692 |

## Threads 16

**Started:** Sat Jun 20 06:24:37 EDT 2026

**Finished:** Sat Jun 20 06:52:39 EDT 2026

**Elapsed:** 1682 seconds

**pp512:** ± t/s

**tg128:** ± t/s

### Raw Output

```
| model                          |       size |     params | backend    | threads |            test |                  t/s |
| ------------------------------ | ---------: | ---------: | ---------- | ------: | --------------: | -------------------: |
| qwen2 7B Q4_K - Medium         |   4.36 GiB |     7.62 B | CPU        |      16 |           pp512 |          2.74 ± 0.00 |
| qwen2 7B Q4_K - Medium         |   4.36 GiB |     7.62 B | CPU        |      16 |           tg128 |          1.15 ± 0.00 |

build: b4c0549a4 (9352)
```

| 16 | ± | ± | 1682 |

## Threads 24

**Started:** Sat Jun 20 06:52:39 EDT 2026

**Finished:** Sat Jun 20 07:21:04 EDT 2026

**Elapsed:** 1705 seconds

**pp512:** ± t/s

**tg128:** ± t/s

### Raw Output

```
| model                          |       size |     params | backend    | threads |            test |                  t/s |
| ------------------------------ | ---------: | ---------: | ---------- | ------: | --------------: | -------------------: |
| qwen2 7B Q4_K - Medium         |   4.36 GiB |     7.62 B | CPU        |      24 |           pp512 |          2.72 ± 0.00 |
| qwen2 7B Q4_K - Medium         |   4.36 GiB |     7.62 B | CPU        |      24 |           tg128 |          1.12 ± 0.00 |

build: b4c0549a4 (9352)
```

| 24 | ± | ± | 1705 |

## Threads 32

**Started:** Sat Jun 20 07:21:04 EDT 2026

**Finished:** Sat Jun 20 07:49:39 EDT 2026

**Elapsed:** 1715 seconds

**pp512:** ± t/s

**tg128:** ± t/s

### Raw Output

```
| model                          |       size |     params | backend    | threads |            test |                  t/s |
| ------------------------------ | ---------: | ---------: | ---------- | ------: | --------------: | -------------------: |
| qwen2 7B Q4_K - Medium         |   4.36 GiB |     7.62 B | CPU        |      32 |           pp512 |          2.73 ± 0.00 |
| qwen2 7B Q4_K - Medium         |   4.36 GiB |     7.62 B | CPU        |      32 |           tg128 |          1.09 ± 0.00 |

build: b4c0549a4 (9352)
```

| 32 | ± | ± | 1715 |

# Notes

- NUMA sweep uses node-local memory via --membind.
- Thread sweep uses NUMA node 0 only.
- Compare tg128 for real-world inference performance.
- Compare pp512 for prompt ingestion performance.