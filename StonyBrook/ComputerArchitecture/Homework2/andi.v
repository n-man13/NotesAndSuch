module andi ( input [31:0] reg_in, output [31:0] reg_out, input [15:0] immediate);
    // AND immediate value to register
    // zero extend value
    wire [31:0] zero_extended_value;
    assign zero_extended_value = {{16'b0000000000000000}, immediate[15:0]};
    alu myALU (.A(reg_in), .B(zero_extended_value), .ALU_Sel(3'b010), .ALU_Out(reg_out));
endmodule