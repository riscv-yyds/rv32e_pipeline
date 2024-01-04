`timescale 1ns/1ps

module ysyx_23060072_tb;
    reg clk;
    reg rst_n;

    initial begin
        clk = 1'b0;
        rst_n = 1'b0;
        #100
        rst_n = 1'b1;
        #5000
        $finish;
    end

    always #20 clk = ~clk;

    ysyx_23060072_core  u_core(
        .clk        (clk    ),
        .rst_n      (rst_n  )
    );

    /*initial begin
        //$readmemh("./rom_hex.txt", rom);
        //$readmemb("./rom_binary.txt", u_core.if_stage.ifu.rom);
        $readmemb("C:/Users/Administrator/Desktop/MAI/file/rv32e_pipeline/rom_binary.txt", u_core.if_stage.ifu.rom);
    end*/

    initial  begin
        $fsdbDumpfile("rv32e_pipeline.fsdb");
        $fsdbDumpvars(0);
        $fsdbDumpMDA;
    end

endmodule