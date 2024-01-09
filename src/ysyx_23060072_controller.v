`include "ysyx_23060072_define.v"
`timescale 1 ns / 1 ps
module ysyx_23060072_controller(
    input                  clk,
    input                  rst_n,

    //================= if_stage =================//
    input                  predict_flag_i,

    //================= ex_stage =================//
    // from alu
    input                  jump_flag_i,
    input    [31:0]        jump_pc_i,
    // from clint
    input                  clint_jump_flag_i,
    input    [31:0]        clint_jump_pc_i,
    input                  clint_hold_flag_i,
    // from multdiv
    input                  multdiv_hold_flag_i,

    //================ lsu_stage =================//
    input                  LSU_hold_flag_i,

    //================ controller =================//
    input                  forwardD_i,

    //================== output ==================//
    output                 clean_flag_o,
    output   [31:0]        jump_pc_o,
    output                 if_hold_flag_o,
    output                 id_hold_flag_o,
    output                 ex_hold_flag_o
);

    // 冲刷并跳转到正确的PC只发生在 ex_stage
    assign  clean_flag_o    =   (!rst_n)? `ysyx_23060072_disable : clint_jump_flag_i? `ysyx_23060072_enable : (predict_flag_i != jump_flag_i)? `ysyx_23060072_enable : `ysyx_23060072_disable;
    assign  jump_pc_o       =   (!rst_n)? `ysyx_23060072_disable : clint_jump_flag_i? clint_jump_pc_i : jump_pc_i;

    // 暂停请求分别发生在 ex_stage 和 lsu_stage
    wire    hold_flag_ex;
    wire    hold_flag_LSU;    
    reg     forwardD_hold;

    assign  hold_flag_ex    =   (!rst_n)? `ysyx_23060072_disable : (clint_hold_flag_i | multdiv_hold_flag_i)? `ysyx_23060072_enable : `ysyx_23060072_disable;
    assign  hold_flag_LSU   =   (!rst_n)? `ysyx_23060072_disable : (LSU_hold_flag_i)? `ysyx_23060072_enable : `ysyx_23060072_disable;

    assign  if_hold_flag_o  =   id_hold_flag_o;
    assign  id_hold_flag_o  =   ex_hold_flag_o | forwardD_hold;
    //assign  ex_hold_flag_o  =   hold_flag_ex | hold_flag_LSU | forwardD_hold;
    assign  ex_hold_flag_o  =   hold_flag_ex | hold_flag_LSU;

    // load-use fsm
    localparam IDLE         = `ysyx_23060072_disable;
    localparam WAIT_LOAD    = 1'b1;

    reg current_state;
    reg next_state;

    always @(posedge clk) begin
        if (!rst_n)
            current_state <= IDLE;
        else
            current_state <= next_state;
    end

    always @(*) begin
        case (current_state)
            IDLE:       begin
                            if (forwardD_i) begin
                                next_state  = WAIT_LOAD;
                                forwardD_hold = `ysyx_23060072_disable;
                            end else begin
                                next_state = IDLE;
                                forwardD_hold = `ysyx_23060072_disable;
                            end
                        end

            WAIT_LOAD:  begin
                            if (!LSU_hold_flag_i) begin
                                next_state = IDLE;
                                forwardD_hold = `ysyx_23060072_enable;
                            end else begin
                                next_state = WAIT_LOAD;
                                forwardD_hold = `ysyx_23060072_disable;
                            end
                        end

            default:    begin
                            next_state = IDLE;
                            forwardD_hold = `ysyx_23060072_disable;
                        end

        endcase 
    end

endmodule