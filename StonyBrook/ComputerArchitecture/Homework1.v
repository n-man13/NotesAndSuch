module FullAdder(input a, input b, input ci, output s, output co);
    /*
    Implement a full adder using verilog
    */
    assign s = a ^ b ^ ci;
    assign co = (a & b) | (b & ci) | (a & ci);

endmodule

module FullAdderTestBench;
reg a,b,cin;
wire s,co;

FullAdder adder(a,b,cin,s,co);

initial begin
a = 0; b = 0; cin = 0;
#10 $stop;
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
                
endmodule