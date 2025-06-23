`timescale 1ns / 1ps


module tb_mem ();

    reg clk;
    reg wr;
    reg [7:0] addr, wdata;
    wire [7:0] rdata;

    ram dut (
        .clk(clk),
        .addr(addr),
        .wdata(wdata),
        .wr(wr),
        .rdata(rdata)
    );

    always #5 clk = ~clk;

    initial begin
        #0;
        clk = 0;
        wr = 0;
        addr = 0;
        wdata = 0;

        #10;
        wr = 1'b1;

        #10;
        addr  = 1;
        wdata = 8'h55;

        #10;
        addr  = 2;
        wdata = 8'h56;

        #20;
        wr   = 0;
        addr = 1;
        #10;
        addr = 2;
        #100;
        $stop;

    end

endmodule
