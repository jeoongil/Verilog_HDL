`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/05/08 15:09:06
// Design Name: 
// Module Name: adder
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////



module FA_4(
    input a0,
    input a1,
    input a2,
    input a3,
    input b0,
    input b1,
    input b2,
    input b3,
    input cin,
    output s0,
    output s1,
    output s2,
    output s3,
    output cout
);

//4bit full adder

wire w_c0, w_c1, w_c2;

    full_adder U_FA0 (
        .a(a0),
        .b(b0),
        .cin(1'b0),
        .s(s0),
        .cout(w_c0)
    );

    full_adder U_FA1 (
        .a(a1),
        .b(b1),
        .cin(w_c0),
        .s(s1),
        .cout(w_c1)
    );

    full_adder U_FA2 (
        .a(a2),
        .b(b2),
        .cin(w_c1),
        .s(s2),
        .cout(w_c2)
    );

    full_adder U_FA3 (
        .a(a3),
        .b(b3),
        .cin(w_c2),
        .s(s3),
        .cout(cout)
    );  
endmodule


// full adder
module full_adder(
    input a,
    input b,
    input cin,
    output s,
    output cout
);

wire w_s0, w_c0, w_c1;

assign cout = (w_c0 | w_c1);

// 인스턴스화(instance) -> 인스턴스의 이름 필요 : U_HA0
// 포트의 이름으로할 시 .[](입력)
half_adder U_HA0(
    .a(a),
    .b(b),
    .s(w_s0),
    .c(w_c0)
);

// 인스턴스화(instance) -> 인스턴스의 이름 필요 : U_HA1
half_adder U_HA1(
    .a(w_s0),
    .b(cin),
    .s(s),
    .c(w_c1)
);
endmodule



module half_adder (
    input a,
    input b,
    output s,
    output c
);

    assign s = a ^ b;
    assign c = a & b;
endmodule