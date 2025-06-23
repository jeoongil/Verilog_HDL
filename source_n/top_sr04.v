`timescale 1ns / 1ps

module top_sr04 (
    input  clk,
    input  rst,
    input  start,
    input  echo,
    output trig,
    output [7:0] fnd_data,
    output [3:0] fnd_com

);

    wire [13:0] w_dist;

    sr04_controller U_SR04_CNTL (
        .clk(clk),
        .rst(rst),
        .start(start),
        .echo(echo),
        .trig(trig),
        .dist(w_dist),
        .dist_done(dist_done)
    );

    fnd_controller U_FND_CNTL (
        .clk(clk),
        .reset(rst),
        .count_data(w_dist),
        .fnd_data(fnd_data),
        .fnd_com(fnd_com)
    );

endmodule
