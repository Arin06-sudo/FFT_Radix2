module control_fsm( clk,rst,start,done,
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
    
    
    

endmodule
