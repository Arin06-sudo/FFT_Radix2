
module FFT_module_top(input clk,
                      input rst,
                      input start_fft,
                      output fft_done);

     parameter N = 4; 
       
     wire [$clog2(N)-1:0] read_address_a;
     
     wire [$clog2(N)-1:0] read_address_b;
     
     wire [$clog2(N)-1:0] write_address_a;
     
     wire [$clog2(N)-1:0] write_address_b;
     
     wire [$clog2(N/2)-1:0] rom_address;
     
     wire we;

    control_fsm control_u1(.clk(clk),.rst(rst),
                           .start(start_fft),.done(fft_done),
                           .read_addra(read_address_a),
                           .read_addrb(read_address_b),
                           .write_addra(write_address_a),
                           .write_addrb(write_address_b),
                           .read_addr_rom(rom_address),
                           .write_enable(we));
                          
   
    wire signed [31:0] W_out_rom;
    
    wire signed [15:0] sum_out_real;
    wire signed [15:0] sum_out_complex;
    wire signed [15:0] sub_out_real;
    wire signed [15:0] sub_out_complex;
 
    wire signed [31:0] A_out_mem;
    wire signed [31:0] B_out_mem;
    
    
    twiddle_rom rom_u2(.addr(rom_address),
                       .data_out(W_out_rom),
                       .rd_en(1'b1));

    dual_port_ram ram_u3(.clk(clk),
                            .rst(rst),
                            .addra(we?write_address_a:read_address_a),
                            .addrb(we?write_address_b:read_address_b),
                            .we(we),
                            .data_in_A({sum_out_real,sum_out_complex}),
                            .data_in_B({sub_out_real,sub_out_complex}),
                            .data_out_A(A_out_mem),
                            .data_out_B(B_out_mem));
                            
    wire signed [15:0] BW_real;
    wire signed [15:0] BW_complex;                        
    
    cmultiplier c_u4( .clk(clk),.rst(rst),
                      .real1(B_out_mem[31:16]),.complex1(B_out_mem[15:0]),
                      .real2(W_out_rom[31:16]),.complex2(W_out_rom[15:0]),
                      .real_out(BW_real),
                      .complex_out(BW_complex));
                      
                      
    wire signed [15:0] A_delayed_real;
    
    wire signed [15:0] A_delayed_complex;
    
    two_cycle_delay delay_u5(.clk(clk),
                             .rst(rst),
                             .real1(A_out_mem[31:16]),.complex1(A_out_mem[15:0]),
                             .real_out(A_delayed_real),.complex_out(A_delayed_complex));
    
    
    butterfly_unit butterfly_u6( .real1(A_delayed_real),
                                 .complex1(A_delayed_complex),
                                 .real2(BW_real),
                                 .complex2(BW_complex),                  
                                 .sumout_real(sum_out_real),.sumout_complex(sum_out_complex),
                                 .subout_real(sub_out_real),.subout_complex(sub_out_complex));
   
           
endmodule
