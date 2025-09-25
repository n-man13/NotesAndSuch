module FullAdder(input a, input b, input ci, output s, output co);
    /*
    Implement a full adder using verilog
    */
    wire temp;
    wire foo;
    wire bar;
    wire baz;
    wire quux;


    xor(temp, a, b);
    xor(s, temp, ci);

    and(foo, a, b);
    and(bar, b, ci);
    and(baz, a, ci);
    or(quux, foo, bar);
    or(co, baz, quux);

endmodule

module FourBitAdder(input [3:0] a, input [3:0] b, output [4:0] s);
    /*
    implement a 4 bit adder using full adder from above
    */
    wire [2:0] c;
    FullAdder first(a[0], b[0], 0, s[0], c[0]);
    FullAdder second(a[1], b[1], c[0], s[1], c[1]);
    FullAdder third(a[2], b[2], c[1], s[2], c[2]);
    FullAdder fourth(a[3], b[3], c[2], s[3], s[4]);
    


endmodule

module test;
    reg a,b,cin;
    // reg [3:0] one,two;
    // reg [4:0] sum;
    wire s,co;
    integer i;



    FullAdder adder(a, b, cin, s, co);
    // FourBitAdder four(one, two, sum);

    initial begin
        
        a = 0; b = 0; cin = 0; 
        #10
        a = 0; b = 0; cin = 1;
        #10
        a = 0; b = 1; cin = 0;
        #10
        a = 0; b = 1; cin = 1;
        #10
        a = 1; b = 0; cin = 0;
        #10
        a = 1; b = 0; cin = 1;
        #10
        a = 1; b = 1; cin = 0;
        #10
        a = 1; b = 1; cin = 1;
        #10 

        /* for (i = 0; i < 16; i = i + 1) begin
            {one, two} = i;
            #10
        end */

        $finish();
    end

    initial begin
        $dumpfile("test.vcd");
        $dumpvars(0,test);
    end
                
endmodule