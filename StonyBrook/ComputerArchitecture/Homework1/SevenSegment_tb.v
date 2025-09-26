module SevenSegment_tb;
    reg [3:0] a;
    reg [3:0] b;
    reg [6:0] segment;
    wire over;
    integer i, j;

    SevenSegment sev(a, b, segment, over);

    // same code from Adder_4_tb
    initial begin
        a = 4'b0000;
        b = 4'b0000;
        for (i = 0; i < 256; i = i + 1) begin
            {a, b} = i;
            #10;
        end
    end 

    initial begin
        $dumpfile("test_seven.vcd");
        $dumpvars(0, SevenSegment_tb);
    end

endmodule
