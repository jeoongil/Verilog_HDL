`timescale 1ns / 1ps

module tb_mystopwatch ();

    reg clk, rst, sw0, btnL_clear, btnR_runstop;
    wire [3:0] fnd_com;
    wire [7:0] fnd_data;

    stopwatch dut(
        .clk(clk),
        .rst(rst),
        .sw0(sw0),
        .btnL_clear(btnL_clear),
        .btnR_runstop(btnR_runstop),
        .fnd_com(fnd_com),
        .fnd_data(fnd_data)
    );

    always #5 clk = ~clk;

    initial begin
        // 초기화
        clk = 0;
        rst = 1;
        sw0 = 0;
        btnR_runstop = 0;
        btnL_clear = 0;

        #100;
        rst = 0;

        // stopwatch 시작
        #100;
        btnR_runstop = 1;
        #1000000;
        btnR_runstop = 0;

        #100000;
        $stop;
    end
endmodule


