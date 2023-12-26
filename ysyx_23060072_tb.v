`timescale 1ns/1ps

module ysyx_23060072_tb;
    reg clk;
    reg rst_n;

    initial begin
        clk = 0;
        rst_n = 0;
        #100;
        rst_n = 1;
        #5000;
        $finish;
    end

    always #20 clk = ~clk;

    ysyx_23060072_core  u_core(
        .clk        (clk    ),
        .rst_n      (rst_n  )
    );

endmodule