`timescale 1ns / 1ps

module testbench();

    reg        clk;
    reg        reset;
    reg        rx;
    reg        btnU;
    reg        btnL_RunStop;
    reg        btnR_Clear;
    reg        btnD;
    reg        sw0;
    reg        sw1;
    reg        sw2;
    reg        sw3;
    reg        sw4;
    wire       tx;
    wire [3:0] LED;
    wire [7:0] fnd_data;
    wire [3:0] fnd_com;

    top_s_watch_uart U_PROJECT_TOP(
        .clk(clk),
        .rst(reset),
        .rx(rx),
        .btnU_up(btnU),
        .btnL_clear(btnL_RunStop),
        .btnR_runstop(btnR_Clear),
        .btnD_down(btnD),
        .sw0(sw0),
        .sw1(sw1),
        .sw2(sw2),
        .sw3(sw3),
        .sw4(sw4),
        .tx(tx),
        .led(led),
        .fnd_data(fnd_data),
        .fnd_com(fnd_com)
    );

    always #5 clk = ~clk;

    initial begin
        #0; clk = 0; reset = 1; btnU = 0; btnL_RunStop = 0; btnR_Clear = 0; btnD = 0; sw0 = 0; sw1 = 0; sw2 = 0;
        sw3 = 0; sw4 = 0; rx = 1;
        #20; reset = 0; 
        #10; rx = 0;//start
        #104160; rx = 1;
        #104160; rx = 0;
        #104160; rx = 1;
        #104160; rx = 1;
        #104160; rx = 0;
        #104160; rx = 0;
        #104160; rx = 1;
        #104160; rx = 0;// M => MODE 변경 
        #104160; rx = 1;// STOP
         #100000000; rx = 0;//start
        // WATCH 모드
        #104160; rx = 1;
        #104160; rx = 1;
        #104160; rx = 0;
        #104160; rx = 0;
        #104160; rx = 1;
        #104160; rx = 1;
        #104160; rx = 0;
        #104160; rx = 0;// 3 => 초 제어 모드 
        #104160; rx = 1;// STOP
        #100000000; rx = 0;//start
        #104160; rx = 1;
        #104160; rx = 0;
        #104160; rx = 1;
        #104160; rx = 0;
        #104160; rx = 1;
        #104160; rx = 0;
        #104160; rx = 1;
        #104160; rx = 0;// U => UP 
        #104160; rx = 1;// STOP
        #100000000; rx = 0;//start
        // STOP WATCH 모드
        #104160; rx = 1;
        #104160; rx = 1;
        #104160; rx = 1;
        #104160; rx = 0;
        #104160; rx = 0;
        #104160; rx = 0;
        #104160; rx = 1;
        #104160; rx = 0;// G => START
        #104160; rx = 1;// STOP
        #100000000; rx = 0;//start
        #104160; rx = 1;
        #104160; rx = 1;
        #104160; rx = 1;
        #104160; rx = 0;
        #104160; rx = 0;
        #104160; rx = 0;
        #104160; rx = 1;
        #104160; rx = 0;// G
        #104160; rx = 1;// STOP
        #100000000; rx = 0;//start
        #104160; rx = 1;
        #104160; rx = 0;
        #104160; rx = 1;
        #104160; rx = 1;
        #104160; rx = 0;
        #104160; rx = 0;
        #104160; rx = 1;
        #104160; rx = 0;// M => MODE 변경 
        #104160; rx = 1;// STOP
        #100000000; rx = 0;//start
        // WATCH 모드
        #104160; rx = 1;
        #104160; rx = 1;
        #104160; rx = 0;
        #104160; rx = 0;
        #104160; rx = 1;
        #104160; rx = 1;
        #104160; rx = 0;
        #104160; rx = 0;// 3 => 초 제어 모드 
        #104160; rx = 1;// STOP
        #100000000; rx = 0;//start
        #104160; rx = 1;
        #104160; rx = 0;
        #104160; rx = 1;
        #104160; rx = 0;
        #104160; rx = 1;
        #104160; rx = 0;
        #104160; rx = 1;
        #104160; rx = 0;// U => UP 
        #104160; rx = 1;// STOP
        #100000000; rx = 0;//start
        #104160; rx = 1;
        #104160; rx = 0;
        #104160; rx = 1;
        #104160; rx = 0;
        #104160; rx = 1;
        #104160; rx = 0;
        #104160; rx = 1;
        #104160; rx = 0;// U => UP 
        #104160; rx = 1;// STOP
        #100000000; rx = 0;//start
        #104160; rx = 0;
        #104160; rx = 0;
        #104160; rx = 1;
        #104160; rx = 0;
        #104160; rx = 0;
        #104160; rx = 0;
        #104160; rx = 1;
        #104160; rx = 0;// D => UP 
        #104160; rx = 1;// STOP
        #1000000000;
        $stop;
    end
endmodule
