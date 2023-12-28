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

    //rom进行初始�?
    initial begin
        //$readmemh("./rom_hex.txt", rom);
        //$readmemb("./rom_binary.txt", u_core.if_stage.ifu.rom);
        //$readmemb("rom_binary.txt", rom);
        $readmemh("rom_hex.txt", rom);
    end
	
    assign inst_rdata_o = rom[read_addr];

endmodule


