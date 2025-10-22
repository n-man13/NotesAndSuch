`timescale 1ns / 1ps
module processor_tb;

    wire clk;
    wire [31:0] instruction;
    initial begin
        $dumpfile("hw2.vcd");
        $dumpvars(0, processor_tb);
        //$stop;
        #200; // Run simulation for 200 time units
        $finish;
    end
    processor myProcessor(.initial_pc(0));
    //programMem prog_mem ( .pc(0), .instruction(instruction));

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

        /* // Test 1
        instruction = 32'b001000_00000_01000_0000_0000_0000_0100; // ADDI
        #10;
        instruction = 32'b001000_00000_01001_0000_0000_0000_1111; // ADDI
        #10;
        instruction = 32'b001000_00000_01010_0000_0000_0001_0100; // ADDI
        #10;
        instruction = 32'b001000_00000_10001_0000_0000_0000_1000; // ADDI
        #10;
        instruction = 32'b101011_10001_01000_0000_0000_0000_0000; // SW
        #10;
        instruction = 32'b101011_10001_01001_0000_0000_0000_1000; // SW
        #10;
        instruction = 32'b101011_10001_01010_1111_1111_1111_1100; // SW
        #10;
        instruction = 32'b000000_00000_00000_00000_00000_000000; // HALT
        #10; */

        /* 
        // Test 2
        instruction = 32'b001000_00000_01000_0000_0000_0000_1000; // ADDI
        #10;
        instruction = 32'b001000_00000_01001_0000_0000_0000_1111; // ADDI
        #10;
        instruction = 32'b101011_01000_01001_0000_0000_0000_0000; // SW
        #10;
        instruction = 32'b000000_01001_01000_01010_00000_100000; // ADD
        #10;
        instruction = 32'b000000_01001_01000_01011_00000_100010; // SUB
        #10;
        instruction = 32'b000000_01010_01011_10001_00000_000010; // MUL
        #10;
        instruction = 32'b001000_00000_01000_0000_0000_0000_0100; // ADDI
        #10;
        instruction = 32'b100011_01000_10010_1111_1111_1111_1100; // LW
        #10;
        instruction = 32'b000000_10001_10010_10010_00000_100010; // SUB
        #10;
        instruction = 32'b000000_10001_00000_10010_00000_000000; // SLL
        #10;
        instruction = 32'b101011_01000_10010_0000_0000_0000_0000; // SW
        #10;
        instruction = 32'b000000_00000_00000_00000_00000_000000; // HALT
        #10; */


endmodule