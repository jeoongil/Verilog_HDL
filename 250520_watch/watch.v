`timescale 1ns / 1ps


module watch (
    input clk,
    input rst,
    input sw0,
    input sw1,
    input sw2,
    input sw3,
    input sw4,
    input btnU_up,
    input btnD_down,
    output [3:0] fnd_com,
    output [7:0] fnd_data
);

    wire [6:0] w_msec;
    wire [5:0] w_sec;
    wire [5:0] w_min;
    wire [4:0] w_hour;
    wire o_up, o_down;
     
    wire w_sec_up;
    wire w_sec_down;
    wire w_min_up;
    wire w_min_down;
    wire w_hour_up;
    wire w_hour_down;

    btn_debounce U_BTNU_UP (
        .clk  (clk),
        .rst  (rst),
        .i_btn(btnU_up),
        .o_btn(o_up)
    );

    btn_debounce U_BTND_DOWN (
        .clk  (clk),
        .rst  (rst),
        .i_btn(btnD_down),
        .o_btn(o_down)
    );

    watch_cu U_Watch_CU (
        .clk(clk),
        .rst(rst),
        .btnU_up(o_up),
        .btnD_down(o_down),
        .sw1(sw1),
        .sw2(sw2),
        .sw3(sw3),
        .sw4(sw4),
        .tick_sec_u(w_sec_up),
        .tick_sec_d(w_sec_down),
        .tick_min_u(w_min_up),
        .tick_min_d(w_min_down),
        .tick_hour_u(w_hour_up),
        .tick_hour_d(w_hour_down)
    );

    watch_dp U_Watch_DP (
        .clk(clk),
        .rst(rst),
        .tick_sec_up(w_sec_up),
        .tick_sec_down(w_sec_down),
        .tick_min_up(w_min_up),
        .tick_min_down(w_min_down),
        .tick_hour_up(w_hour_up),
        .tick_hour_down(w_hour_down),
        .msec(w_msec),
        .sec (w_sec),
        .min (w_min),
        .hour(w_hour)
    );

    fnd_controller U_FND_CNTL (
        .clk(clk),
        .rst(rst),
        .sw0(sw0),
        .msec(w_msec),
        .sec(w_sec),
        .min(w_min),
        .hour(w_hour),
        .fnd_data(fnd_data),
        .fnd_com(fnd_com)
    );
endmodule
