`include "ysyx_23060072_define.v"
`timescale 1 ns / 1 ps
module ysyx_23060072_simple_bpu(
    // from if_stage
    input  [31:0]    instr_rdata_i,
    input  [31:0]    instr_addr_i,

    // to if_stage
    output  wire           predict_flag_o,
    output  wire [31:0]    predict_pc_o
);


    wire opcode_jal;
    wire opcode_branch;
    wire [31:0] imm_j_type;
    wire [31:0] imm_b_type;
    reg  [31:0] predict_pc_adder;

    //only predict jal and branch
    assign opcode_jal = (instr_rdata_i[6:0] == `ysyx_23060072_OPCODE_JAL)? `ysyx_23060072_enable : `ysyx_23060072_disable;
    assign opcode_branch = (instr_rdata_i[6:0] == `ysyx_23060072_OPCODE_BRANCH)? `ysyx_23060072_enable : `ysyx_23060072_disable;


    assign imm_j_type = { {12{instr_rdata_i[31]}}, instr_rdata_i[19:12], instr_rdata_i[20], instr_rdata_i[30:21], 1'b0 };
    assign imm_b_type = { {19{instr_rdata_i[31]}}, instr_rdata_i[31], instr_rdata_i[7], instr_rdata_i[30:25], instr_rdata_i[11:8], 1'b0 };

    assign predict_flag_o = ( ( (opcode_branch==`ysyx_23060072_enable) & imm_b_type[31]) | (opcode_jal==`ysyx_23060072_enable) )? `ysyx_23060072_enable : `ysyx_23060072_disable;
    

    always@(*) begin
        case({opcode_jal, opcode_branch})
            2'b10: predict_pc_adder = imm_j_type;
            2'b01: predict_pc_adder = imm_b_type;
            default: predict_pc_adder = 32'b0;
        endcase
    end

    assign predict_pc_o = instr_addr_i + predict_pc_adder;

endmodule