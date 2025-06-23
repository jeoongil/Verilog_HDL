`timescale 1ns / 1ps

module fnd_display(
    input clk,         // 100MHz clock source
    input timer_mode,           // 타이머 모드 신호
    input [6:0] timer_seconds,  // 타이머 초 값 (0~99)
    input [1:0] in1_in2,        // 모터 방향
    input [3:0] display_number, // 듀티사이클 등 기존 표시값
    output [3:0] an,            // 애노드 신호
    output [6:0] seg,           // 세그먼트 패턴
    output dp                   // 소수점
);

    parameter FORWARD =  4'b1010; // f
    parameter BACKWARD = 4'b1011; // b

    reg [3:0] LED_BCD;
    reg [26:0] refresh_counter = 0;
    reg [1:0] LED_activating_counter;
    reg [3:0] r_an;
    reg r_dp;
    assign an = r_an;
    assign dp = r_dp;

    // refresh_counter 및 LED_activating_counter
    always @(posedge clk) begin
        refresh_counter <= refresh_counter + 1;
    end
    always @(*) begin
        LED_activating_counter = refresh_counter[19:18];
    end

    // 애노드 및 표시값 결정
    always @(*) begin
        if (timer_mode) begin
            // 타이머 모드: 두 자리만 표시
            case (LED_activating_counter)
                2'b00: begin
                    r_an = 4'b1110; // 첫째 자리만 on
                    LED_BCD = timer_seconds % 10; // 십의 자리
                    r_dp = 1'b1;
                end
                2'b01: begin
                    r_an = 4'b1101; // 둘째 자리만 on
                    LED_BCD = timer_seconds / 10; // 일의 자리
                    r_dp = 1'b1;
                end
                default: begin
                    r_an = 4'b1111; // 나머지는 모두 off
                    LED_BCD = 4'd0;
                    r_dp = 1'b1;
                end
            endcase
        end else begin
            // 기존 모드: 네 자리 모두 표시 (예시)
            case (LED_activating_counter)
                2'b00: begin
                    r_an = 4'b0111;
                    // 방향 표시
                    if (in1_in2 == 2'b10)
                        LED_BCD = FORWARD;
                    else if (in1_in2 == 2'b01)
                        LED_BCD = BACKWARD;
                    else
                        LED_BCD = 4'd0;
                    r_dp = 1'b1;
                end
                2'b01: begin
                    r_an = 4'b1011;
                    LED_BCD = (display_number % 1000) / 100;
                    r_dp = 1'b1;
                end
                2'b10: begin
                    r_an = 4'b1101;
                    LED_BCD = ((display_number % 1000) % 100) / 10;
                    r_dp = 1'b1;
                end
                2'b11: begin
                    r_an = 4'b1110;
                    LED_BCD = ((display_number % 1000) % 100) % 10;
                    r_dp = 1'b1;
                end
            endcase
        end
    end

    // 7세그먼트 디코딩
    reg [6:0] r_fnd_dis;
    assign seg = r_fnd_dis;
    always @(*) begin
        case (LED_BCD)
            4'b0000: r_fnd_dis = 7'b0000001; // "0"
            4'b0001: r_fnd_dis = 7'b1001111; // "1"
            4'b0010: r_fnd_dis = 7'b0010010; // "2"
            4'b0011: r_fnd_dis = 7'b0000110; // "3"
            4'b0100: r_fnd_dis = 7'b1001100; // "4"
            4'b0101: r_fnd_dis = 7'b0100100; // "5"
            4'b0110: r_fnd_dis = 7'b0100000; // "6"
            4'b0111: r_fnd_dis = 7'b0001111; // "7"
            4'b1000: r_fnd_dis = 7'b0000000; // "8"
            4'b1001: r_fnd_dis = 7'b0000100; // "9"
            4'b1010: r_fnd_dis = 7'b0111000; // "f"
            4'b1011: r_fnd_dis = 7'b1100000; // "b"
            default: r_fnd_dis = 7'b0000001; // "0"
        endcase
    end

endmodule



