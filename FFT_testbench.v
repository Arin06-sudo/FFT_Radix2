

`timescale 1ns / 1ps // Always good practice to include a timescale

module FFT_testbench;

    reg clk, rst, start;
    wire done;

    // 1. ADDED INSTANCE NAME 'dut'
    FFT_module_top dut (
        .clk(clk),
        .rst(rst),
        .start_fft(start),
        .fft_done(done)
    );

    // 2. CLOCK GENERATION
    always #5 clk = ~clk;

    initial begin
        // 3. INITIALIZE ALL SIGNALS AT TIME ZERO
        clk = 1'b0;
        rst = 1'b0;
        start = 1'b0;

        // Pulse the reset
        #20 rst = 1'b1;
        
        // Wait a bit, then pulse the start signal
        #10 start = 1'b1;
        #10 start = 1'b0; // Bring it back down after 1 clock cycle!


    end

endmodule
