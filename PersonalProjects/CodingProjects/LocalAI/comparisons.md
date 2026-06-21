# Benchmarking Llama.cpp with various configurations
Testing how the server operates with differing commands. 
## Command 1: (Generic Bench CPU)
./build/bin/llama-bench  \
  -m ./models/Qwen2.5-7B-Instruct-Q4_K_M.gguf \
  -t 8 \
  -ngl 0 \
  -p 512 \
  -n 128
| model                          |       size |     params | backend    | threads |            test |                  t/s |
| ------------------------------ | ---------: | ---------: | ---------- | ------: | --------------: | -------------------: |
| qwen2 7B Q4_K - Medium         |   4.36 GiB |     7.62 B | CPU        |       8 |           pp512 |          3.71 ± 0.00 |
| qwen2 7B Q4_K - Medium         |   4.36 GiB |     7.62 B | CPU        |       8 |           tg128 |          1.72 ± 0.00 |

## Command 2: (NUMA Bound)
numactl --cpunodebind=1 --preferred=1 ./build/bin/llama-bench \
  -m ./models/Qwen2.5-7B-Instruct-Q4_K_M.gguf \
  -t 8 \
  -ngl 0 \
  -p 512 \
  -n 128
| model                          |       size |     params | backend    | threads |            test |                  t/s |
| ------------------------------ | ---------: | ---------: | ---------- | ------: | --------------: | -------------------: |
| qwen2 7B Q4_K - Medium         |   4.36 GiB |     7.62 B | CPU        |       8 |           pp512 |          2.75 ± 0.00 |
| qwen2 7B Q4_K - Medium         |   4.36 GiB |     7.62 B | CPU        |       8 |           tg128 |          1.78 ± 0.00 |

## Command 3: (Full CPU Interleave)
numactl --interleave=all ./build/bin/llama-bench \
  -m ./models/Qwen2.5-7B-Instruct-Q4_K_M.gguf \
  -t 32 \
  -ngl 0 \
  -p 512 \
  -n 128
| model                          |       size |     params | backend    | threads |            test |                  t/s |
| ------------------------------ | ---------: | ---------: | ---------- | ------: | --------------: | -------------------: |
| qwen2 7B Q4_K - Medium         |   4.36 GiB |     7.62 B | CPU        |      32 |           pp512 |         10.38 ± 0.00 |
| qwen2 7B Q4_K - Medium         |   4.36 GiB |     7.62 B | CPU        |      32 |           tg128 |          1.44 ± 0.01 |

## Command 3.5:
numactl --cpunodebind=0 --membind=0 ./build/bin/llama-bench \
  -m ./models/Qwen2.5-7B-Instruct-Q4_K_M.gguf \
  -t 4,8,12,16 \
  -ngl 0 \
  -p 512 \
  -n 128

## Command 4: (Full GPU)
./build/bin/llama-bench \
  -m ./models/Qwen2.5-7B-Instruct-Q4_K_M.gguf \
  -ngl 99 \
  -p 512 \
  -n 128