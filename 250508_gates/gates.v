`timescale 1ns / 1ps // 합성시간 기준 => 동작시간 / 해석단위

// module : 시작, endmodule : 끝 => C의 중괄호와 같음
// '()' : 함수의 괄호와 동일, ';' : 끝맺음(사용시 주의)
// gate 부분 : module의 이름
// input : 입력 정의, output : 출력 정의 => 따로 구분해도 되고, 하나로 같이 기술해도 ok

module gates(
    input a,
    input b,
    output y0,
    output y1,
    output y2,
    output y3,
    output y4,
    output y5
    
);

    // gates
    assign y0 = a & b; // AND
    assign y1 = a | b; // OR
    assign y2 = ~(a & b); // NAND
    assign y3 = ~(a | b); // NOR
    assign y4 = a ^ b; // XOR
    assign y5 = ~a; // NOT

endmodule

// ',' : comma(구분자) => 마지막에는 X 
// assign y0 = a & b; : wire 자료형 연결할 때 assign

// assign : wire to wire 항상 연결해라! ex) y0에 a와 b를 AND 연산해서 연결해라.
// wire는 자료형
// input (wire) a => 자료형 code에서 생략 가능하여 생략함. 위의 input 정의 문장고 같음.
// ; : 종료를 의미

// 입력 단위 : byte가 아닌 bit! (wire의 기본 단위 1bit)
// Wire의 기능 -> 값을 저장하지 못함.
// | : 비트연산, || : 논리연산 (참 or 거짓)

// RTL ANALYSIS -> Elaborated Design : 최적화해서 알아서 스케메틱 생성
// 설계 후 합성까지

// 합성후 스케메틱에 맞춰 FPGA에 맞춰 핀 배치 (constraint->핀에 할당 :In/Out 설정)

