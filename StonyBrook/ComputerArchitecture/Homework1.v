module FullAdder(input a, input b, input ci, output s, output co);
    /*
    Implement a full adder using verilog
    */
    wire tempSum;
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

module test;
reg a,b,cin;
wire s,co;


FullAdder adder(a,b,cin,s,co);

initial begin
    $dumpfile("test.vcd");
    $dumpvars(0,test);
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
    $finish();
end

initial
begin
   $dumpfile("test.vcd");
   $dumpvars(0,test);
end
                
endmodule