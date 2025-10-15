module dFlipFlop ( input clk, input d, output q, output qbar);
    always @(posedge clk) begin
        q <= d;
        qbar <= !d;
    end
endmodule