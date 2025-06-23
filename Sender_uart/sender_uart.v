`timescale 1ns / 1ps
module sender_uart (
    input clk,
    input rst,
    input rx,
    input [7:0] i_rh_data,
    input [7:0] i_t_data,
    input btn_start,
    input dht11_valid,
    output tx,
    output tx_done
);
    wire w_start, w_tx_full;
    wire [15:0] w_rh_ascii, w_t_ascii;
    reg [2:0] state, state_next;
    reg [2:0] send_cnt_reg, send_cnt_next;
    reg [7:0] send_data_reg, send_data_next;
    reg send_reg, send_next;

    btn_debounce U_START_BD (
        .clk  (clk),
        .rst  (rst),
        .i_btn(btn_start),
        .o_btn(w_start)
    );

    uart_controller U_UART_CNTL (
        .clk(clk),
        .rst(rst),
        .rx(rx),
        .rx_pop(),
        .tx_push_data(send_data_reg),
        .tx_push(send_reg),
        .rx_pop_data(),
        .rx_empty(),
        .rx_done(),
        .tx_full(w_tx_full),
        .tx_done(tx_done),
        .tx_busy(),
        .tx(tx)
    );

    datatoascii U_RH_ASCII (
        .i_data(i_rh_data),
        .o_data(w_rh_ascii)
    );
    datatoascii U_T_ASCII (
        .i_data(i_t_data),
        .o_data(w_t_ascii)
    );

    // FSM 상태 정의
    localparam S_IDLE  = 0,
               S_WAIT  = 1,
               S_SEND  = 2,
               S_DONE  = 3;

    // 상태 및 데이터 레지스터
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            state         <= S_IDLE;
            send_data_reg <= 0;
            send_reg      <= 0;
            send_cnt_reg  <= 0;
        end else begin
            state         <= state_next;
            send_data_reg <= send_data_next;
            send_reg      <= send_next;
            send_cnt_reg  <= send_cnt_next;
        end
    end

    // FSM 및 송신 제어
    always @(*) begin
        state_next      = state;
        send_data_next  = send_data_reg;
        send_next       = 0;
        send_cnt_next   = send_cnt_reg;

        case (state)
            S_IDLE: begin
                send_cnt_next = 0;
                if (w_start)
                    state_next = S_WAIT;
            end
            S_WAIT: begin
                if (dht11_valid)
                    state_next = S_SEND;
            end
            S_SEND: begin
                if (~w_tx_full) begin
                    send_next = 1;
                    case (send_cnt_reg)
                        3'd0: send_data_next = w_rh_ascii[15:8]; // RH 십의 자리
                        3'd1: send_data_next = w_rh_ascii[7:0];  // RH 일의 자리
                        3'd2: send_data_next = ",";              // 구분자
                        3'd3: send_data_next = w_t_ascii[15:8];  // T 십의 자리
                        3'd4: send_data_next = w_t_ascii[7:0];   // T 일의 자리
                        3'd5: send_data_next = 8'h0A;            // 개행(\n)
                        default: send_data_next = 8'h20;
                    endcase
                    send_cnt_next = send_cnt_reg + 1;
                    if (send_cnt_reg == 3'd5)
                        state_next = S_DONE;
                end
            end
            S_DONE: begin
                if (!w_start)
                    state_next = S_IDLE;
            end
        endcase
    end
endmodule

// decoder, LUT
module datatoascii (
    input  [7:0] i_data,
    output [15:0] o_data  // 2바이트(십의 자리, 일의 자리)
);
    assign o_data[7:0]   = i_data % 10 + 8'h30;        // 일의 자리
    assign o_data[15:8]  = (i_data / 10) % 10 + 8'h30; // 십의 자리
endmodule
