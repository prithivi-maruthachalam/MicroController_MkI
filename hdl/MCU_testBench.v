`timescale 1ns/1ns

module MCU_tb;
    reg clk;
    reg rst;


    MicroController MCU(
        .clk(clk),
        .rst(rst)
    );

    initial begin
        rst = 1;
        #100;
        rst = 0;
        #1200;
        $finish;
    end

    initial begin
        clk = 0;
        forever #10 clk = ~clk;
    end
endmodule