# Summer Server Migration & Infrastructure Plan

This document outlines the step-by-step procedures for consolidating hardware resources into the HP ProLiant DL385p Gen8 (AI Server/SSH Portal) and repurposing the Dell PowerEdge R710 (Infrastructure/Utility Server).

---

## Phase 1: Hardware Consolidated Memory Swap (Revised for Mixed Speeds)

### Hardware Audit
* **Samsung Modules (4x):** 8GB 1Rx4 PC3-12800R (1600MHz, Single Rank)
* **Hynix Modules (16x):** 8GB 2Rx4 PC3-10600R (1333MHz, Dual Rank)

### Goal
Deploy a 128GB or 160GB uniform memory architecture inside the HP Gen8. All channels will automatically clock down to 1333MHz to maintain stable locksteps across the bus layout.

### Execution Steps (Pure Symmetrical 128GB Configuration)
1. **Preparation:** Power down both systems, pull cables, and place them on an anti-static mat. Remove both top panels.
2. **Clear the HP Gen8:** Strip the original lopsided modules entirely from the HP board. 
3. **Isolate the Hynix Array:** Extract the 16 matching Hynix 8GB modules from the Dell R710. Set the 4 Samsung modules aside for alternative projects or auxiliary channels.
4. **Populate the Motherboard (White Slots First):**
   * Locate the 24 DIMM slots on the HP board. 
   * Install **8 Hynix modules into CPU 1's designated banks**, making sure to occupy the white slots first (e.g., Ch 1 Slot A, Ch 2 Slot B) according to the motherboard engraving.
   * Mirror this configuration precisely by installing the remaining **8 Hynix modules into CPU 2's designated slots**.
5. **Dell R710 Re-population:** * Take the 4 remaining Samsung 1600MHz sticks and install them cleanly into the Dell R710's primary slots (`A1, A2` and `B1, B2`) to give the secondary server a perfectly uniform 32GB baseline.


---

## Phase 2: AI Server Configuration (HP DL385p Gen8 Beta)

### 1. Base OS & Optimization
* **OS:** Install a headless distribution of **Ubuntu Server 24.04 LTS** or **Debian 12** onto the front drive array.
* **CPU Inference Optimization:** Because the AMD Opteron 6274 processors natively support **AVX** but lack newer AVX2 instructions, compiling your AI engine from source is necessary to ensure the binaries target your hardware's exact vector widths.
  ```bash
  # Install build tools and NUMA utilities
  sudo apt update && sudo apt install build-essential cmake git numactl -y

  # Clone and compile llama.cpp locally
  git clone [https://github.com/ggerganov/llama.cpp](https://github.com/ggerganov/llama.cpp)
  cd llama.cpp
  make -j$(nproc)
