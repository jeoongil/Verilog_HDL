`timescale 1ns / 1ps

// 하나의 시뮬레이션 환경 모듈. 입력 출력 x
// 내가 설계한 모듈을 test하기 위해서
module tb_calculator();


    // 테스트 할 모듈의 input은 reg로 입력
    // 출력은 wire
    reg clk, reset;
    reg [7:0] a,b;
    wire [7:0] fnd_data;
    wire [3:0] fnd_com;

    // 인스턴스화

    calculator dut (
    .clk(clk),
    .reset(reset),
    .a(a),
    .b(b),
    .fnd_data(fnd_data),
    .fnd_com(fnd_com)    
    );

    // // dut 라는 이름으로 모듈을 인스턴스화 시킴.
    // Adder dut (         //dut : design under test
    //     .a(a),
    //     .b(b),
    //     // .cin(),  
    //     .s(s),
    //     .cout(cout)
    // );

    // i++, i-- 불가
    // 변수는 밖에서 선언토록
    integer i, j;

    always #5 clk =~clk; // 항상 5ns마다 반전(?)

    //initial
    initial begin
        #0; // 0 delay * timescale 시간 (ns), 시간은 누적된다.
        //a=0; b=8'h00; // a=0;(10진수) : 8bit 전체가 초기화 됨. / b=8'h00;(16진수) -> 8은 비트수
        clk = 1'b0;
        reset = 1'b1;
        a = 8'h00;  // _언더바는 합성할 때 무시된다. "표현을 쉽게
        b = 8'h00;
        
        #20;
        reset =1'b0;

        #10;
        for(i=100; i<=110; i=i+1)begin
            for(j=100; j<=110; j=j+1)begin
            a=i;
            b=j;
            #10;
            end
        end
        $finish; // $ : 시스템 축약어, finish : testbonch, simulation을 종료
        //$stop; // stop : 잠시 멈춤  
    end

endmodule