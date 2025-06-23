`timescale 1ns / 1ps

module sender_uart (
    input clk,
    input rst,
    input rx,
    input [9:0] i_send_data,
    input btn_start,
    output tx,
    output tx_done
);
    wire w_start;
    wire [23:0] w_send_data;
    reg [1:0] c_state, n_state;
    reg [7:0] send_data_reg, send_data_next;
    reg send_reg, send_next;
    reg [1:0] send_cnt_reg, send_cnt_next;

    /*
    btn_debounce U_START_BD (
        .clk  (clk),
        .rst  (rst),
        .i_btn(btn_start),
        .o_btn(w_start)
    );
*/
    assign w_start = btn_start;

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

    datatoascii U_DtoA (
        .i_data(i_send_data),
        .o_data(w_send_data)
    );

    always @(posedge clk, posedge rst) begin
        if (rst) begin
            c_state <= 0;
            send_data_reg <= 0;
            send_reg <= 0;
            send_cnt_reg <= 0;
        end else begin
            c_state <= n_state;
            send_data_reg <= send_data_next;
            send_reg <= send_next;
            send_cnt_reg <= send_cnt_next;
        end
    end

    always @(*) begin
        n_state = c_state;
        send_data_next = send_data_reg;
        send_next = send_reg;
        send_cnt_next = send_cnt_reg;
        case (c_state)
            00: begin
                if (w_start) begin
                    n_state = 1;
                    send_cnt_next = 0;
                end
            end

            01: begin  // send
                // n_state = 0;
                if (~w_tx_full) begin
                    send_next = 1;  // send tick 생성    
                    if (send_cnt_reg < 3) begin
                        // 상위부터 보내기
                        case (send_cnt_reg)
                            00: send_data_next = w_send_data[23:16];
                            01: send_data_next = w_send_data[15:8];
                            10: send_data_next = w_send_data[7:0];
                        endcase
                        send_cnt_next = send_cnt_reg + 1;
                    end else begin
                        n_state = 0;
                    end
                    //send_data_next = "0";
                end else n_state = c_state;
            end
        endcase
    end

endmodule

// decoder, LUT
module datatoascii (
    input  [ 9:0] i_data,
    output [23:0] o_data   // 3byte
);

    assign o_data[7:0]   = i_data % 10 + 8'h30;  // 나머지 + 8'h30
    assign o_data[15:8]  = (i_data / 10) % 10 + 8'h30;
    assign o_data[23:16] = (i_data / 100) % 10 + 8'h30;

endmodule
