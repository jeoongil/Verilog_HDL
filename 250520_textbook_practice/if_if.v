`timescale 1ns / 1ps


module if_if(
    input selA,
    input selB,
    input selC,
    input selD,
    input [3:0] dinA,
    input [3:0] dinB,
    input [3:0] dinC,
    input [3:0] dinD,
    input [3:0] dinE,
    output [3:0] dout
    );

    reg [3:0] dout;

    always @(*) begin
        dout = dinE;
        if (selA) dout = dinA;
        if (selB) dout = dinB;
        if (selC) dout = dinC;
        if (selD) dout = dinD;
    end
endmodule
