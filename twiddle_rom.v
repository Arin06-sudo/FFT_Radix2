
module twiddle_rom( addr,
                    data_out,
                    rd_en);

    parameter N=8;
    
    output reg signed [15:0] data_out;
    
    input [$clog2(N/2)-1:0] addr;
    
    input rd_en;
    
    reg [15:0] rom_mem [0:N/2-1];                   
    
    always@(rd_en) begin
    
        data_out = rom_mem[addr];   
                   
   end
