`timescale 1ns / 1ps
//calculator
module calculator (
    input clk,
    input reset,
    input [7:0] a,
    input [7:0] b,
    output [7:0] fnd_data,
    output [3:0] fnd_com
);

    wire [7:0] w_sum;
    wire w_carry;

    // fnd_controller
    fnd_controller U_FND_CNTR (
        .clk(clk),
        .reset(reset),
        .sum({w_carry, w_sum}),// 결합 연산자 사용하여, 1bit+ 8bit : 9bit
        .fnd_data(fnd_data),
        .fnd_com(fnd_com)
    );

    // 8bit adder
    Adder U_ADDER (
        .a(a),
        .b(b),
        // input cin,  
        .s(w_sum),
        .cout(w_carry)
    );


endmodule

// 8bit adder
module Adder (
    input [7:0] a,
    input [7:0] b,
    // input cin,  
    output [8:0] s,
    output cout
);

    wire w_c;

    full_adder_4bit U_FA4_H (
        .a(a[7:4]),
        .b(b[7:4]),
        .cin(w_c),
        .s(s[7:4]),
        .cout(cout)
    );

    full_adder_4bit U_FA4_L (
        .a(a[3:0]),
        .b(b[3:0]),
        .cin(1'b0),
        .s(s[3:0]),
        .cout(w_c)
    );
endmodule


module full_adder_4bit (
    input  [3:0] a, // input (wire 4bit a) [3:0] a, / [4:1]도 가능. 반드시 0부터 시작할 필요는 x
    input [3:0] b,  // 위와 마찬가지로 4bit
    input cin,  // 1bit 넘어오는 수!
    output [3:0] s,
    output cout
);
    wire w_c0, w_c1, w_c2;

    full_adder U_FA3 (
        .a(a[3]),  // input a의 0의 bit을 의미함.
        .b(b[3]),
        .cin(w_c2),
        .s(s[3]),
        .cout(cout)
    );

    full_adder U_FA2 (
        .a(a[2]),  // input a의 0의 bit을 의미함.
        .b(b[2]),
        .cin(w_c1),
        .s(s[2]),
        .cout(w_c2)
    );

    full_adder U_FA1 (
        .a(a[1]),  // input a의 0의 bit을 의미함.
        .b(b[1]),
        .cin(w_c0),
        .s(s[1]),
        .cout(w_c1)
    );

    full_adder U_FA0 (
        .a(a[0]),  // input a의 0의 bit을 의미함.
        .b(b[0]),
        .cin(cin),
        .s(s[0]),
        .cout(w_c0)
    );
endmodule


module full_adder (
    input  a,
    input  b,
    input  cin,
    output s,
    output cout
);

    wire w_s, w_c1, w_c2;

    assign cout = w_c1 | w_c2;

    // 인스턴스화, 실체화
    half_adder U_HA1 (
        .a(w_s),
        .b(cin),
        .s(s),
        .c(w_c2)
    );

    half_adder U_HA0 (
        .a(a),
        .b(b),
        .s(w_s),
        .c(w_c1)
    );
endmodule

module half_adder (
    input  a,
    input  b,
    output s,
    output c
);

    xor (
        s, a, b
    );  // (출력, 입력1, 입력2, 입력3, ...) / assign s = a ^ b;
    and (c, a, b);  //assign c = a | b;

endmodule
