`include "ysyx_23060072_define.v"
`timescale 1 ns / 1 ps
module ysyx_23060072_if_stage(
    input                   clk,
    input                   rst_n,

    // from controller
    input                   if_hold_flag_i,
    input                   clean_flag_i,
    input [31:0]            jump_pc_i,

    // to id_ex_stage
    //output reg [31:0]       pc_o,
    output     [31:0]       pc_o,
    output reg              predict_flag_o,
    output reg [31:0]       instr_rdata_o
);


    reg  [31:0] pc_next;
    reg  [31:0] pc_reg;
    wire [31:0] instr_rdata_next;
    wire [31:0] bpu_predict_pc;
    wire        bpu_predict_flag;
    wire [31:0] instr_addr;
    wire [31:0] instr_rdata;

    ysyx_23060072_IFU    ifu(
                   //.rst_n           (rst_n          ),
                   .instr_addr_i    (instr_addr     ),
                   .inst_rdata_o    (instr_rdata    ));
    
    ysyx_23060072_simple_bpu bpu( 
                       // from if_stage
                       .instr_rdata_i   (instr_rdata_next   ),
                       .instr_addr_i    (pc_reg             ),
                       // to if_stage
                       .predict_flag_o  (bpu_predict_flag   ),
                       .predict_pc_o    (bpu_predict_pc     ));

    // no rst
    /*
    always@(*) begin
        if(clean_flag_i==`ysyx_23060072_enable)
            pc_next = jump_pc_i;
        else if (if_hold_flag_i == `ysyx_23060072_enable)
            pc_next = pc_reg;
        else if(bpu_predict_flag==`ysyx_23060072_enable)
            pc_next = bpu_predict_pc;
        else
            pc_next = pc_reg + 32'd4;
    end
    */

    // has rst
    always@(*) begin
        if (!rst_n)
            pc_next = 32'd0;
        else if(clean_flag_i==`ysyx_23060072_enable)
            pc_next = jump_pc_i;
        else if (if_hold_flag_i == `ysyx_23060072_enable)
            pc_next = pc_reg;
        else if(bpu_predict_flag==`ysyx_23060072_enable)
            pc_next = bpu_predict_pc;
        else
            pc_next = pc_reg + 32'd4;
    end

    assign instr_rdata_next = (clean_flag_i == `ysyx_23060072_enable)?    32'h0000_0013 : instr_rdata;
    assign instr_addr = pc_next;

    // posedge of rst_n
    reg rst_n_r;
    always @(posedge clk) begin
        if (!rst_n)
            rst_n_r <= 1'b0;
        else
            rst_n_r <= 1'b1;
    end

    wire posedge_rst_n = rst_n & (!rst_n_r);

    // pc_reg
    always@(posedge clk) begin
        if (!rst_n)
            pc_reg <=  32'd0;
        else if (posedge_rst_n)
            pc_reg <=  32'd0;
        else
            pc_reg <=  pc_next;  
    end

    assign pc_o = pc_reg;

    // pipeline (if_stage to id_ex_stage)
    always@(posedge clk) begin
        if (!rst_n) begin
            instr_rdata_o <=  32'd0;
            predict_flag_o <=  1'b0;
        end else if(!if_hold_flag_i) begin
            //pc_o <= pc_reg;
            instr_rdata_o <=  instr_rdata_next;
            predict_flag_o <=  bpu_predict_flag;
        end else begin
            //pc_o <= pc_o;
            instr_rdata_o <=  instr_rdata_o;
            predict_flag_o <=  predict_flag_o;
        end
    end

endmodule