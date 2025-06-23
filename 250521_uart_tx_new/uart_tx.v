`timescale 1ns / 1ps

module uart_tx (
    input clk,
    input rst,
    input baud_tick,
    input start,
    input [7:0] din,
    output o_tx_done,
    output o_tx_busy,
    output o_tx
);
    // state 바꾸지 못하게 하려고 localparam으로
    localparam IDLE = 0, START = 1, DATA = 2, STOP = 3, WAIT = 4;


    // FSM 구조로 설계
    reg [3:0] c_state, n_state;  // 데이터가 위에 11개여서 4비트
    reg tx_reg, tx_next;
    reg [2:0] data_cnt_reg, data_cnt_next;  // data bit 전송 반복 구조를 위해서
    reg [3:0] b_cnt_reg, b_cnt_next; //  디버그 : 처음에 reg [2:0]이 었어서 state가 증가하지 못했음.
    reg tx_done_reg, tx_done_next; 
    reg tx_busy_reg, tx_busy_next;

    assign o_tx = tx_reg;
    assign o_tx_done = tx_done_reg; 
    assign o_tx_busy = tx_busy_reg;

    // assign o_tx_done = ((c_state == STOP) & (b_cnt_reg == 7)) ? 1'b1 : 1'b0;

    // state register
    always @(posedge clk, posedge rst) begin
        if (rst) begin
            c_state <= 0;
            tx_reg <= 1'b1;  // 출력 초기를 High로 하기위해 0->1'b1;
            data_cnt_reg <= 0;
            b_cnt_reg <= 0;  // baud tick을 0부터 7까지 count
            tx_done_reg <=0;
            tx_busy_reg <=0;
        end else begin
            c_state <= n_state;
            tx_reg <= tx_next;  // reg는 next로부터
            data_cnt_reg <= data_cnt_next;
            b_cnt_reg <= b_cnt_next;
            tx_done_reg <= tx_done_next;
            tx_busy_reg <= tx_busy_next;
        end
    end

    // next state CL / 조합 논리는 보통 * 넣음 ok, 하나만 보겠다 그거 넣으면 됌.
    always @(*) begin

        // 초기화 설정
        n_state = c_state;
        tx_next = tx_reg;
        data_cnt_next = data_cnt_reg;
        b_cnt_next = b_cnt_reg;
        tx_done_next = 0;
        tx_busy_next = tx_busy_reg;

        case (c_state)
            IDLE: begin
                b_cnt_next = 0;
                data_cnt_next = 0;
                tx_next = 1'b1;
                tx_done_next = 1'b0;
                tx_busy_next = 1'b0;
                if (start == 1'b1) begin // tick 보내는 것 없이 바로 넘겨버림.
                    n_state = START; // state의 상태로 먼저 넘어가서 tick 생기는 거 체크/ state가 먼저 가고 출력이 나옴
                    tx_busy_next = 1'b1; // 뒤에서 컨트롤하는 블락에 넘김김 
                    // start_flag =1'b1;
                end
            end
            // 상태를 먼저 내보내고 그리고 기다림.
            // 한 틱 기다렸다가 내보냄.
            START: begin
                if (baud_tick == 1'b1) begin
                    tx_next = 1'b0;
                    if(b_cnt_reg== 8) begin // 8개의 틱이 되면 state를 넘기기 위함임. (IDLE 0에서부터 8까지 8tick. 그리고 next state)
                        n_state = DATA;
                        data_cnt_next = 0;
                        b_cnt_next = 0;
                    end else begin
                        b_cnt_next = b_cnt_reg +1;
                    end
                end
            end

            DATA: begin
                tx_next = din[data_cnt_reg];
                if (baud_tick == 1'b1) begin
                    if (b_cnt_reg == 3'b111) begin // 8번 카운트하기 위함. 8이면 다음으로 넘어갈 수 있도록록
                        if (data_cnt_reg == 3'b111) begin
                            n_state = STOP;
                        end
                        b_cnt_next = 0;
                        data_cnt_next = data_cnt_reg + 1;
                    end else begin
                        b_cnt_next = b_cnt_reg +1;
                    end
                end
            end

            STOP: begin
                tx_next = 1'b1;
                if (baud_tick == 1'b1) begin
                    if (b_cnt_reg == 3'b111) begin
                        n_state = IDLE;
                        tx_done_next = 1'b1;
                        tx_busy_next = 1'b0;
                    end
                    b_cnt_next = b_cnt_reg +1;
                end
            end
        endcase
    end

endmodule


/*
`timescale 1ns / 1ps

module uart_tx (
    input clk,
    input rst,
    input baud_tick,
    input start,
    input [7:0] din,
    output o_tx
);
    // state 바꾸지 못하게 하려고 localparam으로
    localparam IDLE = 0, START = 1, DATA0 = 2, DATA1 =3,
                DATA2 = 4, DATA3 = 5, DATA4 = 6, DATA5 = 7,
                DATA6 = 8, DATA7 = 9, STOP =10, WAIT = 11;

    // FSM 구조로 설계

    reg [3:0] c_state, n_state; // 데이터가 위에 11개여서 4비트
    reg tx_reg, tx_next;
    reg [2:0] data_cnt_reg, data_cnt_next; // data bit 전송 반복 구조를 위해서
    assign o_tx = tx_reg;

    // state register
    always @(posedge clk, posedge rst) begin
        if (rst) begin
            c_state <=0;
            tx_reg <=1'b1; // 출력 초기를 High로 하기위해 0->1'b1;
            data_cnt_reg <= 0;
        end else begin
            c_state <= n_state;
            tx_reg <= tx_next; // reg는 next로부터
            data_cnt_reg <= data_cnt_next;
        end
    end

    // next state CL / 조합 논리는 보통 * 넣음 ok, 하나만 보겠다 그거 넣으면 됌.
    always @(*) begin
        
        // 초기화 설정
        n_state = c_state;
        tx_next = tx_reg;
        data_cnt_next = data_cnt_reg;

        
        case (c_state)
            IDLE: begin
                if (start == 1'b1) begin
                    n_state = START; // state의 상태로 먼저 넘어가서 tick 생기는 거 체크/ state가 먼저 가고 출력이 나옴
                    // start_flag =1'b1;
                end
            end
            // 상태를 먼저 내보내고 그리고 기다림.
            // 한 틱 기다렸다가 내보냄.
            START: begin
                if (baud_tick == 1'b1) begin
                    tx_next = 1'b0;
                    n_state = DATA0;
                end
            end 

            DATA0 : begin
                if (baud_tick == 1'b1) begin
                    tx_next = din[0]; //LSB부터 나가므로 din[0]
                    n_state = DATA1;
                end                
            end

            DATA1 : begin
                if (baud_tick == 1'b1) begin
                    tx_next = din[1]; 
                    n_state = DATA2;
                end                
            end

            DATA2 : begin
                if (baud_tick == 1'b1) begin
                    tx_next = din[2]; 
                    n_state = DATA3;
                end                
            end

            DATA3 : begin
                if (baud_tick == 1'b1) begin
                    tx_next = din[3]; 
                    n_state = DATA4;
                end                
            end

            DATA4 : begin
                if (baud_tick == 1'b1) begin
                    tx_next = din[4]; 
                    n_state = DATA5;
                end                
            end

            DATA5 : begin
                if (baud_tick == 1'b1) begin
                    tx_next = din[5]; 
                    n_state = DATA6;
                end                
            end

            DATA6 : begin
                if (baud_tick == 1'b1) begin
                    tx_next = din[6]; 
                    n_state = DATA7;
                end                
            end

            DATA7 : begin
                if (baud_tick == 1'b1) begin
                    tx_next = din[7]; 
                    n_state = STOP;
                end                
            end

            STOP : begin
                if (baud_tick == 1'b1) begin
                    tx_next = 1'b1; 
                    n_state = WAIT; // 틱과 동시에 바로 IDLE x
                end                
            end

            WAIT : begin // state를 위해 하나 기다리려고 WAIT을 만듬 
                if (baud_tick == 1'b1) begin
                    n_state = IDLE;
                end                
            end
        endcase
    end

endmodule

*/
