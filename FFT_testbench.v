

module FFT_testbench;

reg clk,rst,start;

wire done;

FFT_module_top(.clk(clk),.rst(rst),.start_fft(start),.fft_done(done));


initial begin

#5 clk = ~clk;

end

initial begin

rst = 1'b1;

#10 rst = 1'b0;

#10 start = 1'b1;

end


endmodule
