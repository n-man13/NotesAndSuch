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
    
    memoryFile mem( mem_address, write_enable_mem, mem_data, read_data_wire);
    
    registerFile regFile( .readReg1(read_reg1), .readReg2(read_reg2), .writeReg(write_reg), .writeData(write_data), .writeEnable(write_enable_reg), .readData1(reg_data1), .readData2(reg_data2));

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
        pc = pc + 1;
    end

    always @(*) begin
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
                        write_enable_reg = 1;
                        if (a < b)
                            write_data = 32'b1;
                        else
                            write_data = 32'b0;
                        write_enable_reg = 0;
                    end
                endcase
                write_data = ALU_out_wire;
                #1;
                write_enable_reg = 0;
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
                #1;
                write_enable_reg = 0;
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
                #1;
                write_enable_mem = 0;
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
                #1;
                write_enable_reg = 0;
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
                #1;
                write_enable_reg = 0;
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
                #1;
                write_enable_reg = 0;
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
