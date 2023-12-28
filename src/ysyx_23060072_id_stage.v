`include "ysyx_23060072_define.v"
`timescale 1 ns / 1 ps
module ysyx_23060072_id_stage(
    input                                  clk,
    input                                  rst_n,

    // from if_stage
    input    [31:0]                        instr_rdata_i,
    input    [31:0]                        pc_i,
    input                                  timer_interrupt_i,

    // from controller
    input                                  id_hold_flag_i,
    input                                  clean_flag_i,

    // from wb_stage
    input                                  wb_flag_i,
    input    [4:0]                         wb_reg_addr_i,
    input    [31:0]                        wb_reg_data_i,

    // to ex_stage
    output reg   [31:0]                        pc_o,
    output reg                                 timer_interrupt_o,
    output reg   [4:0]                         alu_op_o,
    output reg   [2:0]                         csr_opcode_o,
    output reg   [11:0]                        csr_addr_o,
    //`ysyx_23060072_ALU
    output reg   [31:0]                        operand_a_o,
    output reg   [31:0]                        operand_b_o,
    output reg   [31:0]                        operand_imm_o,
    //clint
    //LSU
    output reg                                 load_flag_o,
    output reg                                 store_flag_o,
    output reg   [1:0]                         LSU_type_o,
    output reg                                 LSU_signed_o,
    //WB
    output reg   [4:0]                         wb_reg_waddr_o,
    output reg                                 wb_flag_o,
    //multdiv
    output reg   [3:0]                         multdiv_opcode_o,
    output reg                                 multdiv_en_o,

    // to forward
    output reg   [4:0]                         id2ex_rs1_addr_o,  
    output reg   [4:0]                         id2ex_rs2_addr_o,
    output                                     has_rs1_o,  
    output                                     has_rs2_o 
);


    wire [4:0] wb_reg_waddr;
    wire [31:0] wb_operand_result;
    wire wb_flag;

    wire [31:0] rega_rdata;
    wire [31:0] regb_rdata;
    wire [4:0] rega_raddr;
    wire [4:0] regb_raddr;

    wire [31:0] operand_a;
    wire [31:0] operand_b;
    wire [31:0] operand_imm;
    wire [4:0]  alu_op;
    wire [1:0] LSU_type;
    wire LSU_signed;
    wire store_flag;
    wire load_flag;
    wire [2:0] csr_opcode;
    wire [11:0] csr_addr;
    wire [3:0] multdiv_opcode;
    wire multdiv_en;

    /*(* DONT_TOUCH = "true|yes" *)*/ysyx_23060072_decoder decoder(   .instr_rdata_i(instr_rdata_i),
                                .rega_rdata_i(rega_rdata),
                                .regb_rdata_i(regb_rdata),
                                /*
                                .wb_bypass_data_i(wb_reg_data_i),
                                .wb_bypass_addr_i(wb_reg_addr_i),
                                .wb_bypass_we_i(wb_flag_i),
                                */
                                .pc_i(pc_i),
                                .alu_op_o(alu_op),
                                .operand_a_o(operand_a),
                                .operand_b_o(operand_b),
                                .operand_imm_o(operand_imm),
                                .rega_raddr_o(rega_raddr),
                                .regb_raddr_o(regb_raddr),
                                .wb_reg_waddr_o(wb_reg_waddr),
                                .wb_flag_o(wb_flag),
                                .LSU_type_o(LSU_type),
                                .LSU_signed_o(LSU_signed),
                                .store_flag_o(store_flag),
                                .load_flag_o(load_flag),
                                .csr_opcode_o(csr_opcode),
                                .csr_addr_o(csr_addr),
                                .multdiv_opcode_o(multdiv_opcode),
                                .multdiv_en_o(multdiv_en),
                                .has_rs1(has_rs1_o),
                                .has_rs2(has_rs2_o));

    /*(* DONT_TOUCH = "true|yes" *)*/ysyx_23060072_regfile regfile(   .clk(clk),
                                .rst_n(rst_n),
                                .rega_raddr_i(rega_raddr),
                                .regb_raddr_i(regb_raddr),
                                .wb_reg_addr_i(wb_reg_addr_i),
                                .wb_flag_i(wb_flag_i),
                                .wb_wdata_i(wb_reg_data_i),
                                .rega_rdata_o(rega_rdata),
                                .regb_rdata_o(regb_rdata));



    // pipeline control signal (id_stage to ex_stage)
    always@(posedge clk) begin
        if (!rst_n) begin
            wb_flag_o <=  `ysyx_23060072_disable;
            load_flag_o <=  `ysyx_23060072_disable;
            store_flag_o <=  `ysyx_23060072_disable;
            timer_interrupt_o <=  `ysyx_23060072_disable;
            alu_op_o <=  `ysyx_23060072_ALU_NOP;
            multdiv_en_o <=  `ysyx_23060072_disable;
        end
        else if(clean_flag_i) begin
            wb_flag_o <=  `ysyx_23060072_disable;
            load_flag_o <=  `ysyx_23060072_disable;
            store_flag_o <=  `ysyx_23060072_disable;
            timer_interrupt_o <=  `ysyx_23060072_disable;
            alu_op_o <=  `ysyx_23060072_ALU_NOP;
            multdiv_en_o <=  `ysyx_23060072_disable;
        end else if(!id_hold_flag_i) begin
            wb_flag_o <=  wb_flag;
            load_flag_o <=  load_flag;
            store_flag_o <=  store_flag;
            timer_interrupt_o <=  timer_interrupt_i;
            alu_op_o <=  alu_op;
            multdiv_en_o <=  multdiv_en;
        end else begin
            wb_flag_o <=  wb_flag_o;
            load_flag_o <=  load_flag_o;
            store_flag_o <=  store_flag_o;
            timer_interrupt_o <=  timer_interrupt_o;
            alu_op_o <=  alu_op_o;
            multdiv_en_o <=  multdiv_en_o;
        end
    end

    // pipeline data flow ( id2ex_stage to wb_stage)
    always@(posedge clk) begin
        if (!rst_n) begin
            pc_o <=  32'd0;
            operand_a_o <= 32'd0;
            operand_b_o <= 32'd0;
            operand_imm_o <= 32'd0;
            csr_opcode_o <= 3'd0;
            csr_addr_o <=  12'd0;
            LSU_type_o <=  2'd0;
            LSU_signed_o <=  1'b0;
            wb_reg_waddr_o <=  5'd0;
            multdiv_opcode_o <=  4'd0;
            id2ex_rs1_addr_o  <=  5'd0;
            id2ex_rs2_addr_o  <=  5'd0;
        end
        if(!id_hold_flag_i) begin
            pc_o <=  pc_i;
            operand_a_o <=  operand_a;
            operand_b_o <=  operand_b;
            operand_imm_o <=  operand_imm;
            csr_opcode_o <=  csr_opcode;
            csr_addr_o <=  csr_addr;
            LSU_type_o <=  LSU_type;
            LSU_signed_o <=  LSU_signed;
            wb_reg_waddr_o <=  wb_reg_waddr;
            multdiv_opcode_o <=  multdiv_opcode;
            id2ex_rs1_addr_o  <=  rega_raddr;
            id2ex_rs2_addr_o  <=  regb_raddr;
        end else begin
            pc_o <=  pc_o;
            operand_a_o <=  operand_a_o;
            operand_b_o <=  operand_b_o;
            operand_imm_o <=  operand_imm_o;
            csr_opcode_o <=  csr_opcode_o;
            csr_addr_o <=  csr_addr_o;
            LSU_type_o <=  LSU_type_o;
            LSU_signed_o <=  LSU_signed_o;
            wb_reg_waddr_o <=  wb_reg_waddr_o;
            multdiv_opcode_o <=  multdiv_opcode_o;
            id2ex_rs1_addr_o  <=  id2ex_rs1_addr_o;
            id2ex_rs2_addr_o  <=  id2ex_rs2_addr_o;
        end
    end

endmodule