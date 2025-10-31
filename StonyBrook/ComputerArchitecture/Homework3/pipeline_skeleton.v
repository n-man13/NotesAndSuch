`timescale 1ns / 1ps

// pipeline_skeleton.v
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
    wire [31:0] pc_plus1_if;   // pc + 1 computed in IF

    // Hook to existing programMem (combinational read)
    programMem prog_mem(.pc(pc), .instruction(instr_if));

    // compute pc+1 in IF (word-addressed PC like your existing design)
    assign pc_plus1_if = pc + 1;

    // ------------------------------------------------------------------
    // IF/ID pipeline register
    // ------------------------------------------------------------------
    wire [31:0] ifid_instr_out;
    wire [31:0] ifid_pc_plus1_out;

    IF_ID_reg IFID(
        .clk(clk),
        .reset(reset),
        .stall(1'b0),         // TODO: connect to hazard unit
        .flush(1'b0),         // TODO: assert on branch taken
        .instr_in(instr_if),
        .pc_plus1_in(pc_plus1_if),
        .instr_out(ifid_instr_out),
        .pc_plus1_out(ifid_pc_plus1_out)
    );

    // ------------------------------------------------------------------
    // ID stage: decode, register file read, control generation
    // ------------------------------------------------------------------
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
    wire [2:0] ALUOp_id; // ALU operation selection (width as needed)

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

    // ID/EX pipeline register (capture decoded values + control signals)
    // Many signals will be captured here; we provide placeholders
    wire [31:0] idex_pc_plus1_out;
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
    wire [2:0] idex_ALUOp;

    ID_EX_reg IDEX(
        .clk(clk),
        .reset(reset),
        .stall(1'b0), // TODO: connect hazard detection stall
        // inputs
        .pc_plus1_in(ifid_pc_plus1_out),
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
        .ALUSrc_in(ALUSrc_id),
        .ALUOp_in(ALUOp_id),
        // outputs
        .pc_plus1_out(idex_pc_plus1_out),
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
        .ALUSrc_out(idex_ALUSrc),
        .ALUOp_out(idex_ALUOp)
    );

    // ------------------------------------------------------------------
    // EX stage: ALU, branch target calculation, forwarding muxes
    // ------------------------------------------------------------------
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
        .write_reg_in(idex_rt_out /* or idex_rd_out depending on RegDst */),
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

// ------------------------------------------------------------------
// Pipeline register modules: implement these to capture signals across
// clock edges. They include stall and flush behavior where needed.
// ------------------------------------------------------------------

module IF_ID_reg(
    input wire clk,
    input wire reset,
    input wire stall,
    input wire flush,
    input wire [31:0] instr_in,
    input wire [31:0] pc_plus1_in,
    output reg [31:0] instr_out,
    output reg [31:0] pc_plus1_out
);
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            instr_out <= 32'b0; // treat 0 as NOP
            pc_plus1_out <= 32'b0;
        end else if (stall) begin
            // keep current values
            instr_out <= instr_out;
            pc_plus1_out <= pc_plus1_out;
        end else if (flush) begin
            instr_out <= 32'b0; // injected bubble
            pc_plus1_out <= 32'b0;
        end else begin
            instr_out <= instr_in;
            pc_plus1_out <= pc_plus1_in;
        end
    end
endmodule

module ID_EX_reg(
    input wire clk,
    input wire reset,
    input wire stall,
    // data inputs
    input wire [31:0] pc_plus1_in,
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
    input wire ALUSrc_in,
    input wire [2:0] ALUOp_in,
    // outputs
    output reg [31:0] pc_plus1_out,
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
    output reg ALUSrc_out,
    output reg [2:0] ALUOp_out
);
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            pc_plus1_out <= 32'b0;
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
            ALUSrc_out <= 1'b0;
            ALUOp_out <= 3'b000;
        end else if (stall) begin
            // insert bubble: zero control signals, keep others or freeze as design requires
            RegWrite_out <= 1'b0;
            MemRead_out <= 1'b0;
            MemWrite_out <= 1'b0;
            MemToReg_out <= 1'b0;
            ALUSrc_out <= 1'b0;
            ALUOp_out <= 3'b000;
            // Optionally freeze data fields or pass through previous values depending on hazard design
        end else begin
            pc_plus1_out <= pc_plus1_in;
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
            ALUSrc_out <= ALUSrc_in;
            ALUOp_out <= ALUOp_in;
        end
    end
endmodule

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

// End of skeleton
