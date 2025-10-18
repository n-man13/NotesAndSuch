module processor ( input [31:0] instruction );
    // Simple single-cycle processor
    wire clk, write_enable;
    wire [7:0] read_reg1, read_reg2, write_reg;
    wire [31:0] alu_result, mem_address, mem_data, reg_data1, reg_data2, write_data;
    clock myClock(clk);
    memoryFile mem( mem_address, mem_data);
    registerFile regFile( .readReg1(read-reg1), .readReg2(read_reg2), 
    .writeReg(write_reg), .writeData(write_data), .writeEnable(write_enable), 
    .readData1(reg_data1), .readData2(reg_data2));

    always @(posedge clk) begin
    // Decode instruction
    wire [5:0] opcode = instruction[31:26];
    case (opcode)
        0: begin
            // R-type instruction
            wire [4:0] rs = instruction[25:21];
            wire [4:0] rt = instruction[20:16];
            wire [4:0] rd = instruction[15:11];
            wire [5:0] funct = instruction[5:0];
            write_reg = rd;
            write_enable = 1;
            case (funct )
                32: begin
                    // ADD
                    alu myALU (.A(rs), .B(rt), .ALU_Sel(3'b000), .ALU_Out(write_data));
                end
                36: begin
                    // AND
                    alu myALU (.A(rs), .B(rt), .ALU_Sel(3'b010), .ALU_Out(write_data));
                end
                24: begin
                    // MULT
                    alu myALU (.A(rs), .B(rt), .ALU_Sel(3'b001), .ALU_Out(write_data));
                end
                36: begin
                    // AND
                    alu myALU (.A(rs), .B(rt), .ALU_Sel(3'b010), .ALU_Out(write_data));
                end
                37: begin
                    // OR
                    alu myALU (.A(rs), .B(rt), .ALU_Sel(3'b011), .ALU_Out(write_data));
                end
                38: begin
                    // XOR
                    alu myALU (.A(rs), .B(rt), .ALU_Sel(3'b100), .ALU_Out(write_data));
                end
                39: begin
                    // NOR
                    alu myALU (.A(rs), .B(rt), .ALU_Sel(3'b101), .ALU_Out(write_data));
                end
                0: begin
                    // SLL
                    alu myALU (.A(rs), .B(rt), .ALU_Sel(3'b110), .ALU_Out(write_data));
                end
                2: begin
                    // SRL
                    alu myALU (.A(rs), .B(rt), .ALU_Sel(3'b111), .ALU_Out(write_data));
                end
            endcase
            write_enable = 0;
        end
        8: begin
            // ADDI instruction
            wire [4:0] rs = instruction[25:21];
            wire [4:0] rt = instruction[20:16];
            wire [15:0] immediate = instruction[15:0];
            read_reg1 = rs;
            write_reg = rt;
            write_enable = 1;
            addi myADDI (.regi(reg_data1), .register(write_data), .value(immediate));
            write_enable = 0;
        end
        default: result = 32'b0;
        43: begin
            // SW instruction
            wire [4:0] base = instruction[25:21];
            wire [4:0] rt = instruction[20:16];
            wire [15:0] offset = instruction[15:0];
            read_reg1 = base;
            read_reg2 = rt;
            // Calculate memory address
            addi myAddi (.regi(reg_data1), .register(mem_address), .value(offset));
            mem_data = reg_data2;
        end

        default: ;
    endcase
    end
endmodule