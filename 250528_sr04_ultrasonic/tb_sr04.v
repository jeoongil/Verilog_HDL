`timescale 1ns / 1ps


module tb_sr04 ();

    reg clk, rst, start, echo;
    wire trig;
    wire [9:0] dist;

    sr04_controller dut (
        .clk(clk),
        .rst(rst),
        .start(start),
        .echo(echo),
        .trig(trig),
        .dist(dist),
        .dist_done()
    );

    always #5 clk = ~clk;

    initial begin
        #0;
        clk   = 0;
        rst   = 1;
        start = 0;
        echo  = 0;

        #20;
        rst = 0;

        #20;
        start = 1;
        #20;
        start = 0;
        
        #25000;
        echo = 1;
        #(1000 * 1000);
        echo = 0;
        #100;

        $stop;
    end

endmodule
