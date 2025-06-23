`timescale 1ns / 1ps

module tb_fsm();

reg clk, reset;
reg [2:0] sw;
wire [2:0] led;

fsm dut (
    .clk(clk),
    .reset(reset),
    .sw(sw),
    .led(led)
);

always #5 clk =~clk;

initial begin
    #0;
    clk = 1'b0;
    reset = 1'b1;
    sw = 3'b000;

    #10;
    reset= 1'b0;

    // 상태 전이 시나리오에 따라 sw 입력 변화
        // 상태: IDLE → STATE1
        #10 sw = 3'b001; // sw 조건 충족
        #10 sw = 3'b000; // 입력 제거 (상태 유지 확인)

        // STATE1 → STATE2
        #10 sw = 3'b010;
        #10 sw = 3'b000;

        // STATE2 → STATE3
        #10 sw = 3'b011;
        #10 sw = 3'b000;

        // STATE3 → STATE4
        #10 sw = 3'b100;
        #10 sw = 3'b000;

        // STATE4 → STATE5
        #10 sw = 3'b101;
        #10 sw = 3'b000;

        // STATE5 → IDLE
        #10 sw = 3'b110;
        #10 sw = 3'b000;

        // 추가로 IDLE → STATE3 바로 가는 경로
        #10 sw = 3'b111;
        #10 sw = 3'b000;

        // 시뮬레이션 종료
        #50;
        $finish;
    end

endmodule
