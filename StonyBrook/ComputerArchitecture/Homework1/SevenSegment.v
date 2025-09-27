module SevenSegment(input [3:0] a, input [3:0] b, output [6:0] d, output overflow);
    reg [6:0] d;
    wire [4:0] s;
    wire [3:0] lessSig;

    FourBitAdder add(a, b, s);
    assign overflow = s[4];
    assign lessSig = s[3:0];

    always @(lessSig) begin
        case (lessSig)
            0 : d = 7'b0000001;
            1 : d = 7'b1001110;
            2 : d = 7'b0010010;
            3 : d = 7'b0000110;
            4 : d = 7'b1001100;
            5 : d = 7'b0100100;
            6 : d = 7'b0100000;
            7 : d = 7'b0001111;
            8 : d = 7'b0000000;
            9 : d = 7'b0000100;
            10 : d = 7'b0001000;
            11 : d = 7'b1100000;
            12 : d = 7'b0110001;
            13 : d = 7'b1000010;
            14 : d = 7'b0110000;
            15 : d = 7'b0111000;
        endcase
    end

endmodule