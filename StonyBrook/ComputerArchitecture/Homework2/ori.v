module ori ( input [31:0] reg_in , output [31:0] reg_out, input [15:0] immediate);
    // OR immediate value to register
    // sign extend immediate
    wire [31:0] sign_extended_immediate;
    assign sign_extended_immediate = {{16{immediate[15]}}, immediate[15:0]};
    alu myALU (.A(reg_in), .B(sign_extended_immediate), .ALU_Sel(3'b011), .ALU_Out(reg_out));
endmodule