`include "define.v"
module ysyx_23060072_wb_stage(
    input                           clk,
    input                           rst_n,

    // from wb_stage
    // pipeline control signal (lsu_stage to wb_stage)
    input                           wb_flag_i,
    // pipeline data flow (lsu_stage to wb_stage)
    input   [4:0]                   wb_addr_i,           
    input   [31:0]                  wb_data_i,

    output                          wb_flag_o,
    output  [31:0]                  wb_addr_o,            
    output  [31:0]                  wb_data_o
);

    assign  wb_flag_o   =   wb_flag_i;
    assign  wb_addr_o   =   wb_addr_i;
    assign  wb_data_o   =   wb_data_i;

    /*reg [31:0]  wb_data;
    always@(*) begin
        if (csr_wb_flag_i)
            wb_data = csr_rdata;
        else if (LSU_wb_flag_i)
            wb_data = wb_wdata;
        else if (multdiv_en_i)
            wb_data = multdiv_result;
        else
            wb_data = operand_result;
    end*/


endmodule