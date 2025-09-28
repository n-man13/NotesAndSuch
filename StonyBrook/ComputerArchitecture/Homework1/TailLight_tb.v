`timescale 1ns / 1ps

module TailLight_tb;

    reg clock;
    reg reset;
    reg left;
    reg right;
    wire la;
    wire lb;
    wire lc;
    wire ra;
    wire rb;
    wire rc;

    TailLight tail(reset, clock, left, right, lc, lb, la, ra, rb, rc);

    initial begin
        $dumpfile("test_tail.vcd");
        $dumpvars(0, TailLight_tb);
        clock = 0;
        forever #5 clock = ~clock;
    end
    initial begin
        reset = 1;
        left = 0;
        right = 0; // set all values to default
        #10;
        reset = 0; // reset back to 0
        #10;
        left = 1; // start left case
        #10;
        left = 0;
        #30;
        right = 1; // start right case
        #10;
        right = 0;
        #30;
        left = 1; // start left case
        #10;
        left = 0;
        #10;
        reset = 1; // manual reset during left case
        #10;
        reset = 0;
        #10;
        right = 1; // start right case
        #10;
        right = 0;
        #10;
        reset = 1; // manual reset during right case
        #10;
        reset = 0;
        #10;
        left = 1; // testing priority left if both signals are on
        right = 1;
        reset = 1;
        #10;
        reset = 0;
        #10;
        left = 0;
        right = 0;
        #30;
        left = 1; // testing if left can immediate transition back to left
        #40;
        left = 0;
        #20;
        left = 1; // testing if right is triggered during left, nothing happens until after
        #10;
        left = 0;
        right = 1;
        #40;
        right = 0;
        left = 1;
        #30;
        left = 0;
        #30;
        reset = 1;
        #10;
        reset = 0;

        $finish;
    end

endmodule