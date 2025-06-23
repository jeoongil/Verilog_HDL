`timescale 1ns / 1ps

module timer_setting (
    input clk,                // 100MHz clock
    input rst,                // Reset
    input timer_mode,         // 타이머 모드 on/off
    input inc_btn,            // 증가 버튼
    input dec_btn,            // 감소 버튼
    input start_btn,          // 시작 버튼
    input clk_1hz,            // 1초 펄스 클럭
    output reg [6:0] timer_seconds,  // 현재 출력 값
    output reg timer_running           // 실행 중 플래그
);

    reg [6:0] r_set_seconds;
    reg [6:0] r_count_seconds;
    reg r_timer_finished;

    // 메인 FSM
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            r_set_seconds     <= 7'd0;
            r_count_seconds   <= 7'd0;
            timer_running     <= 1'b0;
            r_timer_finished  <= 1'b0;
        end else if (timer_mode) begin
            if (!timer_running) begin
                if (start_btn && r_set_seconds > 0) begin
                    timer_running     <= 1'b1;
                    r_timer_finished  <= 1'b0;
                    r_count_seconds   <= r_set_seconds;
                end else begin
                    if (inc_btn && r_set_seconds < 7'd99)
                        r_set_seconds <= r_set_seconds + 1;
                    else if (dec_btn && r_set_seconds > 0)
                        r_set_seconds <= r_set_seconds - 1;
                end
            end else if (timer_running && clk_1hz) begin
                if (r_count_seconds > 0)
                    r_count_seconds <= r_count_seconds - 1;
                else begin
                    timer_running     <= 1'b0;
                    r_timer_finished  <= 1'b1;
                    r_set_seconds     <= 7'd0;  // ✅ 타이머 종료 후 설정값 초기화
                end
            end
        end else begin
            timer_running     <= 1'b0;
            r_timer_finished  <= 1'b0;
            r_set_seconds     <= 7'd0;
            r_count_seconds   <= 7'd0;
        end
    end

    // 출력 결정
    always @(*) begin
        if (timer_mode) begin
            if (timer_running)
                timer_seconds = r_count_seconds;
            else
                timer_seconds = r_set_seconds;
        end else begin
            timer_seconds = 7'd0;
        end
    end

endmodule