`include "ysyx_23060072_define.v"
`timescale 1 ns / 1 ps
module ysyx_23060072_ex_stage(
    input                                   clk,
    input                                   rst_n,

    // from id_stage
    input    [31:0]                         pc_i,
    input                                   timer_interrupt_i,
    //ALU
    input    [31:0]                         operand_a_i,
    input    [31:0]                         operand_b_i,
    input    [31:0]                         operand_imm_i,
    input    [4:0]                          alu_op_i,
    //clint
    input    [2:0]                          csr_opcode_i,
    input    [11:0]                         csr_addr_i,
    //LSU
    input                                   load_flag_i,
    input                                   store_flag_i,
    input    [1:0]                          LSU_type_i,
    input                                   LSU_signed_i,
    //WB
    input    [4:0]                          wb_reg_waddr_i,
    input                                   wb_flag_i,
    //multdiv
    input    [3:0]                          multdiv_opcode_i,
    input                                   multdiv_en_i,
    
    // from controller
    input                                   ex_hold_flag_i,
    // to controller
    output                                  jump_flag_o,
    output   [31:0]                         jump_pc_o,
    output                                  clint_hold_flag_o,
    output                                  clint_jump_flag_o,
    output   [31:0]                         clint_jump_pc_o,
    output                                  multdiv_hold_flag_o,

    // to lsu_stage
    // pipeline control signal (ex_stage to lsu_stage)
    output  reg                             wb_flag_o,
    output  reg [1:0]                       LSU_type_o,
    output  reg                             store_flag_o,
    output  reg                             load_flag_o,
    output  reg                             LSU_signed_o,
    // pipeline data flow (ex_stage to lsu_stage)
    output  reg [4:0]                       wb_addr_o,
    output  reg [31:0]                      operand_a_o,
    output  reg [31:0]                      operand_b_o,
    output  reg [31:0]                      operand_imm_o,
    output  reg [31:0]                      wb_data_ex_o
);

    wire            csr_wb_flag;
    wire            clint_jump_flag;
    wire            clint_hold_flag;
    wire            multdiv_hold_flag;
    wire  [31:0]    multdiv_result;
    wire  [31:0]    csr_rdata;
    wire  [31:0]    operand_result;
    wire  [31:0]    clint_jump_pc;



/*(* DONT_TOUCH = "true|yes" *)*/ysyx_23060072_alu       alu(   
                                .operand_pc_i       (pc_i                   ),
                                .alu_op_i           (alu_op_i               ),
                                .operand_a_i        (operand_a_i            ),
                                .operand_b_i        (operand_b_i            ),
                                .operand_imm_i      (operand_imm_i          ),
                                .operand_result_o   (operand_result         ),
                                .jump_flag_o        (jump_flag_o            ),
                                .jump_pc_o          (jump_pc_o              ));


/*(* DONT_TOUCH = "true|yes" *)*/ysyx_23060072_clint     clint(   
                                .clk                (clk                    ),
                                .rst_n              (rst_n                  ),
                                .pc_i               (pc_i                   ),
                                .csr_opcode_i       (csr_opcode_i           ),
                                .csr_addr_i         (csr_addr_i             ),
                                .operand_a_i        (operand_a_i            ),
                                //.operand_b_i        (operand_b_i            ),
                                //.timer_interrupt_i  (timer_interrupt_i      ),
                                .clint_hold_flag_o  (clint_hold_flag_o      ),
                                .clint_jump_pc_o    (clint_jump_pc_o        ),
                                .clint_jump_flag_o  (clint_jump_flag_o      ),
                                .csr_wb_wdata_o     (csr_rdata              ),
                                .csr_wb_flag_o      (csr_wb_flag            ));

/*ysyx_23060072_multdiv   multdiv(   
                                .clk                (clk                    ),
                                .rst_n              (rst_n                  ),
                                .operand_a_i        (operand_a              ),
                                .operand_b_i        (operand_b              ),
                                .multdiv_en_i       (multdiv_en_i           ),
                                .op_i               (multdiv_opcode_i       ),
                                .multdiv_result_o   (multdiv_result         ),
                                .hold_flag_o        (multdiv_hold_flag_o    ));*/

    assign  multdiv_hold_flag_o =   1'b0;

    reg [31:0]  wb_data_ex;
    always@(*) begin
        if (csr_wb_flag)
            wb_data_ex = csr_rdata;
        else if (multdiv_en_i)
            wb_data_ex = 'd0;
        else
            wb_data_ex = operand_result;
    end


    // pipeline control signal (ex_stage to lsu_stage)
    always@(posedge clk) begin
        if (!rst_n) begin
            // from id_stage
            wb_flag_o           <=  1'd0;
            // lsu needed
            LSU_type_o          <=  2'd0;
            store_flag_o        <=  1'b0;
            load_flag_o         <=  1'b0;
            LSU_signed_o        <=  1'b0;
        end else if (!ex_hold_flag_i) begin
            // from id_stage
            wb_flag_o           <=  wb_flag_i;
            // lsu needed
            LSU_type_o          <=  LSU_type_i;
            store_flag_o        <=  store_flag_i;
            load_flag_o         <=  load_flag_i;
            LSU_signed_o        <=  LSU_signed_i;
        end else begin
            // from id_stage
            wb_flag_o           <=  wb_flag_o;
            // lsu needed
            LSU_type_o          <=  LSU_type_o;
            store_flag_o        <=  store_flag_o;
            load_flag_o         <=  load_flag_o;
            LSU_signed_o        <=  LSU_signed_o;
        end
    end


    // pipeline data flow (ex_stage to lsu_stage)
    always@(posedge clk) begin
        if (!rst_n) begin
            // from id_stage
            wb_addr_o           <=  5'd0;
            // lsu needed
            operand_a_o         <=  32'd0;  
            operand_b_o         <=  32'd0;  
            operand_imm_o       <=  32'd0; 
            // wb needed
            wb_data_ex_o        <=  32'd0;
        end else if (!ex_hold_flag_i) begin
            // from id_stage
            wb_addr_o           <=  wb_reg_waddr_i;
            // lsu needed
            operand_a_o         <=  operand_a_i;  
            operand_b_o         <=  operand_b_i;  
            operand_imm_o       <=  operand_imm_i;  
            // wb needed
            wb_data_ex_o        <=  wb_data_ex;
        end else begin
            // from id_stage
            wb_addr_o           <=  wb_addr_o;
            // lsu needed
            operand_a_o         <=  operand_a_o;  
            operand_b_o         <=  operand_b_o;  
            operand_imm_o       <=  operand_imm_o;  
            // wb needed
            wb_data_ex_o        <=  wb_data_ex_o;
        end
    end


endmodule