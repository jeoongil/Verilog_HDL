`timescale 1ns / 1ps

module dht11_controller (
    input clk,
    input rst,
    input start,
    output [7:0] rh_data,
    output [7:0] t_data,
    output dht11_done,
    output dnt11_vaild,
    output [2:0] state_led,
    inout dht11_io
);

    wire w_tick;

    tick_gen_10us U_TICK (
        .clk(clk),
        .rst(rst),
        .o_tick(w_tick)
    );

    parameter IDLE = 0, START = 1, WAIT = 2, SYNCL = 3, SYNCH = 4, DATA_SYNC = 5, DATA_DETECT = 6, STOP = 7;

    reg [2:0] c_state, n_state;
    reg [$clog2(1900)-1:0] t_cnt_reg, t_cnt_next;
    reg dht11_reg, dht11_next;
    reg io_en_reg, io_en_next;
    reg [39:0] data_reg, data_next;
    reg vaild_reg, vaild_next;
    reg [5:0] bit_cnt_reg, bit_cnt_next;
    reg dht11_io_d1, dht11_io_d2;
    wire dht11_fall;

    assign dht11_io = (io_en_reg) ? dht11_reg : 1'bz;
    assign state_led = c_state;
    assign dnt11_vaild = vaild_reg;
    assign rh_data = data_reg[39:32];
    assign t_data = data_reg[23:16];
    assign dht11_done = (c_state == STOP);

    // Falling edge detection
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            dht11_io_d1 <= 1;
            dht11_io_d2 <= 1;
        end else begin
            dht11_io_d1 <= dht11_io;
            dht11_io_d2 <= dht11_io_d1;
        end
    end

    assign dht11_fall = (dht11_io_d2 == 1'b1 && dht11_io_d1 == 1'b0);

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            c_state <= IDLE;
            t_cnt_reg <= 0;
            dht11_reg <= 1'b1;
            io_en_reg <= 1'b1;
            data_reg <= 0;
            vaild_reg <= 0;
            bit_cnt_reg <= 0;
        end else begin
            c_state <= n_state;
            t_cnt_reg <= t_cnt_next;
            dht11_reg <= dht11_next;
            io_en_reg <= io_en_next;
            data_reg <= data_next;
            vaild_reg <= vaild_next;
            bit_cnt_reg <= bit_cnt_next;
        end
    end

    always @(*) begin
        n_state = c_state;
        t_cnt_next = t_cnt_reg;
        dht11_next = dht11_reg;
        io_en_next = io_en_reg;
        data_next = data_reg;
        vaild_next = vaild_reg;
        bit_cnt_next = bit_cnt_reg;

        case (c_state)
            IDLE: begin
                dht11_next = 1'b1;
                io_en_next = 1'b1;
                if (start) begin 
                    n_state = START;
                    t_cnt_next = 0;
                    bit_cnt_next = 0;
                    data_next = 0;
                    vaild_next = 0;
                end
            end

            START: begin
               if (w_tick) begin
                    dht11_next = 1'b0;
                    t_cnt_next = (t_cnt_reg == 1800) ? 0 : t_cnt_reg + 1;
                    n_state = (t_cnt_reg == 1800) ? WAIT : START;
                end
            end

            WAIT: begin
                dht11_next = 1'b1;
                if (w_tick) begin
                    if (t_cnt_reg == 2) begin
                        n_state = SYNCL;
                        t_cnt_next = 0;
                        io_en_next = 1'b0;
                    end else begin
                        t_cnt_next = t_cnt_reg + 1;
                    end
                end
            end

            SYNCL: begin
                if (w_tick && dht11_io) n_state = SYNCH;
            end

            SYNCH: begin
                if (w_tick && !dht11_io) n_state = DATA_SYNC;
            end

            DATA_SYNC: begin
                if (w_tick && dht11_io) begin
                    n_state = DATA_DETECT;
                    t_cnt_next = 0;
                end
            end

            DATA_DETECT: begin
                if (dht11_fall) begin
                    bit_cnt_next = bit_cnt_reg + 1;
                    data_next = {data_reg[38:0], (t_cnt_reg >= 5)};
                    t_cnt_next = 0;
                    n_state = (bit_cnt_reg == 39) ? STOP : DATA_SYNC;
                end
                else if (w_tick && dht11_io) begin
                    t_cnt_next = t_cnt_reg + 1;
                end
            end

            STOP: begin
                if (w_tick) begin
                    if ((data_reg[39:32] + data_reg[31:24] + data_reg[23:16] + data_reg[15:8]) & 8'hFF == data_reg[7:0])
                        vaild_next = 1;
                    else vaild_next = 0;
                    n_state = IDLE;
                end
            end
        endcase
    end

endmodule



module tick_gen_10us (
    input  clk,
    input  rst,
    output o_tick
);
    parameter F_COUNT = 1000;
    reg [$clog2(F_COUNT)-1:0] counter_reg;
    reg tick_reg;

    assign o_tick = tick_reg;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            counter_reg <= 0;
            tick_reg <= 0;
        end else begin
            if (counter_reg == F_COUNT - 1) begin
                counter_reg <= 0;
                tick_reg <= 1'b1;
            end else begin
                counter_reg <= counter_reg + 1;
                tick_reg <= 1'b0;
            end
        end
    end
endmodule





/*
`timescale 1ns / 1ps

module dht11_controller (
    input clk,
    input rst,
    input start,
    output [7:0] rh_data,
    output [7:0] t_data,
    output dht11_done,
    output dnt11_vaild,  // check sum
    output [2:0] state_led,
    inout dht11_io
);

    wire w_tick;

    tick_gen_10us U_TICK (
        .clk(clk),
        .rst(rst),
        .o_tick(w_tick)
    );

    parameter IDLE = 0, START = 1, WAIT = 2, SYNCL = 3, SYNCH = 4, DATA_SYNC = 5, DATA_DETECT = 6, STOP = 7;

    reg [2:0] c_state, n_state;
    reg [$clog2(1900) -1:0]
        t_cnt_reg, t_cnt_next;  // 1800이 맞는데 불안해서 1900
    reg dht11_reg, dht11_next;
    reg io_en_reg, io_en_next;
    reg [39:0] data_reg, data_next;
    reg vaild_reg, vaild_next;
    reg [5:0] bit_cnt_reg, bit_cnt_next;

    assign dht11_io = (io_en_reg) ? dht11_reg : 1'bz;
    assign state_led = c_state;
    assign dnt11_vaild = vaild_reg;

    // 최종 수신된 데이터 중 RH, T 정수부만 외부 출력 연결
    assign rh_data = data_reg[39:32];  // 상대습도 정수
    assign t_data  = data_reg[23:16];  // 온도 정수


    always @(posedge clk, posedge rst) begin
        if (rst) begin
            c_state <= 0;
            t_cnt_reg <= 0;
            dht11_reg <= 1'b1;  // 초기값 항상 high로.
            io_en_reg <=1'b1; // idle에서 항상 출력 모드로 (1이어야지만 출력이 나감)
            data_reg <= 0;
            vaild_reg <= 0;
            bit_cnt_reg <=0;
        end else begin
            c_state   <= n_state;
            t_cnt_reg <= t_cnt_next;
            dht11_reg <= dht11_next;
            io_en_reg <= io_en_next;
            data_reg  <= data_next;
            vaild_reg <= vaild_next;
            bit_cnt_reg <= bit_cnt_next;
        end
    end

    always @(*) begin
        n_state = c_state;
        t_cnt_next = t_cnt_reg;
        dht11_next = dht11_reg;
        io_en_next = io_en_reg;
        data_next = data_reg;
        vaild_next = vaild_reg;
        bit_cnt_next = bit_cnt_reg;

        case (c_state)
            IDLE: begin
                dht11_next = 1'b1;
                io_en_next = 1'b1;
                if (start) begin
                    n_state = START;  // START로 상태 보내고 tick 검사.
                end
            end

            START: begin
                if (w_tick) begin
                    dht11_next = 1'b0;
                    if (t_cnt_reg == 1900) begin
                        n_state = WAIT;  //
                        t_cnt_next = 0;
                    end else begin
                        t_cnt_next = t_cnt_reg + 1;
                    end
                end
            end

            WAIT: begin
                // 출력 High로
                dht11_next = 1'b1;
                if (w_tick) begin
                    if (t_cnt_next == 2) begin
                        n_state = SYNCL;
                        t_cnt_next = 0;
                        // 출력을 입력으로 전환
                        io_en_next = 1'b0;
                    end else begin
                        t_cnt_next = t_cnt_reg + 1;
                    end
                end
            end

            SYNCL: begin  // 출력 내보낼 거 없음. 읽어와야함.
                if (w_tick) begin
                    if (dht11_io) begin
                        n_state = SYNCH;
                    end
                end
            end

            SYNCH: begin
                if (w_tick) begin
                    if (!dht11_io) begin  // Low가 될 때
                        n_state = DATA_SYNC;
                    end
                end
            end

            DATA_SYNC: begin
                if (w_tick) begin
                    if (dht11_io) begin
                        n_state = DATA_DETECT;
                    end
                end
            end

            DATA_DETECT: begin
            if (w_tick) begin
                if (!dht11_io) begin
                    // High 신호 끝 → 비트 판별
                    data_next = {data_reg[38:0], (t_cnt_reg > 5)}; // >50us이면 '1', 이하이면 '0'
                    bit_cnt_next = bit_cnt_reg + 1;
                    t_cnt_next = 0;
                        if (bit_cnt_reg == 39) begin
                            n_state = STOP;
                        end else begin
                            n_state = DATA_SYNC;  // 다음 비트 수신 대기
                        end
                end else begin
                    t_cnt_next = t_cnt_reg + 1; // High 길이 측정 중
                end
                end
            end

            STOP: begin
            if (w_tick) begin
                if ((data_reg[39:32] + data_reg[31:24] + data_reg[23:16] + data_reg[15:8]) & 8'hFF == data_reg[7:0]) begin
                    vaild_next = 1'b1;
                    end else begin
                        vaild_next = 1'b0;
                    end
                    n_state = IDLE;
                end
             end
        endcase
    end

endmodule


module tick_gen_10us (
    input  clk,
    input  rst,
    output o_tick
);
    parameter F_COUNT = 1000;  // 1000 : 100KHz , 100 : 1MHz
    reg [$clog2(F_COUNT)-1:0] counter_reg;
    reg tick_reg;

    assign o_tick = tick_reg;

    always @(posedge clk, posedge rst) begin
        if (rst) begin
            counter_reg <= 0;
            tick_reg <= 0;
        end else begin
            if (counter_reg == F_COUNT - 1) begin
                counter_reg <= 0;
                tick_reg <= 1'b1;
            end else begin
                counter_reg <= counter_reg + 1;
                tick_reg <= 1'b0;
            end
        end
    end

endmodule

*/
