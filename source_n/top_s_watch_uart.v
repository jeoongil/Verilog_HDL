`timescale 1ns / 1ps

module top_s_watch_uart (
    input clk,
    input rst,
    input sw0,
    input sw1,
    input sw2,
    input sw3,
    input sw4,
    input rx,
    input btnU_up,
    input btnD_down,
    input btnR_runstop,
    input btnL_clear,

    output [3:0] led,
    output [3:0] fnd_com,
    output [7:0] fnd_data,
    output tx

);
    wire [7:0] w_rx_data;
    wire w_rx_done;
    wire w_tx_done;

    wire w_s_sw0; // 시간 모드
    wire w_s_sw1; // 시계,스톱워치
    wire w_s_sw2; // 초
    wire w_s_sw3; // 분
    wire w_s_sw4; // 시간

    wire w_btnC_rst;
    wire w_btnL_l;
    wire w_btnR_r;
    wire w_btnU_u;
    wire w_btnD_d;

    uart_controller U_UART_CNTL (
        .clk(clk),
        .rst(rst),
        .btn_start(btnU_up),
        .rx(rx),
        .rx_data(w_rx_data),
        .rx_done(w_rx_done),
        .tx_done(w_tx_done), //
        .tx(tx)
    );

    uart_cu U_UART_CU (
        .clk(clk),
        .rst(rst),
        .rx_data(w_rx_data),
        .rx_done(w_rx_done),

        .s_sw0(w_s_sw0),
        .s_sw1(w_s_sw1),
        .s_sw2(w_s_sw2),
        .s_sw3(w_s_sw3),
        .s_sw4(w_s_sw4),

        .s_btnC_rst(w_btnC_rst),
        .s_btnL_clear(w_btnL_l),
        .s_btnR_runstop(w_btnR_r),
        .s_btnU_up(w_btnU_u),
        .s_btnD_down(w_btnD_d)

    );

   
      top U_Stopwatch (
        .clk(clk),
        .rst(rst | w_btnC_rst),
        .sw0(sw0 | w_s_sw0),
        .sw1(sw1 | w_s_sw1),
        .sw2(sw2 | w_s_sw2),
        .sw3(sw3 | w_s_sw3),
        .sw4(sw4 | w_s_sw4),
        .btnL_clear(btnL_clear),
        .btnR_runstop(btnR_runstop),
        .btnU_up(btnU_up),
        .btnD_down(btnD_down),
        .u_rst(w_btnC_rst),
        .u_runstop(w_btnR_r),
        .u_clear(w_btnL_l),
        .u_up(w_btnU_u),
        .u_down(w_btnD_d),
        .led(led),
        .fnd_data(fnd_data),
        .fnd_com(fnd_com)
    );

endmodule
