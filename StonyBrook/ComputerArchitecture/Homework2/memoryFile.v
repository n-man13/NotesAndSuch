module memoryFile ( input [31:0] address, output [31:0] data);
    // Memory file, just output address as data
    reg [31:0] memory [0:255];
    always @(*) begin
        data < = memory[address[7:0]];
    end
endmodule