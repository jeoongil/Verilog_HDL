`timescale 1ns / 1ps

module uart_controller (
    input clk,
    input rst,
    input btn_start,
    input rx,
    output [7:0] rx_data,
    output rx_done,
    
    output tx_done,
    output tx
);

    wire w_bd_tick;
    wire w_start;
    wire w_tx_done, w_tx_busy;
    wire [7:0] w_dout;
    wire w_rx_done;

    assign rx_data = w_dout;
    assign rx_done = w_rx_done;
    assign tx_done = w_tx_done;
    

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
        .start({w_start | w_rx_done}),
        .din(w_dout),  // 8'h30
        .o_tx_done(w_tx_done),
        .o_tx_busy(w_tx_busy),
        .o_tx(tx)
    );

    uart_rx U_UART_RX (
        .clk(clk),
        .rst(rst),
        .b_tick(w_bd_tick),
        .rx(rx),
        .o_dout(w_dout),
        .o_rx_done(w_rx_done)
    );


    baudrate U_BR (
        .clk(clk),
        .rst(rst),
        .baud_tick(w_bd_tick)
    );

endmodule


