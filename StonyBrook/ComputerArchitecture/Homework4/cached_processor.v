`timescale 1ns / 1ps

// 5-stage pipelined MIPS processor with forwarding and hazard detection

module pipelined_processor(
    input wire clk,
    input wire reset,
    input wire [31:0] initial_pc,
    input wire enable_forwarding,      // 1 = forwarding enabled, 0 = disabled
    input wire enable_hazard_detection, // 1 = stalls on hazards, 0 = no stalls
    output wire done
);

    // IF stage
    reg [31:0] pc;
    wire [31:0] instr_if;
    wire [31:0] next_pc_if;

    programMem prog_mem(.pc(pc), .instruction(instr_if));
    assign next_pc_if = pc + 1;

    // IF/ID register
    wire [31:0] ifid_instr_out;
    wire [31:0] ifid_next_pc_out;

    IF_ID_reg IFID(
        .clk(clk),
        .reset(reset),
        .stall(stall),
        .flush(flush_ifid),
        .instr_in(instr_if),
        .next_pc_in(next_pc_if),
        .instr_out(ifid_instr_out),
        .next_pc_out(ifid_next_pc_out)
    );

    wire halt_if = (instr_if[31:26] == 6'b111111);

    // ID
    wire [5:0] id_opcode = ifid_instr_out[31:26];
    wire [5:0] id_funct  = ifid_instr_out[5:0];
    wire [4:0] id_rs     = ifid_instr_out[25:21];
    wire [4:0] id_rt     = ifid_instr_out[20:16];
    wire [4:0] id_rd     = ifid_instr_out[15:11];
    wire [15:0] id_imm   = ifid_instr_out[15:0];

    wire RegWrite_id;    // write enable to regfile
    wire MemRead_id;     // load
    wire MemWrite_id;    // store
    wire MemToReg_id;    // choose data for WB
    wire ALUSrc_id;      // ALU
    wire RegDst_id;      // R-type vs I-type
    wire Branch_id;      // branch signal
    wire BranchNotEqual_id; // 1 for BNE, 0 for BEQ
    wire [3:0] ALUOp_id;
    wire ExtOp_id;
    
    wire stall;
    wire flush_ifid;
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
        .BranchNotEqual(BranchNotEqual_id),
        .ALUOp(ALUOp_id),
        .ExtOp(ExtOp_id)
    );

    wire [31:0] reg_read1_id;
    wire [31:0] reg_read2_id;
    wire [31:0] writeback_data_wb;
    wire [4:0] writeback_reg_wb;
    wire writeback_enable_wb;
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

    wire [31:0] imm_ext_id = ExtOp_id ? {16'b0, id_imm} : {{16{id_imm[15]}}, id_imm};
    
    // For shift instructions, use shamt field instead of immediate
    wire is_shift_id = (id_opcode == 6'b000000) && ((id_funct == 6'b000000) || (id_funct == 6'b000010));
    wire [31:0] shamt_ext_id = {27'b0, ifid_instr_out[10:6]};
    wire [31:0] imm_or_shamt = is_shift_id ? shamt_ext_id : imm_ext_id;

    // ID/EX register
    wire [31:0] idex_next_pc_out;
    wire [31:0] idex_regdata1_out;
    wire [31:0] idex_regdata2_out;
    wire [31:0] idex_imm_out;
    wire [4:0]  idex_rs_out;
    wire [4:0]  idex_rt_out;
    wire [4:0]  idex_rd_out;

    // control signals (ID/EX)
    wire idex_RegWrite;
    wire idex_MemRead;
    wire idex_MemWrite;
    wire idex_MemToReg;
    wire idex_ALUSrc;
    wire idex_RegDst;
    wire idex_Branch;
    wire idex_BranchNotEqual;
    wire [3:0] idex_ALUOp;
    wire idex_Halt_out;

    wire idex_JAL_out;
    wire [31:0] idex_link_out;
    wire exmem_JAL_out;
    wire [31:0] exmem_link_out;
    wire memwb_JAL_out;
    wire [31:0] memwb_link_out;

    wire halt_id = (ifid_instr_out[31:26] == 6'b111111) && !flush_ifid;
    wire is_jal = (id_opcode == 6'b000011);
    wire [31:0] jal_target = {6'b0, ifid_instr_out[25:0]};
    wire is_jr = (id_opcode == 6'b000000) && (id_funct == 6'b001000);
    wire [31:0] jr_target = reg_read1_id;

    ID_EX_reg IDEX(
        .clk(clk),
        .reset(reset),
        .stall(stall),
        .flush(flush_idex),
        .next_pc_in(ifid_next_pc_out),
        .regdata1_in(reg_read1_id),
        .regdata2_in(reg_read2_id),
        .imm_in(imm_or_shamt),
        .rs_in(id_rs),
        .rt_in(id_rt),
        .rd_in(id_rd),
        .RegWrite_in(RegWrite_id | is_jal),
        .MemRead_in(MemRead_id),
        .MemWrite_in(MemWrite_id),
        .MemToReg_in(MemToReg_id),
        .RegDst_in(RegDst_id),
        .Branch_in(Branch_id),
        .BranchNotEqual_in(BranchNotEqual_id),
        .ALUSrc_in(ALUSrc_id),
        .ALUOp_in(ALUOp_id),
        .JAL_in(is_jal),
        .link_in(ifid_next_pc_out),
        .Halt_in(halt_id),
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
        .BranchNotEqual_out(idex_BranchNotEqual),
        .ALUSrc_out(idex_ALUSrc),
        .ALUOp_out(idex_ALUOp)
        , .Halt_out(idex_Halt_out)
        , .JAL_out(idex_JAL_out)
        , .link_out(idex_link_out)
    );

    wire [4:0] idex_write_reg = idex_RegDst ? idex_rd_out : idex_rt_out;

    // EX: ALU, branch target calculation, forwarding muxes
    wire [31:0] alu_input_A;
    wire [31:0] alu_input_B_pre;
    wire [31:0] alu_input_B = idex_ALUSrc ? idex_imm_out : alu_input_B_pre;
    wire is_shift_ex = (idex_ALUOp == 4'b0110) || (idex_ALUOp == 4'b0111);
    wire [31:0] alu_input_A_final = is_shift_ex ? alu_input_B_pre : alu_input_A;
    wire [31:0] alu_result_ex;

    wire [1:0] ForwardA;
    wire [1:0] ForwardB;

    wire registers_equal = (alu_result_ex == 32'd1);
    wire branch_decision = idex_BranchNotEqual ? !registers_equal : registers_equal;
    wire branch_taken = idex_Branch & branch_decision;
    wire [31:0] branch_target = idex_next_pc_out + idex_imm_out;

    forwarding_unit FU(
        .enable_forwarding(enable_forwarding),
        .EX_MEM_RegWrite(exmem_RegWrite_out),
        .EX_MEM_Rd(exmem_write_reg_out),
        .MEM_WB_RegWrite(memwb_RegWrite_out),
        .MEM_WB_Rd(memwb_writereg_out),
        .ID_EX_Rs(idex_rs_out),
        .ID_EX_Rt(idex_rt_out),
        .ForwardA(ForwardA),
        .ForwardB(ForwardB)
    );

    hazard_unit HZ(
        .enable_hazard_detection(enable_hazard_detection),
        .enable_forwarding(enable_forwarding),
        .ID_EX_MemRead(idex_MemRead),
        .ID_EX_Rt(idex_rt_out),
        .ID_EX_RegWrite(idex_RegWrite),
        .ID_EX_Rd(idex_write_reg),
        .EX_MEM_RegWrite(exmem_RegWrite_out),
        .EX_MEM_Rd(exmem_write_reg_out),
        .IF_ID_Rs(ifid_instr_out[25:21]),
        .IF_ID_Rt(ifid_instr_out[20:16]),
        .stall(stall)
    );

    wire [31:0] forward_from_memwb = memwb_MemToReg_out ? memwb_memread_out : memwb_aluout_out;
    reg [31:0] alu_input_A_reg;
    reg [31:0] alu_input_Bpre_reg;
    always @(*) begin
        case (ForwardA)
            2'b10: alu_input_A_reg = exmem_alu_result_out;
            2'b01: alu_input_A_reg = forward_from_memwb;
            default: alu_input_A_reg = idex_regdata1_out;
        endcase

        case (ForwardB)
            2'b10: alu_input_Bpre_reg = exmem_alu_result_out;
            2'b01: alu_input_Bpre_reg = forward_from_memwb;
            default: alu_input_Bpre_reg = idex_regdata2_out;
        endcase
    end

    assign alu_input_A = alu_input_A_reg;
    assign alu_input_B_pre = alu_input_Bpre_reg;

    alu alu_ex(.a(alu_input_A_final), .b(alu_input_B), .alu_sel(idex_ALUOp), .alu_out(alu_result_ex));

    // EX/MEM register
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
        .JAL_in(idex_JAL_out),
        .link_in(idex_link_out),
        .alu_result_in(alu_result_ex),
        .write_data_in(alu_input_B_pre),
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
        , .JAL_out(exmem_JAL_out)
        , .link_out(exmem_link_out)
    );

    // MEM access with cache
    wire [31:0] mem_read_data_mem;
    wire cache_stall;
    wire mem_write_en;
    wire [31:0] mem_write_addr;
    wire [31:0] mem_write_data;
    wire mem_read_en;
    wire [31:0] mem_read_addr;
    wire [31:0] mem_read_data_from_mem;
    
    cache_controller cache(
        .clk(clk),
        .reset(reset),
        .cpu_read(exmem_MemRead_out),
        .cpu_write(exmem_MemWrite_out),
        .cpu_addr(exmem_alu_result_out),
        .cpu_write_data(exmem_write_data_out),
        .cpu_read_data(mem_read_data_mem),
        .cache_stall(cache_stall),
        .mem_write_en(mem_write_en),
        .mem_write_addr(mem_write_addr),
        .mem_write_data(mem_write_data),
        .mem_read_en(mem_read_en),
        .mem_read_addr(mem_read_addr),
        .mem_read_data(mem_read_data_from_mem)
    );
    
    memoryFile data_mem(
        .clk(clk),
        .addr(mem_write_en ? mem_write_addr : mem_read_addr),
        .writeEnable(mem_write_en),
        .writeData(mem_write_data),
        .readData(mem_read_data_from_mem)
    );

    // MEM/WB register
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
        .JAL_in(exmem_JAL_out),
        .link_in(exmem_link_out),
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
        , .JAL_out(memwb_JAL_out)
        , .link_out(memwb_link_out)
    );

    // WB selection
    assign writeback_data_wb = memwb_JAL_out ? memwb_link_out : (memwb_MemToReg_out ? memwb_memread_out : memwb_aluout_out);
    assign writeback_reg_wb  = memwb_JAL_out ? 5'd31 : memwb_writereg_out;
    assign writeback_enable_wb = memwb_RegWrite_out | memwb_JAL_out;

    // PC update logic
    wire branch_taken_ex = branch_taken;
    wire [31:0] branch_target_ex = branch_target;
    assign flush_ifid = branch_taken_ex | is_jal | is_jr;
    
    reg branch_taken_prev;
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            branch_taken_prev <= 1'b0;
        end else begin
            branch_taken_prev <= branch_taken_ex;
        end
    end
    wire flush_idex = branch_taken_prev;

    assign done = memwb_Halt_out;

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            pc <= initial_pc;
        end else begin
            if (branch_taken_ex) begin
                pc <= branch_target_ex;
            end else if (is_jal) begin
                pc <= jal_target;
            end else if (is_jr) begin
                pc <= jr_target;
            end else if (halt_if) begin
                pc <= pc;
            end else if (stall) begin
                pc <= pc;
            end else begin
                pc <= pc + 1;
            end
        end
    end

endmodule


module alu (
    input [31:0] a,
    input [31:0] b,
    input [3:0] alu_sel,
    output reg [31:0] alu_out
);
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
        case (alu_sel)
            4'b0000: alu_out = a + b;          // Addition
            4'b0001: alu_out = (a * b);        // Multiplication
            4'b0010: alu_out = a & b;          // Bitwise AND
            4'b0011: alu_out = a | b;          // Bitwise OR
            4'b0100: alu_out = a ^ b;          // Bitwise XOR
            4'b0101: alu_out = ~(a | b);       // Bitwise NOR
            4'b0110: alu_out = a << b[4:0];    // Logical left shift
            4'b0111: alu_out = a >> b[4:0];    // Logical right shift
            4'b1000: alu_out = a - b;          // Subtraction
            4'b1010: alu_out = (a < b) ? 32'b1 : 32'b0; // SLT
            4'b1001: alu_out = (a == b) ? 32'b1 : 32'b0; // Equality check
            default: alu_out = 32'b0;        // Default case set to zero
        endcase
    end
endmodule

// Register file
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

    always @(posedge clk) begin
        if (writeEnable && (writeReg != 5'd0))
            registers[writeReg] <= writeData;
        registers[0] <= 32'd0;
    end

    // Internal forwarding: if reading the same register being written, forward the write data
    assign readData1 = (writeEnable && (readReg1 == writeReg) && (readReg1 != 5'd0)) ? writeData : registers[readReg1];
    assign readData2 = (writeEnable && (readReg2 == writeReg) && (readReg2 != 5'd0)) ? writeData : registers[readReg2];

endmodule

// ===== 2-WAY SET-ASSOCIATIVE CACHE (COMMENTED OUT) =====
// 2-way set-associative cache (8KB, 32-byte blocks, write-back, write-allocate, LRU)

module cache_controller(
    input wire clk,
    input wire reset,
    input wire cpu_read,
    input wire cpu_write,
    input wire [31:0] cpu_addr,
    input wire [31:0] cpu_write_data,
    output reg [31:0] cpu_read_data,
    output reg cache_stall,
    output reg mem_write_en,
    output reg [31:0] mem_write_addr,
    output reg [31:0] mem_write_data,
    output reg mem_read_en,
    output reg [31:0] mem_read_addr,
    input wire [31:0] mem_read_data
);
    // 8KB cache / 32 bytes per block = 256 blocks
    // 2-way set-associative: 256 blocks / 2 ways = 128 sets
    // Index = 7 bits (128 sets)
    // Block offset = 5 bits (32 bytes = 8 words)
    // Tag = 32 - 7 - 5 = 20 bits
    
    parameter WAYS = 2;
    parameter INDEX_BITS = 7;
    parameter OFFSET_BITS = 5;
    parameter TAG_BITS = 20;
    parameter NUM_SETS = 128;
    parameter WORDS_PER_BLOCK = 8;
    
    reg valid_bit [0:NUM_SETS-1][0:WAYS-1];
    reg dirty_bit [0:NUM_SETS-1][0:WAYS-1];
    reg [TAG_BITS-1:0] tag_field [0:NUM_SETS-1][0:WAYS-1];
    reg [31:0] data_block [0:NUM_SETS-1][0:WAYS-1][0:WORDS_PER_BLOCK-1];
    reg lru_bit [0:NUM_SETS-1];  // 0 = way 0 is LRU, 1 = way 1 is LRU
    
    wire [TAG_BITS-1:0] addr_tag = cpu_addr[31:31-TAG_BITS+1];
    wire [INDEX_BITS-1:0] addr_index = cpu_addr[31-TAG_BITS:OFFSET_BITS];
    wire [2:0] addr_word_offset = cpu_addr[4:2];
    
    parameter IDLE = 3'b000;
    parameter COMPARE_TAG = 3'b001;
    parameter WRITE_BACK = 3'b010;
    parameter ALLOCATE = 3'b011;
    parameter WRITE_HIT = 3'b100;
    
    reg [2:0] state;
    reg [2:0] wb_counter;
    reg [2:0] alloc_counter;
    reg was_read;  
    reg hit_way;   
    reg victim_way; 
    
    
    reg [TAG_BITS-1:0] saved_tag;
    reg [INDEX_BITS-1:0] saved_index;
    reg [2:0] saved_word_offset;
    reg saved_cpu_read;
    reg saved_cpu_write;
    
    wire way0_hit = valid_bit[saved_index][0] && (tag_field[saved_index][0] == saved_tag);
    wire way1_hit = valid_bit[saved_index][1] && (tag_field[saved_index][1] == saved_tag);
    wire cache_hit = way0_hit || way1_hit;
    
    integer i, j, k;
    
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            state <= IDLE;
            cache_stall <= 1'b0;
            mem_write_en <= 1'b0;
            mem_read_en <= 1'b0;
            cpu_read_data <= 32'b0;
            wb_counter <= 3'b0;
            alloc_counter <= 3'b0;
            
            for (i = 0; i < NUM_SETS; i = i + 1) begin
                lru_bit[i] <= 1'b0;
                for (k = 0; k < WAYS; k = k + 1) begin
                    valid_bit[i][k] <= 1'b0;
                    dirty_bit[i][k] <= 1'b0;
                    tag_field[i][k] <= {TAG_BITS{1'b0}};
                    for (j = 0; j < WORDS_PER_BLOCK; j = j + 1) begin
                        data_block[i][k][j] <= 32'b0;
                    end
                end
            end
        end else begin
            case (state)
                IDLE: begin
                    cache_stall <= 1'b0;
                    mem_write_en <= 1'b0;
                    mem_read_en <= 1'b0;
                    
                    if (cpu_read || cpu_write) begin
                        saved_tag <= addr_tag;
                        saved_index <= addr_index;
                        saved_word_offset <= addr_word_offset;
                        saved_cpu_read <= cpu_read;
                        saved_cpu_write <= cpu_write;
                        
                        state <= COMPARE_TAG;
                        cache_stall <= 1'b1;
                    end
                end
                
                COMPARE_TAG: begin
                    if (cache_hit) begin
                        hit_way <= way0_hit ? 1'b0 : 1'b1;
                        
                        if (saved_cpu_read) begin
                            cpu_read_data <= way0_hit ? data_block[saved_index][0][saved_word_offset] 
                                                      : data_block[saved_index][1][saved_word_offset];
                            cache_stall <= 1'b0;
                            state <= IDLE;
                            lru_bit[saved_index] <= way0_hit ? 1'b1 : 1'b0;
                        end else if (saved_cpu_write) begin
                            state <= WRITE_HIT;
                        end
                    end else begin
                        was_read <= saved_cpu_read;
                        
                        if (!valid_bit[saved_index][0]) begin
                            victim_way <= 1'b0;
                        end else if (!valid_bit[saved_index][1]) begin
                            victim_way <= 1'b1;
                        end else begin
                            victim_way <= lru_bit[saved_index];
                        end
                        
                        if ((valid_bit[saved_index][lru_bit[saved_index]] && 
                             dirty_bit[saved_index][lru_bit[saved_index]]) ||
                            (!valid_bit[saved_index][0] && valid_bit[saved_index][1] && dirty_bit[saved_index][1]) ||
                            (!valid_bit[saved_index][1] && valid_bit[saved_index][0] && dirty_bit[saved_index][0])) begin
                            state <= WRITE_BACK;
                            wb_counter <= 3'b0;
                        end else begin
                            state <= ALLOCATE;
                            alloc_counter <= 3'b0;
                        end
                    end
                end
                
                WRITE_HIT: begin
                    data_block[saved_index][hit_way][saved_word_offset] <= cpu_write_data;
                    dirty_bit[saved_index][hit_way] <= 1'b1;
                    cache_stall <= 1'b0;
                    state <= IDLE;
                    lru_bit[saved_index] <= hit_way ? 1'b0 : 1'b1;
                end
                
                WRITE_BACK: begin
                    mem_write_en <= 1'b1;
                    mem_write_addr <= {tag_field[saved_index][victim_way], saved_index, wb_counter, 2'b00};
                    mem_write_data <= data_block[saved_index][victim_way][wb_counter];
                    
                    if (wb_counter == 3'd7) begin
                        mem_write_en <= 1'b0;
                        state <= ALLOCATE;
                        alloc_counter <= 3'b0;
                        wb_counter <= 3'b0;
                    end else begin
                        wb_counter <= wb_counter + 1;
                    end
                end
                
                ALLOCATE: begin
                    mem_read_en <= 1'b1;
                    mem_read_addr <= {saved_tag, saved_index, alloc_counter, 2'b00};
                    
                    if (alloc_counter > 0 || mem_read_en) begin
                        data_block[saved_index][victim_way][alloc_counter - 1] <= mem_read_data;
                    end
                    
                    if (alloc_counter == 3'd7) begin
                        data_block[saved_index][victim_way][3'd7] <= mem_read_data;
                        
                        valid_bit[saved_index][victim_way] <= 1'b1;
                        tag_field[saved_index][victim_way] <= saved_tag;
                        dirty_bit[saved_index][victim_way] <= 1'b0;
                        
                        mem_read_en <= 1'b0;
                        alloc_counter <= 3'b0;
                        
                        lru_bit[saved_index] <= victim_way ? 1'b0 : 1'b1;
                        
                        if (was_read) begin
                            cpu_read_data <= data_block[saved_index][victim_way][saved_word_offset];
                            cache_stall <= 1'b0;
                            state <= IDLE;
                        end else begin
                            hit_way <= victim_way;
                            state <= WRITE_HIT;
                        end
                    end else begin
                        alloc_counter <= alloc_counter + 1;
                    end
                end
                
                default: begin
                    state <= IDLE;
                end
            endcase
        end
    end
endmodule

// ===== END 2-WAY SET-ASSOCIATIVE CACHE =====

// ===== DIRECT-MAPPED CACHE =====
// Direct-mapped cache (8KB, 32-byte blocks, write-back, write-allocate)
/*
module cache_controller(
    input wire clk,
    input wire reset,
    input wire cpu_read,
    input wire cpu_write,
    input wire [31:0] cpu_addr,
    input wire [31:0] cpu_write_data,
    output reg [31:0] cpu_read_data,
    output reg cache_stall,
    output reg mem_write_en,
    output reg [31:0] mem_write_addr,
    output reg [31:0] mem_write_data,
    output reg mem_read_en,
    output reg [31:0] mem_read_addr,
    input wire [31:0] mem_read_data
);
    // 8KB cache / 32 bytes per block = 256 blocks
    // Direct-mapped: index = 8 bits
    // Block offset = 5 bits (32 bytes = 8 words)
    // Tag = 32 - 8 - 5 = 19 bits
    
    parameter INDEX_BITS = 8;
    parameter OFFSET_BITS = 5;
    parameter TAG_BITS = 19;
    parameter NUM_BLOCKS = 256;
    parameter WORDS_PER_BLOCK = 8;
    
    reg valid_bit [0:NUM_BLOCKS-1];
    reg dirty_bit [0:NUM_BLOCKS-1];
    reg [TAG_BITS-1:0] tag_field [0:NUM_BLOCKS-1];
    reg [31:0] data_block [0:NUM_BLOCKS-1][0:WORDS_PER_BLOCK-1];
    
    wire [TAG_BITS-1:0] addr_tag = cpu_addr[31:31-TAG_BITS+1];
    wire [INDEX_BITS-1:0] addr_index = cpu_addr[31-TAG_BITS:OFFSET_BITS];
    wire [2:0] addr_word_offset = cpu_addr[4:2];
    
    parameter IDLE = 3'b000;
    parameter COMPARE_TAG = 3'b001;
    parameter WRITE_BACK = 3'b010;
    parameter ALLOCATE = 3'b011;
    parameter WRITE_HIT = 3'b100;
    
    reg [2:0] state;
    reg [2:0] wb_counter;
    reg [2:0] alloc_counter;
    reg was_read;  // Remember if original request was read or write
    
    // Captured address components (stable during multi-cycle operations)
    reg [TAG_BITS-1:0] saved_tag;
    reg [INDEX_BITS-1:0] saved_index;
    reg [2:0] saved_word_offset;
    reg saved_cpu_read;
    reg saved_cpu_write;
    
    wire cache_hit = valid_bit[saved_index] && (tag_field[saved_index] == saved_tag);
    
    integer i, j;
    
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            state <= IDLE;
            cache_stall <= 1'b0;
            mem_write_en <= 1'b0;
            mem_read_en <= 1'b0;
            cpu_read_data <= 32'b0;
            wb_counter <= 3'b0;
            alloc_counter <= 3'b0;
            
            for (i = 0; i < NUM_BLOCKS; i = i + 1) begin
                valid_bit[i] <= 1'b0;
                dirty_bit[i] <= 1'b0;
                tag_field[i] <= {TAG_BITS{1'b0}};
                for (j = 0; j < WORDS_PER_BLOCK; j = j + 1) begin
                    data_block[i][j] <= 32'b0;
                end
            end
        end else begin
            case (state)
                IDLE: begin
                    cache_stall <= 1'b0;
                    mem_write_en <= 1'b0;
                    mem_read_en <= 1'b0;
                    
                    if (cpu_read || cpu_write) begin
                        // Capture address components and operation type for stable reference during multi-cycle operations
                        saved_tag <= addr_tag;
                        saved_index <= addr_index;
                        saved_word_offset <= addr_word_offset;
                        saved_cpu_read <= cpu_read;
                        saved_cpu_write <= cpu_write;
                        
                        state <= COMPARE_TAG;
                        cache_stall <= 1'b1;
                    end
                end
                
                COMPARE_TAG: begin
                    if (cache_hit) begin
                        if (saved_cpu_read) begin
                            cpu_read_data <= data_block[saved_index][saved_word_offset];
                            cache_stall <= 1'b0;
                            state <= IDLE;
                        end else if (saved_cpu_write) begin
                            state <= WRITE_HIT;
                        end
                    end else begin
                        // Save whether this is a read or write for later
                        was_read <= saved_cpu_read;
                        if (valid_bit[saved_index] && dirty_bit[saved_index]) begin
                            state <= WRITE_BACK;
                            wb_counter <= 3'b0;
                        end else begin
                            state <= ALLOCATE;
                            alloc_counter <= 3'b0;
                        end
                    end
                end
                
                WRITE_HIT: begin
                    data_block[saved_index][saved_word_offset] <= cpu_write_data;
                    dirty_bit[saved_index] <= 1'b1;
                    cache_stall <= 1'b0;
                    state <= IDLE;
                end
                
                WRITE_BACK: begin
                    mem_write_en <= 1'b1;
                    mem_write_addr <= {tag_field[saved_index], saved_index, wb_counter, 2'b00};
                    mem_write_data <= data_block[saved_index][wb_counter];
                    
                    if (wb_counter == 3'd7) begin
                        mem_write_en <= 1'b0;
                        state <= ALLOCATE;
                        alloc_counter <= 3'b0;
                        wb_counter <= 3'b0;
                    end else begin
                        wb_counter <= wb_counter + 1;
                    end
                end
                
                ALLOCATE: begin
                    mem_read_en <= 1'b1;
                    mem_read_addr <= {saved_tag, saved_index, alloc_counter, 2'b00};
                    
                    if (alloc_counter > 0 || mem_read_en) begin
                        data_block[saved_index][alloc_counter - 1] <= mem_read_data;
                    end
                    
                    if (alloc_counter == 3'd7) begin
                        data_block[saved_index][3'd7] <= mem_read_data;
                        
                        valid_bit[saved_index] <= 1'b1;
                        tag_field[saved_index] <= saved_tag;
                        dirty_bit[saved_index] <= 1'b0;
                        
                        mem_read_en <= 1'b0;
                        alloc_counter <= 3'b0;
                        
                        // Use saved request type, not current cpu_read/cpu_write
                        if (was_read) begin
                            cpu_read_data <= data_block[saved_index][saved_word_offset];
                            cache_stall <= 1'b0;
                            state <= IDLE;
                        end else begin
                            state <= WRITE_HIT;
                        end
                    end else begin
                        alloc_counter <= alloc_counter + 1;
                    end
                end
                
                default: begin
                    state <= IDLE;
                end
            endcase
        end
    end
endmodule
*/
// ===== END DIRECT-MAPPED CACHE =====

// Data memory - 64KB (16384 words)
module memoryFile (
    input  wire        clk,
    input  wire [31:0] addr,
    input  wire        writeEnable,
    input  wire [31:0] writeData,
    output wire [31:0] readData
);
    reg [31:0] mem [16383:0];
    integer i;
    initial begin
        for (i=0; i<16384; i=i+1) mem[i] = 32'd0;
    end

    always @(posedge clk) begin
        if (writeEnable)
            mem[addr[15:2]] <= writeData;
    end

    assign readData = mem[addr[15:2]];
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
    /* Test 6
        addi $t0, $0, 0 # base address
        addi $t1, $0, 100 # loop bound
        loop: lw $t2, 0($t0)
            addi $t0, $t0, 4
            addi $t1, $t1, -1
            bne $t1, $0, loop
        halt
    */
    /* Test 7
        addi $t0, $0, 0
        addi $t1, $0, 32
        loop2: lw $t2, 0($t0)
            lw $t3, 64($t0)
            sw $t2, 128($t0)
            addi $t0, $t0, 4
            addi $t1, $t1, -1
            bne $t1, $0, loop2
        halt
    */
    /* Test 8
        addi $t0, $0, 0
        addi $t1, $0, 8192
        addi $t2, $0, 32
        loop3: lw $t3, 0($t0)
            nop
            nop
            lw $t4, 0($t1)
            nop
            nop
            addi $t2, $t2, -1
            bne $t2, $0, loop3
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
        instructions[13] = 32'b000000_01010_01011_10001_00000_011000; // MUL
        instructions[14] = 32'b001000_00000_01000_0000_0000_0000_0100; // ADDI
        instructions[15] = 32'b100011_01000_10010_1111_1111_1111_1100; // LW
        instructions[16] = 32'b000000_10001_10010_10010_00000_100010; // SUB
        instructions[17] = 32'b000000_00000_10001_10010_00010_000000; // SLL
        instructions[18] = 32'b101011_01000_10010_0000_0000_0000_0000; // SW
        instructions[19] = 32'b111111_00000_00000_0000_0000_0000_0000; // HALT

        // Test 3
        instructions[20] = 32'b001000_00000_00100_0000_0000_0000_0110; // ADDI
        instructions[21] = 32'b000011_00000_00000_0000_0000_0001_1000; // JAL to factorial
        instructions[22] = 32'b101011_00010_00010_0000_0000_0000_0000; // SW
        instructions[23] = 32'b111111_00000_00000_0000_0000_0000_0000; // HALT
        instructions[24] = 32'b001000_11101_11101_1111_1111_1111_1000; // ADDI - Factorial 
        instructions[25] = 32'b101011_11101_00100_0000_0000_0000_0100; // SW
        instructions[26] = 32'b101011_11101_11111_0000_0000_0000_0000; // SW
        instructions[27] = 32'b001000_00000_01000_0000_0000_0000_0010; // ADDI
        instructions[28] = 32'b000000_00100_01000_01000_00000_101010; // SLT
        instructions[29] = 32'b000100_01000_00000_0000_0000_0000_0011; // BEQ
        instructions[30] = 32'b001000_00000_00010_0000_0000_0000_0001; // ADDI
        instructions[31] = 32'b001000_11101_11101_0000_0000_0000_1000; // ADDI
        instructions[32] = 32'b000000_11111_00000_00000_00000_001000; // JR $ra
        instructions[33] = 32'b001000_00100_00100_1111_1111_1111_1111; // ADDI - else
        instructions[34] = 32'b000011_00000_00000_0000_0000_0001_1000; // JAL to factorial
        instructions[35] = 32'b100011_11101_11111_0000_0000_0000_0000; // LW 
        instructions[36] = 32'b100011_11101_00100_0000_0000_0000_0100; // LW 
        instructions[37] = 32'b001000_11101_11101_0000_0000_0000_1000; // ADDI
        instructions[38] = 32'b000000_00100_00010_00010_00000_011000; // MUL
        instructions[39] = 32'b000000_11111_00000_00000_00000_001000; // JR

        // Test 4
        instructions[40] = 32'b001000_00000_01000_0000_0000_0000_1000; // ADDI $t0, $0, 8
        instructions[41] = 32'b001000_00000_01001_0000_0000_0000_1111; // ADDI $t1, $0, 15
        instructions[42] = 32'b101011_01000_01001_0000_0000_0000_0000; // SW $t1, 0($t0)
        instructions[43] = 32'b100011_01000_01010_0000_0000_0000_0000; // LW $t2, 0($t0)
        instructions[44] = 32'b000000_01001_01010_01011_00000_100000; // ADD $t3, $t1, $t2
        instructions[45] = 32'b000100_01011_01010_0000_0000_0000_0010; // BEQ $t3, $t2, label (+2)
        instructions[46] = 32'b000000_01011_01001_01100_00000_100010; // SUB $t4, $t3, $t1
        instructions[47] = 32'b000000_01100_01011_10000_00000_100000; // ADD $s0, $t4, $t3 (label)
        instructions[48] = 32'b111111_00000_00000_0000_0000_0000_0000; // HALT

        // Test 5
        instructions[49] = 32'b001000_00000_01000_0000_0000_0000_0100; // ADDI
        instructions[50] = 32'b001000_00000_01001_0000_0000_0000_0101; // ADDI
        instructions[51] = 32'b000000_01000_01001_01010_00000_100000; // ADD
        instructions[52] = 32'b000000_01010_01001_01011_00000_100010; // SUB
        instructions[53] = 32'b000000_01011_01010_01100_00000_100100; // AND
        instructions[54] = 32'b000000_01100_01000_01101_00000_100101; // OR
        instructions[55] = 32'b101011_01000_01101_0000_0000_0000_0000; // SW
        instructions[56] = 32'b111111_00000_00000_0000_0000_0000_0000; // HALT

        // Test 6
        instructions[57] = 32'b001000_00000_01000_0000_0000_0000_0000; // ADDI $t0, $0, 0
        instructions[58] = 32'b001000_00000_01001_0000_0000_0110_0100; // ADDI $t1, $0, 100
        instructions[59] = 32'b100011_01000_01010_0000_0000_0000_0000; // LW $t2, 0($t0)
        instructions[60] = 32'b001000_01000_01000_0000_0000_0000_0100; // ADDI $t0, $t0, 4
        instructions[61] = 32'b001000_01001_01001_1111_1111_1111_1111; // ADDI $t1, $t1, -1
        instructions[62] = 32'b000101_01001_00000_1111_1111_1111_1100; // BNE $t1, $0, loop (-4)
        instructions[63] = 32'b111111_00000_00000_0000_0000_0000_0000; // HALT

        // Test 7
        instructions[64] = 32'b001000_00000_01000_0000_0000_0000_0000; // ADDI $t0, $0, 0
        instructions[65] = 32'b001000_00000_01001_0000_0000_0010_0000; // ADDI $t1, $0, 32
        instructions[66] = 32'b100011_01000_01010_0000_0000_0000_0000; // LW $t2, 0($t0)
        instructions[67] = 32'b100011_01000_01011_0000_0000_0100_0000; // LW $t3, 64($t0)
        instructions[68] = 32'b101011_01000_01010_0000_0000_1000_0000; // SW $t2, 128($t0)
        instructions[69] = 32'b001000_01000_01000_0000_0000_0000_0100; // ADDI $t0, $t0, 4
        instructions[70] = 32'b001000_01001_01001_1111_1111_1111_1111; // ADDI $t1, $t1, -1
        instructions[71] = 32'b000101_01001_00000_1111_1111_1111_1010; // BNE $t1, $0, loop2 (-6)
        instructions[72] = 32'b111111_00000_00000_0000_0000_0000_0000; // HALT

        // Test 8: Conflict test - accesses address 0 and 8192 (0x2000) which conflict in direct-mapped
        // Both addresses have index=0 (bits 5-12 are all 0) but different tags
        // Direct-mapped: will thrash, evicting and reloading same cache line repeatedly (many misses)
        // 2-way: both blocks fit in same set (index 0) using different ways (few misses)
        instructions[73] = 32'b001000_00000_01000_0000_0000_0000_0000; // ADDI $t0, $0, 0
        instructions[74] = 32'b001000_00000_01001_0010_0000_0000_0000; // ADDI $t1, $0, 8192 (0x2000)
        instructions[75] = 32'b001000_00000_01010_0000_0000_0010_0000; // ADDI $t2, $0, 32 (loop counter)
        instructions[76] = 32'b100011_01000_01011_0000_0000_0000_0000; // loop3: LW $t3, 0($t0)
        instructions[77] = 32'b000000_00000_00000_00000_00000_000000; // NOP
        instructions[78] = 32'b000000_00000_00000_00000_00000_000000; // NOP
        instructions[79] = 32'b100011_01001_01100_0000_0000_0000_0000; // LW $t4, 0($t1)
        instructions[80] = 32'b000000_00000_00000_00000_00000_000000; // NOP
        instructions[81] = 32'b000000_00000_00000_00000_00000_000000; // NOP
        instructions[82] = 32'b001000_01010_01010_1111_1111_1111_1111; // ADDI $t2, $t2, -1
        instructions[83] = 32'b000101_01010_00000_1111_1111_1111_1000; // BNE $t2, $0, loop3 (-8)
        instructions[84] = 32'b111111_00000_00000_0000_0000_0000_0000; // HALT
    end
    always @(*) begin
        instruction_reg = instructions[pc];
    end
    
endmodule


// IF/ID register
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
            instr_out <= 32'b0;
            next_pc_out <= 32'b0;
        end else if (stall) begin
            instr_out <= instr_out;
            next_pc_out <= next_pc_out;
        end else if (flush) begin
            instr_out <= 32'b0;
            next_pc_out <= 32'b0;
        end else begin
            instr_out <= instr_in;
            next_pc_out <= next_pc_in;
        end
    end
endmodule

// ID/EX register
module ID_EX_reg(
    input wire clk,
    input wire reset,
    input wire stall,
    input wire flush,
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
    input wire BranchNotEqual_in,
    input wire ALUSrc_in,
    input wire [3:0] ALUOp_in,
    input wire JAL_in,
    input wire [31:0] link_in,
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
    output reg BranchNotEqual_out,
    output reg ALUSrc_out,
    output reg [3:0] ALUOp_out, 
    output reg Halt_out,
    output reg JAL_out,
    output reg [31:0] link_out
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
            BranchNotEqual_out <= 1'b0;
            ALUSrc_out <= 1'b0;
            ALUOp_out <= 4'b0000;
            Halt_out <= 1'b0;
            JAL_out <= 1'b0;
            link_out <= 32'b0;
        end else if (flush) begin
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
            BranchNotEqual_out <= 1'b0;
            ALUSrc_out <= 1'b0;
            ALUOp_out <= 4'b0000;
            Halt_out <= 1'b0;
            JAL_out <= 1'b0;
            link_out <= 32'b0;
        end else if (stall) begin
            RegWrite_out <= 1'b0;
            MemRead_out <= 1'b0;
            MemWrite_out <= 1'b0;
            MemToReg_out <= 1'b0;
            RegDst_out <= 1'b0;
            Branch_out <= 1'b0;
            BranchNotEqual_out <= 1'b0;
            ALUSrc_out <= 1'b0;
            ALUOp_out <= 4'b0000;
            Halt_out <= 1'b0;
            JAL_out <= 1'b0;
            link_out <= 32'b0;
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
            BranchNotEqual_out <= BranchNotEqual_in;
            ALUSrc_out <= ALUSrc_in;
            ALUOp_out <= ALUOp_in;
            Halt_out <= Halt_in;
            JAL_out <= JAL_in;
            link_out <= link_in;
        end
    end
endmodule

// EX/MEM register
module EX_MEM_reg(
    input wire clk,
    input wire reset,
    input wire Halt_in,
    input wire JAL_in,
    input wire [31:0] link_in,
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
    output reg MemToReg_out, 
    output reg Halt_out, 
    output reg JAL_out, 
    output reg [31:0] link_out
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
            JAL_out <= 1'b0;
            link_out <= 32'b0;
        end else begin
            alu_result_out <= alu_result_in;
            write_data_out <= write_data_in;
            write_reg_out <= write_reg_in;
            RegWrite_out <= RegWrite_in;
            MemRead_out <= MemRead_in;
            MemWrite_out <= MemWrite_in;
            MemToReg_out <= MemToReg_in;
            Halt_out <= Halt_in;
            JAL_out <= JAL_in;
            link_out <= link_in;
        end
    end
endmodule

// MEM/WB register
module MEM_WB_reg(
    input wire clk,
    input wire reset,
    input wire Halt_in,
    input wire JAL_in,
    input wire [31:0] link_in,
    input wire [31:0] mem_read_in,
    input wire [31:0] alu_result_in,
    input wire [4:0] write_reg_in,
    input wire RegWrite_in,
    input wire MemToReg_in,
    output reg [31:0] mem_read_out,
    output reg [31:0] alu_result_out,
    output reg [4:0] write_reg_out,
    output reg RegWrite_out,
    output reg MemToReg_out, 
    output reg Halt_out, 
    output reg JAL_out, 
    output reg [31:0] link_out
);
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            mem_read_out <= 32'b0;
            alu_result_out <= 32'b0;
            write_reg_out <= 5'b0;
            RegWrite_out <= 1'b0;
            MemToReg_out <= 1'b0;
            Halt_out <= 1'b0;
            JAL_out <= 1'b0;
            link_out <= 32'b0;
        end else begin
            mem_read_out <= mem_read_in;
            alu_result_out <= alu_result_in;
            write_reg_out <= write_reg_in;
            RegWrite_out <= RegWrite_in;
            MemToReg_out <= MemToReg_in;
            Halt_out <= Halt_in;
            JAL_out <= JAL_in;
            link_out <= link_in;
        end
    end
endmodule

// Control signals
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
    output reg BranchNotEqual,
    output reg [3:0] ALUOp,
    output reg ExtOp
);
    always @(*) begin
        RegWrite = 1'b0;
        MemRead  = 1'b0;
        MemWrite = 1'b0;
        MemToReg = 1'b0;
        ALUSrc   = 1'b0;
        RegDst   = 1'b0;
        Branch   = 1'b0;
        BranchNotEqual = 1'b0;
        ALUOp    = 4'b1111;
        ExtOp    = 1'b0;

        case (opcode)
            6'b000000: begin
                RegWrite = 1'b1;
                ALUSrc = 1'b0;
                RegDst = 1'b1;
                case (funct)
                    6'b100000: ALUOp = 4'b0000; // ADD (32)
                    6'b011000: ALUOp = 4'b0001; // MUL (24)
                    6'b100100: ALUOp = 4'b0010; // AND (36)
                    6'b100101: ALUOp = 4'b0011; // OR  (37)
                    6'b100111: ALUOp = 4'b0101; // NOR (39)
                    6'b000000: begin ALUOp = 4'b0110; ALUSrc = 1'b1; end // SLL (0)
                    6'b000010: begin ALUOp = 4'b0111; ALUSrc = 1'b1; end // SRL (2)
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
                ExtOp = 1'b0;
            end
            6'b100011: begin
                RegWrite = 1'b1;
                MemRead = 1'b1;
                MemToReg = 1'b1;
                ALUSrc = 1'b1;
                RegDst = 1'b0;
                ALUOp = 4'b0000;
            end
            6'b101011: begin
                MemWrite = 1'b1;
                ALUSrc = 1'b1;
                ALUOp = 4'b0000;
            end
            6'b000100: begin // BEQ
                Branch = 1'b1;
                BranchNotEqual = 1'b0;
                ALUSrc = 1'b0;
                ALUOp =  4'b1001;
            end
            6'b000101: begin // BNE
                Branch = 1'b1;
                BranchNotEqual = 1'b1;
                ALUSrc = 1'b0;
                ALUOp =  4'b1001;
            end
            6'b001100: begin
                RegWrite = 1'b1;
                ALUSrc = 1'b1;
                RegDst = 1'b0;
                ALUOp = 4'b0010;
                ExtOp = 1'b1;
            end
            6'b001101: begin
                RegWrite = 1'b1;
                ALUSrc = 1'b1;
                RegDst = 1'b0;
                ALUOp = 4'b0011;
                ExtOp = 1'b1;
            end
            default: begin
            end
        endcase
    end
endmodule

// Forwarding
module forwarding_unit(
    input wire enable_forwarding,
    input wire EX_MEM_RegWrite,
    input wire [4:0] EX_MEM_Rd,
    input wire MEM_WB_RegWrite,
    input wire [4:0] MEM_WB_Rd,
    input wire [4:0] ID_EX_Rs,
    input wire [4:0] ID_EX_Rt,
    output reg [1:0] ForwardA,
    output reg [1:0] ForwardB
);
    always @(*) begin
        ForwardA = 2'b00;
        ForwardB = 2'b00;

        if (enable_forwarding) begin
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
    end
endmodule

// Hazard detection unit
module hazard_unit(
    input wire enable_hazard_detection,
    input wire enable_forwarding,
    input wire ID_EX_MemRead,
    input wire [4:0] ID_EX_Rt,
    input wire ID_EX_RegWrite,
    input wire [4:0] ID_EX_Rd,
    input wire EX_MEM_RegWrite,
    input wire [4:0] EX_MEM_Rd,
    input wire [4:0] IF_ID_Rs,
    input wire [4:0] IF_ID_Rt,
    output reg stall
);
    wire is_load = ID_EX_MemRead;
    wire load_dest_valid = (ID_EX_Rt != 5'b0);
    wire load_rs_match = (ID_EX_Rt == IF_ID_Rs);
    wire load_rt_match = (ID_EX_Rt == IF_ID_Rt);
    wire load_use_hazard = is_load && load_dest_valid && (load_rs_match || load_rt_match);
    
    wire idex_dest_valid = (ID_EX_Rd != 5'b0);
    wire idex_rs_match = (ID_EX_Rd == IF_ID_Rs);
    wire idex_rt_match = (ID_EX_Rd == IF_ID_Rt);
    wire idex_raw_hazard = ID_EX_RegWrite && idex_dest_valid && (idex_rs_match || idex_rt_match);
    
    wire exmem_dest_valid = (EX_MEM_Rd != 5'b0);
    wire exmem_rs_match = (EX_MEM_Rd == IF_ID_Rs);
    wire exmem_rt_match = (EX_MEM_Rd == IF_ID_Rt);
    wire exmem_raw_hazard = EX_MEM_RegWrite && exmem_dest_valid && (exmem_rs_match || exmem_rt_match);
    
    always @(*) begin
        if (!enable_hazard_detection) begin
            stall = 1'b0;
        end else if (enable_forwarding) begin
            stall = load_use_hazard;
        end else begin
            stall = load_use_hazard || idex_raw_hazard || exmem_raw_hazard;
        end
    end

endmodule

module pipeline_processor_tb;
    reg clk;
    reg reset;

    
    wire done;
    pipelined_processor DUT(
        .clk(clk),
        .reset(reset),
        .initial_pc(73),
        .enable_forwarding(1'b1), // enable forwarding
        .enable_hazard_detection(1'b1), // enable hazard detection
        .done(done)
    );

    initial begin
        clk = 1;
        forever begin
            #5 clk = ~clk;
        end
    end

    integer cycle_count;
    integer branch_count;
    integer cache_accesses;
    integer cache_hits;
    integer cache_misses;
    real hit_rate;
    reg [2:0] prev_cache_state;
    reg prev_exmem_memread;
    reg prev_exmem_memwrite;
    reg [31:0] prev_exmem_addr;
    
    initial begin
        $dumpfile("hw_cached.vcd");
        $dumpvars(0, pipeline_processor_tb);

        reset = 1;
        cycle_count = 0;
        branch_count = 0;
        cache_accesses = 0;
        cache_hits = 0;
        cache_misses = 0;
        prev_cache_state = 3'b000;
        prev_exmem_memread = 0;
        prev_exmem_memwrite = 0;
        prev_exmem_addr = 0;
        #9;
        reset = 0;

        #10000;
        $display("TIMEOUT after %d cycles", cycle_count);
        $display("Branches taken: %d", branch_count);
        $display("Final PC: %d", DUT.pc);
        $display("Final $t1 (r9): %d (0x%h)", DUT.regFile.registers[9], DUT.regFile.registers[9]);
        $display("Final $t0 (r8): %d", DUT.regFile.registers[8]);
        $display("");
        $display("===== Cache Statistics =====");
        $display("Total memory accesses: %d", cache_accesses);
        $display("Cache hits:            %d", cache_hits);
        $display("Cache misses:          %d", cache_misses);
        if (cache_accesses > 0) begin
            hit_rate = (cache_hits * 100.0) / cache_accesses;
            $display("Hit rate:              %.2f%%", hit_rate);
        end
        $finish;
    end

    // Watch for done and finish immediately
    always @(posedge clk) begin
        if (done) begin
            $display("Program completed at time %t", $time);
            $display("Total cycles: %d, Branches taken: %d", cycle_count, branch_count);
            $display("Final $t0 (r8): %d, Final $t1 (r9): %d", DUT.regFile.registers[8], DUT.regFile.registers[9]);
            $display("");
            $display("===== Cache Statistics =====");
            $display("Total memory accesses: %d", cache_accesses);
            $display("Cache hits:            %d", cache_hits);
            $display("Cache misses:          %d", cache_misses);
            if (cache_accesses > 0) begin
                hit_rate = (cache_hits * 100.0) / cache_accesses;
                $display("Hit rate:              %.2f%%", hit_rate);
            end
            #1 $finish;
        end
        if (!reset) begin
            cycle_count = cycle_count + 1;
            if (DUT.branch_taken) begin
                branch_count = branch_count + 1;
            end

            // Track memory accesses and hits/misses when cache enters COMPARE_TAG state
            // This counts actual cache accesses, which is the most accurate metric
            if (DUT.cache.state == DUT.cache.COMPARE_TAG && prev_cache_state != DUT.cache.COMPARE_TAG) begin
                cache_accesses = cache_accesses + 1;
                
                if (DUT.cache.cache_hit) begin
                    cache_hits = cache_hits + 1;
                    if (cache_accesses <= 30) begin
                        $display("  Access %d: HIT - addr=0x%h, R=%b W=%b", 
                                 cache_accesses, {DUT.cache.saved_tag, DUT.cache.saved_index, DUT.cache.saved_word_offset, 2'b00},
                                 DUT.cache.saved_cpu_read, DUT.cache.saved_cpu_write);
                    end
                end else begin
                    cache_misses = cache_misses + 1;
                    if (cache_accesses <= 30) begin
                        $display("  Access %d: MISS - addr=0x%h, R=%b W=%b", 
                                 cache_accesses, {DUT.cache.saved_tag, DUT.cache.saved_index, DUT.cache.saved_word_offset, 2'b00},
                                 DUT.cache.saved_cpu_read, DUT.cache.saved_cpu_write);
                    end
                end
            end
            
            prev_cache_state = DUT.cache.state;
            prev_exmem_memread = DUT.exmem_MemRead_out;
            prev_exmem_memwrite = DUT.exmem_MemWrite_out;
            prev_exmem_addr = DUT.exmem_alu_result_out;
        end
    end
    


endmodule
