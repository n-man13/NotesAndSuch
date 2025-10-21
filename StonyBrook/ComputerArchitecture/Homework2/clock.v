`timescale 1ns/1ps
module clock ( output reg clk );
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end
endmodule