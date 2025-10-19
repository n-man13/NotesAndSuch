module processor ( input [31:0] instruction );
    // Simple single-cycle processor
    reg clk, write_enable_mem, write_enable_reg;
    wire [5:0] read_reg1, read_reg2, write_reg;
    wire [31:0] alu_result, mem_address, mem_data, reg_data1, reg_data2, write_data, read_data;

    clock myClock(clk);
    
    memoryFile mem( mem_address, write_enable_mem, mem_data, read_data);
    
    registerFile regFile( .readReg1(read_reg1), .readReg2(read_reg2), 
    .writeReg(write_reg), .writeData(write_data), .writeEnable(write_enable_reg), 
    .readData1(reg_data1), .readData2(reg_data2));

    wire [5:0] opcode;
    wire [5:0] funct;
    wire [4:0] rs, rt, rd, base;
    wire [15:0] immediate;
    wire [2:0] ALU_Sel;
    wire [31:0] ANDI_in, ADDI_in, ADDI_out, ORI_in;

    alu myALU (.A(rs), .B(rt), .ALU_Sel(ALU_Sel), .ALU_Out(write_data));
    andi myANDI (.reg_in(ANDI_in), .reg_out(write_data), .immediate(immediate));
    addi myADDI (.reg_in(ADDI_in), .reg_out(ADDI_out), .immediate(immediate));
    ori myORI (.reg_in(ORI_in), .reg_out(write_data), .immediate(immediate));

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
                        // MULT
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
                ADDI_out = write_data;
                write_enable_reg = 0;
            end
            default: result = 32'b0;
            43: begin
                // SW instruction
                base = instruction[25:21];
                rt = instruction[20:16];
                immediate = instruction[15:0];
                read_reg1 = base;
                read_reg2 = rt;
                // Calculate memory address
                ADDI_in = reg_data1;
                ADDI_out = mem_address;
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
                ADDI_out = mem_address;
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
                ORI_in = reg_data1;
                write_enable_reg = 0;
            end

            default: ; // do nothing
        endcase
    end
endmodule