module registerFile ( input [4:0] readReg1, input [4:0] readReg2, input [4:0] writeReg, 
input [31:0] writeData, input writeEnable, output reg [31:0] readData1, output reg [31:0] readData2);

    reg [31:0] registers [31:0];
    integer i;

    initial begin
        // Initialize registers to 0
        for (i = 0; i < 32; i = i + 1) begin
            registers[i] <= 0;
        end
    end

    always @(*) begin
        readData1 = registers[readReg1];
        readData2 = registers[readReg2];
    end

    always @(posedge writeEnable) begin
        registers[writeReg] <= writeData;
    end

    
endmodule