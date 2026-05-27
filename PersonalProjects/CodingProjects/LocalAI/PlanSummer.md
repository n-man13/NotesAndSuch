# Summer Server Migration & Infrastructure Plan

This document outlines the step-by-step procedures for consolidating hardware resources into the HP ProLiant DL385p Gen8 (AI Server/SSH Portal) and repurposing the Dell PowerEdge R710 (Infrastructure/Utility Server).

## Project Purpose & Architectural Vision
The objective of this project is to consolidate underutilized enterprise server hardware into an efficient, dual-node local laboratory environment over the Summer 2026 break.

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

## Phase 2: AI Server Implementation (HP ProLiant DL385p Gen8)

### Step 1: Headless OS Initialization
* Install a minimal, headless instance of **AlmaLinux 9** onto the front drive array. 
* Avoid installing graphical user interface (GUI) groups to preserve maximum RAM and CPU overhead for the model context windows.

### Step 2: Toolchain Optimization & `llama.cpp` Compilation
Because the dual AMD Opteron 6274 processors natively support **AVX** but lack newer AVX2 instructions, compiling the inference software from source allows the host compiler to target your specific register widths precisely.

1. Install essential build tools, compilation runtimes, and NUMA policy hooks:
   ```bash
   sudo dnf groupinstall "Development Tools" -y
   sudo dnf install cmake numactl epel-release -y

2. Clone the inference engine and compile it locally
     # Clone and compile llama.cpp locally
  git clone [https://github.com/ggerganov/llama.cpp](https://github.com/ggerganov/llama.cpp)
  cd llama.cpp
  make -j$(nproc)

### Step 3: Dual Port Networking and Remote Workspace Access
To ensure secure access from the university campus without exposing raw network endpoints to the public internet, a mesh VPN framework (such as Tailscale) will be mapped to manage traffic routing.

#### Network Service Mapping

    Port 22 (SSH Admin Portal): Bound exclusively to the internal VPN tunnel interface. Password-based authentication must be disabled in /etc/ssh/sshd_config (PasswordAuthentication no), enforcing strict cryptographic key-based authorization.

    Port 11434 (VS Code IDE Backend Integration): Exposed to allow your laptop's Continue.dev extension to query the local LLM runtime engine directly over the secure tunnel.

#### Exposing the AI API Engine (Ollama Configuration Example)

If using Ollama for service management, override the default local-only binding by modifying its systemd service configuration:
  sudo systemctl edit ollama.service

Append the network binding definition:
Ini, TOML

[Service]
Environment="OLLAMA_HOST=0.0.0.0:11434"

Reload systemd and cycle the process daemon:
Bash

sudo systemctl daemon-reload
sudo systemctl restart ollama