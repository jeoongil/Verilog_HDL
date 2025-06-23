`timescale 1ns / 1ps

module tb_uart_task();

uart_controller U_UART_ (
    .clk(),
    .rst(),
    .btn_start(),
    .tx_din(),
    .rx(),

    .rx_data(),
    .rx_done(),
    .tx_done(),
    .tx()
);


endmodule
