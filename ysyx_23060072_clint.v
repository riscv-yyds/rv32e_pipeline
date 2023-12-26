`include "ysyx_23060072_define.v"
`timescale 1 ns / 1 ps
module ysyx_23060072_clint(
    input                          clk,
    input                          rst_n,

    // from if_stage
    input    [31:0]                pc_i,
    input                          timer_interrupt_i,

    // from decoder
    input    [2:0]                 csr_opcode_i,   // csr指令类型
    input    [11:0]                csr_addr_i,     // csr的寄存器地址（确定是哪个寄存器）
    input    [31:0]                operand_a_i,
    input    [31:0]                operand_b_i,

    // to wb_stage
    output   [31:0]                csr_wb_wdata_o,
    output                         csr_wb_flag_o,

    // to controller
    output                         clint_hold_flag_o,
    output   [31:0]                clint_jump_pc_o,
    output                         clint_jump_flag_o
);


/////////////////////////`ysyx_23060072_CSR register file///////////////////////////
/////////////////////////////////////////////////////////////////////
    wire [31:0] MHARTID;   // read only
    wire [31:0] MISA;      // read only
    
    reg  [63:0] CYCLE;
    reg  [31:0] MSTATUS;
    reg  [31:0] MIE;
    reg  [31:0] MTVEC;
    reg  [31:0] MSCRATCH;
    reg  [31:0] MEPC;
    reg  [31:0] MCAUSE;
    reg  [31:0] MTVAL;
    reg  [31:0] MIP;

    wire [31:0] MISA_VALUE =
      (0                 <<  0)  // A - Atomic Instructions extension
    | (0                 <<  2)  // C - Compressed extension
    | (0                 <<  3)  // D - Double precision floating-point extension
    | (0                 <<  4)  // E - RV32E base ISA
    | (0                 <<  5)  // F - Single precision floating-point extension
    | (1                 <<  8)  // I - RV32I/64I/128I base ISA
    | (0                 << 12)  // M - Integer Multiply/Divide extension
    | (0                 << 13)  // N - User level interrupts supported
    | (0                 << 18)  // S - Supervisor mode implemented
    | (0                 << 20)  // U - User mode implemented
    | (0                 << 23)  // X - Non-standard extensions present
    | (0                 << 30); // M-XLEN

    wire [31:0] MHARTID_VALUE = 32'b0;
    assign MHARTID = MHARTID_VALUE;
    assign MISA = MISA_VALUE;

    // cycle counter
    // 复位撤销后就�?直计�?
    always@(posedge clk) begin
        if (!rst_n) begin
            CYCLE <=  64'b0;
        end else begin
            CYCLE <=  CYCLE + 1'b1;
        end
    end

    reg [31:0] csr_rdata_reg;
    assign csr_wb_wdata_o = csr_rdata_reg;
    always@(*) begin
        // 根据输入的寄存器地址决定csr的读数据来自哪个csr寄存器
        case(csr_addr_i)
            `ysyx_23060072_CSR_MHARTID:    csr_rdata_reg = MHARTID;
            `ysyx_23060072_CSR_MSTATUS:    csr_rdata_reg = MSTATUS;
            `ysyx_23060072_CSR_MISA:       csr_rdata_reg = MISA;
            `ysyx_23060072_CSR_MIE:        csr_rdata_reg = MIE;
            `ysyx_23060072_CSR_MTVEC:      csr_rdata_reg = MTVEC;
            `ysyx_23060072_CSR_MSCRATCH:   csr_rdata_reg = MSCRATCH;
            `ysyx_23060072_CSR_MEPC:       csr_rdata_reg = MEPC;
            `ysyx_23060072_CSR_MCAUSE:     csr_rdata_reg = MCAUSE;
            `ysyx_23060072_CSR_MTVAL:      csr_rdata_reg = MTVAL;
            `ysyx_23060072_CSR_MIP:        csr_rdata_reg = MIP;
            `ysyx_23060072_CSR_CYCLE:      csr_rdata_reg = CYCLE[31:0];
            `ysyx_23060072_CSR_CYCLEH:     csr_rdata_reg = CYCLE[63:32];
            default:        csr_rdata_reg = 32'b0;
        endcase
    end

    reg [31:0]  csr_wdata;
    reg [31:0]  csr_waddr;
    // 在下面的三段式状态机中控制
    reg         csr_we;
    reg  [11:0] csr_addr;
    // `ysyx_23060072_CSR write (sequential wire)
    always@(posedge clk) begin
        if(!rst_n) begin
            MSTATUS <=  32'b0;
            MIE <=  32'b0;
            MTVEC <=  32'b0;
            MSCRATCH <=  32'b0;
            MEPC <=  32'b0;
            MCAUSE <=  32'b0;
            MTVAL <=  32'b0;
            MIP <=  32'b0;
        end else if(csr_we) begin
            case(csr_addr)
                `ysyx_23060072_CSR_MSTATUS:    MSTATUS <=  csr_wdata;
                `ysyx_23060072_CSR_MIE:        MIE <=  csr_wdata;
                `ysyx_23060072_CSR_MTVEC:      MTVEC <=  csr_wdata;
                `ysyx_23060072_CSR_MSCRATCH:   MSCRATCH <=  csr_wdata;
                `ysyx_23060072_CSR_MEPC:       MEPC <=  csr_wdata;
                `ysyx_23060072_CSR_MCAUSE:     MCAUSE <=  csr_wdata;
                `ysyx_23060072_CSR_MTVAL:      MTVAL <=  csr_wdata;
                `ysyx_23060072_CSR_MIP:        MIP <=  csr_wdata;
                default: ;
            endcase
        end
    end

    //typedef enum wire [2:0]  { IDLE, WRITE_OUTPUT_WAIT, UP_MCAUSE, UP_MEPC, UP_MTVAL/*没有见到*/, UP_MSTATUS, EXC_JUMP } clint_fsm_e;
    localparam IDLE                 = 3'b000;
    localparam WRITE_OUTPUT_WAIT    = 3'b001;
    localparam UP_MCAUSE            = 3'b010;
    localparam UP_MEPC              = 3'b011;
    localparam UP_MTVAL             = 3'b100;
    localparam UP_MSTATUS           = 3'b101;
    localparam EXC_JUMP             = 3'b110;

    reg [2:0] clint_current_state, clint_next_state;

    // 只有当前状态为idle的时候才不需要暂停CPU的工作
    assign clint_hold_flag_o = (clint_next_state != IDLE)? `ysyx_23060072_enable : `ysyx_23060072_disable;

    // 3-stage-fsm
    always@(posedge clk)begin
        if(!rst_n)
            clint_current_state <=  IDLE;
        else
            clint_current_state <=  clint_next_state;
    end

    always@(*) begin
        if(!rst_n)
            clint_next_state =  IDLE;
        else
        case(clint_current_state)
            IDLE:   begin
                        if(timer_interrupt_i && MSTATUS[3])
                            clint_next_state = UP_MCAUSE;
                        else
                            case(csr_opcode_i)
                                `ysyx_23060072_CLINT_ECALL:     clint_next_state = UP_MCAUSE;
                                `ysyx_23060072_CLINT_EBREAK:    clint_next_state = UP_MCAUSE;
                                `ysyx_23060072_CLINT_MRET:      clint_next_state = UP_MSTATUS;
                                `ysyx_23060072_CLINT_CSRRW,
                                `ysyx_23060072_CLINT_CSRRS,
                                `ysyx_23060072_CLINT_CSRRC: clint_next_state = WRITE_OUTPUT_WAIT;
                                `ysyx_23060072_CLINT_NONE: clint_next_state = IDLE;
                                default: clint_next_state = IDLE;
                            endcase
                    end
            WRITE_OUTPUT_WAIT: clint_next_state = IDLE;
            UP_MCAUSE: clint_next_state = UP_MEPC;
            UP_MEPC: clint_next_state = UP_MSTATUS;
            UP_MSTATUS: clint_next_state = EXC_JUMP;
            EXC_JUMP: clint_next_state = WRITE_OUTPUT_WAIT;
            default: clint_next_state = IDLE;
        endcase
    end


    reg         clint_jump_flag_reg;
    reg         csr_wb_flag_reg;
    reg [31:0]  clint_jump_pc_reg;

    assign  clint_jump_flag_o   =   clint_jump_flag_reg;
    assign  clint_jump_pc_o     =   clint_jump_pc_reg;
    assign  csr_wb_flag_o       =   csr_wb_flag_reg;


    always@(posedge clk) begin
        if(!rst_n) begin
            csr_addr <=  `ysyx_23060072_CSR_MHARTID;
            csr_wdata <=  32'b0;
            csr_we <=  `ysyx_23060072_disable;
            clint_jump_flag_reg <=  `ysyx_23060072_disable;
            clint_jump_pc_reg <=  32'b0;
            csr_wb_flag_reg <=  1'b0;
        end else begin
            case(clint_next_state)
                IDLE:       begin
                                clint_jump_flag_reg <=  `ysyx_23060072_disable;
                                clint_jump_pc_reg <=  32'b0;
                                csr_wdata <=  32'b0;
                                csr_addr <=  `ysyx_23060072_CSR_MHARTID;
                                csr_we <=  `ysyx_23060072_disable;
                                csr_wb_flag_reg <=  1'b0;
                            end
                WRITE_OUTPUT_WAIT:  begin
                                        clint_jump_flag_reg <=  `ysyx_23060072_disable;
                                        clint_jump_pc_reg <=  32'b0;
                                        case(csr_opcode_i)
                                            `ysyx_23060072_CLINT_CSRRW: begin
                                                            csr_addr <=  csr_addr_i;
                                                            csr_wdata <=  operand_a_i;    // 往rd写入rs1
                                                            csr_we <=  `ysyx_23060072_enable;
                                                            csr_wb_flag_reg <=  1'b1;
                                                        end
                                            `ysyx_23060072_CLINT_CSRRS: begin
                                                            csr_addr <=  csr_addr_i;
                                                            csr_wdata <=  csr_rdata_reg | operand_a_i;
                                                            csr_we <=  `ysyx_23060072_enable;
                                                            csr_wb_flag_reg <=  1'b1;
                                                        end
                                            `ysyx_23060072_CLINT_CSRRC: begin
                                                            csr_addr <=  csr_addr_i;
                                                            csr_wdata <=  csr_rdata_reg & operand_a_i;
                                                            csr_we <=  `ysyx_23060072_enable;
                                                            csr_wb_flag_reg <=  1'b1;
                                                        end
                                            `ysyx_23060072_CLINT_MRET,
                                            `ysyx_23060072_CLINT_ECALL,
                                            `ysyx_23060072_CLINT_EBREAK,
                                            `ysyx_23060072_CLINT_NONE: begin
                                                        csr_addr <=  `ysyx_23060072_CSR_MHARTID;   // ecall和mret在此不作任何操作
                                                        csr_wdata <=  32'b0;
                                                        csr_we <=  `ysyx_23060072_disable;
                                                        csr_wb_flag_reg <=  1'b0;
                                                        end
                                            default: begin
                                                        csr_addr <=  `ysyx_23060072_CSR_MHARTID;
                                                        csr_wdata <=  32'b0;
                                                        csr_we <=  `ysyx_23060072_disable;
                                                        csr_wb_flag_reg <=  1'b0;
                                                    end
                                        endcase
                                    end
                UP_MCAUSE:  begin
                                clint_jump_flag_reg <=  `ysyx_23060072_disable;
                                clint_jump_pc_reg <=  32'b0;
                                csr_wb_flag_reg <=  1'b0;
                                if(timer_interrupt_i && MSTATUS[3]) begin
                                    csr_addr <=  `ysyx_23060072_CSR_MCAUSE;
                                    csr_wdata <=  32'h80000004;
                                    csr_we <=  `ysyx_23060072_enable;
                                end else begin
                                    case(csr_opcode_i)
                                        `ysyx_23060072_CLINT_ECALL:    begin
                                                            csr_addr <=  `ysyx_23060072_CSR_MCAUSE;  // mcause = 0xb
                                                            csr_wdata <=  32'd11;
                                                            csr_we <=  `ysyx_23060072_enable;
                                                        end
                                        `ysyx_23060072_CLINT_EBREAK:   begin
                                                            csr_addr <=  `ysyx_23060072_CSR_MCAUSE;
                                                            csr_wdata <=  32'd3;
                                                            csr_we <=  `ysyx_23060072_enable;
                                                        end
                                        default:        begin
                                                            csr_addr <=  `ysyx_23060072_CSR_MHARTID;
                                                            csr_wdata <=  32'b0;
                                                            csr_we <=  `ysyx_23060072_disable;
                                                        end
                                    endcase
                                end
                            end
                UP_MEPC:    begin
                                clint_jump_flag_reg <=  `ysyx_23060072_disable;
                                clint_jump_pc_reg <=  32'b0;
                                csr_wb_flag_reg <=  1'b0;
                                if(timer_interrupt_i && MSTATUS[3]) begin
                                    csr_addr <=  `ysyx_23060072_CSR_MEPC;
                                    csr_wdata <=  pc_i;
                                    //csr_wdata <=  pc_i + 32'd4;
                                    csr_we <=  `ysyx_23060072_enable;
                                end else begin
                                    case(csr_opcode_i)
                                        `ysyx_23060072_CLINT_EBREAK,
                                        `ysyx_23060072_CLINT_ECALL:    begin
                                                            csr_addr <=  `ysyx_23060072_CSR_MEPC;  // mepc = pc_now
                                                            csr_wdata <=  pc_i;
                                                            csr_we <=  `ysyx_23060072_enable;
                                                        end
                                        default:        begin
                                                            csr_addr <=  `ysyx_23060072_CSR_MHARTID;
                                                            csr_wdata <=  32'b0;
                                                            csr_we <=  `ysyx_23060072_disable;
                                                        end
                                    endcase
                                end
                            end
                UP_MSTATUS: begin
                                clint_jump_flag_reg <=  `ysyx_23060072_disable;
                                clint_jump_pc_reg <=  32'b0;
                                csr_wb_flag_reg <=  1'b0;
                                if(csr_opcode_i == `ysyx_23060072_CLINT_MRET) begin
                                    csr_addr <=  `ysyx_23060072_CSR_MSTATUS;
                                    csr_wdata <=  { MSTATUS[31:4], MSTATUS[7], MSTATUS[2:0] };
                                    csr_we <=  `ysyx_23060072_enable;
                                end else begin
                                    csr_addr <=  `ysyx_23060072_CSR_MSTATUS;   // ysyx中的ecall未定义行为
                                    csr_wdata <=  { MSTATUS[31:4], 1'b0, MSTATUS[2:0] };
                                    csr_we <=  `ysyx_23060072_enable;
                                end
                            end
                EXC_JUMP:   begin
                                csr_addr <=  `ysyx_23060072_CSR_MHARTID;
                                csr_wdata <=  32'b0;
                                csr_we <=  `ysyx_23060072_disable;
                                clint_jump_flag_reg <=  `ysyx_23060072_enable;
                                csr_wb_flag_reg <=  1'b0;
                                if(csr_opcode_i == `ysyx_23060072_CLINT_MRET)
                                    clint_jump_pc_reg <=  MEPC;
                                else
                                    clint_jump_pc_reg <=  MTVEC;  // ecall跳转
                            end
            endcase
        end
    end




endmodule