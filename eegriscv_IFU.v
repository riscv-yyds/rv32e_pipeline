`include "define.v"
module ysyx_23060072_IFU(
    input           rst_n,
    input  [31:0]   instr_addr_i,
    output [31:0]   inst_rdata_o
);
    
    import "DPI-C" function void vaddr_read(input int raddr, input byte rlen, output int rdata);

    // inst
    always @(*) begin
        if (!rst_n)
            vaddr_read(32'h80000000, 4, inst_rdata_o)    ;
        else
            vaddr_read(instr_addr_i, 4, instr_rdata_o)                                 ;
    end


endmodule 