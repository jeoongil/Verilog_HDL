`timescale 1ns / 1ps


module tb_LED();

reg sw0, sw1;
wire [3:0] led;

led dut (
    .sw0(sw0),
    .sw1(sw1),
    .led(led)
);


initial begin
    #0;
    sw0 = 0;
    sw1 = 0;

    #100
    sw0 = 0;
    sw1 = 0;

    #100
    sw0 = 1;
    sw1 = 0;

    #100
    sw0 = 0;
    sw1 = 1;

    #100
    sw0 = 1;
    sw1 = 1;


    #100000;
    $stop;
end


endmodule
