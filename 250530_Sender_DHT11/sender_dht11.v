`timescale 1ns / 1ps

module sender_dht11(
    input clk,
    input rst,
    input start,
    input rx,
    output tx,
    output [8:0] led,
    output [7:0] fnd_data,
    output [3:0] fnd_com,
    inout dht11_io
    );

    wire [7:0] w_rh_data, w_t_data;


    top_dht11 U_DHT11 (
    .clk(clk),
    .rst(rst),
    .start(start),

    .led(led),
    .fnd_data(fnd_data),
    .fnd_com(fnd_com),

    .dht11_io(dht11_io),

    .rh_data(w_rh_data),
    .t_data(w_t_data)

);


    sender_uart U_SENDER_UART (

    .clk(clk),
    .rst(rst),
    .rx(rx),
    .btn_start(start),

    .i_rh_data(w_rh_data),
    .i_t_data(w_t_data),
    .tx(tx),
    .tx_done()
);
endmodule
