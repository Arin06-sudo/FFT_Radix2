`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// es: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module cmultiplier(input signed [15:0] real1,complex1,real2,complex2,
                   input clk,rst,
                   output reg signed  [15:0] real_out,complex_out);
                   
                   reg  signed [31:0] r1r2,c1c2,r1c2,r2c1;
                   wire signed [31:0] sum_real,sum_complex;
                   
                   always@(posedge clk or negedge rst)begin
                   
                    if(!rst) begin
                        r1r2 <= 32'd0;
                        c1c2 <= 32'd0;
                        r1c2 <= 32'd0;
                        r2c1 <= 32'd0;
                        
                    end
                    else begin
                        r1r2 <= real1*real2;
                        c1c2 <= complex1*complex2;
                        r1c2 <= real1*complex2;
                        r2c1 <= real2*complex1;
                    end
                   end
                   
                   assign sum_real = r1r2 - c1c2;
                   assign sum_complex = r1c2 + r2c1;
                   
                   
                   always@(posedge clk or negedge rst) begin
                    if(!rst) begin
                        real_out <= 16'd0;
                        complex_out <= 16'd0;
                    end
                    
                    else begin
                        real_out <= sum_real[30:15]; /*after multiplication, the format is Q2.30, so to 
                        convert it to Q1.15, we have to perform truncation of the final multiplication result*/
                        
                        complex_out <= sum_complex[30:15];
                    end
                   end

endmodule

module two_cycle_delay(input signed[15:0] real1,complex1,
                       input clk,
                       input rst,
                       output signed [15:0] real_out,complex_out);
                      
    reg signed [15:0] reald1,cmplxd1;
    reg signed [15:0] reald2,cmplxd2;
 
    always@(posedge clk or negedge rst) begin
    
        if(!rst) begin
            reald1 <= 0;
            reald2 <= 0;
            cmplxd1 <= 0;
            cmplxd2 <= 0;

        end
        
        else begin
            reald1 <= real1;
            cmplxd1 <= complex1;
            reald2 <= reald1;
            cmplxd2 <= cmplxd1;

        end
            
    end
    
    assign real_out = reald2;
    assign complex_out = cmplxd2;
       
endmodule  
               
module butterfly_unit(input signed[15:0] real1,complex1,
                      input signed[15:0]real2,complex2,                  
                      output signed[15:0] sumout_real,sumout_complex,
                      output signed[15:0] subout_real,subout_complex);
                      
   wire signed [16:0] real_sum,complex_sum; // taking output accumulator of 17 bits to avoid overflow and handle scaling
  
   
   
   wire signed[16:0] real_sub,complex_sub;
   
   assign real_sum = $signed(real1) + $signed(real2);
   assign complex_sum = $signed(complex1) + $signed(complex2);
   
   assign real_sub = $signed(real1) - $signed(real2);
   assign complex_sub = $signed(complex1) - $signed(complex2);

   assign sumout_real = real_sum[16:1];
   assign sumout_complex = complex_sum[16:1]; //(the result is scaled by factor of two if it exceeds the bounds of +1 and -1)
   assign subout_real = real_sub[16:1];
   assign subout_complex = complex_sub[16:1]; 
                               

endmodule



module dual_port_ram ( clk,
                       rst,
                       addra,
                       addrb,
                       we,
                       data_in_A,
                       data_in_B,
                       data_out_A,
                       data_out_B);

    input clk,we,rst;                      
    parameter N=8; 
    input[$clog2(N)-1:0] addra,addrb;
    input signed [31:0] data_in_A,data_in_B;    
    output reg signed [31:0] data_out_A,data_out_B;
   
    reg signed [31:0] mem [0:N-1]; /*since we have to fetch both the complex and 
    real numbers we have used 32 bit, first 16 bits for real number next 16 bits for complex*/
    
    
    initial begin
       // 8-Point Cosine Wave in BIT-REVERSED ORDER {Real, Imag}
        mem[0] = 32'h4000_0000; // Index 0 ( 0.500)
        mem[1] = 32'hC000_0000; // Index 4 (-0.500)
        mem[2] = 32'h0000_0000; // Index 2 ( 0.000)
        mem[3] = 32'h0000_0000; // Index 6 ( 0.000)
        mem[4] = 32'h2D41_0000; // Index 1 ( 0.353)
        mem[5] = 32'hD2BF_0000; // Index 5 (-0.353)
        mem[6] = 32'hD2BF_0000; // Index 3 (-0.353)
        mem[7] = 32'h2D41_0000; // Index 7 ( 0.353)
    end
    
    always @(posedge clk or negedge rst) begin
        if(!rst) begin
            data_out_A <= 0;
            data_out_B <= 0;
         end
         
        else begin 
            if(we) begin
                mem[addra] <= data_in_A; //port A
                mem[addrb] <= data_in_B; //port B
            end
            
            else begin
                data_out_A <= mem[addra]; //port A
                data_out_B <= mem[addrb]; //port B
            end
             
            
        end
        
    end
endmodule


module twiddle_rom( addr,
                    data_out,
                    rd_en);

    parameter N=8;
    
    output reg [31:0] data_out;
    
    input [$clog2(N/2)-1:0] addr;
    
    input rd_en;
    
    reg [31:0] rom_mem [0:N/2-1]; 
    
    initial begin
    
        $readmemh("twiddle_2.mem",rom_mem);
    
    end
  
    always@(rd_en or addr) begin
    
        data_out = rom_mem[addr];   
                   
   end

endmodule



module control_fsm( clk,rst,
                    start,done,
                    read_addra,read_addrb,
                    write_addra,write_addrb,
                    read_addr_rom,
                    write_enable);

    parameter N = 8;
    input clk,rst,start;
    output reg [$clog2(N)-1:0] read_addra ,read_addrb;
    output reg [$clog2(N)-1:0] write_addra,write_addrb;
    output reg [$clog2(N/2)-1:0] read_addr_rom;
    output reg write_enable;
    output reg done;
    
    reg [2:0] state,next_state;
    
        // The number of stages is exactly log2(N)
    parameter TOTAL_STAGES = $clog2(N);
    
    // The width of the counter needs to hold the number 'TOTAL_STAGES'
    reg [$clog2(TOTAL_STAGES + 1) : 0] stage_counter;
    
    // The maximum number of groups is N/2
    reg [$clog2(N/2)-1 : 0] group_counter;
    
    // The maximum number of butterflies in a group is N/2
    reg [$clog2(N/2)-1 : 0] butterfly_counter;
    
    wire [$clog2(N)-1:0] stride;
    
    assign stride = 1<<(stage_counter-1); 
    
    wire[$clog2(N)-1:0] read_address_a = group_counter*stride*2+butterfly_counter;
    wire [$clog2(N)-1:0]read_address_b = read_address_a+stride;    
    wire [$clog2(N/2)-1:0] read_rom = butterfly_counter<<($clog2(N)-stage_counter);
    

    
    wire [$clog2(N)-1:0] max_butterfly_count = stride;
    wire [$clog2(N)-1:0] max_group_count = (N/2)>>(stage_counter-1);
    
    
    parameter IDLE = 3'b000, READ = 3'b001, CALC1= 3'b010, CALC2 = 3'b011, WRITE = 3'b100;
    
    always@(posedge clk or negedge rst) begin
        
        if(!rst) begin
            done <= 0;
            read_addra <= 0;
            read_addrb <= 0;
            write_addra <= 0;
            write_addrb <= 0;
            read_addr_rom <=0;
            write_enable <=0;
            state <= IDLE;
            stage_counter<=1;
            group_counter <=0;
            butterfly_counter <=0;

        end

        else begin 
        
            case(state)
            IDLE: begin
                done <=0;
                write_enable <=0;
                if(start) state<= READ;
                
                else state <= IDLE;
            end
            
            READ: begin
                write_enable<=0;
                read_addra <= read_address_a;
                read_addrb <= read_address_b;               
                read_addr_rom <= read_rom;  
                state <= CALC1;
           
            end
            
            CALC1 : state<= CALC2; /*states required for waiting till the hardware does its job
            (since cmultiplier is pipelined it takes two clock cycles for the multiplication to be generated*/

            CALC2: begin

                write_addra <= read_addra;
                write_addrb <= read_addrb;
                state <= WRITE;
            
            end
            
            WRITE: begin
                write_enable <= 1;
                state <= READ;
                
                if(butterfly_counter == max_butterfly_count-1) begin
                    butterfly_counter<=0;
                    
                    if(group_counter == max_group_count-1) begin
                        group_counter<=0;
                        
                        if(stage_counter == TOTAL_STAGES) begin
                        
                            done <= 1;
                           
                            state <= IDLE;
                        end    
                        else begin
                            stage_counter <= stage_counter+1;
                        end
                    end
                    
                    else group_counter<=group_counter+1;
                
                end
                
                else butterfly_counter <= butterfly_counter+1;
                
                
                
            end
        
        endcase


        end
    
    end
  
endmodule


module FFT_module_top(input clk,
                      input rst,
                      input start_fft,
                      output fft_done);

     parameter N = 8; 
       
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
