`timescale 1ns / 1ps

module tb_baudrate();
    reg clk;
    reg rst;
    wire baud_tick;

    // DUT
    baudrate #(
        .BAUD(9600)
    ) uut (
        .clk(clk),
        .rst(rst),
        .baud_tick(baud_tick)
    );

    // 100MHz clock generation (10ns period)
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    // Stimulus
    initial begin
        rst = 1;
        #100;
        rst = 0;

        // Let it run for about 1.2ms to observe baud_tick
        #1200000;
        $finish;
    end

endmodule




/*
module tb_baudrate();

    reg clk;
    reg rst;
    wire baud_tick;

    baudrate #(
        .BAUD(9600)
    ) uut (
        .clk(clk),
        .rst(rst),
        .baud_tick(baud_tick)
    );

    
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    
    initial begin
        rst = 1;
        #100;
        rst = 0;

        #1200000;  // 1.2ms
        $finish;
    end
endmodule
*/
