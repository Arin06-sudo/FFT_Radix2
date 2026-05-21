
module two_cycle_delay(input signed[15:0] real1,complex1,
                       input clk,
                       input rst,
                       output signed [15:0] real_out,complex_out);
                      
    reg[15:0] reald1,cmplxd1;
    reg[15:0] reald2,cmplxd2;
 
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
