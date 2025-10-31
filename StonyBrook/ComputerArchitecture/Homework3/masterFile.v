`timescale 1ns / 1ps
module processor ( input [31:0] initial_pc);
    // Simple single-cycle processor
    wire clk;
    reg write_enable_mem, write_enable_reg;
    reg [4:0] read_reg1, read_reg2, write_reg;
    reg [31:0] mem_address, mem_data, a, b, write_data;

    reg [5:0] opcode;
    reg [5:0] funct;
    reg [4:0] rs, rt, rd, base;
    reg [15:0] immediate;
    reg [2:0] ALU_Sel;
    wire [15:0] immediate_wire;
    reg [31:0] ANDI_in, ADDI_in, ORI_in;
    wire [31:0] ANDI_in_wire, ADDI_in_wire, ORI_in_wire, ANDI_out_wire, ADDI_out_wire, ORI_out_wire, ALU_out_wire, reg_data1, reg_data2, read_data_wire;

    clock myClock(.clk(clk));

    reg [31:0] pc;
    //reg [31:0] instruction_reg;
    wire [31:0] instruction;
    initial pc = initial_pc;

    programMem prog_mem ( .pc(pc), .instruction(instruction));

    memoryFile mem( .clk(clk), .addr(mem_address), .writeEnable(write_enable_mem), .writeData(mem_data), .readData(read_data_wire));

    registerFile regFile( .clk(clk),.readReg1(read_reg1), .readReg2(read_reg2), .writeReg(write_reg), .writeData(write_data), .writeEnable(write_enable_reg), .readData1(reg_data1), .readData2(reg_data2));

    alu myALU (.A(a), .B(b), .ALU_Sel(ALU_Sel), .ALU_Out(ALU_out_wire)); 
    andi myANDI (.reg_in(ANDI_in_wire), .reg_out(ANDI_out_wire), .immediate(immediate_wire));
    addi myADDI (.reg_in(ADDI_in_wire), .reg_out(ADDI_out_wire), .immediate(immediate_wire));
    ori myORI (.reg_in(ORI_in_wire), .reg_out(ORI_out_wire), .immediate(immediate_wire));

    assign ANDI_in_wire = ANDI_in;
    assign ORI_in_wire = ORI_in;
    assign ADDI_in_wire = ADDI_in;
    assign immediate_wire = instruction[15:0];
    assign write_enable = write_enable_reg;

    always @(posedge clk) begin
        pc <= pc + 1;
    end

    always @(*) begin
        write_enable_mem = 0;
        write_enable_reg = 0;
        // Decode instruction
        opcode = instruction[31:26];
        case (opcode)
            0: begin
                // R-type instructions
                rs = instruction[25:21];
                rt = instruction[20:16];
                rd = instruction[15:11];
                funct = instruction[5:0];
                read_reg1 = rs;
                read_reg2 = rt;
                a = reg_data1;
                b = reg_data2;
                write_reg = rd;
                write_enable_reg = 1;
                case (funct )
                    32: begin
                        // ADD
                        ALU_Sel = 3'b000;
                    end
                    36: begin
                        // AND
                        ALU_Sel = 3'b010;
                    end
                    24: begin
                        // MUL
                        ALU_Sel = 3'b001;
                    end
                    37: begin
                        // OR
                        ALU_Sel = 3'b011;
                    end
                    39: begin
                        // NOR
                        ALU_Sel = 3'b101;
                    end
                    0: begin
                        // SLL
                        ALU_Sel = 3'b110;
                    end
                    2: begin
                        // SRL
                        ALU_Sel = 3'b111;
                    end
                    8: begin
                        // JR
                        pc = reg_data1 - 1;
                    end
                    42: begin
                        // SLT
                        if (a < b)
                            write_data = 32'b1;
                        else
                            write_data = 32'b0;
                    end
                endcase
                write_data = ALU_out_wire;
            end
            8: begin
                // ADDI instruction
                rs = instruction[25:21];
                rt = instruction[20:16];
                read_reg1 = rs;
                write_reg = rt;
                ADDI_in = reg_data1;
                write_enable_reg = 1;
                write_data = ADDI_out_wire;
            end
            43: begin
                // SW instruction
                rs = instruction[25:21];
                rt = instruction[20:16];
                read_reg1 = base;
                read_reg2 = rt;
                // Calculate memory address
                ADDI_in = reg_data1;
                mem_address = ADDI_out_wire;
                write_enable_mem = 1;
                mem_data = reg_data2;
            end
            35: begin
                // LW instruction
                base = instruction[25:21];
                rt = instruction[20:16];
                read_reg1 = base;
                // Calculate memory address
                ADDI_in = reg_data1;
                mem_address = ADDI_out_wire;
                write_reg = rt;
                write_enable_reg = 1;
                write_data = read_data_wire;
            end
            36: begin
                // ANDI instruction
                rs = instruction[25:21];
                rt = instruction[20:16];
                read_reg1 = rs;
                ANDI_in = reg_data1;
                write_reg = rt;
                write_enable_reg = 1;
                write_data = ANDI_out_wire;
            end
            13: begin
                // ORI instruction
                rs = instruction[25:21];
                rt = instruction[20:16];
                read_reg1 = rs;
                write_reg = rt;
                ORI_in = reg_data1;
                write_enable_reg = 1;
                write_data = ORI_out_wire;
            end
            2: begin
                // J instruction
                pc = {pc[31:26], instruction[25:0]}-1;
            end
            4: begin
                // BEQ instruction
                rs = instruction[25:21];
                rt = instruction[20:16];
                read_reg1 = rs;
                read_reg2 = rt;
                if (reg_data1 == reg_data2) begin
                    pc = pc + {{14{instruction[15]}}, instruction[15:0]} - 1;
                end
            end
            5: begin
                // BNE instruction
                rs = instruction[25:21];
                rt = instruction[20:16];
                read_reg1 = rs;
                read_reg2 = rt;
                if (reg_data1 != reg_data2) begin
                    pc = pc + {{14{instruction[15]}}, instruction[15:0]} - 1;
                end
            end
            3: begin
                // JAL instruction
                write_reg = 5'b11111; // $ra
                write_enable_reg = 1;
                write_data = pc + 1;
                #1;
                write_enable_reg = 0;
                pc = {pc[31:26], instruction[25:0]} - 1;
            end
            6'b111111: begin
                // HALT instruction
                $finish;
            end 

            default:; // do nothing
        endcase
    end
endmodule

module alu ( input [31:0] A, input [31:0] B, input [2:0] ALU_Sel, output reg [31:0] ALU_Out );
    parameter ADD = 3'b000; // 32
    parameter MUL = 3'b001; // 24
    parameter AND = 3'b010; // 36
    parameter OR  = 3'b011; // 37
    parameter XOR = 3'b100; // 38
    parameter NOR = 3'b101; // 39
    parameter SLL = 3'b110; // 0
    parameter SRL = 3'b111; // 2
    always @(*) begin
        case (ALU_Sel)
            3'b000: ALU_Out = A + B;          // Addition
            3'b001: ALU_Out = (A * B);        // Multiplication
            3'b010: ALU_Out = A & B;          // Bitwise AND
            3'b011: ALU_Out = A | B;          // Bitwise OR
            3'b100: ALU_Out = A ^ B;          // Bitwise XOR
            3'b101: ALU_Out = ~(A | B);       // Bitwise NOR
            3'b110: ALU_Out = A << B[4:0];         // Logical left shift
            3'b111: ALU_Out = A >> B[4:0];         // Logical right shift
            default: ALU_Out = 8'b00000000;   // Default case set to zero
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
    reg [31:0] instructions [31:0];
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
        lw $s2, ‐4($t0)
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
factorial: addi $sp, $sp, ‐8
        sw $a0, 4($sp)
        sw $ra, 0($sp)
        addi $t0, $0, 2
        slt $t0, $a0, $t0
        beq $t0, $0, else
        addi $v0, $0, 1
        addi $sp, $sp, 8
        jr $ra
        else: addi $a0, $a0, ‐1
        jal factorial
        lw $ra, 0($sp)
        lw $a0, 4($sp)
        addi $sp, $sp, 8
        mul $v0, $a0, $v0
        jr $ra
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
        /* instructions[1] = 32'b001000_00000_00100_0000_0000_0000_0110; // ADDI
        instructions[2] = 32'b000011_00000_00000_0000_0000_0001_0100; // JAL
        instructions[3] = 32'b101011_00010_00010_0000_0000_0000_0000; // SW
        instructions[4] = 32'b111111_00000_00000_0000_0000_0000_0000; // HALT
        instructions[5] = 32'b001000_11101_11101_1111_1111_1111_1000; // ADDI -- Factorial function starts here
        instructions[6] = 32'b101011_11101_00100_0000_0000_0000_0100; // SW
        instructions[7] = 32'b101011_11101_11111_0000_0000_0000_0000; // SW
        instructions[8] = 32'b001000_00000_01000_0000_0000_0000_0010; // ADDI
        instructions[9] = 32'b000000_00100_01000_01000_00000_101010; // SLT
        instructions[10] = 32'b000100_01000_00000_0000_0000_0000_0011; // BEQ
        instructions[11] = 32'b001000_00000_00010_0000_0000_0000_0001; // ADDI
        instructions[12] = 32'b001000_00000_00010_0000_0000_0000_0001; // ADDI
        instructions[13] = 32'b001000_00010_11111_0000_0000_0000_1000; // ADDI
        instructions[14] = 32'b000011_00000_00000_0000_0000_0001_0100; // JAL
        instructions[15] = 32'b100011_11101_11111_0000_0000_0000_0000; // LW
        instructions[16] = 32'b100011_11101_00100_0000_0000_0000_0100; // LW
        instructions[17] = 32'b001000_11101_11101_0000_0000_0000_1000; // ADDI
        instructions[18] = 32'b000000_00100_11111_00010_00000_000010; // MUL
        instructions[19] = 32'b000000_00000_00000_00000_00000_000000; // HALT */

    end
    always @(*) begin
        instruction_reg = instructions[pc]; // this works
    end
    
endmodule

`timescale 1ns/1ps
module clock ( output reg clk );
    initial begin
        clk = 1;
        forever begin
            #5;
            clk = ~clk;
        end
    end
endmodule

module addi ( input [31:0] reg_in, output [31:0] reg_out, input [15:0] immediate);
    // Add immediate value to register
    // sign extend value
    wire [31:0] sign_extended_value;
    assign sign_extended_value = {{16{immediate[15]}}, immediate[15:0]};

    alu myADDI_ALU (.A(reg_in), .B(sign_extended_value), .ALU_Sel(3'b000), .ALU_Out(reg_out));
endmodule

module andi ( input [31:0] reg_in, output [31:0] reg_out, input [15:0] immediate);
    // AND immediate value to register
    // zero extend value
    wire [31:0] zero_extended_value;
    assign zero_extended_value = {{16'b0000000000000000}, immediate[15:0]};
    alu myALU (.A(reg_in), .B(zero_extended_value), .ALU_Sel(3'b010), .ALU_Out(reg_out));
endmodule

module ori ( input [31:0] reg_in , output [31:0] reg_out, input [15:0] immediate);
    // OR immediate value to register
    // zero extend immediate
    wire [31:0] zero_extended_immediate;
    assign zero_extended_immediate = {{16'b0000000000000000}, immediate[15:0]};
    alu myALU (.A(reg_in), .B(zero_extended_immediate), .ALU_Sel(3'b011), .ALU_Out(reg_out));
endmodule

module processor_tb;

    wire clk;
    initial begin
        $dumpfile("hw2.vcd");
        $dumpvars(0, processor_tb);
        //$stop;
        #200; // Run simulation for 200 time units
        
    end
    processor myProcessor(.initial_pc(0));

endmodule