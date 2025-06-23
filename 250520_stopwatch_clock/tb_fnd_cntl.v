`timescale 1ns / 1ps


module tb_fnd_cntl ();

    reg clk, rst, sw0;
    reg  [6:0] msec;
    reg  [5:0] sec;
    reg  [5:0] min;
    reg  [4:0] hour;
    wire [7:0] fnd_data;
    wire [3:0] fnd_com;


    fnd_controller dut (
        .clk(clk),
        .rst(rst),
        .sw0(sw0),
        .msec(msec),
        .sec(sec),
        .min(min),
        .hour(hour),
        .fnd_data(fnd_data),
        .fnd_com(fnd_com)
    );

    always #5 clk = ~clk;

    initial begin
        // 초기 상태
        clk  = 0;
        rst  = 1;
        sw0  = 0;  // 시작은 msec/sec 모드

        // 입력값 설정
        msec = 7'd12;  // digit_10 = 1, digit_1 = 2
        sec  = 6'd34;  // digit_10 = 3, digit_1 = 4
        min  = 6'd56;  // digit_10 = 5, digit_1 = 6
        hour = 5'd9;  // digit_1  = 9 (digit_10 = 0)

        // 리셋 해제
        #100;
        rst = 0;

        // 1ms 동안 sw0=0 → msec/sec 모드 확인
        #1_000_000;

        // 1ms 동안 sw0=1 → min/hour 모드 확인
        sw0 = 1;
        #1_000_000;

        $stop;
    end





endmodule
