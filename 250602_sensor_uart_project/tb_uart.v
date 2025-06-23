`timescale 1ns / 1ps

module tb_uart();
    reg        clk;
    reg        rst;
    reg        push_tx;       // fifo_tx에 push할 트리거
    reg  [7:0] tx_din;        // 전송할 데이터
    reg        rx;            // PC로부터 수신

    wire       tx;            // TX 라인
    wire       tx_busy;       // UART TX 동작 중
    wire       tx_done;       // 전송 완료

    wire       pop_rx;        // fifo_rx에서 pop할 트리거
    wire [7:0] rx_data;       // 수신된 데이터
    wire       rx_valid;       // 데이터 유효 (fifo_rx not empty)

    UART_CTRL dut(
        .clk(),
        .rst(),
        .push_tx(),       // fifo_tx에 push할 트리거
        .tx_din(),        // 전송할 데이터
        .rx(),            // PC로부터 수신

        .tx(),            // TX 라인
        .tx_busy(),       // UART TX 동작 중
        .tx_done(),       // 전송 완료

        .pop_rx(),        // fifo_rx에서 pop할 트리거
        .rx_data(),       // 수신된 데이터
        .rx_valid()       // 데이터 유효 (fifo_rx not empty)
    );

    always #5 clk = ~clk;

    initial begin
        #0; clk = 0; rst = 1; rx = 1;
        #20 rst = 0;
        #2000000; rx = 0;  //start 
         #104160; rx = 0;  //d0
        #104160; rx = 1;
        #104160; rx = 0;
        #104160; rx = 0; // R
        #104160; rx = 1;
        #104160; rx = 0;
        #104160; rx = 1;
        #104160; rx = 0;  //d7
        #104160; rx = 1;  //stop
        #2000000; rx = 0;  //start 
        #104160; rx = 1;  //d0
        #104160; rx = 0;
        #104160; rx = 1;
        #104160; rx = 0;
        #104160; rx = 1; // U
        #104160; rx = 0;
        #104160; rx = 1;
        #104160; rx = 0;  //d7
        #104160; rx = 1;  //stop
        #2000000; rx = 0;  //start 
        #104160; rx = 0;  //d0
        #104160; rx = 1;
        #104160; rx = 1;
        #104160; rx = 1; // N
        #104160; rx = 0;
        #104160; rx = 0;
        #104160; rx = 1;
        #104160; rx = 0;  //d7
        #104160; rx = 1;  //stop
        #2000000;
        $stop;
    end
endmodule
