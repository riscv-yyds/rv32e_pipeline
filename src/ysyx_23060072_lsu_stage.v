`include "ysyx_23060072_define.v"
module ysyx_23060072_lsu_stage(
    input                               clk,
    input                               rst_n,

    // from ex_stage
    // pipeline control signal (ex_stage to lsu_stage)
    input                               wb_flag_i,
    input   [1:0]                       LSU_type_i,
    input                               store_flag_i,
    input                               load_flag_i,
    input                               LSU_signed_i,
    // pipeline data flow (ex_stage to lsu_stage)
    input   [31:0]                      pc_i,
    input   [4:0]                       wb_addr_i,
    input   [31:0]                      wb_data_i,
    input   [31:0]                      operand_a_i,
    input   [31:0]                      operand_b_i,
    input   [31:0]                      operand_imm_i,

    // to wb_stage
    // pipeline control signal (lsu_stage to wb_stage)
    output  reg                         wb_flag_o,
    output  reg [31:0]                  pc_o,
    // pipeline data flow (lsu_stage to wb_stage)
    output  reg [4:0]                   wb_addr_o,           
    output  reg [31:0]                  wb_data_lsu_o,

    // to controller
    output                              LSU_hold_flag_o,

    // to forward
    output  reg                         load_flag_o
);

    wire  [31:0]    LSU_wb_wdata;
    wire  [31:0]    wb_data_lsu;
    wire            LSU_wb_flag;    

/*(* DONT_TOUCH = "true|yes" *)*/ysyx_23060072_LSU lsu( .clk(clk),
                                .rst_n              (rst_n              ),
                                .LSU_type_i         (LSU_type_i         ),
                                .store_flag_i       (store_flag_i       ),
                                .load_flag_i        (load_flag_i        ),
                                .LSU_signed_i       (LSU_signed_i       ),
                                .operand_a_i        (operand_a_i        ),
                                .operand_b_i        (operand_b_i        ),
                                .operand_imm_i      (operand_imm_i      ),
                                .LSU_hold_flag_o    (LSU_hold_flag_o    ),
                                .wb_wdata_o         (LSU_wb_wdata       ),
                                .LSU_wb_flag_o      (LSU_wb_flag        ));


    assign  wb_data_lsu =   (LSU_wb_flag)?  LSU_wb_wdata :  wb_data_i;

    // pipeline control signal (lsu_stage to wb_stage)
    always@(posedge clk) begin
        if (!rst_n) begin
            // from ex_stage
            wb_flag_o           <=  1'b0;
            load_flag_o         <=  1'b0;
        end else if (!LSU_hold_flag_o) begin
            // from ex_stage
            wb_flag_o           <=  wb_flag_i;
            load_flag_o         <=  load_flag_i;
        end else begin
            // from ex_stage
            wb_flag_o           <=  wb_flag_o;
            load_flag_o         <=  load_flag_o;
        end
    end

    // pipeline data flow (lsu_stage to wb_stage)
    always@(posedge clk) begin
        if (!rst_n) begin
            // from ex_stage
            wb_addr_o           <=  5'd0;
            // from lsu_stage
            pc_o                <=  32'd0;
            wb_data_lsu_o       <=  32'd0;
        end else if (!LSU_hold_flag_o) begin
            // from ex_stage
            wb_addr_o           <=  wb_addr_i;
            // from lsu_stage
            pc_o                <=  pc_i;
            wb_data_lsu_o       <=  wb_data_lsu;
        end else begin
            // from ex_stage
            wb_addr_o           <=  wb_addr_o;
            // from lsu_stage
            pc_o                <=  pc_o;
            wb_data_lsu_o       <=  wb_data_lsu_o;
        end
    end


endmodule 


