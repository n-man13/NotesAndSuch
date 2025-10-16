`timescale 1ps/1ns
module clock ( output clk );
    initial begin
        clk = 0;
        forever #5 clock = ~clock;
    end
endmodule