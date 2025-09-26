module Adder_4_tb;
    reg [3:0] a;
    reg [3:0] b;
    wire [4:0] s;
    integer i, j;

    FourBitAdder four(a, b, s);

    initial begin
        a = 4'b0000;
        b = 4'b0000;
        for (i = 0; i < 256; i = i + 1) begin
            {a, b} = i;
            #10;
        end
    end 

    /* initial begin
        a = 4'b0000; b = 4'b0000;
        #10;
        a = 4'b0000; b = 4'b0001;
        #10;
        a = 4'b0000; b = 4'b1111;
        #10;
        a = 4'b1111; b = 4'b1111;
        #10;
        a = 4'b0001; b = 4'b1111;
        #10;
        $finish;
    end */

    initial begin
        $dumpfile("test_four.vcd");
        $dumpvars(0, Adder_4_tb);
    end

endmodule