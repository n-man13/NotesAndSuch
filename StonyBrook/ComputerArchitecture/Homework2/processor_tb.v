`timescale 1ns / 1ps
module processor_tb;

    wire clk;
    initial begin
        $dumpfile("hw2.vcd");
        $dumpvars(0, processor_tb);
        //$stop;
        #200; // Run simulation for 200 time units
        
    end
    processor myProcessor(.initial_pc(0));

endmodule