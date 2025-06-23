`timescale 1ns / 1ps

module tb_uart ();

    reg clk, rst, start;
    wire baud_tick, tx;

    baudrate dut0 (
        .clk(clk),
        .rst(rst),
        .baud_tick(baud_tick)
    );

    uart_tx dut1 (
        .clk(clk),
        .rst(rst),
        .baud_tick(baud_tick),
        .start(start),
        .din(8'h30),
        .o_tx_done(w_tx_done),
        .o_tx_busy(w_tx_busy),
        .o_tx(tx)
    );

    always #5 clk = ~clk;  // 100M 만들거니까 5n    

    initial begin
        #0;
        clk   = 0;
        rst   = 1'b1;
        start = 1'b0;
        #20;
        rst = 1'b0;  // 20n 후
        #20;
        start = 1'b1;
        #10;
        start = 1'b0;

        #1000000;
//         #10000000;
        $stop;
    end
endmodule
