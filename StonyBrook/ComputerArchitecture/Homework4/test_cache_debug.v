`timescale 1ns/1ps
module test_tb;
    reg clk = 0;
    always #5 clk = ~clk;
    
    initial begin
        $dumpfile("test.vcd");
        $dumpvars;
        #200 $finish;
    end
endmodule
