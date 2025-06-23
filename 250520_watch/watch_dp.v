`timescale 1ns / 1ps
`timescale 1ns / 1ps

module watch_dp (
    input clk,
    input rst,

    input tick_sec_up,
    input tick_sec_down,
    input tick_min_up,
    input tick_min_down,
    input tick_hour_up,
    input tick_hour_down,

    output [6:0] msec,
    output [5:0] sec,
    output [5:0] min,
    output [4:0] hour
);

    wire tick_100hz, tick_sec, tick_min, tick_hour;

    // 밀리초 자리 (수동 증감 없음)
    time_counter_ud #(
        .BIT_WIDTH (7),
        .TICK_COUNT(100)
    ) U_MSEC (
        .clk(clk),
        .rst(rst),
        .i_tick(tick_100hz),
        .i_up(1'b0),
        .i_down(1'b0),
        .o_time(msec),
        .o_tick(tick_sec)
    );

    // 초 자리
    time_counter_ud #(
        .BIT_WIDTH (6),
        .TICK_COUNT(60)
    ) U_SEC (
        .clk(clk),
        .rst(rst),
        .i_tick(tick_sec),
        .i_up(tick_sec_up),
        .i_down(tick_sec_down),
        .o_time(sec),
        .o_tick(tick_min)
    );

    // 분 자리
    time_counter_ud #(
        .BIT_WIDTH (6),
        .TICK_COUNT(60)
    ) U_MIN (
        .clk(clk),
        .rst(rst),
        .i_tick(tick_min),
        .i_up(tick_min_up),
        .i_down(tick_min_down),
        .o_time(min),
        .o_tick(tick_hour)
    );

    // 시 자리
    time_counter_ud #(
        .BIT_WIDTH (5),
        .TICK_COUNT(24)
    ) U_HOUR (
        .clk(clk),
        .rst(rst),
        .i_tick(tick_hour),
        .i_up(tick_hour_up),
        .i_down(tick_hour_down),
        .o_time(hour),
        .o_tick()
    );

    // 항상 동작하는 틱 발생기
    tick_gen_100hz U_TickGen (
        .clk(clk),
        .rst(rst),
        .o_tick_100(tick_100hz)
    );

endmodule

module time_counter_ud #(
    parameter BIT_WIDTH = 6,
    parameter TICK_COUNT = 60
)(
    input clk,
    input rst,
    input i_tick,
    input i_up,
    input i_down,
    output reg [BIT_WIDTH-1:0] o_time,
    output reg o_tick
);

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            o_time <= 0;
            o_tick <= 0;
        end else begin
            o_tick <= 0;

            if (i_up) begin
                if (o_time < TICK_COUNT - 1)
                    o_time <= o_time + 1;
            end else if (i_down) begin
                if (o_time > 0)
                    o_time <= o_time - 1;
            end else if (i_tick) begin
                if (o_time == TICK_COUNT - 1) begin
                    o_time <= 0;
                    o_tick <= 1;
                end else begin
                    o_time <= o_time + 1;
                end
            end
        end
    end
endmodule


module tick_gen_100hz (
    input clk,
    input rst,
    output reg o_tick_100
);
    parameter FCOUNT = 1_000_000;

    reg [$clog2(FCOUNT)-1:0] r_counter;

    // state register
    always @(posedge clk, posedge rst) begin
        if (rst) begin
            r_counter  <= 0;
            o_tick_100 <= 0;
        end else begin
            if (r_counter == FCOUNT-1) begin 
                o_tick_100 <= 1'b1; 
                r_counter <= 0;
            end else begin 
                o_tick_100 <= 1'b0;
                r_counter <= r_counter + 1;
            end
        end
    end
endmodule