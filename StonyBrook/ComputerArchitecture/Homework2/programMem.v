module programMem ( input [31:0] pc, output reg [31:0] instruction);
    reg [31:0] instructions [31:0];

    /* Test 1
        addi $t0, $0, 4
        addi $t1, $0, 15
        addi $t2, $0, 100
        addi $s1, $0, 8
        sw $t0, 0($s1)
        sw $t1, 8($s1)
        sw $t2, -4($s1)
        halt
    */

    initial begin
         // Test 1
        instructions[0] = 32'b001000_00000_01000_0000_0000_0000_0100; // ADDI
        instructions[1] = 32'b001000_00000_01001_0000_0000_0000_1111; // ADDI
        instructions[2] = 32'b001000_00000_01010_0000_0000_0001_0100; // ADDI
        instructions[3] = 32'b001000_00000_10001_0000_0000_0000_1000; // ADDI
        instructions[4] = 32'b101011_10001_01000_0000_0000_0000_0000; // SW
        instructions[5] = 32'b101011_10001_01001_0000_0000_0000_1000; // SW
        instructions[6] = 32'b101011_10001_01010_1111_1111_1111_1100; // SW
        instructions[7] = 32'b111111_00000_00000_00000_00000_000000; // HALT

        // Test 2
        instructions[8] = 32'b001000_00000_01000_0000_0000_0000_1000; // ADDI
        instructions[9] = 32'b001000_00000_01001_0000_0000_0000_1111; // ADDI
        instructions[10] = 32'b101011_01000_01001_0000_0000_0000_0000; // SW
        instructions[11] = 32'b000000_01001_01000_01010_00000_100000; // ADD
        instructions[12] = 32'b000000_01001_01000_01011_00000_100010; // SUB
        instructions[13] = 32'b000000_01010_01011_10001_00000_000010; // MUL
        instructions[14] = 32'b001000_00000_01000_0000_0000_0000_0100; // ADDI
        instructions[15] = 32'b100011_01000_10010_1111_1111_1111_1100; // LW
        instructions[16] = 32'b000000_10001_10010_10010_00000_100010; // SUB
        instructions[17] = 32'b000000_10001_00000_10010_00000_000000; // SLL
        instructions[18] = 32'b101011_01000_10010_0000_0000_0000_0000; // SW
        instructions[19] = 32'b111111_00000_00000_00000_00000_000000; // HALT
        
    end
    always @(*)
        instruction = instructions[pc];
    
endmodule
