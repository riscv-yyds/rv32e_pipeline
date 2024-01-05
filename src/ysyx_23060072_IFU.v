`include "ysyx_23060072_define.v"
/*
module ysyx_23060072_IFU_dpic(
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
*/


module ysyx_23060072_IFU(
    input  [31:0]   instr_addr_i,
    output [31:0]   inst_rdata_o
);
	
	reg [31:0] rom[255:0];

	wire [7:0] read_addr = instr_addr_i[9:2];

    //rom initial
    initial begin
        //$readmemh("../bin/add_addi_sub.txt", rom);
        //$readmemh("../bin/lui_auipc.txt", rom);
        //$readmemh("../bin/store_load.txt", rom);
        //$readmemh("../bin/and_or_xor.txt", rom);
        $readmemh("../bin/data_hazards.txt", rom);
        //$readmemh("../bin/sw_lw_hazards.txt", rom);
    end
	
    assign inst_rdata_o = rom[read_addr];

endmodule


