module addi ( input [31:0] reg_in, output [31:0] reg_out, input [15:0] immediate);
    // Add immediate value to register
    // sign extend value
    wire [31:0] sign_extended_value;
    assign sign_extended_value = {{16{immediate[15]}}, immediate[15:0]};

    alu myADDI_ALU (.A(reg_in), .B(sign_extended_value), .ALU_Sel(3'b000), .ALU_Out(reg_out));
endmodule