`timescale 1ns / 1ps


module tb_uart_cntl ();

    reg clk, rst, start, rx;
    reg [7:0] tx_data, send_data, rx_send_data;
    wire tx, rx_done, tx_done, tx_busy;
    wire [7:0] rx_data;
    integer j=0;
    reg [7:0] rand_data;

    uart_controller U_UART (
        .clk(clk),
        .rst(rst),
        .btn_start(start),
        .rx(rx),
        .tx_din(),  // tx_data
        .tx_busy(tx_busy),
        .rx_data(rx_data),
        .rx_done(rx_done),
        .tx_done(tx_done),
        .tx(tx)
    );

    always #5 clk = ~clk;

    initial begin
        #0;
        clk = 0;
        rst = 1;
        start = 0;
        rx = 1;
        #20;
        rst = 0;

        #100;
        start = 1'b1;
        #10000;
        start = 1'b0;
        #2000000;

        rx = 0;  // start
        #(10416 * 10);
        rx = 1;  // do
        #(10416 * 10);

        rx = 0;
        #(10416 * 10);

        rx = 0;
        #(10416 * 10);
        rx = 0;
        #(10416 * 10);
        rx = 1;
        #(10416 * 10);
        rx = 1;
        #(10416 * 10);
        rx = 0;
        #(10416 * 10);
        rx = 0;  //d7
        #(10416 * 10);
        rx = 1;  // stop

        wait (tx_done); // wait signal (가볍게 랜덤하게 테스트 하고 싶을 때/ 보통 검증은 UVM)

        // 검증 test
        #10;
        rx_send_data = 8'h30;
        for ( j= 0; j<8; j=j+1) begin
            rand_data = $random % 255; //random 숫자의 모수 255 -> 255중 1
            rx_send_data = rand_data;
            send_data_to_rx(rx_send_data);
            wait_for_rx();
        end

        $stop;
    end

    integer i=0;
    // to
    task send_data_to_rx(input [7:0] send_data);
        begin
            // uart tx start condition
            rx = 0;
            #(10416 * 10);
            // rx data lsb transfer
            for (i = 0; i < 8; i = i + 1) begin // 0부터 증가 lsb, msb -> i-1
                rx = send_data[i];
                #(10416 * 3);
            end
            rx =1;
            #(10416 * 3);
            $display("send_data = %h", send_data);
        end
    endtask

    // rx : 수신 완료시 검사기
    task wait_for_rx();
        begin
            wait (rx_done); // tx_done
            if (rx_data == rand_data) begin
                // pass
                $display("PASS!!!, rx_data = %h", rx_data);
            end else begin
                // fail
                $display("FAIL~~~, rx_data = %h", rx_data);
            end

        end
    endtask


endmodule
