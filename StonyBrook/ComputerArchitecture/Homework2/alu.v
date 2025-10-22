module alu ( input [31:0] A, input [31:0] B, input [2:0] ALU_Sel, output reg [31:0] ALU_Out );
    parameter ADD = 3'b000; // 32
    parameter MUL = 3'b001; // 24
    parameter AND = 3'b010; // 36
    parameter OR  = 3'b011; // 37
    parameter XOR = 3'b100; // 38
    parameter NOR = 3'b101; // 39
    parameter SLL = 3'b110; // 0
    parameter SRL = 3'b111; // 2
    always @(*) begin
        case (ALU_Sel)
            3'b000: ALU_Out = A + B;          // Addition
            3'b001: ALU_Out = (A * B);        // Multiplication
            3'b010: ALU_Out = A & B;          // Bitwise AND
            3'b011: ALU_Out = A | B;          // Bitwise OR
            3'b100: ALU_Out = A ^ B;          // Bitwise XOR
            3'b101: ALU_Out = ~(A | B);       // Bitwise NOR
            3'b110: ALU_Out = A << B;         // Logical left shift
            3'b111: ALU_Out = A >> B;         // Logical right shift
            default: ALU_Out = 8'b00000000;   // Default case set to zero
        endcase
    end
endmodule
