module addi ( input regi [31:0], output register [31:0], input value [15:0]);
    // Add immediate value to register
    // sign extend value
    wire [31:0] sign_extended_value;
    assign sign_extended_value = {{16{value[15]}}, value[15:0]};
    alu myALU (.A(regi), .B(sign_extended_value), .ALU_Sel(3'b000), .ALU_Out(register));
endmodule