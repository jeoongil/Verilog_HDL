`timescale 1ns / 1ps

module top (
    input clk,
    input rst,
    input sw0,
    input sw1,
    input sw2,
    input sw3,
    input sw4,
    input btnL_clear,
    input btnR_runstop,
    input btnU_up,
    input btnD_down,
    output [3:0] led,
    output [7:0] fnd_data,
    output [3:0] fnd_com

);
    wire [6:0] w_msec;
    wire [5:0] w_sec;
    wire [5:0] w_min;
    wire [4:0] w_hour;

    wire [6:0] s_msec;
    wire [5:0] s_sec;
    wire [5:0] s_min;
    wire [4:0] s_hour;

    wire [6:0] w_msec_s;
    wire [5:0] w_sec_s;
    wire [5:0] w_min_s;
    wire [4:0] w_hour_s;

    wire o_up, o_down, o_runstop, o_clear;

    led U_LED_CNTL (
        .sw0(sw0),
        .sw1(sw1),
        .led(led)
    );


    btn_debounce U_BTNR_UP (
        .clk  (clk),
        .rst  (rst),
        .i_btn(btnU_up),
        .o_btn(o_up)
    );

    btn_debounce U_BTNL_DOWN (
        .clk  (clk),
        .rst  (rst),
        .i_btn(btnD_down),
        .o_btn(o_down)
    );

    btn_debounce U_BTNR_RUNSTOP (
        .clk  (clk),
        .rst  (rst),
        .i_btn(btnR_runstop),
        .o_btn(o_runstop)
    );

    btn_debounce U_BTNL_CLEAR (
        .clk  (clk),
        .rst  (rst),
        .i_btn(btnL_clear),
        .o_btn(o_clear)
    );

    watch U_Watch (
        .clk(clk),
        .rst(rst),
        .btnU_up(o_up),
        .btnD_down(o_down),
        .sw2(sw2),
        .sw3(sw3),
        .sw4(sw4),
        .msec(w_msec),
        .sec(w_sec),
        .min(w_min),
        .hour(w_hour)
    );

    stopwatch U_StopWatch (
        .clk(clk),
        .rst(rst),
        .sw0(sw0),
        .btnL_clear(o_clear),
        .btnR_runstop(o_runstop),
        .msec(s_msec),
        .sec(s_sec),
        .min(s_min),
        .hour(s_hour)
    );

    assign w_msec_s = (sw1) ? w_msec : s_msec;
    assign w_sec_s  = (sw1) ? w_sec : s_sec;
    assign w_min_s  = (sw1) ? w_min : s_min;
    assign w_hour_s = (sw1) ? w_hour : s_hour;

    fnd_controller U_FND_CNTL (
        .clk(clk),
        .rst(rst),
        .sw0(sw0),
        .msec(w_msec_s),
        .sec(w_sec_s),
        .min(w_min_s),
        .hour(w_hour_s),
        .fnd_data(fnd_data),
        .fnd_com(fnd_com)
    );


endmodule
