`timescale 1ns / 1ps

// pipeline_processor.v
// Skeleton for converting the single-cycle processor to a 5-stage pipelined processor.
// Purpose: provide clear pipeline registers, module boundaries, and stubs for forwarding/hazard units.
// Fill in TODOs to complete the implementation.

module pipelined_processor(
    input wire clk,
    input wire reset,
    input wire [31:0] initial_pc
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
        .stall(1'b0),         // TODO: connect to hazard unit
        .flush(1'b0),         // TODO: assert on branch taken
        .instr_in(instr_if),
        .next_pc_in(next_pc_if),
        .instr_out(ifid_instr_out),
        .next_pc_out(ifid_next_pc_out)
    );

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

    // TODO: instantiate a Control unit to generate the control signals
    // For now we make a control bus placeholder
    wire RegWrite_id;    // write enable to regfile (to be stored in ID/EX)
    wire MemRead_id;     // load
    wire MemWrite_id;    // store
    wire MemToReg_id;    // choose mem data for WB
    wire ALUSrc_id;      // ALU second operand is immediate
    wire RegDst_id;      // choose rd (R-type) vs rt (I-type) as destination
    wire Branch_id;      // branch signal (BEQ/BNE)
    wire [2:0] ALUOp_id; // ALU operation selection (width as needed)

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
        .ALUOp(ALUOp_id)
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

    // immediate ext
    wire [31:0] imm_ext_id = {{16{id_imm[15]}}, id_imm}; // sign-extend default; adjust for ANDI/ORI

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
    wire [2:0] idex_ALUOp;

    ID_EX_reg IDEX(
        .clk(clk),
        .reset(reset),
        .stall(1'b0), // TODO: connect hazard detection stall
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

    // TODO: Instantiate forwarding unit and wire alu_input_A, alu_input_B_pre
    // For now, wire direct: (you will replace with muxes that select forwarded values)
    assign alu_input_A = idex_regdata1_out;
    assign alu_input_B_pre = idex_regdata2_out;

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

    EX_MEM_reg EXMEM(
        .clk(clk),
        .reset(reset),
        .alu_result_in(alu_result_ex),
        .write_data_in(idex_regdata2_out),
        .write_reg_in(idex_write_reg /* selected by RegDst */),
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

    MEM_WB_reg MEMWB(
        .clk(clk),
        .reset(reset),
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

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            pc <= initial_pc;
        end else begin
            if (stall) begin
                pc <= pc; // freeze
            end else if (branch_taken_ex) begin
                pc <= branch_target_ex;
            end else begin
                pc <= pc + 1; // basic increment
            end
        end
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
 *   can be held or also frozen depending on hazard design — this module
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
    input wire [2:0] ALUOp_in,
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
    output reg [2:0] ALUOp_out
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
            ALUOp_out <= 3'b000;
        end else if (stall) begin
            // insert bubble: zero control signals, keep others or freeze as design requires
            RegWrite_out <= 1'b0;
            MemRead_out <= 1'b0;
            MemWrite_out <= 1'b0;
            MemToReg_out <= 1'b0;
            RegDst_out <= 1'b0;
            Branch_out <= 1'b0;
            ALUSrc_out <= 1'b0;
            ALUOp_out <= 3'b000;
            // Optionally freeze data fields or pass through previous values depending on hazard design
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
        end else begin
            alu_result_out <= alu_result_in;
            write_data_out <= write_data_in;
            write_reg_out <= write_reg_in;
            RegWrite_out <= RegWrite_in;
            MemRead_out <= MemRead_in;
            MemWrite_out <= MemWrite_in;
            MemToReg_out <= MemToReg_in;
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
);
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            mem_read_out <= 32'b0;
            alu_result_out <= 32'b0;
            write_reg_out <= 5'b0;
            RegWrite_out <= 1'b0;
            MemToReg_out <= 1'b0;
        end else begin
            mem_read_out <= mem_read_in;
            alu_result_out <= alu_result_in;
            write_reg_out <= write_reg_in;
            RegWrite_out <= RegWrite_in;
            MemToReg_out <= MemToReg_in;
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
    output reg [2:0] ALUOp
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
        ALUOp    = 3'b000; // default to ADD

        case (opcode)
            6'b000000: begin // R-type
                RegWrite = 1'b1;
                ALUSrc = 1'b0;
                RegDst = 1'b1;
                // determine ALUOp by funct
                case (funct)
                    6'b100000: ALUOp = 3'b000; // ADD (32)
                    6'b011000: ALUOp = 3'b001; // MUL (24)
                    6'b100100: ALUOp = 3'b010; // AND (36)
                    6'b100101: ALUOp = 3'b011; // OR  (37)
                    6'b100111: ALUOp = 3'b101; // NOR (39)
                    6'b000000: ALUOp = 3'b110; // SLL (0)
                    6'b000010: ALUOp = 3'b111; // SRL (2)
                    default:   ALUOp = 3'b000;
                endcase
            end
            6'b001000: begin // ADDI (8)
                RegWrite = 1'b1;
                ALUSrc = 1'b1;
                RegDst = 1'b0;
                ALUOp = 3'b000;
            end
            6'b100011: begin // LW (35)
                RegWrite = 1'b1;
                MemRead = 1'b1;
                MemToReg = 1'b1;
                ALUSrc = 1'b1;
                RegDst = 1'b0;
                ALUOp = 3'b000;
            end
            6'b101011: begin // SW (43)
                MemWrite = 1'b1;
                ALUSrc = 1'b1;
                ALUOp = 3'b000;
            end
            6'b000100: begin // BEQ (4)
                Branch = 1'b1;
                ALUSrc = 1'b0;
                ALUOp = 3'b000; // compare via ALU (assume zero test)
            end
            6'b001100: begin // ANDI (12)
                RegWrite = 1'b1;
                ALUSrc = 1'b1;
                RegDst = 1'b0;
                ALUOp = 3'b010;
            end
            6'b001101: begin // ORI (13)
                RegWrite = 1'b1;
                ALUSrc = 1'b1;
                RegDst = 1'b0;
                ALUOp = 3'b011;
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
    output wire [1:0] ForwardA,
    output wire [1:0] ForwardB
);
    // TODO: implement forwarding logic and set ForwardA/ForwardB values
    assign ForwardA = 2'b00;
    assign ForwardB = 2'b00;
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
    // TODO: set stall = 1 when a load-use hazard is detected
    assign stall = 1'b0;
endmodule

