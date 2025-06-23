`timescale 1ns / 1ps

module stopwatch (
    input clk,
    input rst,
    input sw0,
    input btnL_clear,
    input btnR_runstop,
    output [3:0] fnd_com,
    output [7:0] fnd_data

);
    wire [6:0] w_low_digit;
    wire [5:0] w_high_digit;
    wire w_clear, w_runstop, w_option;

    stopwatch_cu U_StopWatch_CU(
    .clk(clk),
    .rst(rst),
    .sw0(sw0),
    .i_clear(btnL_clear),
    .i_runstop(btnR_runstop),
    .o_option(w_option),
    .o_clear(w_clear),
    .o_runstop(w_runstop)
    );

    stopwatch_dp U_StopWatch_DP (
    .clk(clk),
    .rst(rst),
    .run_stop(w_runstop),
    .clear(w_clear),
    .option(w_option),
    .low_digit(w_low_digit),
    .high_digit(w_high_digit)
);

    fnd_controller U_FND_CNTL (
        .clk(clk),
        .rst(rst),
        .msec(w_low_digit),
        .sec(w_high_digit),
        .fnd_data(fnd_data),
        .fnd_com(fnd_com)
    );

endmodule
