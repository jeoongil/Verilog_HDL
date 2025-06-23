`timescale 1ns / 1ps

module watch_cu (
    input clk,
    input rst,
    input btnU_up,
    input btnD_down,
    input sw1,  // 시스템 전체 작동 스위치
    input sw2,  // 초 설정
    input sw3,  // 분 설정
    input sw4,  // 시 설정

    output reg tick_sec_u,
    output reg tick_sec_d,
    output reg tick_min_u,
    output reg tick_min_d,
    output reg tick_hour_u,
    output reg tick_hour_d
);

    // 상태 정의

    parameter SEC_SET = 2'b00;
    parameter MIN_SET = 2'b01;
    parameter HOUR_SET = 2'b10;

    reg [1:0] c_state, n_state;

    // tick 발생기 CE로 버튼을 넣고, 내부 tick 생성기 사용

    wire tick_btnU, tick_btnD;

    tick_gen_100_ce #(
        .FCOUNT(1_000_000)
    ) U_TickU (
        .clk(clk),
        .rst(rst),
        .ce(btnU_up),
        .o_tick_100(tick_btnU)
    );

    tick_gen_100_ce #(
        .FCOUNT(1_000_000)
    ) U_TickD (
        .clk(clk),
        .rst(rst),
        .ce(btnD_down),
        .o_tick_100(tick_btnD)
    );

    // FSM 상태 전이: 스위치에 따라 고정 

    always @(posedge clk or posedge rst) begin
        if (rst) c_state <= SEC_SET;
        else c_state <= n_state;
    end

    always @(*) begin
        if (sw4) n_state = HOUR_SET;
        else if (sw3) n_state = MIN_SET;
        else if (sw2) n_state = SEC_SET;
        else n_state = c_state;  // 유지

    end

    // Tick 출력 로직

    always @(*) begin
        tick_sec_u  = 0;
        tick_sec_d  = 0;
        tick_min_u  = 0;
        tick_min_d  = 0;
        tick_hour_u = 0;
        tick_hour_d = 0;

        if (sw1) begin
            case (c_state)
                SEC_SET: begin
                    tick_sec_u = tick_btnU;
                    tick_sec_d = tick_btnD;
                end
                MIN_SET: begin
                    tick_min_u = tick_btnU;
                    tick_min_d = tick_btnD;
                end
                HOUR_SET: begin
                    tick_hour_u = tick_btnU;
                    tick_hour_d = tick_btnD;
                end
            endcase
        end
    end

endmodule

module tick_gen_100_ce (
    input clk,
    input rst,
    input ce,
    output reg o_tick_100
);
    parameter FCOUNT = 1_000_000;
    reg [$clog2(FCOUNT)-1:0] r_counter;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            r_counter  <= 0;
            o_tick_100 <= 0;
        end else if (ce) begin
            if (r_counter == FCOUNT - 1) begin
                r_counter  <= 0;
                o_tick_100 <= 1;
            end else begin
                r_counter  <= r_counter + 1;
                o_tick_100 <= 0;
            end
        end else begin
            o_tick_100 <= 0;
        end
    end
endmodule


