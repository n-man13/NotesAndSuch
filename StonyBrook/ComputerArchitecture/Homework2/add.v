module add ( input reg a [31:0], input reg b [31:0],  output reg c [31:0]);
    // Add two registers
    assign c = a + b;
endmodule