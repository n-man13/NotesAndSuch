module processor ( input clk, input [31:0] instruction, output [31:0] result);
    // Simple single-cycle processor
    memoryFile mem(clk, 0, 0);
endmodule