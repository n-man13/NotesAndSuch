module processor ( input [31:0] instruction, output [31:0] result);
    // Simple single-cycle processor
    wire clk;
    clock myClock(clk);
    memoryFile mem(clk, 0, 0);
endmodule