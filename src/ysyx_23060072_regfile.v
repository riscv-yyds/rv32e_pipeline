`include "ysyx_23060072_define.v"
`timescale 1 ns / 1 ps
module ysyx_23060072_regfile(
    input   wire           clk,
    input   wire           rst_n,

    // from decoder
    input   wire [4:0]    rega_raddr_i,
    input   wire [4:0]    regb_raddr_i,

    // from wb_stage
    input   wire [4:0]     wb_reg_addr_i,
    input   wire           wb_flag_i,
    input   wire [31:0]    wb_wdata_i,

    // to decoder
    output  reg  [31:0]    rega_rdata_o,
    output  reg  [31:0]    regb_rdata_o
);


    reg  [31:0] rf_reg[0:31];
    wire [31:1] we_index;  // 按位索引写寄存器，因为第0位对应的是0号寄存器，它永远为0且不能被写入，所以不需要对第0位操作
    //assign rf_reg[0] = 32'd0;

    always @(posedge clk) begin
        rf_reg[0] = 32'b0;
    end

    // 读操作 （引入数据旁路解决RAW）
    // 对于三级流水，如果上一条指令写回的地址刚好为本指令的读地址，直接把ex阶段的wb_data连接到读数据端口即可，
    // 因为上一条指令的ex和本指令的id发生在同一个clk
    always@(*) begin
        if( wb_flag_i && (rega_raddr_i==wb_reg_addr_i) && (rega_raddr_i!=32'b0) )
            rega_rdata_o = wb_wdata_i;
        else if (rega_raddr_i == 32'b0)
            rega_rdata_o = 32'b0;
        else
            rega_rdata_o = rf_reg[rega_raddr_i];
    end

    always@(*) begin
        if( wb_flag_i && (regb_raddr_i==wb_reg_addr_i) && (regb_raddr_i!=32'b0) )
            regb_rdata_o = wb_wdata_i;
        else if (regb_raddr_i == 32'b0)
            regb_rdata_o = 32'b0;
        else
            regb_rdata_o = rf_reg[regb_raddr_i];
    end


    // 写操作
    genvar i;
    generate
        for (i = 1; i < 32; i=i+1) begin : we_index_flops
            assign we_index[i] = (wb_reg_addr_i == i) ?  wb_flag_i : 1'b0;
        end
    endgenerate

    genvar j;
    generate
    for (j = 1; j < 32; j=j+1) begin : w_rf_flops
        always@(posedge clk or negedge rst_n) begin
            if(!rst_n)
                rf_reg[j] <=  32'b0;
            // 当索引的第i位拉高时，对应的寄存器执行写操作
            else if(we_index[j])
                rf_reg[j] <=  wb_wdata_i;
        end
    end
    endgenerate

endmodule