`include "ysyx_23060072_define.v"
`timescale 1 ns / 1 ps
module ysyx_23060072_alu(
    // from id_ex_stage
    input    [31:0]            operand_pc_i,

    // from decoder
    input    [4:0]             alu_op_i,
    input    [31:0]            operand_a_i,
    input    [31:0]            operand_b_i,
    input    [31:0]            operand_imm_i,

    // to ex_stage
    output   [31:0]            operand_result_o,
    
    // to controller
    output                     jump_flag_o,
    output   [31:0]            jump_pc_o
);


    reg  compare_big;
    reg  compare_small;
    reg  compare_equal;
    wire compare_signed;
    wire [31:0] sr_shift;
    wire [31:0] sr_shift_mask;
    wire [31:0] operand_a;
    wire [31:0] operand_b;
    wire [31:0] operand_imm;
    wire [31:0] operand_pc;

    assign sr_shift = operand_a >> operand_b[4:0];
    assign sr_shift_mask = 32'hffffffff >> operand_b[4:0];
    assign compare_signed = ( (alu_op_i==`ysyx_23060072_ALU_LT) | (alu_op_i==`ysyx_23060072_ALU_GE) | (alu_op_i==`ysyx_23060072_ALU_SLT) )? `ysyx_23060072_enable : `ysyx_23060072_disable;
    assign operand_a = operand_a_i;
    assign operand_b = operand_b_i;
    assign operand_imm = operand_imm_i;
    assign operand_pc = operand_pc_i;

    // comparsion flag signal generation
    always@(*) begin
        if(compare_signed) begin
            if(operand_a[31]==operand_b[31]) begin
                if(operand_a==operand_b) begin
                    compare_equal = `ysyx_23060072_enable;
                    compare_big = `ysyx_23060072_disable;
                    compare_small = `ysyx_23060072_disable;
                end else if(operand_a > operand_b) begin
                    compare_equal = `ysyx_23060072_disable;
                    compare_big = `ysyx_23060072_enable;
                    compare_small = `ysyx_23060072_disable;
                end else begin
                    compare_equal = `ysyx_23060072_disable;
                    compare_big = `ysyx_23060072_disable;
                    compare_small = `ysyx_23060072_enable;
                end
            end else begin
                if(operand_a[31]==1'b0) begin
                    compare_equal = `ysyx_23060072_disable;
                    compare_big = `ysyx_23060072_enable;
                    compare_small = `ysyx_23060072_disable;
                end else begin
                    compare_equal = `ysyx_23060072_disable;
                    compare_big = `ysyx_23060072_disable;
                    compare_small = `ysyx_23060072_enable;
                end
            end
        end else begin
            if(operand_a==operand_b) begin
                compare_equal = `ysyx_23060072_enable;
                compare_big = `ysyx_23060072_disable;
                compare_small = `ysyx_23060072_disable;
            end else if(operand_a > operand_b) begin
                compare_equal = `ysyx_23060072_disable;
                compare_big = `ysyx_23060072_enable;
                compare_small = `ysyx_23060072_disable;
            end else begin
                compare_equal = `ysyx_23060072_disable;
                compare_big = `ysyx_23060072_disable;
                compare_small = `ysyx_23060072_enable;
            end
        end
    end

    // jump pc generation
    reg [31:0]  jump_pc_reg;
    assign  jump_pc_o = jump_pc_reg;

    always@(*) begin
        if(!jump_flag_o) begin
            jump_pc_reg = operand_pc + 32'd4;
        end else begin
            case(alu_op_i)
                `ysyx_23060072_ALU_JALR: jump_pc_reg = (operand_a + operand_imm);
                `ysyx_23060072_ALU_FENCE_I: jump_pc_reg = operand_pc + 32'd4;
                default: jump_pc_reg = operand_pc + operand_imm;
            endcase
        end
    end

    // jump flag signal generation
    reg     jump_flag_reg;
    assign  jump_flag_o = jump_flag_reg;

    always@(*) begin
        case(alu_op_i)
            `ysyx_23060072_ALU_LTU,
            `ysyx_23060072_ALU_LT: jump_flag_reg = (compare_small==`ysyx_23060072_enable)? `ysyx_23060072_enable : `ysyx_23060072_disable;
            `ysyx_23060072_ALU_GE,
            `ysyx_23060072_ALU_GEU: jump_flag_reg = (compare_big | compare_equal)? `ysyx_23060072_enable : `ysyx_23060072_disable;
            `ysyx_23060072_ALU_EQ: jump_flag_reg = (compare_equal==`ysyx_23060072_enable)? `ysyx_23060072_enable : `ysyx_23060072_disable;
            `ysyx_23060072_ALU_NE: jump_flag_reg = (compare_equal==`ysyx_23060072_disable)? `ysyx_23060072_enable : `ysyx_23060072_disable;
            `ysyx_23060072_ALU_JAL,
            `ysyx_23060072_ALU_JALR,
            `ysyx_23060072_ALU_FENCE_I: jump_flag_reg = `ysyx_23060072_enable;
            default: jump_flag_reg = `ysyx_23060072_disable;
        endcase
    end


    // operand_result compute
    reg [31:0]  operand_result_reg;
    assign  operand_result_o = operand_result_reg;

    always@(*) begin
        case(alu_op_i)
            `ysyx_23060072_ALU_ADD: operand_result_reg = operand_a + operand_b;
            `ysyx_23060072_ALU_SUB: operand_result_reg = operand_a - operand_b;
            `ysyx_23060072_ALU_XOR: operand_result_reg = operand_a ^ operand_b;
            `ysyx_23060072_ALU_OR: operand_result_reg = operand_a | operand_b;
            `ysyx_23060072_ALU_AND: operand_result_reg = operand_a & operand_b;
            `ysyx_23060072_ALU_SRA: operand_result_reg = sr_shift | ({32{operand_a[31]}} & (~sr_shift_mask));
            `ysyx_23060072_ALU_SRL: operand_result_reg = operand_a >> operand_b[4:0];
            `ysyx_23060072_ALU_SLL: operand_result_reg = operand_a << operand_b[4:0];
            `ysyx_23060072_ALU_SLT: operand_result_reg = (compare_small==`ysyx_23060072_enable)? 32'b1 : 32'b0;
            `ysyx_23060072_ALU_SLTU: operand_result_reg = (compare_small==`ysyx_23060072_enable)? 32'b1 : 32'b0;
            `ysyx_23060072_ALU_JAL,
            `ysyx_23060072_ALU_JALR: operand_result_reg = operand_pc + 32'd4;
            default: operand_result_reg = 32'b0;
        endcase
    end

endmodule