`timescale 1ns / 1ps

module stopwatch (
    input clk,
    input rst,
    input sw0,
    input btnL_clear,
    input btnR_runstop,
    
    output [6:0] msec,
    output [5:0] sec,
    output [5:0] min,
    output [4:0] hour
);
   
    wire w_clear, w_runstop;


    stopwatch_cu U_StopWatch_CU (
        .clk(clk),
        .rst(rst),
        .i_clear(btnL_clear),
        .i_runstop(btnR_runstop),
        .o_clear(w_clear),
        .o_runstop(w_runstop)
    );

    stopwatch_dp U_StopWatch_DP (
        .clk(clk),
        .rst(rst),
        .run_stop(w_runstop),
        .clear(w_clear),
        .msec(msec),
        .sec(sec),
        .min(min),
        .hour(hour)
    );

endmodule





























