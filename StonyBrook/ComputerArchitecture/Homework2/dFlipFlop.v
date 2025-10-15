module dFlipFlop ( input clk, input d, output reg q, output reg qbar);
    always @(posedge clk) begin
        q <= d;
        qbar <= !d;
    end
endmodule