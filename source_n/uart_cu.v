`timescale 1ns / 1ps

module uart_cu (
    input clk,
    input rst,
    input [7:0] rx_data,
    input rx_done,

    output reg s_sw0,
    output reg s_sw1,
    output reg s_sw2,
    output reg s_sw3,
    output reg s_sw4,

    output s_btnC_rst,
    output s_btnL_clear,
    output s_btnR_runstop,
    output s_btnU_up,
    output s_btnD_down

);

    reg tick_reg, tick_next, zero;

    assign s_btnC_rst = (rx_data == 8'h1B) ? tick_reg : 0;  // esc
    assign s_btnL_clear = (rx_data == 8'h43) ? tick_reg : 0;  // C
    assign s_btnR_runstop = (rx_data == 8'h47) ? tick_reg : 0;  // G
    assign s_btnU_up = (rx_data == 8'h57) ? tick_reg : 0;  // W
    assign s_btnD_down = (rx_data == 8'h44) ? tick_reg : 0;  // D

    always @(posedge clk, posedge rst) begin
        if (rst) begin
            s_sw0 <= 0;
            s_sw1 <= 0;
            s_sw2 <= 0;
            s_sw3 <= 0;
            s_sw4 <= 0;
            tick_reg <= 0;
            zero <= 0;
        end else begin
            tick_reg <= tick_next & rx_done;
            if (rx_done) begin
                case (rx_data)
                    8'h6D:
                    s_sw0 <= (s_sw0 == 0) ? 1 : 0;  // m (시계/스톱워치)
                    8'h6E:
                    s_sw1 <= (s_sw1 == 0) ? 1 : 0;  // n (시간 자리 모드)
                    8'h31: s_sw2 <= (s_sw2 == 0) ? 1 : 0;  // 1 (초)
                    8'h32: s_sw3 <= (s_sw3 == 0) ? 1 : 0;  // 2 (분)
                    8'h33: s_sw4 <= (s_sw4 == 0) ? 1 : 0;  // 3 (시)
                    default: zero <= 0;
                endcase
            end
        end
    end

    always @(*) begin
        tick_next = tick_reg;
        case (rx_data)
            8'h47:   tick_next = 1'b1;  // G (runstop)
            8'h43:   tick_next = 1'b1;  // C (clear)
            8'h1B:   tick_next = 1'b1;  // ESC (rst)
            8'h57:   tick_next = 1'b1;  // W (up)
            8'h44:   tick_next = 1'b1;  // D (down)
            default: tick_next = 1'b0;
        endcase
    end

endmodule
