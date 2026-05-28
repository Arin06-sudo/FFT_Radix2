
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
    real numbers we have used 32 bit, 16 bit for complex 16 bit for signed*/
    
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

