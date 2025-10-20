module processor ( input [31:0] initial_pc);
    // Simple single-cycle processor
    reg clk, write_enable_mem, write_enable_reg;
    reg [5:0] read_reg1, read_reg2, write_reg;
    reg [31:0] mem_address, mem_data, reg_data1, reg_data2, write_data, read_data;

    clock myClock(clk);

    reg [31:0] pc, instruction;
    initial pc = initial_pc;
    programMem prog_mem (.pc(pc), .instruction(instruction));
    
    memoryFile mem( mem_address, write_enable_mem, mem_data, read_data);
    
    registerFile regFile( .readReg1(read_reg1), .readReg2(read_reg2), .writeReg(write_reg), .writeData(write_data), .writeEnable(write_enable_reg), .readData1(reg_data1), .readData2(reg_data2));

    reg [5:0] opcode;
    reg [5:0] funct;
    reg [4:0] rs, rt, rd, base;
    reg [15:0] immediate;
    wire [2:0] ALU_Sel;
    wire [15:0] immediate_wire;
    wire [31:0] ANDI_in, ADDI_in, ADDI_out, ORI_in, a, b, ALU_Out, ANDI_out, ORI_out;

    alu myALU (.A(a), .B(b), .ALU_Sel(ALU_Sel), .ALU_Out(ALU_Out)); // TODO: cant use reg as variable, must be wires
    andi myANDI (.reg_in(ANDI_in), .reg_out(ANDI_out), .immediate(immediate_wire));
    addi myADDI (.reg_in(ADDI_in), .reg_out(ADDI_out), .immediate(immediate_wire));
    ori myORI (.reg_in(ORI_in), .reg_out(ORI_out), .immediate(immediate_wire));
    assign immediate_wire = immediate;

    always @(posedge clk) begin
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
                endcase
                write_data = ALU_Out;
                write_enable_reg = 0;
            end
            8: begin
                // ADDI instruction
                rs = instruction[25:21];
                rt = instruction[20:16];
                immediate = instruction[15:0];
                read_reg1 = rs;
                write_reg = rt;
                ADDI_in = reg_data1;
                write_enable_reg = 1;
                write_data = ADDI_out;
                write_enable_reg = 0;
            end
            default: ; // do nothing for now
            43: begin
                // SW instruction
                base = instruction[25:21];
                rt = instruction[20:16];
                immediate = instruction[15:0];
                read_reg1 = base;
                read_reg2 = rt;
                // Calculate memory address
                ADDI_in = reg_data1;
                mem_address = ADDI_out;
                write_enable_mem = 1;
                mem_data = reg_data2;
                write_enable_mem = 0;
            end
            35: begin
                // LW instruction
                base = instruction[25:21];
                rt = instruction[20:16];
                immediate = instruction[15:0];
                read_reg1 = base;
                // Calculate memory address
                ADDI_in = reg_data1;
                mem_address = ADDI_out;
                write_reg = rt;
                write_enable_reg = 1;
                write_data = read_data;
                write_enable_reg = 0;
            end
            36: begin
                // ANDI instruction
                rs = instruction[25:21];
                rt = instruction[20:16];
                immediate = instruction[15:0];
                read_reg1 = rs;
                ANDI_in = reg_data1;
                write_reg = rt;
                write_enable_reg = 1;
                write_enable_reg = 0;
            end
            13: begin
                // ORI instruction
                rs = instruction[25:21];
                rt = instruction[20:16];
                immediate = instruction[15:0];
                read_reg1 = rs;
                write_reg = rt;
                ORI_in = reg_data1;
                write_enable_reg = 1;
                write_enable_reg = 0;
            end
            2: begin
                // J instruction
                pc = {pc[31:26], instruction[25:0]}-1;
            end

            default: $finish; // do nothing
        endcase
        pc = pc + 1;
    end
endmodule
