module lw ( input [31:0] address, output [31:0] data);
    // Load word from address to data
    assign data = address;
endmodule