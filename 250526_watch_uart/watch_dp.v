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

    wire w_tick_100hz, w_sec_tick, w_min_tick, w_hour_tick;


    time_counter_watch #(
        .BIT_WIDTH (7),
        .TICK_COUNT(100)
    ) U_MSEC (
        .clk(clk),
        .rst(rst),
        .i_tick(w_tick_100hz),
        .o_time(msec),
        .o_tick(w_sec_tick)
    );

    time_counter_watch #(
        .BIT_WIDTH (6),
        .TICK_COUNT(60)
    ) U_SEC (
        .clk(clk),
        .rst(rst),
        .up_tick(tick_sec_up),
        .down_tick(tick_sec_down),
        .i_tick(w_sec_tick),
        .o_time(sec),
        .o_tick(w_min_tick)
    );

    time_counter_watch #(
        .BIT_WIDTH (6),
        .TICK_COUNT(60)
    ) U_MIN (
        .clk(clk),
        .rst(rst),
        .up_tick(tick_min_up),
        .down_tick(tick_min_down),
        .i_tick(w_min_tick),
        .o_time(min),
        .o_tick(w_hour_tick)
    );

    time_counter_hour #(
        .BIT_WIDTH (5),
        .TICK_COUNT(24)
    ) U_HOUR (
        .clk(clk),
        .rst(rst),
        .up_tick(tick_hour_up),
        .down_tick(tick_hour_down),
        .i_tick(w_hour_tick),
        .o_time(hour),
        .o_tick()
    );

    tick_gen_100hz_watch U_Tick_100Hz (
        .clk(clk),
        .rst(rst),
        .o_tick_100(w_tick_100hz)
    );
endmodule


module time_counter_watch #(
    parameter BIT_WIDTH = 7,
    TICK_COUNT = 100
) (
    input                       clk,
    input                       rst,
    input                       i_tick,
    input                       up_tick,
    input                       down_tick,
    output wire [BIT_WIDTH-1:0] o_time,
    output                      o_tick
);

    reg [$clog2(TICK_COUNT)-1:0] count_reg, count_next;
    reg o_tick_reg, o_tick_next;

    assign o_time = count_reg;
    assign o_tick = o_tick_reg;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            count_reg  <= 0;
            o_tick_reg <= 0;
        end else begin
            // 우선순위: up → down → i_tick
            if (up_tick) begin
                count_reg  <= (count_reg == TICK_COUNT - 1) ? 0 : count_reg + 1;
                o_tick_reg <= 0;
            end else if (down_tick) begin
                count_reg <= (count_reg == 0) ? (TICK_COUNT - 1) : count_reg - 1;
                o_tick_reg <= 0;
            end else if (i_tick) begin
                if (count_reg == TICK_COUNT - 1) begin
                    count_reg  <= 0;
                    o_tick_reg <= 1;
                end else begin
                    count_reg  <= count_reg + 1;
                    o_tick_reg <= 0;
                end
            end else begin
                o_tick_reg <= 0;
            end
        end
    end

    // (CL) next state : tick 1인 구간 체크 
    always @(*) begin
        count_next  = count_reg;
        o_tick_next = 1'b0;
        if (i_tick == 1'b1) begin
            if (count_reg == (TICK_COUNT - 1)) begin
                count_next  = 0;
                o_tick_next = 1'b1;
            end else begin
                count_next  = count_reg + 1;
                o_tick_next = 1'b0;
            end
        end
    end
endmodule

module time_counter_hour #(
    parameter BIT_WIDTH = 7,
    TICK_COUNT = 100
) (
    input                       clk,
    input                       rst,
    input                       i_tick,
    input                       up_tick,
    input                       down_tick,
    output wire [BIT_WIDTH-1:0] o_time,
    output                      o_tick
);

    reg [$clog2(TICK_COUNT)-1:0] count_reg, count_next;
    reg o_tick_reg, o_tick_next;

    assign o_time = count_reg;
    assign o_tick = o_tick_reg;

    // (SL) state register
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            count_reg  <= 12;
            o_tick_reg <= 0;
        end else begin
            // 우선순위: up → down → i_tick
            if (up_tick) begin
                count_reg  <= (count_reg == TICK_COUNT - 1) ? 0 : count_reg + 1;
                o_tick_reg <= 0;
            end else if (down_tick) begin
                count_reg <= (count_reg == 0) ? (TICK_COUNT - 1) : count_reg - 1;
                o_tick_reg <= 0;
            end else if (i_tick) begin
                if (count_reg == TICK_COUNT - 1) begin
                    count_reg  <= 0;
                    o_tick_reg <= 1;
                end else begin
                    count_reg  <= count_reg + 1;
                    o_tick_reg <= 0;
                end
            end else begin
                o_tick_reg <= 0;
            end
        end
    end

    // (CL) next state : tick 1인 구간 체크 
    always @(*) begin
        count_next  = count_reg;
        o_tick_next = 1'b0;
        if (i_tick == 1'b1) begin
            if (count_reg == (TICK_COUNT - 1)) begin
                count_next  = 0;
                o_tick_next = 1'b1;
            end else begin
                count_next  = count_reg + 1;
                o_tick_next = 1'b0;
            end
        end
    end
endmodule

module tick_gen_100hz_watch (
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
            if (r_counter == FCOUNT - 1) begin
                o_tick_100 <= 1'b1;
                r_counter  <= 0;
            end else begin
                o_tick_100 <= 1'b0;
                r_counter  <= r_counter + 1;
            end
        end
    end
endmodule








