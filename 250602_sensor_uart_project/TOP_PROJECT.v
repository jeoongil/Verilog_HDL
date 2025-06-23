`timescale 1ns / 1ps

module TOP_PROJECT(
    input        clk,
    input        reset,
    input        rx, // UART 입력으로
    input        echo,
    input        btnU,
    input        btnL,
    input        btnR,
    input        btnD,
    input  [6:0] sw,
    output       trig,
    output       tx, // UART 출력으로
    output [3:0] LED,
    output [3:0] state_led_dht11,
    output       LED_dht11,
    output [7:0] fnd_data,
    output [3:0] fnd_com,
    output       o_cuckoo,   // LED15
    output       S_W,        // 현재 무슨 모드인지 확인하기 위해 선언 켜지면 센서모드, 꺼지면 시계모드드
    inout        dht11_io
);
    wire [7:0] fnd_data_c, fnd_data_u, fnd_data_t;
    wire [3:0] fnd_com_c, fnd_com_u, fnd_com_t;
    wire w_btnU, w_btnD, w_btnL, w_btnR;
    wire tx_u, tx_t, tx_c; 
    wire w_reset_c;
    wire w_rs_c;         // run/stop
    wire w_clear_c;
    wire w_sr_start_c;
    wire w_dht_start_c;
    wire w_up_c;
    wire w_down_c;
    wire w_sensor_clock_c;

    assign S_W = w_sensor_clock_c; 

    // 네가지 버튼 모드 debounce 처리하는 모듈 인스턴스
    btn_debounce U_BTN_DB (
        .clk(clk),
        .rst(reset),
        .i_btnU(btnU),
        .i_btnD(btnD),
        .i_btnL(btnL),
        .i_btnR(btnR),
        .o_btnU(w_btnU),
        .o_btnD(w_btnD),
        .o_btnL(w_btnL),
        .o_btnR(w_btnR)
    );

    fnd_unit U_FND (
        .fnd_data_c(fnd_data_c), 
        .fnd_data_u(fnd_data_u), 
        .fnd_data_t(fnd_data_t),
        .fnd_com_c(fnd_com_c),
        .fnd_com_u(fnd_com_u),
        .fnd_com_t(fnd_com_t),
        .sw5(sw[5]),
        .w_sensor_clock_c(w_sensor_clock_c),
        .tx_u(tx_u),
        .tx_t(tx_t),
        .fnd_data(fnd_data), 
        .fnd_com(fnd_com),
        .tx(tx)
    );

    CU U_CTRL_UNIT (
        .clk(clk),
        .rst(reset),
        .rx(rx),
        .btnU(w_btnU),
        .btnL(w_btnL),
        .btnR(w_btnR),
        .btnD(w_btnD),
        .sw(sw),
        .reset_c(w_reset_c),
        .rs_c(w_rs_c),         // run/stop
        .clear_c(w_clear_c),
        .sr_start_c(w_sr_start_c),
        .dht_start_c(w_dht_start_c),
        .up_c(w_up_c),
        .down_c(w_down_c),
        .sensor_clock_c(w_sensor_clock_c) // sw[6]와 or되어 있음
    );

    TOP_CLOCK U_CLOCK(
        .clk(clk),
        .reset(w_reset_c),
        .btnU(w_up_c),
        .btnL_RunStop(w_rs_c),
        .btnR_Clear(w_clear_c),
        .btnD(w_down_c),
        .sw0(sw[0]),
        .sw1(sw[1]),
        .sw2(sw[2]),
        .sw3(sw[3]),
        .sw4(sw[4]),
        .LED(LED),
        .fnd_data(fnd_data_c), // 출력
        .fnd_com(fnd_com_c),   // 츌력력
        .o_cuckoo(o_cuckoo)
    );

    TOP_SR04 U_SR04(
        .clk(clk),
        .rst(w_reset_c),
        .btn_start(w_sr_start_c),//uart신호와 연결해야함.
        .echo(echo),
        .trig(trig),
        .tx(tx_u),
        .fnd_data(fnd_data_u),
        .fnd_com(fnd_com_u)
    );

    TOP_DHT11 U_DHT11 (
        .clk(clk),
        .reset(w_reset_c),
        .btnU(w_dht_start_c),
        .tx(tx_t),
        .fnd_data(fnd_data_t),
        .fnd_com(fnd_com_t),
        .state_led_dht11(state_led_dht11),
        .LED_dht11(LED_dht11),
        .dht11_io(dht11_io)
    );
endmodule
