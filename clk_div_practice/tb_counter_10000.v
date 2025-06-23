`timescale 1ns / 1ps

// 하나의 시뮬레이션 환경 모듈. 입력 출력 x
// 내가 설계한 모듈을 test하기 위해서
module tb_counter_10000();


    // 테스트 할 모듈의 input은 reg로 입력
    // 출력은 wire
    reg clk, reset;
    wire [7:0] fnd_data;
    wire [3:0] fnd_com;

    // 인스턴스화

    top_counter_10000 dut (
    .clk(clk),
    .reset(reset),
    .fnd_data(fnd_data),
    .fnd_com(fnd_com)
    );

    integer i, j;

    always #5 clk =~clk; // 항상 5ns마다 반전(?)

    //initial
    initial begin
        #0; // 0 delay * timescale 시간 (ns), 시간은 누적된다.
        clk = 1'b0;
        reset = 1'b1;
        
        #20;
        reset =1'b0;

        $finish; // 
    end

endmodule