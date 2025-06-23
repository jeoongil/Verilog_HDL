`timescale 1ns / 1ps

module top_dht11 (
    input clk,
    input rst,
    input start,
    output [8:0] led,
    output [7:0] fnd_data,
    output [3:0] fnd_com,
    output [7:0] rh_data,
    output [7:0] t_data,
    inout dht11_io

);
    wire w_start;
    wire [7:0] w_rh_data, w_t_data;

    assign rh_data = w_rh_data;
    assign t_data  = w_t_data;

    btn_debounce_sw U_BTN_DEBOUNCE (
        .clk  (clk),
        .rst  (rst),
        .i_btn(start),
        .o_btn(w_start)
    );


    dht11_controller U_DHT11_CNTL (
        .clk(clk),
        .rst(rst),
        .start(w_start),
        .rh_data(w_rh_data),
        .t_data(w_t_data),
        .dht11_done(),
        .dnt11_vaild(),
        .state_led(led),
        .dht11_io(dht11_io)
    );

    fnd_controller U_FND_CNTL (
        .clk(clk),
        .reset(rst),
        .rh_data(w_rh_data),
        .t_data(w_t_data),
        .fnd_data(fnd_data),
        .fnd_com(fnd_com)
    );

endmodule
