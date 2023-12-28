`include "ysyx_23060072_define.v"
`timescale 1 ns / 1 ps
module ysyx_23060072_decoder(
    // from id_ex_stage
    input    [31:0]                instr_rdata_i,
    input    [31:0]                pc_i,

    // from regfile
    input    [31:0]                rega_rdata_i,
    input    [31:0]                regb_rdata_i,

    /* from wb_stage
    input    [31:0]                wb_bypass_data_i,
    input    [4:0]                 wb_bypass_addr_i,
    input                          wb_bypass_we_i,
    */

    // to ex_stage
    output   [3:0]                 alu_op_o,
    output   [31:0]                operand_a_o,
    output   [31:0]                operand_b_o,
    output   [31:0]                operand_imm_o,

    // to regfile
    output   [4:0]                 rega_raddr_o,
    output   [4:0]                 regb_raddr_o,

    // to ex_stage
    output   [4:0]                 wb_reg_waddr_o,
    output                         wb_flag_o,
    // LSU
    output   [1:0]                 LSU_type_o,    // "00"-byte, "01"-half word, "10"-word
    output                         LSU_signed_o,   // "0"-signed, "1"-unsigned
    output                         store_flag_o,
    output                         load_flag_o,
    // clint
    output  [2:0]                  csr_opcode_o,
    output  [11:0]                 csr_addr_o,
    // multdiv
    output  [3:0]                  multdiv_opcode_o,
    output                         multdiv_en_o,

    // to forward
    output                         has_rs1,
    output                         has_rs2
);


    wire [31:0] imm_i_type;
    wire [31:0] imm_s_type;
    wire [31:0] imm_b_type;
    wire [31:0] imm_u_type;
    wire [31:0] imm_j_type;
    wire [2:0] funct3;
    wire [6:0] funct7;
    wire [6:0] opcode;

    assign  funct3  =   instr_rdata_i[14:12];
    assign  funct7  =   instr_rdata_i[31:25];
    assign  opcode  =   instr_rdata_i[6:0];

    assign  has_rs1 =       /* U-type */   
                            (opcode != 7'b0110111) 
                        &&  (opcode != 7'b0010111) 
                            /* J-type */
                        &&  (opcode != 7'b1101111);

    assign  has_rs2 =       /* U-type */   
                            (opcode != 7'b0110111) 
                        &&  (opcode != 7'b0010111) 
                            /* J-type */
                        &&  (opcode != 7'b1101111)
                            /* I-type */
                        &&  (opcode != 7'b0010011)
                        &&  (opcode != 7'b0000011)
                        &&  (opcode != 7'b1100111)  // jalr
                        &&  (opcode != 7'b1110011);
                        

    // csr opcode
    assign csr_addr_o = instr_rdata_i[31:20];

    reg [2:0]   csr_opcode_reg;
    assign  csr_opcode_o = csr_opcode_reg;

    always@(*) begin
        if(opcode == `ysyx_23060072_OPCODE_SYSTEM) begin
            case(funct3)
                3'b000: begin
                            case(instr_rdata_i[21:20])
                                2'b10: csr_opcode_reg = `ysyx_23060072_CLINT_MRET;
                                2'b01: csr_opcode_reg = `ysyx_23060072_CLINT_EBREAK;
                                2'b00: csr_opcode_reg = `ysyx_23060072_CLINT_ECALL;
                                default: csr_opcode_reg = `ysyx_23060072_CLINT_NONE;
                            endcase
                        end
                3'b101,
                3'b001: csr_opcode_reg = `ysyx_23060072_CLINT_CSRRW;
                3'b110,
                3'b010: csr_opcode_reg = `ysyx_23060072_CLINT_CSRRS;
                3'b111,
                3'b011: csr_opcode_reg = `ysyx_23060072_CLINT_CSRRC;
                default: csr_opcode_reg = `ysyx_23060072_CLINT_NONE;
            endcase
        end else begin
            csr_opcode_reg = `ysyx_23060072_CLINT_NONE;
        end
    end

    
    // multdiv opcode
    reg         multdiv_en_reg;
    reg [3:0]   multdiv_opcode_reg;

    assign      multdiv_en_o = multdiv_en_reg;
    assign      multdiv_opcode_o = multdiv_opcode_reg;

    always@(*) begin
        if((opcode == `ysyx_23060072_OPCODE_OP) &&(funct7 == 7'b0000001)) begin
            multdiv_en_reg = 1'b1;
            case(funct3)
                3'b000: multdiv_opcode_reg = `ysyx_23060072_OP_MUL;
                3'b001: multdiv_opcode_reg = `ysyx_23060072_OP_MULH;
                3'b010: multdiv_opcode_reg = `ysyx_23060072_OP_MULHSU;
                3'b011: multdiv_opcode_reg = `ysyx_23060072_OP_MULHU;
                3'b100: multdiv_opcode_reg = `ysyx_23060072_OP_DIV;
                3'b101: multdiv_opcode_reg = `ysyx_23060072_OP_DIVU;
                3'b110: multdiv_opcode_reg = `ysyx_23060072_OP_REM;
                3'b111: multdiv_opcode_reg = `ysyx_23060072_OP_REMU;
                default: multdiv_opcode_reg = `ysyx_23060072_OP_NONE;
            endcase
        end else begin
            multdiv_en_reg = 1'b0;
            multdiv_opcode_reg = `ysyx_23060072_OP_NONE;
        end
    end

    assign imm_i_type = { {20{instr_rdata_i[31]}}, instr_rdata_i[31:20] };
    assign imm_s_type = { {20{instr_rdata_i[31]}}, instr_rdata_i[31:25], instr_rdata_i[11:7] };
    assign imm_b_type = { {19{instr_rdata_i[31]}}, instr_rdata_i[31], instr_rdata_i[7], instr_rdata_i[30:25], instr_rdata_i[11:8], 1'b0 };
    assign imm_u_type = { instr_rdata_i[31:12], 12'b0 };
    assign imm_j_type = { {12{instr_rdata_i[31]}}, instr_rdata_i[19:12], instr_rdata_i[20], instr_rdata_i[30:21], 1'b0 };
    //rs1, rs2
    assign rega_raddr_o = instr_rdata_i[19:15];
    assign regb_raddr_o = instr_rdata_i[24:20];
    //rd, wb_flag
    assign wb_reg_waddr_o = instr_rdata_i[11:7];
    assign wb_flag_o = ( (opcode==`ysyx_23060072_OPCODE_LUI) | (opcode==`ysyx_23060072_OPCODE_AUIPC) | (opcode==`ysyx_23060072_OPCODE_JAL) | (opcode==`ysyx_23060072_OPCODE_JALR) | (opcode==`ysyx_23060072_OPCODE_LOAD) | (opcode==`ysyx_23060072_OPCODE_OP_IMM) | (opcode==`ysyx_23060072_OPCODE_OP) | ((opcode==`ysyx_23060072_OPCODE_SYSTEM)&&(funct3!=3'b000)) )? `ysyx_23060072_enable : `ysyx_23060072_disable;
    //LSU
    assign load_flag_o = (opcode==`ysyx_23060072_OPCODE_LOAD)? `ysyx_23060072_enable : `ysyx_23060072_disable;
    assign store_flag_o = (opcode==`ysyx_23060072_OPCODE_STORE)? `ysyx_23060072_enable : `ysyx_23060072_disable;
    assign LSU_type_o = funct3[1:0];
    assign LSU_signed_o = funct3[2];

    
    /*
    always@(*) begin
        if(rega_raddr_o == 5'b0)
            rega_rdata = 32'b0;
        else if((rega_raddr_o == wb_bypass_addr_i) && wb_bypass_we_i)
            rega_rdata = wb_bypass_data_i;
        else
            rega_rdata = rega_rdata_i;
    end

    always@(*) begin
        if(regb_raddr_o == 5'b0)
            regb_rdata = 32'b0;
        else if((regb_raddr_o == wb_bypass_addr_i) && wb_bypass_we_i)
            regb_rdata = wb_bypass_data_i;
        else
            regb_rdata = regb_rdata_i;
    end*/

    reg [31:0]  operand_a_reg;
    reg [31:0]  operand_b_reg;
    reg [31:0]  operand_imm_reg;
    reg [3:0]   alu_op_reg;

    assign  operand_a_o     =   operand_a_reg;
    assign  operand_b_o     =   operand_b_reg;
    assign  operand_imm_o   =   operand_imm_reg;
    assign  alu_op_o        =   alu_op_reg;   
    
    wire [31:0] rega_rdata  =   rega_rdata_i;
    wire [31:0] regb_rdata  =   regb_rdata_i;

    always@(*) begin
        case(opcode)
            `ysyx_23060072_OPCODE_LUI:     begin   
                                    operand_a_reg = imm_u_type;
                                    operand_b_reg = 32'b0;
                                    operand_imm_reg = 32'b0;
                                    alu_op_reg = `ysyx_23060072_ALU_ADD;
                            end

            `ysyx_23060072_OPCODE_AUIPC:   begin   
                                    operand_a_reg = imm_u_type;
                                    operand_b_reg = pc_i;
                                    operand_imm_reg = 32'b0;
                                    alu_op_reg = `ysyx_23060072_ALU_ADD;
                            end
            
            `ysyx_23060072_OPCODE_JAL:     begin   
                                    operand_a_reg = 32'd0;
                                    operand_b_reg = 32'd0;
                                    operand_imm_reg = imm_j_type;
                                    alu_op_reg = `ysyx_23060072_ALU_JAL;
                            end

            `ysyx_23060072_OPCODE_JALR:    begin   
                                    operand_a_reg = rega_rdata;
                                    operand_b_reg = 32'b0;
                                    operand_imm_reg = imm_i_type;
                                    alu_op_reg = `ysyx_23060072_ALU_JALR;
                            end

            `ysyx_23060072_OPCODE_BRANCH:  begin   
                                    operand_a_reg = rega_rdata;
                                    operand_b_reg = regb_rdata;
                                    operand_imm_reg = imm_b_type;
                                    case(funct3)
                                        3'b000: alu_op_reg = `ysyx_23060072_ALU_EQ;
                                        3'b001: alu_op_reg = `ysyx_23060072_ALU_NE;
                                        3'b100: alu_op_reg = `ysyx_23060072_ALU_LT;
                                        3'b101: alu_op_reg = `ysyx_23060072_ALU_GE;
                                        3'b110: alu_op_reg = `ysyx_23060072_ALU_LTU;
                                        3'b111: alu_op_reg = `ysyx_23060072_ALU_GEU;
                                        default: alu_op_reg = `ysyx_23060072_ALU_NOP;
                                    endcase
                            end

            `ysyx_23060072_OPCODE_LOAD:    begin   
                                    operand_a_reg = rega_rdata;
                                    operand_b_reg = imm_i_type;
                                    operand_imm_reg = 32'b0;
                                    alu_op_reg = `ysyx_23060072_ALU_NOP;
                            end

            `ysyx_23060072_OPCODE_STORE:   begin   
                                    operand_a_reg = rega_rdata;
                                    operand_b_reg = imm_s_type;
                                    operand_imm_reg = regb_rdata;   // regb of store to operand_imm !!!
                                    alu_op_reg = `ysyx_23060072_ALU_NOP;
                            end

            `ysyx_23060072_OPCODE_OP_IMM:  begin   
                                    operand_a_reg = rega_rdata;
                                    operand_b_reg = imm_i_type;
                                    operand_imm_reg = 32'b0;
                                    case(funct3)
                                        3'b000: alu_op_reg = `ysyx_23060072_ALU_ADD;
                                        3'b010: alu_op_reg = `ysyx_23060072_ALU_SLT;
                                        3'b011: alu_op_reg = `ysyx_23060072_ALU_SLTU;
                                        3'b100: alu_op_reg = `ysyx_23060072_ALU_XOR;
                                        3'b110: alu_op_reg = `ysyx_23060072_ALU_OR;
                                        3'b111: alu_op_reg = `ysyx_23060072_ALU_AND;
                                        3'b001: alu_op_reg = `ysyx_23060072_ALU_SLL;
                                        3'b101: begin   
                                                    if(funct7[5]) alu_op_reg = `ysyx_23060072_ALU_SRA;
                                                    else alu_op_reg = `ysyx_23060072_ALU_SRL;
                                                end
                                        default: alu_op_reg = `ysyx_23060072_ALU_NOP;
                                    endcase
                            end

            `ysyx_23060072_OPCODE_OP:      begin   
                                    operand_a_reg = rega_rdata;
                                    operand_b_reg = regb_rdata;
                                    operand_imm_reg = 32'b0;
                                    case(funct3)
                                        3'b000: begin   
                                                    if(funct7[5]) alu_op_reg = `ysyx_23060072_ALU_SUB;
                                                    else alu_op_reg = `ysyx_23060072_ALU_ADD;
                                                end
                                        3'b001: alu_op_reg = `ysyx_23060072_ALU_SLL;
                                        3'b010: alu_op_reg = `ysyx_23060072_ALU_SLT;
                                        3'b011: alu_op_reg = `ysyx_23060072_ALU_SLTU;
                                        3'b100: alu_op_reg = `ysyx_23060072_ALU_XOR;
                                        3'b101: begin   
                                                    if(funct7[5]) alu_op_reg = `ysyx_23060072_ALU_SRA;
                                                    else alu_op_reg = `ysyx_23060072_ALU_SRL;
                                                end
                                        3'b110: alu_op_reg = `ysyx_23060072_ALU_OR;
                                        3'b111: alu_op_reg = `ysyx_23060072_ALU_AND;
                                        default: alu_op_reg = `ysyx_23060072_ALU_NOP;
                                    endcase
                            end

            `ysyx_23060072_OPCODE_SYSTEM:  begin
                                    operand_imm_reg = 32'b0;
                                    case(funct3)
                                        3'b001: begin   // CSRRW
                                                    operand_a_reg = rega_rdata;
                                                    operand_b_reg = 32'b0;
                                                    alu_op_reg = `ysyx_23060072_ALU_NOP;
                                                end
                                        3'b010: begin   // CSRRS
                                                    operand_a_reg = rega_rdata;
                                                    operand_b_reg = 32'b0;
                                                    alu_op_reg = `ysyx_23060072_ALU_NOP;
                                                end
                                        3'b011: begin   // CSRRC
                                                    operand_a_reg = ~rega_rdata;
                                                    operand_b_reg = 32'b0;
                                                    alu_op_reg = `ysyx_23060072_ALU_NOP;
                                                end
                                        3'b101: begin   // CSRRWI
                                                    operand_a_reg = { 27'b0, instr_rdata_i[19:15] };
                                                    operand_b_reg = 32'b0;
                                                    alu_op_reg = `ysyx_23060072_ALU_NOP;
                                                end
                                        3'b110: begin   // CSRRSI
                                                    operand_a_reg = { 27'b0, instr_rdata_i[19:15] };
                                                    operand_b_reg = 32'b0;
                                                    alu_op_reg = `ysyx_23060072_ALU_NOP;
                                                end
                                        3'b111: begin   // CSRRCI
                                                    operand_a_reg = ~{ 27'b0, instr_rdata_i[19:15] };
                                                    operand_b_reg = 32'b0;
                                                    alu_op_reg = `ysyx_23060072_ALU_NOP;
                                                end
                                        default:begin
                                                    operand_a_reg = 32'b0;
                                                    operand_b_reg = 32'b0;
                                                    alu_op_reg = `ysyx_23060072_ALU_NOP;
                                                end
                                    endcase
                            end

            `ysyx_23060072_OPCODE_MISC_MEM:begin
                                    operand_imm_reg = 32'b0;
                                    operand_a_reg = 32'b0;
                                    operand_b_reg = 32'b0;
                                    case(funct3)
                                        3'b000: alu_op_reg = `ysyx_23060072_ALU_NOP; //FENCE
                                        3'b001: alu_op_reg = `ysyx_23060072_ALU_FENCE_I; //FENCE_I
                                        default: alu_op_reg = `ysyx_23060072_ALU_NOP;
                                    endcase
                            end

            default:        begin   
                                    operand_a_reg = 32'b0;
                                    operand_b_reg = 32'b0;
                                    operand_imm_reg = 32'b0;
                                    alu_op_reg = `ysyx_23060072_ALU_NOP;
                            end
        endcase
    end

endmodule
