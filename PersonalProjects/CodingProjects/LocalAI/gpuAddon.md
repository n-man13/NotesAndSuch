# NVIDIA Tesla P4 Integration Guide (AlmaLinux)

This document outlines the procedure to transition from CPU-only inference to CUDA-accelerated inference using a Tesla P4.

## 1. System Preparation (Kernel & Drivers)
As an OS specialist, note that the NVIDIA driver functions as a proprietary kernel module (`nvidia.ko`). In AlmaLinux, we use the `elrepo` or NVIDIA repositories to manage these.

```bash
# Install kernel headers and development tools matching your current running kernel
sudo dnf install kernel-devel-$(uname -r) kernel-headers-$(uname -r) gcc-c++

# Add NVIDIA Repository
sudo dnf config-manager --add-repo http://developer.download.nvidia.com/compute/cuda/repos/rhel8/x86_64/cuda-rhel8.repo

# Install NVIDIA Driver and CUDA Toolkit
# This installs the UVM (Unified Memory Management) and the NVCC compiler.
sudo dnf module install nvidia-driver:latest-dkms
sudo dnf install cuda-toolkit
```
**Why:** The DKMS (Dynamic Kernel Module Support) version is preferred. It ensures that when you update your kernel, the NVIDIA module is automatically recompiled, preventing a mismatch between the syscall interface and the module.

## 2. Building llama.cpp with CMake
The legacy `make` is being deprecated in favor of CMake for better dependency tracking and support for modern build systems like Ninja.

```bash
cd ~/llama.cpp
rm -rf build
mkdir build && cd build

# Configure the build
# -DGGML_CUDA=ON: Enables the CUDA backend.
# -DCMAKE_CUDA_ARCHITECTURES=61: Targets the Pascal architecture (Tesla P4).
cmake .. -DGGML_CUDA=ON -DCMAKE_CUDA_ARCHITECTURES=61

# Build the project
cmake --build . --config Release -j $(nproc)
```

### How it Works (OS/Arch Perspective):
*   **SASS/PTX Generation:** By specifying architecture `61`, `nvcc` generates SASS (Streaming Assembler) code specifically for the Pascal SM (Streaming Multiprocessor) 6.1. Without this, the binary might rely on PTX (Parallel Thread Execution) JIT compilation at runtime, which increases first-token latency.
*   **Memory Mapping:** The build links against `libcuda.so` and `libcudart.so`. At runtime, `llama-server` will use `cudaMalloc` to allocate weights into the Tesla P4's VRAM.

## 3. Optimizing for the Tesla P4
The Tesla P4 is an 8GB card. To maximize throughput:

1.  **NGL (Number of GPU Layers):** You must specify how many layers to offload. A 7B model (Q4_K_M) fits entirely (32-33 layers) within 8GB.
2.  **Unified Memory:** Since your Opterons and the P4 don't share a coherent interconnect (it's PCIe Gen3), minimize host-to-device (H2D) transfers by pinning as much as possible in VRAM.

## 4. Troubleshooting
*   **Persistence Mode:** Ensure persistence mode is on to keep the driver loaded and prevent the 2-second initialization lag on every request.
    ```bash
    sudo nvidia-smi -pm 1
    ```
*   **Cooling:** The P4 is a passive card. If `nvidia-smi` shows temperatures climbing rapidly during prefill, the OS will signal a thermal throttle, dropping the clock speed significantly. Ensure your server chassis provides sufficient CFM over the PCIe slots.

## 5. Verification
Check that the server detects the CUDA management interface:
```bash
./bin/llama-server --version | grep CUDA
```
Look for `GGML_CUDA` in the output.

---
