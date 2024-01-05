
//以上就是我们面临的五种冒险的分析，简单总结如下：
//a.在一个周期开始，EX 阶段要使用上一条处在 EX 阶段指令的执行结果，此时我们将 EX/MEM 寄存器的数据前递。
//b.在一个周期开始，EX 阶段要使用上一条处在 MEM 阶段指令的执行结果，此时我们将 MEM/WB 寄存器的数据前递。
//c.在一个周期开始，EX 阶段要使用上一条处在 WB 阶段指令的执行结果，此时不需要前递（寄存器堆前递机制）
//d.在第一种情况下，如果是上一条是访存指令，即发生加载—使用型冒险。则需要停顿一个周期。
//e.在发生加载——使用型冒险的时候，如果是load后跟着store指令，并且load指令的rd与store指令的rs1 不同而与rs2相同，则不需要停顿，只需要将MEM/WB 寄存器的数据前递到MEM阶段。

module ysyx_23060072_forward(
    input           id2ex_has_rs1,
    input           id2ex_has_rs2,
    input   [4:0]   id2ex_rs1_addr,
    input   [4:0]   id2ex_rs2_addr,
    input   [31:0]  id2ex_operand_a,
    input   [31:0]  id2ex_operand_b,

    input           ex2lsu_wb_flag,
    input           ex2lsu_store_flag,
    input   [4:0]   ex2lsu_wb_addr,
    input   [31:0]  ex2lsu_wb_data_ex,
    input   [31:0]  ex2lsu_operand_b,
    input   [4:0]   ex2lsu_rs1_addr,
    input   [4:0]   ex2lsu_rs2_addr,

    input           lsu2wb_wb_flag,
    input           lsu2wb_load_flag,
    input   [4:0]   lsu2wb_wb_addr,
    input   [31:0]  lsu2wb_wb_data_lsu,

    output reg  [31:0]  operand_a_ex_stage,
    output reg  [31:0]  operand_b_ex_stage,
    output reg  [31:0]  operand_b_lsu_stage
);
	
    wire    [1:0]   forwardA;
    wire    [1:0]   forwardB;
    wire            forwardC;

    /* rs1 ex 前递*/
	assign forwardA[1] = (ex2lsu_wb_flag && id2ex_has_rs1 && (ex2lsu_wb_addr!=5'd0) && (ex2lsu_wb_addr==id2ex_rs1_addr));
    /* rs1 lsu 前递*/
	assign forwardA[0] = (lsu2wb_wb_flag && id2ex_has_rs1 && (lsu2wb_wb_addr!=5'd0) && (lsu2wb_wb_addr==id2ex_rs1_addr));
	
    /* rs2 ex 前递*/
	assign forwardB[1] = (ex2lsu_wb_flag && id2ex_has_rs2 && (ex2lsu_wb_addr!=5'd0) && (ex2lsu_wb_addr==id2ex_rs2_addr));
    /* rs2 lsu 前递*/
	assign forwardB[0] = (lsu2wb_wb_flag && id2ex_has_rs2 && (lsu2wb_wb_addr!=5'd0) && (lsu2wb_wb_addr==id2ex_rs2_addr));

    // unnecessary
    // 在发生加载——使用型冒险的时候，如果是load后跟着store指令，
    // 并且load指令的rd与store指令的 rs1(write address) 不同而与 rs2(write data) 相同，则不需要停顿，
    // 只需要将MEM/WB 寄存器的数据前递到MEM阶段。
	assign forwardC = (lsu2wb_load_flag && ex2lsu_store_flag && (lsu2wb_wb_addr!=5'd0) && (lsu2wb_wb_addr!=ex2lsu_rs1_addr) && (lsu2wb_wb_addr==ex2lsu_rs2_addr));
	
	
	//load-use
	/*assign load_use_flag= 	MemRead_id2ex_o & RegWrite_id2ex_o & (Rd_id2ex_o!=5'd0)   //load
							&(!MemWrite_id2ex_i)     //非store
							& ((Rd_id2ex_o ==Rs1_id2ex_i) | (Rd_id2ex_o ==Rs2_id2ex_i))
							|
							MemRead_id2ex_o & RegWrite_id2ex_o & (Rd_id2ex_o!=5'd0)     //load
							&(MemWrite_id2ex_i)     //store
							& (Rd_id2ex_o ==Rs1_id2ex_i);*/


    // ex_stage					
    always@(*) begin
        if (forwardA[1]) begin
            operand_a_ex_stage    =   ex2lsu_wb_data_ex;
        end else if (forwardA[0]) begin
            operand_a_ex_stage    =   lsu2wb_wb_data_lsu;
        end else begin
            operand_a_ex_stage    =   id2ex_operand_a;
        end
    end   

    always@(*) begin
        if (forwardB[1]) begin
            operand_b_ex_stage    =   ex2lsu_wb_data_ex;
        end else if (forwardB[0]) begin
            operand_b_ex_stage    =   lsu2wb_wb_data_lsu;
        end else begin
            operand_b_ex_stage    =   id2ex_operand_b;
        end
    end   

    //assign operand_b_lsu_stage  =   ex2lsu_operand_b;

    // lsu_stage
    always@(*) begin
        if (forwardC) begin
            operand_b_lsu_stage   =   lsu2wb_wb_data_lsu;
        end else begin
            operand_b_lsu_stage   =   ex2lsu_operand_b;
        end
    end


endmodule




