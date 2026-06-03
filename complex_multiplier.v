
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

