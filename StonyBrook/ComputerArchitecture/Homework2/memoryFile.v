module memoryFile ( input [31:0] address, input write_enable, input [31:0] write_data, output reg [31:0] read_data);
    // Memory file, just output address as data
    reg [31:0] memory [0:255];
    integer i;

    initial begin
        // Initialize memory to 0
        for (i = 0; i < 256; i = i + 1) begin
            memory[i] = 32'b0;
        end
    end
    
    always @(!write_enable) begin
        read_data <= memory[address[7:0]];
    end
    always @(write_enable) begin
        if (write_enable) begin
            memory[address[7:0]] <= write_data;
        end
    end
endmodule