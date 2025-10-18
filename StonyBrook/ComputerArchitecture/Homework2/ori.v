module ori ( input reg_in [31:0], output reg_out [31:0], input immediate [15:0]);
    // OR immediate value to register
    // sign extend immediate
    wire [31:0] sign_extended_immediate;
    assign sign_extended_immediate = {{16{immediate[15]}}, immediate[15:0]};
    alu myALU (.A(reg_in), .B(sign_extended_immediate), .ALU_Sel(3'b011), .ALU_Out(reg_out));
endmodule