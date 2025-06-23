`timescale 1ns / 1ps

module fifo_uart (
    input clk,
    input rst,
    input btn_start,
    input rx,
    output tx
);
    wire w_tx_fifo_empty, w_tx_busy, w_tx_full; 
    wire w_rx_done, w_rx_empty;
    wire [7:0] w_tx_pop_data, w_rx_push_data, w_pupo_data;

    uart_controller U_UART_CNTL (
        .clk(clk),
        .rst(rst),
        .btn_start(btn_start|~w_tx_fifo_empty),
        .rx(rx),
        .tx_data(w_tx_pop_data),
        .tx_busy(w_tx_busy), 
        .rx_data(w_rx_push_data), 
        .rx_done(w_rx_done),
        .tx(tx)
    );

     fifo U_TX_FIFO (
        .clk(clk),
        .rst(rst),
        .push(~w_rx_empty),
        .pop(~w_tx_busy), 
        .push_data(w_pupo_data),
        .full(w_tx_full),
        .empty(w_tx_fifo_empty), 
        .pop_data(w_tx_pop_data) 
    );

    fifo U_RX_FIFO (
        .clk(clk),
        .rst(rst),
        .push(w_rx_done),
        .pop(~w_tx_full),
        .push_data(w_rx_push_data),
        .full(),
        .empty(w_rx_empty),
        .pop_data(w_pupo_data)
    );


endmodule
