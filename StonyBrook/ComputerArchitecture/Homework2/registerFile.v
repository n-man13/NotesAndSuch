module registerFile ( input clk, input [4:0] readReg1, input [4:0] readReg2, 
input [4:0] writeReg, input [31:0] writeData, 
input writeEnable, output [31:0] readData1, output [31:0] readData2);
    reg [31:0] registers [31:0];
    always @(posedge clk) begin
        if (writeEnable) begin
            registers[writeReg] <= writeData;
        end
        assign readData1 = registers[readReg1];
        assign readData2 = registers[readReg2];
    end
    
endmodule