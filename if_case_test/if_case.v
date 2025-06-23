`timescale 1ns / 1ps


// module if_case (
//     input [1:0] a,
//     input [1:0] b,
//     input sel,
//     output reg [1:0] out
// );

//     always @(a or b or sel) begin
//         case (sel)
//             0: out = a;
//             1: out = b;
//         endcase
//     end

// endmodule

module if_case (
    input [1:0] a,
    input [1:0] b,
    input [1:0] c,
    input [1:0] d,
    input [1:0] sel,
    output[1:0] out
);

    // case문
    // always @(*) begin
    //     case (sel)
    //         0: out = a;
    //         1: out = b;
    //         2: out = c;
    //         3: out = d;
    //     endcase
    // end
    // case는 우선순위가 x
    
    // // if문
    // always @(*) begin
    //    if (sel==0) out =a;
    //    else if (sel==0) out = b;
    //    else if (sel==0) out = c;
    //    else out =d;
    // end
    // // if는 우선순위 있음.
    // // 최종적으로 결과값이 같을 것. 물리적으로 시간이 달라질 수 있음. schematic 보면 확인할 수 있음.

    // 3항 연산자
    assign out = (sel==0) ? a: ((sel==1) ? b: ((sel==2) ? c:d));

endmodule
