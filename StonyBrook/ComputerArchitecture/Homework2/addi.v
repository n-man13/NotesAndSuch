module addi ( input regi [7:0], output register [7:0], input value [15:0]);
    // Add immediate value to register
    assign register = regi + value[7:0];
endmodule