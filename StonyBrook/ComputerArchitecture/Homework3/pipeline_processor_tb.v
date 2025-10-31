`timescale 1ns / 1ps

// Simple testbench for the pipelined_processor skeleton
// - toggles clock
// - pulses reset at start
// - instantiates pipelined_processor with initial_pc = 0
// - creates a VCD waveform file (hw_pipeline.vcd)

module pipeline_processor_tb;
    reg clk;
    reg reset;

    // Instantiate the processor under test
    pipelined_processor DUT(
        .clk(clk),
        .reset(reset),
        .initial_pc(32'd0)
    );

    // Clock generator: 10 time unit period (toggle every 5)
    initial begin
        clk = 0;
        forever begin
            #5 clk = ~clk;
        end
    end

    initial begin
        // VCD dump for waveform viewing
        $dumpfile("hw_pipeline.vcd");
        $dumpvars(0, pipeline_processor_tb);

        // Apply reset for a couple of cycles
        reset = 1;
        #12;           // hold reset for slightly more than one clock edge
        reset = 0;

        // Let the simulation run for a while so you can inspect waves
        #1000;
        $finish;
    end

endmodule
