`define  ysyx_23060072_enable  1'b1
`define  ysyx_23060072_disable 1'b0
`define  ysyx_23060072_write_enable 1'b1
`define  ysyx_23060072_read_enable 1'b0

// opcode
`define  ysyx_23060072_OPCODE_LOAD        7'h03
`define  ysyx_23060072_OPCODE_MISC_MEM    7'h0f
`define  ysyx_23060072_OPCODE_OP_IMM      7'h13
`define  ysyx_23060072_OPCODE_AUIPC       7'h17
`define  ysyx_23060072_OPCODE_STORE       7'h23
`define  ysyx_23060072_OPCODE_OP          7'h33
`define  ysyx_23060072_OPCODE_LUI         7'h37
`define  ysyx_23060072_OPCODE_BRANCH      7'h63
`define  ysyx_23060072_OPCODE_JALR        7'h67
`define  ysyx_23060072_OPCODE_JAL         7'h6f
`define  ysyx_23060072_OPCODE_SYSTEM      7'h73

// aluop
// Arithmetics
`define  ysyx_23060072_ALU_ADD            5'h0           
`define  ysyx_23060072_ALU_SUB            5'h1
// Logics                       
`define  ysyx_23060072_ALU_XOR            5'h2
`define  ysyx_23060072_ALU_OR             5'h3
`define  ysyx_23060072_ALU_AND            5'h4
// Shifts   
`define  ysyx_23060072_ALU_SRA            5'h5
`define  ysyx_23060072_ALU_SRL            5'h6
`define  ysyx_23060072_ALU_SLL            5'h7
// Comparisons
`define  ysyx_23060072_ALU_LT             5'h8
`define  ysyx_23060072_ALU_LTU            5'h9
`define  ysyx_23060072_ALU_GE             5'ha
`define  ysyx_23060072_ALU_GEU            5'hb
`define  ysyx_23060072_ALU_EQ             5'hc
`define  ysyx_23060072_ALU_NE             5'hd
// Set lower than
`define  ysyx_23060072_ALU_SLT            5'he
`define  ysyx_23060072_ALU_SLTU           5'hf
// other
`define  ysyx_23060072_ALU_JALR           5'h10
`define  ysyx_23060072_ALU_JAL            5'h11
`define  ysyx_23060072_ALU_NOP            5'h12
`define  ysyx_23060072_ALU_FENCE_I        5'h13

// CSRs
// Machine information
`define  ysyx_23060072_CSR_MHARTID        12'hf14

// Machine trap setup
`define  ysyx_23060072_CSR_MSTATUS        12'h300
`define  ysyx_23060072_CSR_MISA           12'h301
`define  ysyx_23060072_CSR_MIE            12'h304
`define  ysyx_23060072_CSR_MTVEC          12'h305

// Machine trap handling
`define  ysyx_23060072_CSR_MSCRATCH       12'h340
`define  ysyx_23060072_CSR_MEPC           12'h341
`define  ysyx_23060072_CSR_MCAUSE         12'h342
`define  ysyx_23060072_CSR_MTVAL          12'h343
`define  ysyx_23060072_CSR_MIP            12'h344

`define  ysyx_23060072_CSR_CYCLE      12'hc00
`define  ysyx_23060072_CSR_CYCLEH     12'hc80

// csr opcode
`define  ysyx_23060072_CLINT_ECALL    3'h0    
`define  ysyx_23060072_CLINT_EBREAK   3'h1
`define  ysyx_23060072_CLINT_MRET     3'h2
`define  ysyx_23060072_CLINT_NONE     3'h3
`define  ysyx_23060072_CLINT_CSRRW    3'h4
`define  ysyx_23060072_CLINT_CSRRS    3'h5
`define  ysyx_23060072_CLINT_CSRRC    3'h6

// muldiv opcode
`define  ysyx_23060072_OP_MUL         4'h1
`define  ysyx_23060072_OP_MULH        4'h2
`define  ysyx_23060072_OP_MULHSU      4'h3
`define  ysyx_23060072_OP_MULHU       4'h4
`define  ysyx_23060072_OP_DIV         4'h5
`define  ysyx_23060072_OP_DIVU        4'h6
`define  ysyx_23060072_OP_REM         4'h7
`define  ysyx_23060072_OP_REMU        4'h8
`define  ysyx_23060072_OP_NONE        4'h9