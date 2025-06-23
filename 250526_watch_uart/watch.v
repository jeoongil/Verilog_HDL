`timescale 1ns / 1ps

module watch (
    input clk,
    input rst,
    input btnU_up,
    input btnD_down,
    input sw2,
    input sw3,
    input sw4,

    output [6:0] msec,
    output [5:0] sec,
    output [5:0] min,
    output [4:0] hour
);
    wire w_sec_up, w_sec_down;
    wire w_min_up, w_min_down;
    wire w_hour_up, w_hour_down;

    watch_cu U_Watch_CU (
        .clk(clk),
        .rst(rst),
        .btnU_up(btnU_up),
        .btnD_down(btnD_down),
        .sw2(sw2),
        .sw3(sw3),
        .sw4(sw4),
        .tick_sec_up(w_sec_up),
        .tick_sec_down(w_sec_down),
        .tick_min_up(w_min_up),
        .tick_min_down(w_min_down),
        .tick_hour_up(w_hour_up),
        .tick_hour_down(w_hour_down)
    );

    watch_dp U_Watch_DP (
        .clk (clk),
        .rst (rst),
        .tick_sec_up(w_sec_up),
        .tick_sec_down(w_sec_down),
        .tick_min_up(w_min_up),
        .tick_min_down(w_min_down),
        .tick_hour_up(w_hour_up),
        .tick_hour_down(w_hour_down),
        .msec(msec),
        .sec (sec),
        .min (min),
        .hour(hour)
    );

endmodule




















