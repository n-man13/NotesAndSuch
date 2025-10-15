module lw ( input [31:0] address, output [31:0] data, memoryFile mem);
    // Load word from address to data
    assign data = mem.memory[address[7:0]];
endmodule