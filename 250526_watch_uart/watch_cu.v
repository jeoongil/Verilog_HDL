`timescale 1ns / 1ps

module watch_cu(
    input clk,
    input rst,
    input btnU_up,
    input btnD_down,
    input sw2,
    input sw3,
    input sw4,
    output reg tick_sec_up,
    output reg tick_sec_down,
    output reg tick_min_up,
    output reg tick_min_down,
    output reg tick_hour_up,
    output reg tick_hour_down

    );

    reg r_tick_sec, r_tick_min, r_tick_hour;

    reg r_state;

    reg prev_btnU, prev_btnD;

    wire btnU_edge, btnD_edge;

    always @(posedge clk, posedge rst) begin
        if (rst) begin
            tick_sec_up <=0;
            tick_sec_down <=0;
            tick_min_up <=0;
            tick_min_down <=0;
            tick_hour_up <=0;
            tick_hour_down <=0;

        end else begin
            if (sw2) begin
                tick_sec_up <= btnU_edge;
                tick_sec_down <= btnD_edge;
            end else if (sw3) begin
                tick_min_up <= btnU_edge;
                tick_min_down <= btnD_edge;
            end else if (sw4) begin
                tick_hour_up <= btnU_edge;
                tick_hour_down <= btnD_edge;
            end
        end
    end

    // 상승 에지 감지
    assign btnU_edge = ~prev_btnU & btnU_up;
    assign btnD_edge = ~prev_btnD & btnD_down;

    // 버튼 상태 저장 (1 클럭 지연)
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            prev_btnU <= 0;
            prev_btnD <= 0;
        end else begin
            prev_btnU <= btnU_up;
            prev_btnD <= btnD_down;
        end
    end

endmodule







