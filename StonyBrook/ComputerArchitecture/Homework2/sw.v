module sw ( input [31:0] source, input offset, memoryFile mem, output [31:0] destination);
    // Save word from source to destination with offset
    // sign extend offset
    wire [31:0] effective_offset;
    assign effective_offset = {{16{offset[15]}}, offset};
    assign destination = source + effective_offset;
    always @(posedge clk) begin
        mem.memory[destination[7:0]] <= source;
    end
endmodule