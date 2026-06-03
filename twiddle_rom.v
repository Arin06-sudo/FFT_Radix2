
module twiddle_rom( addr,
                    data_out,
                    rd_en);

    parameter N=4;
    
    output reg [31:0] data_out;
    
    input [$clog2(N/2)-1:0] addr;
    
    input rd_en;
    
    reg [31:0] rom_mem [0:N/2-1]; 
    
    initial begin
        rom_mem[0] = 32'h7fff_0000;
        rom_mem[1] = 32'h0000_8000;
        
    
    end

    always@(rd_en or addr) begin
    
        data_out = rom_mem[addr];   
                   
   end

endmodule


