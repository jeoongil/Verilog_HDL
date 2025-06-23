`timescale 1ns / 1ps

module sr04_controller (
    input clk,
    input rst,
    input start,
    input echo,
    output trig,
    output [13:0] dist,
    output dist_done
);

    wire w_tick;

    distance U_Distance (
    .clk(clk),
    .rst(rst), 
    .i_tick(w_tick),
    .echo(echo),   
    .distance(dist), 
    .dist_done(dist_done)       
    );

    start_trigger U_Start_trig (
        .clk(clk),
        .rst(rst),
        .i_tick(w_tick),
        .start(start),
        .o_sr04_trigger(trig)
    );

    tick_gen U_Tick_Gen (
        .clk(clk),
        .rst(rst),
        .o_tick_1mhz(w_tick)
    );

endmodule

module distance (
    input clk,               // 시스템 클럭 (ex: 50MHz)
    input rst,               // 비동기 리셋
    input i_tick,              // 1MHz Tick (1us 간격)
    input echo,              // HC-SR04 센서에서 나오는 Echo 신호
    output reg [13:0] distance,  // 계산된 거리(cm)
    output reg dist_done        // 거리 계산 완료 신호 (1클럭 HIGH)
);

    // FSM 상태 정의
    parameter IDLE  = 2'b00;
    parameter COUNT = 2'b01;
    parameter DONE  = 2'b10;

    reg [1:0] state, next_state;

    reg [15:0] count_reg, count_next;  // Echo HIGH 시간 누적 (tick 단위)
    reg echo_d1, echo_d2;              // edge detection

    wire echo_rise =  echo_d1 & ~echo_d2;  // 상승엣지: 0→1
    wire echo_fall = ~echo_d1 &  echo_d2;  // 하강엣지: 1→0
    wire echo_high =  echo_d1;

    // 상태 및 입력 샘플링 레지스터
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            state      <= IDLE;
            count_reg  <= 0;
            echo_d1    <= 0;
            echo_d2    <= 0;
            distance   <= 0;
            dist_done  <= 0;
        end else begin
            state     <= next_state;
            count_reg <= count_next;

            // Echo 입력 샘플링
            echo_d1 <= echo;
            echo_d2 <= echo_d1;

            // 거리 계산 완료 시 값 반영
            if (state == DONE)
                distance <= count_reg / 58;

            // 완료 신호는 DONE 상태에서만 1클럭 HIGH
            dist_done <= (state == DONE);
        end
    end

    // 상태 전이 및 카운터 제어
    always @(*) begin
        next_state = state;
        count_next = count_reg;

        case (state)
            IDLE: begin
                count_next = 0;
                if (echo_rise)
                    next_state = COUNT;
            end

            COUNT: begin
                if (i_tick && echo_high)
                    count_next = count_reg + 1;  // 1us씩 카운트
                if (echo_fall)
                    next_state = DONE;
            end

            DONE: begin
                next_state = IDLE;  // 결과 반영 후 다시 대기
            end

            default: next_state = IDLE;
        endcase
    end

endmodule


/*
module distance (
    input clk,
    input rst,
    input echo,
    input i_tick,
    output [9:0] distance,
    output dist_done
);
  
 
endmodule
*/


module start_trigger (
    input  clk,
    input  rst,
    input  i_tick,          // 1MHz Tick (1us)
    input  start,           // Start pulse
    output o_sr04_trigger   // 10us HIGH 트리거 출력
);

    // 상태 정의
    parameter IDLE = 1'b0, TRIG = 1'b1;

    reg state, next_state;
    reg [3:0] count_reg, count_next;
    reg trigger_reg, trigger_next;

    assign o_sr04_trigger = trigger_reg;

    // 상태 및 출력 레지스터
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            state       <= IDLE;
            count_reg   <= 0;
            trigger_reg <= 0;
        end else begin
            state       <= next_state;
            count_reg   <= count_next;
            trigger_reg <= trigger_next;
        end
    end

    // 조합 논리
    always @(*) begin
        next_state    = state;
        count_next    = count_reg;
        trigger_next  = 0;

        case (state)
            IDLE: begin
                if (start) begin
                    next_state = TRIG;
                    count_next = 0;
                end
            end

            TRIG: begin
                trigger_next = 1;
                if (i_tick) begin
                    count_next = count_reg + 1;
                    if (count_reg == 9) begin  // 0~9 = 10 tick
                        next_state = IDLE;
                        trigger_next = 0;
                    end
                end
            end
        endcase
    end

endmodule




module tick_gen (
    input  clk,
    input  rst,
    output o_tick_1mhz
);

    parameter F_COUNT = (100 - 1);

    reg [6:0] count;
    reg tick;

    assign o_tick_1mhz = tick;

    always @(posedge clk, posedge rst) begin
        if (rst) begin
            count <= 0;
            tick  <= 0;
        end else begin
            if (count == F_COUNT) begin
                count <= 0;
                tick  <= 1'b1;
            end else begin
                count <= count + 1;
                tick  <= 1'b0;
            end
        end
    end

endmodule
