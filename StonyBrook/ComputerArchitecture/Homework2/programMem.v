module programMem ( input [31:0] pc, output [31:0] instruction);
    reg [31:0] instructions [31:0];
    reg [31:0] instruction_reg;
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
    /* Test 2
        addi $t0, $0, 8
        addi $t1, $0, 15
        sw $t1, 0($t0)
        add $t2, $t1, $t0
        sub $t3, $t1, $t0
        mul $s1, $t2, $t3
        addi $t0, $t0, 4
        lw $s2, ‐4($t0)
        sub $s2, $s1, $s2
        sll $s2, $s1, 2
        sw $s2, 0($t0)
        halt
    */
    /* Test 3
        addi $a0, $0, 6
        jal factorial
        sw $v0, 0($0)
        halt
factorial: addi $sp, $sp, ‐8
        sw $a0, 4($sp)
        sw $ra, 0($sp)
        addi $t0, $0, 2
        slt $t0, $a0, $t0
        beq $t0, $0, else
        addi $v0, $0, 1
        addi $sp, $sp, 8
        jr $ra
        else: addi $a0, $a0, ‐1
        jal factorial
        lw $ra, 0($sp)
        lw $a0, 4($sp)
        addi $sp, $sp, 8
        mul $v0, $a0, $v0
        jr $ra
    */
    assign instruction = instruction_reg; // why isnt this working???

    initial begin
        instruction_reg = 0;
         // Test 1
        instructions[0] = 32'b001000_00000_01000_0000_0000_0000_0100; // ADDI
        instructions[1] = 32'b001000_00000_01001_0000_0000_0000_1111; // ADDI
        instructions[2] = 32'b001000_00000_01010_0000_0000_0001_0100; // ADDI
        instructions[3] = 32'b001000_00000_10001_0000_0000_0000_1000; // ADDI
        instructions[4] = 32'b101011_10001_01000_0000_0000_0000_0000; // SW
        instructions[5] = 32'b101011_10001_01001_0000_0000_0000_1000; // SW
        instructions[6] = 32'b101011_10001_01010_1111_1111_1111_1100; // SW
        instructions[7] = 32'b111111_00000_00000_0000_0000_0000_0000; // HALT

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
        instructions[19] = 32'b111111_00000_00000_0000_0000_0000_0000; // HALT

        // Test 3
        instructions[20] = 32'b001000_00000_00100_0000_0000_0000_0110; // ADDI
        instructions[21] = 32'b000011_00000_00000_0000_0000_0001_0100; // JAL
        instructions[22] = 32'b101011_00010_00010_0000_0000_0000_0000; // SW
        instructions[23] = 32'b111111_00000_00000_0000_0000_0000_0000; // HALT
        instructions[24] = 32'b001000_11101_11101_1111_1111_1111_1000; // ADDI -- Factorial function starts here
        instructions[25] = 32'b101011_11101_00100_0000_0000_0000_0100; // SW
        instructions[26] = 32'b101011_11101_11111_0000_0000_0000_0000; // SW
        instructions[27] = 32'b001000_00000_01000_0000_0000_0000_0010; // ADDI
        instructions[28] = 32'b000000_00100_01000_01000_00000_101010; // SLT
        instructions[29] = 32'b000100_01000_00000_0000_0000_0000_0011; // BEQ
        instructions[30] = 32'b001000_00000_00010_0000_0000_0000_0001; // ADDI
        instructions[31] = 32'b001000_00000_00010_0000_0000_0000_0001; // ADDI
        instructions[32] = 32'b001000_00010_11111_0000_0000_0000_1000; // ADDI
        instructions[33] = 32'b000011_00000_00000_0000_0000_0001_0100; // JAL
        instructions[34] = 32'b100011_11101_11111_0000_0000_0000_0000; // LW
        instructions[35] = 32'b100011_11101_00100_0000_0000_0000_0100; // LW
        instructions[36] = 32'b001000_11101_11101_0000_0000_0000_1000; // ADDI
        instructions[37] = 32'b000000_00100_11111_00010_00000_000010; // MUL
        instructions[38] = 32'b000000_00000_00000_00000_00000_000000; // HALT
        
    end
    always @(*) begin
        instruction_reg = instructions[pc]; // this works
    end
    
endmodule
