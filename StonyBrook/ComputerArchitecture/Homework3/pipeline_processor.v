`timescale 1ns / 1ps

// pipeline_processor.v
// Skeleton for converting the single-cycle processor to a 5-stage pipelined processor.
// Purpose: provide clear pipeline registers, module boundaries, and stubs for forwarding/hazard units.
// Fill in TODOs to complete the implementation.

module pipelined_processor(
    input wire clk,
    input wire reset,
    input wire [31:0] initial_pc,
    output wire done
);

    // ------------------------------------------------------------------
    // Basic PC / IF outputs
    // ------------------------------------------------------------------
    reg [31:0] pc;
    wire [31:0] instr_if;      // instruction read from instruction memory (IF)
    wire [31:0] next_pc_if;   // pc + 1 computed in IF

    // Hook to existing programMem (combinational read)
    programMem prog_mem(.pc(pc), .instruction(instr_if));

    // compute next_pc_if in IF (word-addressed PC like your existing design)
    // next_pc_if represents the PC of the following instruction (pc + 1)
    assign next_pc_if = pc + 1;

    /* ------------------------------------------------------------------
     * IF/ID pipeline register
     * ------------------------------------------------------------------
     * ifid_next_pc_out carries the "next PC" value produced in IF (next_pc_if).
     * This value is useful for jump-and-link (JAL) and other PC-relative
     * operations.
     */
    wire [31:0] ifid_instr_out;
    wire [31:0] ifid_next_pc_out;

    IF_ID_reg IFID(
        .clk(clk),
        .reset(reset),
        .stall(stall),         // TODO: connect to hazard unit
        .flush(flush_ifid),         // TODO: assert on branch taken
        .instr_in(instr_if),
        .next_pc_in(next_pc_if),
        .instr_out(ifid_instr_out),
        .next_pc_out(ifid_next_pc_out)
    );

    // detect HALT as soon as instruction memory outputs it (IF stage)
    wire halt_if = (instr_if[31:26] == 6'b111111);


    /* ------------------------------------------------------------------
     * ID stage: decode, register file read, control generation
     * ------------------------------------------------------------------
     * Notes:
     * - Register file reads occur here (combinational/asynchronous reads).
     * - The Control unit should generate the control signals that travel in
     *   the ID/EX pipeline register. Fill in the Control unit and hook the
     *   signals into the ID_EX_reg instance below.
     */
    // decode fields
    wire [5:0] id_opcode = ifid_instr_out[31:26];
    wire [5:0] id_funct  = ifid_instr_out[5:0];
    wire [4:0] id_rs     = ifid_instr_out[25:21];
    wire [4:0] id_rt     = ifid_instr_out[20:16];
    wire [4:0] id_rd     = ifid_instr_out[15:11];
    wire [15:0] id_imm   = ifid_instr_out[15:0];

    wire RegWrite_id;    // write enable to regfile (to be stored in ID/EX)
    wire MemRead_id;     // load
    wire MemWrite_id;    // store
    wire MemToReg_id;    // choose mem data for WB
    wire ALUSrc_id;      // ALU second operand is immediate
    wire RegDst_id;      // choose rd (R-type) vs rt (I-type) as destination
    wire Branch_id;      // branch signal (BEQ/BNE)
    wire [3:0] ALUOp_id; // ALU operation selection (4-bit to match ALU)
    wire ExtOp_id; // ExtOp: 0 = sign-extend (default), 1 = zero-extend (for ANDI/ORI)
    
    // Hazard and flush control signals
    wire stall;          // from hazard detection unit
    wire flush_ifid;     // asserted on branch-taken

    // instantiate control unit
    control_unit CU(
        .opcode(id_opcode),
        .funct(id_funct),
        .RegWrite(RegWrite_id),
        .MemRead(MemRead_id),
        .MemWrite(MemWrite_id),
        .MemToReg(MemToReg_id),
        .ALUSrc(ALUSrc_id),
        .RegDst(RegDst_id),
        .Branch(Branch_id),
        .ALUOp(ALUOp_id),
        .ExtOp(ExtOp_id)
    );

    // Register file (reuse the existing one) - asynchronous read
    wire [31:0] reg_read1_id;
    wire [31:0] reg_read2_id;
    wire [31:0] writeback_data_wb;
    wire [4:0] writeback_reg_wb;
    wire writeback_enable_wb;

    // Connect register file: writes will come from WB stage
    registerFile regFile(
        .clk(clk),
        .writeEnable(writeback_enable_wb),
        .writeReg(writeback_reg_wb),
        .writeData(writeback_data_wb),
        .readReg1(id_rs),
        .readReg2(id_rt),
        .readData1(reg_read1_id),
        .readData2(reg_read2_id)
    );

    // immediate ext (use ExtOp from control unit: 0=sign-extend, 1=zero-extend)
    wire [31:0] imm_ext_id = ExtOp_id ? {16'b0, id_imm} : {{16{id_imm[15]}}, id_imm};

    /* ID/EX pipeline register (capture decoded values + control signals)
     * Many signals will be captured here; we provide placeholders
     */
    wire [31:0] idex_next_pc_out;
    wire [31:0] idex_regdata1_out;
    wire [31:0] idex_regdata2_out;
    wire [31:0] idex_imm_out;
    wire [4:0]  idex_rs_out;
    wire [4:0]  idex_rt_out;
    wire [4:0]  idex_rd_out;

    // control signals in pipeline (ID/EX)
    wire idex_RegWrite;
    wire idex_MemRead;
    wire idex_MemWrite;
    wire idex_MemToReg;
    wire idex_ALUSrc;
    wire idex_RegDst;
    wire idex_Branch;
    wire [3:0] idex_ALUOp;
    wire idex_Halt_out;

    // indicate HALT in ID (derived from IF/ID instruction)
    wire halt_id = (ifid_instr_out[31:26] == 6'b111111);

    ID_EX_reg IDEX(
        .clk(clk),
        .reset(reset),
        .stall(stall), // TODO: connect hazard detection stall
        // inputs
        .next_pc_in(ifid_next_pc_out),
        .regdata1_in(reg_read1_id),
        .regdata2_in(reg_read2_id),
        .imm_in(imm_ext_id),
        .rs_in(id_rs),
        .rt_in(id_rt),
        .rd_in(id_rd),
        // control inputs (TODO: wire these from Control unit)
        .RegWrite_in(RegWrite_id),
        .MemRead_in(MemRead_id),
        .MemWrite_in(MemWrite_id),
        .MemToReg_in(MemToReg_id),
        .RegDst_in(RegDst_id),
        .Branch_in(Branch_id),
        .ALUSrc_in(ALUSrc_id),
        .ALUOp_in(ALUOp_id),
    .Halt_in(halt_id),
    // outputs
        .next_pc_out(idex_next_pc_out),
        .regdata1_out(idex_regdata1_out),
        .regdata2_out(idex_regdata2_out),
        .imm_out(idex_imm_out),
        .rs_out(idex_rs_out),
        .rt_out(idex_rt_out),
        .rd_out(idex_rd_out),
        .RegWrite_out(idex_RegWrite),
        .MemRead_out(idex_MemRead),
        .MemWrite_out(idex_MemWrite),
        .MemToReg_out(idex_MemToReg),
        .RegDst_out(idex_RegDst),
        .Branch_out(idex_Branch),
        .ALUSrc_out(idex_ALUSrc),
        .ALUOp_out(idex_ALUOp)
        , .Halt_out(idex_Halt_out)
    );

    // Decide the destination register for EX stage (RegDst control)
    wire [4:0] idex_write_reg = idex_RegDst ? idex_rd_out : idex_rt_out;

    // ------------------------------------------------------------------
    // EX stage: ALU, branch target calculation, forwarding muxes
    // ------------------------------------------------------------------
    // Notes:
    // - Forwarding muxes should select operands from ID/EX, EX/MEM, or MEM/WB
    //   as determined by the forwarding_unit outputs.  For now the ALU uses
    //   the direct ID/EX register values; replace these with muxed signals.
    // ALU inputs with forwarding (placeholder signals)
    wire [31:0] alu_input_A;
    wire [31:0] alu_input_B_pre;
    wire [31:0] alu_input_B = idex_ALUSrc ? idex_imm_out : alu_input_B_pre;
    wire [31:0] alu_result_ex;

    // Instantiate forwarding unit and wire alu_input_A, alu_input_B_pre
    // Forwarding selects operands from ID/EX, EX/MEM, or MEM/WB to avoid stalls
    wire [1:0] ForwardA;
    wire [1:0] ForwardB;

    forwarding_unit FU(
        .EX_MEM_RegWrite(exmem_RegWrite_out),
        .EX_MEM_Rd(exmem_write_reg_out),
        .MEM_WB_RegWrite(memwb_RegWrite_out),
        .MEM_WB_Rd(memwb_writereg_out),
        .ID_EX_Rs(idex_rs_out),
        .ID_EX_Rt(idex_rt_out),
        .ForwardA(ForwardA),
        .ForwardB(ForwardB)
    );

    // Hazard detection unit for load-use hazards
    hazard_unit HZ(
        .ID_EX_MemRead(idex_MemRead),
        .ID_EX_Rt(idex_rt_out),
        .IF_ID_Rs(ifid_instr_out[25:21]),
        .IF_ID_Rt(ifid_instr_out[20:16]),
        .stall(stall)
    );

    // Values to forward from MEM/WB (choose mem-read or ALU result depending on MemToReg)
    wire [31:0] forward_from_memwb = memwb_MemToReg_out ? memwb_memread_out : memwb_aluout_out;

    // Mux the forwarded values into ALU inputs
    reg [31:0] alu_input_A_reg;
    reg [31:0] alu_input_Bpre_reg;
    always @(*) begin
        // ForwardA: 00 = ID/EX.regdata1, 10 = EX/MEM.alu_result, 01 = MEM/WB
        case (ForwardA)
            2'b10: alu_input_A_reg = exmem_alu_result_out;
            2'b01: alu_input_A_reg = forward_from_memwb;
            default: alu_input_A_reg = idex_regdata1_out;
        endcase

        // ForwardB: 00 = ID/EX.regdata2, 10 = EX/MEM.alu_result, 01 = MEM/WB
        case (ForwardB)
            2'b10: alu_input_Bpre_reg = exmem_alu_result_out;
            2'b01: alu_input_Bpre_reg = forward_from_memwb;
            default: alu_input_Bpre_reg = idex_regdata2_out;
        endcase
    end

    assign alu_input_A = alu_input_A_reg;
    assign alu_input_B_pre = alu_input_Bpre_reg;

    // Use existing ALU module
    alu alu_ex(.A(alu_input_A), .B(alu_input_B), .ALU_Sel(idex_ALUOp), .ALU_Out(alu_result_ex));

    // EX/MEM pipeline register
    wire [31:0] exmem_alu_result_out;
    wire [31:0] exmem_write_data_out;
    wire [4:0]  exmem_write_reg_out;
    wire exmem_RegWrite_out;
    wire exmem_MemRead_out;
    wire exmem_MemWrite_out;
    wire exmem_MemToReg_out;
    wire exmem_Halt_out;

    EX_MEM_reg EXMEM(
        .clk(clk),
        .reset(reset),
        .Halt_in(idex_Halt_out),
        .alu_result_in(alu_result_ex),
        .write_data_in(idex_regdata2_out),
        .write_reg_in(idex_write_reg),
        .RegWrite_in(idex_RegWrite),
        .MemRead_in(idex_MemRead),
        .MemWrite_in(idex_MemWrite),
        .MemToReg_in(idex_MemToReg),
        .alu_result_out(exmem_alu_result_out),
        .write_data_out(exmem_write_data_out),
        .write_reg_out(exmem_write_reg_out),
        .RegWrite_out(exmem_RegWrite_out),
        .MemRead_out(exmem_MemRead_out),
        .MemWrite_out(exmem_MemWrite_out),
        .MemToReg_out(exmem_MemToReg_out)
        , .Halt_out(exmem_Halt_out)
    );

    // ------------------------------------------------------------------
    // MEM stage: data memory access
    // ------------------------------------------------------------------
    wire [31:0] mem_read_data_mem;

    // Hook to existing memoryFile (synchronous write, combinational read)
    memoryFile data_mem(
        .clk(clk),
        .addr(exmem_alu_result_out),
        .writeEnable(exmem_MemWrite_out),
        .writeData(exmem_write_data_out),
        .readData(mem_read_data_mem)
    );

    // MEM/WB pipeline register
    wire [31:0] memwb_memread_out;
    wire [31:0] memwb_aluout_out;
    wire [4:0] memwb_writereg_out;
    wire memwb_RegWrite_out;
    wire memwb_MemToReg_out;
    wire memwb_Halt_out;

    MEM_WB_reg MEMWB(
        .clk(clk),
        .reset(reset),
        .Halt_in(exmem_Halt_out),
        .mem_read_in(mem_read_data_mem),
        .alu_result_in(exmem_alu_result_out),
        .write_reg_in(exmem_write_reg_out),
        .RegWrite_in(exmem_RegWrite_out),
        .MemToReg_in(exmem_MemToReg_out),
        .mem_read_out(memwb_memread_out),
        .alu_result_out(memwb_aluout_out),
        .write_reg_out(memwb_writereg_out),
        .RegWrite_out(memwb_RegWrite_out),
        .MemToReg_out(memwb_MemToReg_out)
        , .Halt_out(memwb_Halt_out)
    );

    // ------------------------------------------------------------------
    // WB stage: writeback selection
    // ------------------------------------------------------------------
    // choose between memory data and alu result
    assign writeback_data_wb = memwb_MemToReg_out ? memwb_memread_out : memwb_aluout_out;
    assign writeback_reg_wb  = memwb_writereg_out;
    assign writeback_enable_wb = memwb_RegWrite_out;

    // ------------------------------------------------------------------
    // PC update logic (handles stall and branch/flush)
    // ------------------------------------------------------------------
    // TODO: branch decision should be computed in EX and provided here
    wire branch_taken_ex = 1'b0;       // TODO: from EX stage
    wire [31:0] branch_target_ex = 32'b0; // TODO: from EX stage
    wire stall = 1'b0; // TODO: from hazard detection unit
    wire flush_ifid = 1'b0; // TODO: assert when branch taken

    // expose done when HALT reaches MEM/WB (pipeline drained / HALT at last stage)
    assign done = memwb_Halt_out;

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            pc <= initial_pc;
        end else begin
            if (stall || halt_if) begin
                pc <= pc; // freeze on hazard stall or HALT fetched
            end else if (branch_taken_ex) begin
                pc <= branch_target_ex;
            end else begin
                pc <= pc + 1; // basic increment
            end
        end
    end

endmodule


module alu ( input [31:0] A, input [31:0] B, input [3:0] ALU_Sel, output reg [31:0] ALU_Out );
    parameter ADD = 4'b0000; // 32
    parameter MUL = 4'b0001; // 24
    parameter AND = 4'b0010; // 36
    parameter OR  = 4'b0011; // 37
    parameter XOR = 4'b0100; // 38
    parameter NOR = 4'b0101; // 39
    parameter SLL = 4'b0110; // 0
    parameter SRL = 4'b0111; // 2
    parameter SUB = 4'b1000; // 34
    parameter SLT = 4'b1010; // 42
    always @(*) begin
        case (ALU_Sel)
            4'b0000: ALU_Out = A + B;          // Addition
            4'b0001: ALU_Out = (A * B);        // Multiplication
            4'b0010: ALU_Out = A & B;          // Bitwise AND
            4'b0011: ALU_Out = A | B;          // Bitwise OR
            4'b0100: ALU_Out = A ^ B;          // Bitwise XOR
            4'b0101: ALU_Out = ~(A | B);       // Bitwise NOR
            4'b0110: ALU_Out = A << B[4:0];    // Logical left shift
            4'b0111: ALU_Out = A >> B[4:0];    // Logical right shift
            4'b1000: ALU_Out = A - B;         // Subtraction
            4'b1010: ALU_Out = (A < B) ? 32'b1 : 32'b0; // SLT
            4'b1001: ALU_Out = (A == B) ? 32'b1 : 32'b0; // Equality check
            default: ALU_Out = 32'b0;        // Default case set to zero
        endcase
    end
endmodule
// Synchronous register file: async read, sync write on posedge clk
module registerFile (
    input  wire        clk,
    input  wire        writeEnable,
    input  wire [4:0]  writeReg,
    input  wire [31:0] writeData,
    input  wire [4:0]  readReg1,
    input  wire [4:0]  readReg2,
    output wire [31:0] readData1,
    output wire [31:0] readData2
);
    reg [31:0] registers [0:31];
    integer i;

    initial begin
        for (i = 0; i < 32; i = i + 1)
            registers[i] = 32'd0;
    end

    // synchronous write on clk
    always @(posedge clk) begin
        if (writeEnable && (writeReg != 5'd0))
            registers[writeReg] <= writeData;
        registers[0] <= 32'd0; // ensure $zero stays zero
    end

    // asynchronous read
    assign readData1 = registers[readReg1];
    assign readData2 = registers[readReg2];

endmodule


// Simple data memory: synchronous write on clk, combinational read
module memoryFile (
    input  wire        clk,
    input  wire [31:0] addr,        // byte address expected, but we use word-aligned indexing
    input  wire        writeEnable,
    input  wire [31:0] writeData,
    output wire [31:0] readData
);
    reg [31:0] mem [0:255];
    integer i;
    initial begin
        for (i=0; i<256; i=i+1) mem[i] = 32'd0;
    end

    // synchronous write
    always @(posedge clk) begin
        if (writeEnable)
            mem[addr[7:0] >> 2] <= writeData; // word index: assume addr aligned
    end

    // combinational read
    assign readData = mem[addr[7:0] >> 2];
endmodule

module programMem ( input [31:0] pc, output [31:0] instruction);
    reg [31:0] instructions [127:0];
    reg [31:0] instruction_reg;
    /* Test 1
        addi $t0, $0, 4
        addi $t1, $0, 15
        addi $t2, $0, 100
        addi $s1, $0, 8
        sw $t0, 0($s1)
        sw $t1, 8($s1)
        sw $t2, -4($s1)
        halt
    */
    /* Test 2
        addi $t0, $0, 8
        addi $t1, $0, 15
        sw $t1, 0($t0)
        add $t2, $t1, $t0
        sub $t3, $t1, $t0
        mul $s1, $t2, $t3
        addi $t0, $t0, 4
    lw $s2, -4($t0)
        sub $s2, $s1, $s2
        sll $s2, $s1, 2
        sw $s2, 0($t0)
        halt
    */
    /* Test 3
        addi $a0, $0, 6
        jal factorial
        sw $v0, 0($0)
        halt
factorial: addi $sp, $sp, -8
        sw $a0, 4($sp)
        sw $ra, 0($sp)
        addi $t0, $0, 2
        slt $t0, $a0, $t0
        beq $t0, $0, else
        addi $v0, $0, 1
        addi $sp, $sp, 8
        jr $ra
    else: addi $a0, $a0, -1
        jal factorial
        lw $ra, 0($sp)
        lw $a0, 4($sp)
        addi $sp, $sp, 8
        mul $v0, $a0, $v0
        jr $ra
    */
    /* Test 4
        addi $t0, $0, 8
        addi $t1, $0, 15
        sw $t1, 0($t0)
        lw $t2, 0($t0)
        add $t3, $t1, $t2
        beq $t3, $t2, label
        sub $t4, $t3, $t1
        label: add $s0, $t4, $t3
        halt
    */
    /* Test 5
        addi $t0, $0, 4
        addi $t1, $0, 5
        add $t2, $t0, $t1
        sub $t3, $t2, $t1
        and $t4, $t3, $t2
        or $t5, $t4, $t0
        sw $t5, 0($t0)
        halt
    */
    assign instruction = instruction_reg;

    initial begin
        instruction_reg = 0;
         // Test 1
        instructions[0] = 32'b001000_00000_01000_0000_0000_0000_0100; // ADDI
        instructions[1] = 32'b001000_00000_01001_0000_0000_0000_1111; // ADDI
        instructions[2] = 32'b001000_00000_01010_0000_0000_0001_0100; // ADDI
        instructions[3] = 32'b001000_00000_10001_0000_0000_0000_1000; // ADDI
        instructions[4] = 32'b101011_10001_01000_0000_0000_0000_0000; // SW
        instructions[5] = 32'b101011_10001_01001_0000_0000_0000_1000; // SW
        instructions[6] = 32'b101011_10001_01010_1111_1111_1111_1100; // SW
        instructions[7] = 32'b111111_00000_00000_0000_0000_0000_0000; // HALT

        // Test 2
        instructions[8] = 32'b001000_00000_01000_0000_0000_0000_1000; // ADDI
        instructions[9] = 32'b001000_00000_01001_0000_0000_0000_1111; // ADDI
        instructions[10] = 32'b101011_01000_01001_0000_0000_0000_0000; // SW
        instructions[11] = 32'b000000_01001_01000_01010_00000_100000; // ADD
        instructions[12] = 32'b000000_01001_01000_01011_00000_100010; // SUB
        instructions[13] = 32'b000000_01010_01011_10001_00000_000010; // MUL
        instructions[14] = 32'b001000_00000_01000_0000_0000_0000_0100; // ADDI
        instructions[15] = 32'b100011_01000_10010_1111_1111_1111_1100; // LW
        instructions[16] = 32'b000000_10001_10010_10010_00000_100010; // SUB
        instructions[17] = 32'b000000_10001_00000_10010_00000_000000; // SLL
        instructions[18] = 32'b101011_01000_10010_0000_0000_0000_0000; // SW
        instructions[19] = 32'b111111_00000_00000_0000_0000_0000_0000; // HALT

        // Test 3
        instructions[20] = 32'b001000_00000_00100_0000_0000_0000_0110; // ADDI
        instructions[21] = 32'b000011_00000_00000_0000_0000_0001_0100; // JAL
        instructions[22] = 32'b101011_00010_00010_0000_0000_0000_0000; // SW
        instructions[23] = 32'b111111_00000_00000_0000_0000_0000_0000; // HALT
        instructions[24] = 32'b001000_11101_11101_1111_1111_1111_1000; // ADDI -- Factorial function starts here
        instructions[25] = 32'b101011_11101_00100_0000_0000_0000_0100; // SW
        instructions[26] = 32'b101011_11101_11111_0000_0000_0000_0000; // SW
        instructions[27] = 32'b001000_00000_01000_0000_0000_0000_0010; // ADDI
        instructions[28] = 32'b000000_00100_01000_01000_00000_101010; // SLT
        instructions[29] = 32'b000100_01000_00000_0000_0000_0000_0011; // BEQ
        instructions[30] = 32'b001000_00000_00010_0000_0000_0000_0001; // ADDI
        instructions[31] = 32'b001000_00000_00010_0000_0000_0000_0001; // ADDI
        instructions[32] = 32'b001000_00010_11111_0000_0000_0000_1000; // ADDI
        instructions[33] = 32'b000011_00000_00000_0000_0000_0001_0100; // JAL
        instructions[34] = 32'b100011_11101_11111_0000_0000_0000_0000; // LW
        instructions[35] = 32'b100011_11101_00100_0000_0000_0000_0100; // LW
        instructions[36] = 32'b001000_11101_11101_0000_0000_0000_1000; // ADDI
        instructions[37] = 32'b000000_00100_11111_00010_00000_000010; // MUL
        instructions[38] = 32'b111111_00000_00000_0000_0000_0000_0000; // HALT

        // Test 4
        instructions[39] = 32'b001000_00000_01000_0000_0000_0000_1000; // ADDI
        instructions[40] = 32'b001000_00000_01001_0000_0000_0000_1111; // ADDI
        instructions[41] = 32'b101011_01000_01001_0000_0000_0000_0000; // SW
        instructions[42] = 32'b100011_01000_01010_0000_0000_0000_0000; // LW
        instructions[43] = 32'b000000_01001_01010_01011_00000_100000; // ADD
        instructions[44] = 32'b000100_01011_01010_0000_0000_0000_0010; // BEQ
        instructions[45] = 32'b000000_01011_01001_01100_00000_100010; // SUB
        instructions[46] = 32'b000000_01100_01011_10000_00000_100000; // ADD -- label
        instructions[47] = 32'b111111_00000_00000_0000_0000_0000_0000; // HALT

        // Test 5
        instructions[48] = 32'b001000_00000_01000_0000_0000_0000_0100; // ADDI
        instructions[49] = 32'b001000_00000_01001_0000_0000_0000_0101; // ADDI
        instructions[50] = 32'b000000_01000_01001_01010_00000_100000; // ADD
        instructions[51] = 32'b000000_01010_01001_01011_00000_100010; // SUB
        instructions[52] = 32'b000000_01011_01010_01100_00000_100100; // AND
        instructions[53] = 32'b000000_01100_01000_01101_00000_100101; // OR
        instructions[54] = 32'b101011_01000_01101_0000_0000_0000_0000; // SW
        instructions[55] = 32'b111111_00000_00000_0000_0000_0000_0000; // HALT
    end
    always @(*) begin
        instruction_reg = instructions[pc]; // this works
    end
    
endmodule


/* ------------------------------------------------------------------
 * Pipeline register modules: implement these to capture signals across
 * clock edges. They include stall and flush behavior where needed.
 * ------------------------------------------------------------------ */

/* IF/ID pipeline register
 *
 * Purpose:
 * - Latch the instruction fetched in IF along with the "next PC" value so
 *   that the ID stage has a stable instruction and PC value to operate on.
 * - Supports stall and flush semantics: when a stall is asserted the IF/ID
 *   contents may be held (freeze); when a flush is asserted the register is
 *   cleared to a NOP (commonly implemented by writing zeroed instruction).
 *
 * Behavior summary:
 * - On reset: clear outputs to represent a NOP.
 * - On stall: retain current outputs (freeze fetch stage progress).
 * - On flush: insert a bubble by setting outputs to NOP.
 * - Normal operation: capture instr_in and next_pc_in at the rising edge of clk.
 */
module IF_ID_reg(
    input wire clk,
    input wire reset,
    input wire stall,
    input wire flush,
    input wire [31:0] instr_in,
    input wire [31:0] next_pc_in,
    output reg [31:0] instr_out,
    output reg [31:0] next_pc_out
);
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            instr_out <= 32'b0; // treat 0 as NOP
            next_pc_out <= 32'b0;
        end else if (stall) begin
            // keep current values
            instr_out <= instr_out;
            next_pc_out <= next_pc_out;
        end else if (flush) begin
            instr_out <= 32'b0; // injected bubble
            next_pc_out <= 32'b0;
        end else begin
            instr_out <= instr_in;
            next_pc_out <= next_pc_in;
        end
    end
endmodule

/* ID/EX pipeline register
 *
 * Purpose:
 * - Capture and hold decoded instruction information (operands, immediate,
 *   destination register fields) and the control signals generated during ID
 *   so the EX stage can operate on a stable set of inputs for one clock cycle.
 * - Provide stall and bubble (flush) support: when a hazard is detected the
 *   hazard unit can assert `stall` to freeze or insert a bubble into the EX
 *   stage. A common bubble implementation clears control signals so the EX
 *   stage performs no state-changing operations this cycle.
 *
 * Behavior summary:
 * - On reset: clears all data and control outputs (NOP in pipeline).
 * - On stall: control signals are typically zeroed (bubble) while data fields
 *   can be held or also frozen depending on hazard design - this module
 *   currently zeros control signals on stall to inject a bubble.
 * - Normal operation: copies ID inputs to outputs on the rising edge of clk.
 *
 * Signals carried (examples): next_pc, readData1, readData2, sign-extended
 * immediate, rs/rt/rd fields, and control signals such as RegWrite, MemRead,
 * MemWrite, MemToReg, ALUSrc, ALUOp (these travel to EX and beyond).
 */
module ID_EX_reg(
    input wire clk,
    input wire reset,
    input wire stall,
    input wire Halt_in,
    // data inputs
    input wire [31:0] next_pc_in,
    input wire [31:0] regdata1_in,
    input wire [31:0] regdata2_in,
    input wire [31:0] imm_in,
    input wire [4:0] rs_in,
    input wire [4:0] rt_in,
    input wire [4:0] rd_in,
    // control inputs
    input wire RegWrite_in,
    input wire MemRead_in,
    input wire MemWrite_in,
    input wire MemToReg_in,
    input wire RegDst_in,
    input wire Branch_in,
    input wire ALUSrc_in,
    input wire [3:0] ALUOp_in,
    // outputs
    output reg [31:0] next_pc_out,
    output reg [31:0] regdata1_out,
    output reg [31:0] regdata2_out,
    output reg [31:0] imm_out,
    output reg [4:0] rs_out,
    output reg [4:0] rt_out,
    output reg [4:0] rd_out,
    output reg RegWrite_out,
    output reg MemRead_out,
    output reg MemWrite_out,
    output reg MemToReg_out,
    output reg RegDst_out,
    output reg Branch_out,
    output reg ALUSrc_out,
    output reg [3:0] ALUOp_out, 
    output reg Halt_out
);
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            next_pc_out <= 32'b0;
            regdata1_out <= 32'b0;
            regdata2_out <= 32'b0;
            imm_out <= 32'b0;
            rs_out <= 5'b0;
            rt_out <= 5'b0;
            rd_out <= 5'b0;
            RegWrite_out <= 1'b0;
            MemRead_out <= 1'b0;
            MemWrite_out <= 1'b0;
            MemToReg_out <= 1'b0;
            RegDst_out <= 1'b0;
            Branch_out <= 1'b0;
            ALUSrc_out <= 1'b0;
            ALUOp_out <= 4'b0000;
            Halt_out <= 1'b0;
        end else if (stall) begin
            // insert bubble: zero control signals, keep others or freeze as design requires
            RegWrite_out <= 1'b0;
            MemRead_out <= 1'b0;
            MemWrite_out <= 1'b0;
            MemToReg_out <= 1'b0;
            RegDst_out <= 1'b0;
            Branch_out <= 1'b0;
            ALUSrc_out <= 1'b0;
            ALUOp_out <= 4'b0000;
            // Optionally freeze data fields or pass through previous values depending on hazard design
            Halt_out <= 1'b0;
        end else begin
            next_pc_out <= next_pc_in;
            regdata1_out <= regdata1_in;
            regdata2_out <= regdata2_in;
            imm_out <= imm_in;
            rs_out <= rs_in;
            rt_out <= rt_in;
            rd_out <= rd_in;
            RegWrite_out <= RegWrite_in;
            MemRead_out <= MemRead_in;
            MemWrite_out <= MemWrite_in;
            MemToReg_out <= MemToReg_in;
            RegDst_out <= RegDst_in;
            Branch_out <= Branch_in;
            ALUSrc_out <= ALUSrc_in;
            ALUOp_out <= ALUOp_in;
            Halt_out <= Halt_in;
        end
    end
endmodule

/* EX/MEM pipeline register
 *
 * Purpose:
 * - Transfer ALU results, store-data (register value to write to memory),
 *   destination register index, and control signals from the EX stage to the
 *   MEM stage. This isolates the MEM stage from changes occurring in EX on the
 *   next cycle.
 *
 * Signals carried:
 * - alu_result: computed address or ALU result used for loads/stores and
 *   arithmetic results forwarded to later stages.
 * - write_data: register value to be written to data memory on stores.
 * - write_reg: destination register index for the WB stage.
 * - control signals: RegWrite, MemRead, MemWrite, MemToReg.
 *
 * Behavior summary:
 * - On reset: outputs cleared.
 * - Normal operation: copies inputs to outputs on rising clk edge.
 */
module EX_MEM_reg(
    input wire clk,
    input wire reset,
    input wire Halt_in,
    input wire [31:0] alu_result_in,
    input wire [31:0] write_data_in,
    input wire [4:0] write_reg_in,
    input wire RegWrite_in,
    input wire MemRead_in,
    input wire MemWrite_in,
    input wire MemToReg_in,
    output reg [31:0] alu_result_out,
    output reg [31:0] write_data_out,
    output reg [4:0] write_reg_out,
    output reg RegWrite_out,
    output reg MemRead_out,
    output reg MemWrite_out,
    output reg MemToReg_out
    , output reg Halt_out
);
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            alu_result_out <= 32'b0;
            write_data_out <= 32'b0;
            write_reg_out <= 5'b0;
            RegWrite_out <= 1'b0;
            MemRead_out <= 1'b0;
            MemWrite_out <= 1'b0;
            MemToReg_out <= 1'b0;
            Halt_out <= 1'b0;
        end else begin
            alu_result_out <= alu_result_in;
            write_data_out <= write_data_in;
            write_reg_out <= write_reg_in;
            RegWrite_out <= RegWrite_in;
            MemRead_out <= MemRead_in;
            MemWrite_out <= MemWrite_in;
            MemToReg_out <= MemToReg_in;
            Halt_out <= Halt_in;
        end
    end
endmodule

/* MEM/WB pipeline register
 *
 * Purpose:
 * - Pass the data loaded from memory (for loads), the ALU result (for
 *   arithmetic instructions), the destination register index, and the control
 *   signals from the MEM stage to the WB stage where register writes occur.
 *
 * Signals carried:
 * - mem_read: data read from data memory (valid when MemToReg is asserted).
 * - alu_result: passthrough of ALU result for instructions that write back
 *   ALU results instead of memory data.
 * - write_reg: destination register for the write-back stage.
 * - control signals: RegWrite, MemToReg.
 *
 * Behavior summary:
 * - On reset: outputs cleared.
 * - Normal operation: capture inputs on rising clk and present them to WB.
 */
module MEM_WB_reg(
    input wire clk,
    input wire reset,
    input wire Halt_in,
    input wire [31:0] mem_read_in,
    input wire [31:0] alu_result_in,
    input wire [4:0] write_reg_in,
    input wire RegWrite_in,
    input wire MemToReg_in,
    output reg [31:0] mem_read_out,
    output reg [31:0] alu_result_out,
    output reg [4:0] write_reg_out,
    output reg RegWrite_out,
    output reg MemToReg_out
    , output reg Halt_out
);
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            mem_read_out <= 32'b0;
            alu_result_out <= 32'b0;
            write_reg_out <= 5'b0;
            RegWrite_out <= 1'b0;
            MemToReg_out <= 1'b0;
            Halt_out <= 1'b0;
        end else begin
            mem_read_out <= mem_read_in;
            alu_result_out <= alu_result_in;
            write_reg_out <= write_reg_in;
            RegWrite_out <= RegWrite_in;
            MemToReg_out <= MemToReg_in;
            Halt_out <= Halt_in;
        end
    end
endmodule

// ------------------------------------------------------------------
// Control unit: generate control signals from opcode (and funct for R-type)
// ------------------------------------------------------------------
module control_unit(
    input wire [5:0] opcode,
    input wire [5:0] funct,
    output reg RegWrite,
    output reg MemRead,
    output reg MemWrite,
    output reg MemToReg,
    output reg ALUSrc,
    output reg RegDst,
    output reg Branch,
    output reg [3:0] ALUOp,
    output reg ExtOp
);
    always @(*) begin
        // default values
        RegWrite = 1'b0;
        MemRead  = 1'b0;
        MemWrite = 1'b0;
        MemToReg = 1'b0;
        ALUSrc   = 1'b0;
        RegDst   = 1'b0;
        Branch   = 1'b0;
        ALUOp    = 4'b1111; // default to Invalid
        ExtOp    = 1'b0;   // default: sign-extend

        case (opcode)
            6'b000000: begin // R-type
                RegWrite = 1'b1;
                ALUSrc = 1'b0;
                RegDst = 1'b1;
                // determine ALUOp by funct
                case (funct)
                    6'b100000: ALUOp = 4'b0000; // ADD (32)
                    6'b011000: ALUOp = 4'b0001; // MUL (24)
                    6'b100100: ALUOp = 4'b0010; // AND (36)
                    6'b100101: ALUOp = 4'b0011; // OR  (37)
                    6'b100111: ALUOp = 4'b0101; // NOR (39)
                    6'b000000: ALUOp = 4'b0110; // SLL (0)
                    6'b000010: ALUOp = 4'b0111; // SRL (2)
                    6'b100010: ALUOp = 4'b1000; // SUB (34)
                    6'b101010: ALUOp = 4'b1010; // SLT (42)
                    default:   ALUOp = 4'b1111;
                endcase
            end
            6'b001000: begin // ADDI (8)
                RegWrite = 1'b1;
                ALUSrc = 1'b1;
                RegDst = 1'b0;
                ALUOp = 4'b0000;
                ExtOp = 1'b0; // sign-extend for ADDI
            end
            6'b100011: begin // LW (35)
                RegWrite = 1'b1;
                MemRead = 1'b1;
                MemToReg = 1'b1;
                ALUSrc = 1'b1;
                RegDst = 1'b0;
                ALUOp = 4'b0000;
            end
            6'b101011: begin // SW (43)
                MemWrite = 1'b1;
                ALUSrc = 1'b1;
                ALUOp = 4'b0000;
            end
            6'b000100: begin // BEQ (4)
                Branch = 1'b1;
                ALUSrc = 1'b0;
                ALUOp =  4'b1001; // compare via ALU (assume zero test)
            end
            6'b001100: begin // ANDI (12)
                RegWrite = 1'b1;
                ALUSrc = 1'b1;
                RegDst = 1'b0;
                ALUOp = 4'b0010;
                ExtOp = 1'b1; // zero-extend for ANDI
            end
            6'b001101: begin // ORI (13)
                RegWrite = 1'b1;
                ALUSrc = 1'b1;
                RegDst = 1'b0;
                ALUOp = 4'b0011;
                ExtOp = 1'b1; // zero-extend for ORI
            end
            default: begin
                // keep defaults (no-op)
            end
        endcase
    end
endmodule

// ------------------------------------------------------------------
// Forwarding unit stub - implement logic to set ForwardA/ForwardB
// ------------------------------------------------------------------
module forwarding_unit(
    input wire EX_MEM_RegWrite,
    input wire [4:0] EX_MEM_Rd,
    input wire MEM_WB_RegWrite,
    input wire [4:0] MEM_WB_Rd,
    input wire [4:0] ID_EX_Rs,
    input wire [4:0] ID_EX_Rt,
    output reg [1:0] ForwardA,
    output reg [1:0] ForwardB
);
    // Forwarding policy (standard):
    // - ForwardA/B = 2'b00 : use ID/EX register value
    // - ForwardA/B = 2'b10 : use EX/MEM.alu_result
    // - ForwardA/B = 2'b01 : use MEM/WB (alu result or mem read depending on MemToReg)
    always @(*) begin
        // defaults
        ForwardA = 2'b00;
        ForwardB = 2'b00;

        // EX hazard (highest priority)
        if (EX_MEM_RegWrite && (EX_MEM_Rd != 5'b0) && (EX_MEM_Rd == ID_EX_Rs)) begin
            ForwardA = 2'b10;
        end else if (MEM_WB_RegWrite && (MEM_WB_Rd != 5'b0) && (MEM_WB_Rd == ID_EX_Rs)) begin
            ForwardA = 2'b01;
        end

        if (EX_MEM_RegWrite && (EX_MEM_Rd != 5'b0) && (EX_MEM_Rd == ID_EX_Rt)) begin
            ForwardB = 2'b10;
        end else if (MEM_WB_RegWrite && (MEM_WB_Rd != 5'b0) && (MEM_WB_Rd == ID_EX_Rt)) begin
            ForwardB = 2'b01;
        end
    end
endmodule

// ------------------------------------------------------------------
// Hazard detection unit stub - detect load-use hazards and assert stall
// ------------------------------------------------------------------
module hazard_unit(
    input wire ID_EX_MemRead,
    input wire [4:0] ID_EX_Rt,
    input wire [4:0] IF_ID_Rs,
    input wire [4:0] IF_ID_Rt,
    output wire stall
);
    // Step 1: Check if instruction in ID/EX is a load
    wire is_load = ID_EX_MemRead;
    
    // Step 2: Check if load's destination register isn't $zero
    wire valid_dest = (ID_EX_Rt != 5'b0);
    
    // Step 3: Check if either source register matches the load's destination
    wire rs_match = (ID_EX_Rt == IF_ID_Rs);  // first source register match
    wire rt_match = (ID_EX_Rt == IF_ID_Rt);  // second source register match
    wire reg_hazard = rs_match || rt_match;   // either match is a hazard
    
    // Final stall condition: must be a load, valid destination, and register hazard
    assign stall = is_load && valid_dest && reg_hazard;

endmodule

module pipeline_processor_tb;
    reg clk;
    reg reset;

    
    wire done;
    pipelined_processor DUT(
        .clk(clk),
        .reset(reset),
        .initial_pc(20),
        .done(done)
    );

    initial begin
        clk = 1;
        forever begin
            #5 clk = ~clk;
        end
    end

    initial begin
        $dumpfile("hw_pipeline.vcd");
        $dumpvars(0, pipeline_processor_tb);

        reset = 1;
        #12;           // hold reset
        reset = 0;

        #5000;
        $finish;
    end

    // Watch for done and finish immediately
    always @(posedge clk) begin
        if (done) begin
            #1 $finish;
        end
    end

endmodule
