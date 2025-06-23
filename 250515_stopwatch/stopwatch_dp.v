`timescale 1ns / 1ps

module stopwatch_dp (
    input clk,
    input rst,
    input run_stop,
    input clear,
    output [6:0] msec,
    output [5:0] sec
);

    wire w_tick_100hz, w_sec_tick, w_min_tick;

    time_counter #(
        .BIT_WIDTH (7),
        .TICK_COUNT(100)  // parameter 값 입력 완료
    ) U_MSEC (
        .clk(clk),
        .rst(rst | clear),
        .i_tick(w_tick_100hz),
        .o_time(msec),
        .o_tick(w_sec_tick)
    );

    time_counter #(
        .BIT_WIDTH (6),
        .TICK_COUNT(60)  // parameter 값 입력 완료
    ) U_SEC (
        .clk(clk),
        .rst(rst | clear),
        .i_tick(w_sec_tick),
        .o_time(sec),
        .o_tick(w_min_tick)
    );

    tick_gen_100hz U_Tick_100Hz (
        .clk(clk & run_stop),
        .rst(rst | clear),
        .o_tick_100(w_tick_100hz)
    );

endmodule

// counter 4개는 비효율. 하나로 퉁
module time_counter #(
    parameter BIT_WIDTH = 7,
    TICK_COUNT = 100
) (
    input clk,
    input rst,
    input                       i_tick, // 개수를 세서 시간이 증가하는 것을 확인 하기 위해 선언한 변수
    output wire [BIT_WIDTH-1:0] o_time,  
    output o_tick
);

    reg [$clog2(TICK_COUNT)-1:0] count_reg, count_next;
    reg o_tick_reg, o_tick_next;

    assign o_time = count_reg;
    assign o_tick = o_tick_reg;

    // (SL) state register : clk 들어오면 출력으로 나가고 싶음.
    always @(posedge clk, posedge rst) begin
        if (rst) begin
            count_reg <= 0;
            o_tick_reg <= 0;
        end else begin
            count_reg <= count_next;
            o_tick_reg <= o_tick_next;
        end
    end

    // (CL) next state : tick 1인 구간 체크 / 값의 변화는 반영. 하지만 엣지가 발생하는 순간에 값이 업데이트 되는 것임.
    // 비교 대상은 항상 현재. next (x)
    always @(*) begin
        count_next = count_reg; //next는 연산 돼서 업데이트 되면 값이 바뀜. next는 현재임.
        o_tick_next = 1'b0;
        if (i_tick == 1'b1) begin
            if (count_reg == (TICK_COUNT - 1)) begin
                count_next = 0;
                o_tick_next = 1'b1;  // tick 생성기. tick 올림. 
            end else begin
                count_next = count_reg + 1;
                o_tick_next = 1'b0;
            end
        end
    end

endmodule

// Latch 전상태유지... -> 값을 바꿔야하는데 값이 안바뀌게됨. => 조합 논리끼리 섞여서... 없애야함.


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
            if (r_counter == FCOUNT-1) begin //카운트 값이 일치 했을 때, o_tick_100을 상승
                o_tick_100 <= 1'b1; // 해당 값에 도달하는 순간 tick을 올림. 한클럭 동안 올린 값 유지하고 다시 내림(-> 이때가 아마 0부터 다시 시작)
                r_counter <= 0;
            end else begin // 비트 수가 안맞으면 초기화 시키고 카운트 증가 시킴.
                o_tick_100 <= 1'b0; // 해당 값 지나면 다시 (tick_gen의 clk을)0으로 
                r_counter <= r_counter + 1;
            end
        end
    end


endmodule
