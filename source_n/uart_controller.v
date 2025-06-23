`timescale 1ns / 1ps

module uart_controller (
    input clk,
    input rst,
    input btn_start,
    input [7:0] tx_din,
    input rx,
    output [7:0] rx_data,
    output rx_done,
    output tx_done,
    output tx_busy,
    output tx
);

    wire w_bd_tick;
    wire w_start;
    wire w_tx_done, w_tx_busy;
    wire [7:0] w_rx_data, w_rx_pop_data ,w_tx_pop_data;
    wire w_rx_done, w_rx_empty, w_tx_full, w_tx_start;

    assign rx_data = w_rx_data;
    assign rx_done = w_rx_done;
    assign tx_done = w_tx_done;
    assign tx_busy = w_tx_busy;



    btn_debounce U_BTN_DB_START (
        .clk  (clk),
        .rst  (rst),
        .i_btn(btn_start),
        .o_btn(w_start)
    );

    uart_tx U_UART_TX (
        .clk(clk),
        .rst(rst),
        .baud_tick(w_bd_tick),
        .start(w_start | (~w_tx_start)), // 수정 필요
        .din(w_tx_pop_data),  // 8'h30
        .o_tx_done(w_tx_done),
        .o_tx_busy(w_tx_busy),
        .o_tx(tx)
    );

     fifo U_FIFO_TX (
        .clk(clk),
        .rst(rst),
        .push(~w_rx_empty),
        .pop(~w_tx_busy), 
        .push_data(w_rx_pop_data),
        .full(w_tx_full),
        .empty(w_tx_start),
        .pop_data(w_tx_pop_data)
    );

    fifo U_FIFO_RX (
        .clk(clk),
        .rst(rst),
        .push(w_rx_done),
        .pop(~w_tx_full), // from tx fifo
        .push_data(w_rx_data),
        .full(), // don't use
        .empty(w_rx_empty), // from tx fifo
        .pop_data(w_rx_pop_data)
    );

    uart_rx U_UART_RX (
        .clk(clk),
        .rst(rst),
        .b_tick(w_bd_tick),
        .rx(rx),
        .o_dout(w_rx_data),
        .o_rx_done(w_rx_done)
    );


    baudrate U_BR (
        .clk(clk),
        .rst(rst),
        .baud_tick(w_bd_tick)
    );

endmodule


