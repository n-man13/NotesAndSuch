# Task 1: Develop a Five-Stage Pipelined MIPS Processor
Implement a five-stage pipeline following the canonical MIPS design with the following stages:
1. Instruction Fetch (IF)
2. Instruction Decode / Register Fetch (ID)
3. Execute (EX)
4. Memory Access (MEM)
5. Write Back (WB)

You may reuse and adapt your modules from the single-cycle processor (ALU, Control Unit, Register File, Memory, etc.), but modify the datapath and control logic to support pipelined execution.

## Implementation

### Pipeline Design Overview
I started with the standard 5-stage pipeline design we covered in class (shown below) as my foundation. This diagram was really helpful for understanding the basic datapath and where pipeline registers needed to go.

![alt text](./images/PipelinedProcessor.png)

However, I made several modifications as I worked through the implementation:

**Key Additions:**
- **JAL/JR Support:** Added logic to detect jump instructions in the ID stage and calculate jump targets. JAL writes the return address to $ra, while JR reads from a register to determine where to jump.
- **Shift Instruction Handling:** SLL/SRL needed special treatment since the shift amount comes from the instruction's shamt field (bits 10:6) rather than from a register. I passed this through the immediate field and swapped the ALU inputs for shift operations.
- **Branch Logic:** Implemented branch decision making in the EX stage where the ALU result is checked against zero for BEQ instructions. The branch target is calculated as PC+1+offset.

## Pipeline Hazard Handling:
- **Forwarding Unit:** Detects when data is needed from EX/MEM or MEM/WB stages and forwards it to avoid unnecessary stalls
- **Hazard Detection Unit:** Catches load-use hazards where an instruction immediately uses data being loaded from memory, inserting a 1-cycle stall
- **Pipeline Flushing:** When branches, jumps (JAL), or jump-registers (JR) are taken, the IF/ID register is flushed to prevent wrong instructions from executing


## Hazard Detection Comparison

### Pipeline Behavior
- **With hazard detection:** The hazard unit detects when an instruction needs data that hasn't been written back yet and inserts stalls to wait for it
- **Without hazard detection:** Instructions just keep going without waiting, even if they need data from a previous instruction

### Handling Data Hazards
- **With hazard detection:** When a read after write hazard is detected, the pipeline inserts a bubble to give the data time to become available
- **Without hazard detection:** Read after write hazards aren't caught, so instructions end up reading old/stale values from registers

### Performance Impact
- **With hazard detection:** Slower because of all the stall cycles inserted between dependent instructions
- **Without hazard detection:** Runs faster since there are no stalls, but the results are wrong

### Test 4 Results

| Register | With Hazard Detection | Without Hazard Detection |
|----------|----------------------|--------------------------|
| $t0 | 8 | 8 |
| $t1 | 15 | 15 |
| $t2 | 15 | **0** |
| $t3 | 30 | **15** |
| $t4 | 15 | **0** |
| $s0 | 45 | **15** |
| Mem[8] | 15 | **0** |

As you can see, when hazard detection is enabled, all register values match what we expect from the program. Without hazard detection, $t2, $t3, $t4, $s0, and Mem[8] end up with incorrect values because instructions read registers before the correct data was written to them.
