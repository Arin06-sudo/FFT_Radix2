
module control_fsm( clk,rst,
                    start,done,
                    read_addra,read_addrb,
                    write_addra,write_addrb,
                    read_addr_rom,
                    write_enable);

    parameter N = 4;
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

