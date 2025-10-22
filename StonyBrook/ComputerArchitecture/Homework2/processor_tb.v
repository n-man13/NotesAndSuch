`timescale 1ns / 1ps
module processor_tb;

    wire clk;
    wire [31:0] pc;
    initial begin
        $dumpfile("hw2.vcd");
        $dumpvars(0, processor_tb);
        //$stop;
        pc = 0;
        #200; // Run simulation for 200 time units
        pc = 8;
        #200;
        pc = 20;
        #200;
        $finish;
    end
    processor myProcessor(.initial_pc(pc));

endmodule