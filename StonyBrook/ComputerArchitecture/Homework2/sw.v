module sw ( input [31:0] source, input offset, output [31:0] destination);
    // Save word from source to destination with offset
    assign destination = source + offset;
endmodule