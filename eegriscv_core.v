`include "define.v"
`timescale 1 ns / 1 ps
module ysyx_23060072_core(
    input              clk,
    input              rst_n,

    // from instruction memory
    input    [31:0]    instr_rdata_i,

    // from bus
    input              s0_en_i,

    // from timer
    input              timer_interrupt_i,

    // from bus
    input    [31:0]    mem_rdata_i,
    input              slave_req_i,
    input              slave_rsp_i,

    // to instruction memory
    output   [31:0]    instr_addr_o,

    // to data memory
    output             mem_we_o,
    output   [31:0]    mem_addr_o,
    output   [31:0]    mem_wdata_o,
    output             mem_en_o
);


    wire [31:0]     if2id_pc;
    wire [31:0]     if2id_instr_rdata;
    wire            if2id_timer_interrupt;

    wire [31:0]     id2ex_pc;
    wire            id2ex_timer_interrupt;
    wire [31:0]     id2ex_operand_a;
    wire [31:0]     id2ex_operand_b;
    wire [31:0]     id2ex_operand_imm;
    wire [4:0]      id2ex_alu_op;
    wire [2:0]      id2ex_csr_opcode;
    wire [11:0]     id2ex_csr_addr;
    wire            id2ex_load_flag;
    wire            id2ex_store_flag;
    wire [1:0]      id2ex_LSU_type;
    wire            id2ex_LSU_signed;
    wire [4:0]      id2ex_wb_reg_waddr;
    wire            id2ex_wb_flag;
    wire [3:0]      id2ex_multdiv_opcode;
    wire            id2ex_multdiv_en;


    wire            ex2lsu_wb_flag;            
    wire [1:0]      ex2lsu_LSU_type;            
    wire            ex2lsu_store_flag;            
    wire            ex2lsu_load_flag;            
    wire            ex2lsu_LSU_sighed;            
    wire [31:0]     ex2lsu_wb_addr;            
    wire [31:0]     ex2lsu_operand_a;            
    wire [31:0]     ex2lsu_operand_b;            
    wire [31:0]     ex2lsu_operand_imm;            
    wire [31:0]     ex2lsu_wb_data_ex;

    wire            lsu2wb_wb_flag    ;
    wire [4:0]      lsu2wb_wb_addr    ;
    wire [31:0]     lsu2wb_wb_data_lsu;

    wire            wb2id_wb_flag;
    wire [4:0]      wb2id_wb_reg_addr;
    wire [31:0]     wb2id_wb_reg_data;

    wire            if2ctrl_predict_flag;
    wire            ex2ctrl_jump_flag;
    wire            ex2ctrl_clint_hold_flag;
    wire            ex2ctrl_clint_jump_flag;
    wire            ex2ctrl_multdiv_hold_flag;
    wire [31:0]     ex2ctrl_jump_pc;
    wire [31:0]     ex2ctrl_clint_jump_pc;
    wire            lsu2ctrl_LSU_hold_flag;
    wire            ctrl2if_hold_flag;
    wire            ctrl2id_hold_flag;
    wire            ctrl2ex_hold_flag;
    wire [31:0]     ctrl2if_jump_pc;
    wire            clean_flag;

    wire [4:0]      id2fw_id_ex_rs1_addr_o;
    wire [4:0]      id2fw_id_ex_rs2_addr_o;
    wire            id2fw_has_rs1;
    wire            id2fw_has_rs2;
    wire            lsu2fw_load_flag;
    wire [31:0]     fw2ex_rs1;
    wire [31:0]     fw2ex_rs2;
    wire [31:0]     fw2lsu_rs2;



/*(* DONT_TOUCH = "true|yes" *)*/ ysyx_23060072_if_stage     if_stage( 
                                .clk                    (clk                    ),
                                .rst_n                  (rst_n                  ),
                                .instr_rdata_i          (instr_rdata_i          ),
                                .s0_en_i                (s0_en_i                ),
                                .if_hold_flag_i         (ctrl2if_hold_flag      ),
                                .clean_flag_i           (clean_flag             ),
                                .jump_pc_i              (ctrl2if_jump_pc        ),
                                .timer_interrupt_i      (timer_interrupt_i      ),
                                .pc_o                   (if2id_pc               ),
                                .predict_flag_o         (if2ctrl_predict_flag   ),
                                .instr_rdata_o          (if2id_instr_rdata      ),
                                .timer_interrupt_o      (if2id_timer_interrupt  ),
                                .instr_addr_o           (instr_addr_o           ));


/*(* DONT_TOUCH = "true|yes" *)*/ ysyx_23060072_id_stage     id_stage( 
                                .clk                    (clk                    ),
                                .rst_n                  (rst_n                  ),
                                .instr_rdata_i          (if2id_instr_rdata      ),
                                .pc_i                   (if2id_pc               ),
                                .timer_interrupt_i      (if2id_timer_interrupt  ),
                                .id_hold_flag_i         (ctrl2id_hold_flag      ),
                                .clean_flag_i           (clean_flag             ),
                                .wb_flag_i              (wb2id_wb_flag          ),
                                .wb_reg_addr_i          (wb2id_wb_reg_addr      ),
                                .wb_reg_data_i          (wb2id_wb_reg_data      ),
                                .pc_o                   (id2ex_pc               ),
                                .timer_interrupt_o      (id2ex_timer_interrupt  ),
                                .operand_a_o            (id2ex_operand_a        ),
                                .operand_b_o            (id2ex_operand_b        ),
                                .operand_imm_o          (id2ex_operand_imm      ),
                                .alu_op_o               (id2ex_alu_op           ),
                                .csr_opcode_o           (id2ex_csr_opcode       ),
                                .csr_addr_o             (id2ex_csr_addr         ),
                                .load_flag_o            (id2ex_load_flag        ),
                                .store_flag_o           (id2ex_store_flag       ),
                                .LSU_type_o             (id2ex_LSU_type         ),
                                .LSU_signed_o           (id2ex_LSU_signed       ),
                                .wb_reg_waddr_o         (id2ex_wb_reg_waddr     ),
                                .wb_flag_o              (id2ex_wb_flag          ),
                                .multdiv_opcode_o       (id2ex_multdiv_opcode   ),
                                .multdiv_en_o           (id2ex_multdiv_en       ),
                                .id_ex_rs1_addr_o       (id2fw_id_ex_rs1_addr   ),
                                .id_ex_rs2_addr_o       (id2fw_id_ex_rs2_addr   ),
                                .has_rs1_o              (id2fw_has_rs1          ),
                                .has_rs2_o              (id2fw_has_rs2          ));


/*(* DONT_TOUCH = "true|yes" *)*/ ysyx_23060072_ex_stage     ex_stage( 
                                .clk                    (clk                    ),
                                .rst_n                  (rst_n                  ),
                                .pc_i                   (id2ex_pc               ),
                                .timer_interrupt_i      (id2ex_timer_interrupt  ),
                                .operand_a_i            (fw2ex_operand_a        ),
                                .operand_b_i            (fw2ex_operand_b        ),
                                .operand_imm_i          (id2ex_operand_imm      ),
                                .alu_op_i               (id2ex_alu_op           ),
                                .csr_opcode_i           (id2ex_csr_opcode       ),
                                .csr_addr_i             (id2ex_csr_addr         ),
                                .load_flag_i            (id2ex_load_flag        ),
                                .store_flag_i           (id2ex_store_flag       ),
                                .LSU_type_i             (id2ex_LSU_type         ),
                                .LSU_signed_i           (id2ex_LSU_signed       ),
                                .wb_reg_waddr_i         (id2ex_wb_reg_waddr     ),
                                .wb_flag_i              (id2ex_wb_flag          ),
                                .multdiv_en_i           (id2ex_multdiv_en       ),
                                .multdiv_opcode_i       (id2ex_multdiv_opcode   ),
                                .ex_hold_flag_i         (ctrl2ex_hold_flag      ),
                                .jump_flag_o            (ex2ctrl_jump_flag      ),
                                .jump_pc_o              (ex2ctrl_jump_pc        ),
                                .clint_hold_flag_o      (ex2ctrl_clint_hold_flag),
                                .clint_jump_flag_o      (ex2ctrl_clint_jump_flag),
                                .clint_jump_pc_o        (ex2ctrl_clint_jump_pc  ),
                                .multdiv_hold_flag_o    (ex2ctrl_multdiv_hold_flag),
                                .wb_flag_o              (ex2lsu_wb_flag         ),
                                .LSU_type_o             (ex2lsu_LSU_type        ),
                                .store_flag_o           (ex2lsu_store_flag      ),
                                .load_flag_o            (ex2lsu_load_flag       ),
                                .LSU_signed_o           (ex2lsu_LSU_sighed      ),
                                .wb_addr_o              (ex2lsu_wb_addr         ),
                                .operand_a_o            (ex2lsu_operand_a       ),
                                .operand_b_o            (ex2lsu_operand_b       ),
                                .operand_imm_o          (ex2lsu_operand_imm     ),
                                .wb_data_ex_o           (ex2lsu_wb_data_ex      )
                            );


/*(* DONT_TOUCH = "true|yes" *)*/ ysyx_23060072_lsu_stage    lsu_stage(
                                .clk                    (clk                    ),
                                .rst_n                  (rst_n                  ), 
                                .wb_flag_i              (ex2lsu_wb_flag         ),                                           
                                .LSU_type_i             (ex2lsu_LSU_type        ),
                                .store_flag_i           (ex2lsu_store_flag      ),
                                .load_flag_i            (ex2lsu_load_flag       ),
                                .LSU_signed_i           (ex2lsu_LSU_sighed      ),
                                .wb_addr_i              (ex2lsu_wb_addr         ),
                                .operand_a_i            (ex2lsu_operand_a       ),
                                .operand_b_i            (fw2lsu_operand_b       ),
                                .operand_imm_i          (ex2lsu_operand_imm     ),
                                .wb_flag_o              (lsu2wb_wb_flag         ),
                                .wb_addr_o              (lsu2wb_wb_addr         ),      
                                .wb_data_lsu_o          (lsu2wb_wb_data_lsu     ),
                                .LSU_hold_flag_o        (lsu2ctrl_LSU_hold_flag ),
                                .load_flag_o            (lsu2fw_load_flag       ));


/*(* DONT_TOUCH = "true|yes" *)*/ ysyx_23060072_wb_stage     wb_stage(
                                .clk                    (clk                    ),                                                
                                .rst_n                  (rst_n                  ),
                                .wb_flag_i              (lsu2wb_wb_flag         ),
                                .wb_addr_i              (lsu2wb_wb_addr         ),      
                                .wb_data_i              (lsu2wb_wb_data_lsu     ),
                                .wb_flag_o              (wb2id_wb_flag          ),
                                .wb_addr_o              (wb2id_wb_reg_addr      ),
                                .wb_data_o              (wb2id_wb_reg_data      ));


/*(* DONT_TOUCH = "true|yes" *)*/ ysyx_23060072_controller   controller( 
                                .clk                    (clk                    ),
                                .rst_n                  (rst_n                  ),
                                .predict_flag_i         (if2ctrl_predict_flag   ),
                                .jump_flag_i            (ex2ctrl_jump_flag      ),
                                .jump_pc_i              (ex2ctrl_jump_pc        ),
                                .clint_jump_flag_i      (ex2ctrl_clint_jump_flag),
                                .clint_jump_pc_i        (ex2ctrl_clint_jump_pc  ),
                                .clint_hold_flag_i      (ex2ctrl_clint_hold_flag),
                                .multdiv_hold_flag_i    (ex2ctrl_multdiv_hold_flag),
                                .LSU_hold_flag_i        (lsu2ctrl_LSU_hold_flag ),  // from lsu
                                .clean_flag_o           (clean_flag             ),
                                .jump_pc_o              (ctrl2if_jump_pc        ),
                                .if_hold_flag_o         (ctrl2if_hold_flag      ),
                                .id_hold_flag_o         (ctrl2id_hold_flag      ),
                                .ex_hold_flag_o         (ctrl2ex_hold_flag      ));


/*(* DONT_TOUCH = "true|yes" *)*/ ysyx_23060072_forward      forward( 
                                .id2ex_has_rs1          (id2fw_has_rs1          ),
                                .id2ex_has_rs2          (id2fw_has_rs2          ),
                                .ex2lsu_wb_flag         (ex2lsu_wb_flag         ),
                                .lsu2wb_wb_flag         (lsu2wb_wb_flag         ),
                                .lsu2wb_load_flag       (lsu2wb_load_flag       ),
                                .ex2lsu_store_flag      (ex2lsu_store_flag      ),
                                .ex2lsu_wb_addr         (ex2lsu_wb_addr         ),
                                .lsu2wb_wb_addr         (lsu2wb_wb_addr         ),
                                .id2ex_rs1_addr         (id2fw_id_ex_rs1_addr   ),
                                .id2ex_rs2_addr         (id2fw_id_ex_rs2_addr   ),
                                .ex2lsu_wb_data         (ex2lsu_wb_data         ),
                                .lsu2wb_wb_data         (lsu2wb_wb_data         ),
                                .id2ex_operand_a        (id2ex_operand_a        ),
                                .id2ex_operand_b        (id2ex_operand_b        ),
                                .ex2lsu_operand_b       (ex2lsu_operand_b       ),
                                .operand_a_ex_stage     (fw2ex_operand_a        ),
                                .operand_b_ex_stage     (fw2ex_operand_b        ),
                                .operand_b_lsu_stage    (fw2lsu_operand_b       ));


endmodule
