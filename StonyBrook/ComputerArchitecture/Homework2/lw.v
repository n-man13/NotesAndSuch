module lw ( input [31:0] address, input [15:0] offset, output [31:0] data, memoryFile mem);
    // Load word from address to data
    wire [31:0] effective_address;
    // sign extend offset
    assign effective_address = {{16{offset[15]}}, offset} + address;
    assign data = mem.memory[effective_address[7:0]];
endmodule