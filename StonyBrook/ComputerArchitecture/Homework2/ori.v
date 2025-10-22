module ori ( input [31:0] reg_in , output [31:0] reg_out, input [15:0] immediate);
    // OR immediate value to register
    // zero extend immediate
    wire [31:0] zero_extended_immediate;
    assign zero_extended_immediate = {{16'b0000000000000000}, immediate[15:0]};
    alu myALU (.A(reg_in), .B(zero_extended_immediate), .ALU_Sel(3'b011), .ALU_Out(reg_out));
endmodule