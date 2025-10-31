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
    wire done;
    pipelined_processor DUT(
        .clk(clk),
        .reset(reset),
        .initial_pc(20),
        .done(done)
    );

    // Clock generator: 10 time unit period (toggle every 5)
    initial begin
        clk = 1;
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
        // Let the simulation run; the testbench will finish when DUT.done is asserted
        // Safety timeout in case done never asserts
        #5000;
        $finish;
    end

    // Watch for done (HALT propagated to MEM/WB) and finish immediately
    always @(posedge clk) begin
        if (done) begin
            #1 $finish;
        end
    end

endmodule
