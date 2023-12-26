`include "ysyx_23060072_define.v"
/*
module ysyx_23060072_LSU_dpic(
    input              clk,
    input              rst_n,

    // from decoder
    input    [1:0]     LSU_type_i,    // "00"-byte, "01"-half word, "10"-word
    input              store_flag_i,
    input              load_flag_i,
    input              LSU_signed_i,
    input    [31:0]    operand_a_i,
    input    [31:0]    operand_b_i,
    input    [31:0]    operand_imm_i,

    // to controller
    output             LSU_hold_flag_o,

    // to id_stage
    output   [31:0]    wb_wdata_o,

    // to wb
    output             LSU_wb_flag_o
);

    import "DPI-C" function void vaddr_read(input int mem_addr, input byte rlen, output int rdata);
    import "DPI-C" function void vaddr_write(input int mem_addr, input int wdata, input byte wmask);


    wire [31:0] mem_addr;
    wire        ren;

    reg         wen;
    reg  [7:0]  wmask;
    reg  [7:0]  rlen;
    reg  [31:0] rdata;
    reg  [31:0] wb_wdata;
    reg  [31:0] wb_wdata_reg;
    reg         LSU_wb_flag_reg;
    reg         LSU_hold_flag_reg;

    assign  ren             =   load_flag_i;
    assign  mem_addr        =   operand_a_i + operand_b_i;
    assign  data_offset     =   mem_addr[1:0];
    assign  wb_wdata_o      =   wb_wdata_reg;
    assign  LSU_wb_flag_o   =   LSU_wb_flag_reg;
    assign  LSU_hold_flag_o =   LSU_hold_flag_reg;  

*/
    // **************************************** load ****************************************//
    /*
    always@(*) begin
        case(LSU_type_i)
            2'b00:      rlen = 8'd1; 
            2'b01:      rlen = 8'd2; 
            2'b10:      rlen = 8'd4; 
            default:    rlen = 8'd0;
        endcase
    end

    always @(*) begin
        if (ren)
            vaddr_read(mem_addr, rlen, rdata);
        else
            rdata   =   32'd0;
    end
     
    // generate wb_wdata
    // LSU_signed_i: 0-signed, 1-unsigned
    always@(*) begin
        case(LSU_type_i)
            2'b00:  begin
                        if (!LSU_signed_i)
                            wb_wdata = {{24{rdata[7]}}, rdata[7:0]};
                        else
                            wb_wdata = {{24{1'b0}}, rdata[7:0]};
                    end
            2'b01:  begin
                        if (!LSU_signed_i)
                            wb_wdata = {{16{rdata[15]}}, rdata[15:0]};
                        else
                            wb_wdata = {{16{1'b0}}, rdata[15:0]};
                    end
            2'b10:  wb_wdata = rdata;
            default:wb_wdata = 32'b0;
        endcase
    end
*/

    // **************************************** store ****************************************// 
    /*
    always@(*) begin
        case(LSU_type_i)
            2'b00:      wmask = 8'b00000001; 
            2'b01:      wmask = 8'b00000011; 
            2'b10:      wmask = 8'b00001111; 
            default:    wmask = 8'b00000000;
        endcase
    end

    always@(*) begin
        if (wen)
            vaddr_write(mem_addr, operand_imm_i, wmask);
    end
    */

    // **************************************** fsm ****************************************// 
    // 不论读写，只让他延迟一拍即可完成操作，对于读操作，只需将输出数据延迟一拍再输出即可，
    // 对于写操作，需要让写使能延迟一拍再使能有效
/*
    localparam  IDLE    =   3'b000;
    localparam  LOAD    =   3'b001;
    localparam  STORE   =   3'b010;     

    reg [2:0] s_current_state, s_next_state;

    always @(posedge clk) begin
        if(!rst_n)
            s_current_state <=  IDLE;
        else
            s_current_state <=  s_next_state;
    end

    always@(*) begin
        case(s_current_state)
            IDLE:   begin
                        if (load_flag_i) begin
                            s_next_state        =   LOAD;
                            LSU_hold_flag_reg   =   1'b1;
                        end else if (store_flag_i) begin
                            s_next_state        =   STORE;
                            LSU_hold_flag_reg   =   1'b1;
                        end else begin
                            s_next_state        =   IDLE;
                            LSU_hold_flag_reg   =   1'b0;
                        end
                    end
            LOAD:   begin
                        s_next_state        =   IDLE;
                        LSU_hold_flag_reg   =   1'b0;
                    end
            STORE:  begin
                        s_next_state        =   IDLE;
                        LSU_hold_flag_reg   =   1'b0;
                    end
            default:begin
                        s_next_state        =   IDLE;
                        LSU_hold_flag_reg   =   1'b0;
                    end
        endcase 
    end 

    always@(posedge clk) begin
            if(!rst_n) begin
                wen             <=  1'b0;
                wb_wdata_reg    <=  32'd0;
                LSU_wb_flag_reg <=  1'b0;
            end else begin
                case(s_next_state)
                    IDLE:   begin
                                wen             <=  1'b0;
                                wb_wdata_reg    <=  32'd0;
                                LSU_wb_flag_reg <=  1'b0;
                            end
                    LOAD:   begin
                                wen             <=  1'b0;
                                wb_wdata_reg    <=  wb_wdata;
                                LSU_wb_flag_reg <=  1'b1;
                            end
                    STORE:  begin
                                wen             <=  1'b1;
                                wb_wdata_reg    <=  32'd0;
                                LSU_wb_flag_reg <=  1'b0;
                            end
                    default:begin
                                wen             <=  1'b0;
                                wb_wdata_reg    <=  32'd0;
                                LSU_wb_flag_reg <=  1'b0;
                            end
                endcase
            end
        end


endmodule
*/



module ysyx_23060072_LSU(
    input              clk,
    input              rst_n,

    // from decoder
    input    [1:0]     LSU_type_i,    // "00"-byte, "01"-half word, "10"-word
    input              store_flag_i,
    input              load_flag_i,
    input              LSU_signed_i,
    input    [31:0]    operand_a_i,
    input    [31:0]    operand_b_i,
    input    [31:0]    operand_imm_i,

    // to controller
    output             LSU_hold_flag_o,

    // to id_stage
    output   [31:0]    wb_wdata_o,

    // to wb
    output             LSU_wb_flag_o
);

    wire [31:0] mem_addr;
    wire        ren;

    reg         wen;
    reg  [7:0]  wmask;
    reg  [31:0] rdata;
    reg  [31:0] wb_wdata;
    reg  [31:0] mem_wdata;
    reg  [31:0] wb_wdata_reg;
    reg         LSU_wb_flag_reg;
    reg         LSU_hold_flag_reg;

    assign  ren             =   load_flag_i;
    assign  mem_addr        =   operand_a_i + operand_b_i;
    assign  data_offset     =   mem_addr[1:0];
    assign  wb_wdata_o      =   wb_wdata_reg;
    assign  LSU_wb_flag_o   =   LSU_wb_flag_reg;
    assign  LSU_hold_flag_o =   LSU_hold_flag_reg;  

    reg [31:0] mem [1023:0];

    // **************************************** load ****************************************// 
    always @(*) begin
        if (ren)
            rdata   =   mem[mem_addr[9:0]];
        else
            rdata   =   32'd0;
    end
     
    // generate wb_wdata
    // LSU_signed_i: 0-signed, 1-unsigned
    always@(*) begin
        case(LSU_type_i)
            2'b00:  begin
                        case(data_offset)
                            2'b00:  if(!LSU_signed_i) wb_wdata = { {24{rdata[7]}}, rdata[7:0] };
                                    else wb_wdata = { 24'b0, rdata[7:0] };
                            2'b01:  if(!LSU_signed_i) wb_wdata = { {24{rdata[15]}}, rdata[15:8] };
                                    else wb_wdata = { 24'b0, rdata[15:8] };
                            2'b10:  if(!LSU_signed_i) wb_wdata = { {24{rdata[23]}}, rdata[23:16] };
                                    else wb_wdata = { 24'b0, rdata[23:16] };
                            2'b11:  if(!LSU_signed_i) wb_wdata = { {24{rdata[31]}}, rdata[31:24] };
                                    else wb_wdata = { 24'b0, rdata[31:24] };
                            default:wb_wdata = 32'b0;
                        endcase
                    end
            2'b01:  begin
                        case(data_offset)
                            2'b00:  if(!LSU_signed_i) wb_wdata = { {16{rdata[15]}}, rdata[15:0] };
                                    else wb_wdata = { 16'b0, rdata[15:0] };
                            2'b01:  if(!LSU_signed_i) wb_wdata = { {16{rdata[23]}}, rdata[23:8] };
                                    else wb_wdata = { 16'b0, rdata[23:8] };
                            2'b10:  if(!LSU_signed_i) wb_wdata = { {16{rdata[31]}}, rdata[31:16] };
                                    else wb_wdata = { 16'b0, rdata[31:16] };
                            default:wb_wdata = 32'b0;
                        endcase
                    end
            2'b10:  wb_wdata = rdata;
            default:wb_wdata = 32'b0;
        endcase
    end



    // **************************************** store ****************************************// 
    always@(posedge clk) begin
        if (wen)
            mem[mem_addr[9:0]]  <=  mem_wdata;
    end

    always@(*) begin
        case(LSU_type_i)
            2'b00:  begin
                        case(data_offset)
                            2'b00: mem_wdata = { rdata[31:8], operand_imm_i[7:0] };
                            2'b01: mem_wdata = { rdata[31:16], operand_imm_i[7:0], rdata[7:0] };
                            2'b10: mem_wdata = { rdata[31:24], operand_imm_i[7:0], rdata[15:0] };
                            2'b11: mem_wdata = { operand_imm_i[7:0], rdata[23:0] };
                            default: mem_wdata = 32'b0;
                        endcase
                    end
            2'b01:  begin
                        case(data_offset)
                            2'b00: mem_wdata = { rdata[31:16], operand_imm_i[15:0] };
                            2'b01: mem_wdata = { rdata[31:24], operand_imm_i[15:0], rdata[7:0] };
                            2'b10: mem_wdata = { operand_imm_i[15:0], rdata[15:0] };
                            default: mem_wdata = 32'b0;
                        endcase
                    end
            2'b10:  mem_wdata = operand_imm_i;
            default: mem_wdata = 32'b0;
        endcase
    end


    // **************************************** fsm ****************************************// 
    // 不论读写，只让他延迟一拍即可完成操作，对于读操作，只需将输出数据延迟一拍再输出即可，
    // 对于写操作，需要让写使能延迟一拍再使能有效
    localparam  IDLE    =   3'b000;
    localparam  LOAD    =   3'b001;
    localparam  STORE   =   3'b010;     

    reg [2:0] s_current_state, s_next_state;

    always @(posedge clk) begin
        if(!rst_n)
            s_current_state <=  IDLE;
        else
            s_current_state <=  s_next_state;
    end

    always@(*) begin
        case(s_current_state)
            IDLE:   begin
                        if (load_flag_i) begin
                            s_next_state        =   LOAD;
                            LSU_hold_flag_reg   =   1'b1;
                        end else if (store_flag_i) begin
                            s_next_state        =   STORE;
                            LSU_hold_flag_reg   =   1'b1;
                        end else begin
                            s_next_state        =   IDLE;
                            LSU_hold_flag_reg   =   1'b0;
                        end
                    end
            LOAD:   begin
                        s_next_state        =   IDLE;
                        LSU_hold_flag_reg   =   1'b0;
                    end
            STORE:  begin
                        s_next_state        =   IDLE;
                        LSU_hold_flag_reg   =   1'b0;
                    end
            default:begin
                        s_next_state        =   IDLE;
                        LSU_hold_flag_reg   =   1'b0;
                    end
        endcase 
    end 

    always@(posedge clk) begin
            if(!rst_n) begin
                wen             <=  1'b0;
                wb_wdata_reg    <=  32'd0;
                LSU_wb_flag_reg <=  1'b0;
            end else begin
                case(s_next_state)
                    IDLE:   begin
                                wen             <=  1'b0;
                                wb_wdata_reg    <=  32'd0;
                                LSU_wb_flag_reg <=  1'b0;
                            end
                    LOAD:   begin
                                wen             <=  1'b0;
                                wb_wdata_reg    <=  wb_wdata;
                                LSU_wb_flag_reg <=  1'b1;
                            end
                    STORE:  begin
                                wen             <=  1'b1;
                                wb_wdata_reg    <=  32'd0;
                                LSU_wb_flag_reg <=  1'b0;
                            end
                    default:begin
                                wen             <=  1'b0;
                                wb_wdata_reg    <=  32'd0;
                                LSU_wb_flag_reg <=  1'b0;
                            end
                endcase
            end
        end


endmodule