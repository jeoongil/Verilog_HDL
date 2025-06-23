`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/05/08 14:12:32
// Design Name: 
// Module Name: tb_gates
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

// tb의 모듈안에 배치 -> 인스턴스화, TOP에서 불러오는 것들은 인스턴스화(실체화/Hlo로 배치치)! TOP는 안해줘도 됌.

module tb_gates();

// reg : register (데이터 저장 가능(default:1bit)), 자료형
// 나오는 것만 보기 위해 wire 선언
    reg a, b; // 입력
    wire y0, y1, y2, y3, y4, y5; // 출력

//gates : module의 port 이름, 괄호안의 a : 자료형 a, .a : port 이름
// dut 부분 : 배치할 때의 이름 (구분하기 위함)
gates dut(
    .a(a),
    .b(b),
    .y0(y0),
    .y1(y1),
    .y2(y2),
    .y3(y3),
    .y4(y4),
    .y5(y5) 
);

// initial : 초기화
// begin end : initial 안에서의 시작과 끝, 순서대로 한 줄씩
initial begin 
    #0; // 시간값, #0 : Delay 시간(0)
    //a=0; // 1bit 입력값 : 0/, 다른 표시 없으면 기본적으로 1bit임
    a = 1'b0; // 1: 비트수, ': 수치화(?), b: binary(2진수), 0: 값
    b=0;
    
    #10; // 10nsec (단위가 1ns이기 때문.), 10ns만큼 더해짐
    a = 1'b1;
    b = 1'b0;

    #10; 
    a = 1'b0; // 20ns
    b = 1'b1;

    #10; 
    a = 1'b1; // 30ns
    b = 1'b1;
    #10; // 결과값을 보기 위해서 한 번 더 delay 주어야함.
    $finish;
end

endmodule
