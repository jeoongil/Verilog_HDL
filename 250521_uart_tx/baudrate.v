`timescale 1ns / 1ps

module baudrate(
    input clk,
    input rst,
    output baud_tick

);
    // clk 100MHz,
    parameter BAUD = 9600;
    parameter BAUD_COUNT = 100_000_000/(BAUD*8); // 8배속 올린 이유 : RX ,TX 같은 소스로 사용하기 위해서.
    reg [$clog2(BAUD_COUNT)-1:0] count_reg, count_next; // f/f로부터 next 현재값을 피드백 받아서 값을 전달하기 위해 (피드백 구조이기 때문에 next 필요요)
    reg baud_tick_reg, baud_tick_next;

    assign baud_tick = baud_tick_reg;
    // assign baud_count = 100_000_000 / baud_rate;

    always @(posedge clk, posedge rst) begin
        if (rst) begin
            count_reg <=0;
            baud_tick_reg <=0;
        end else begin
            count_reg <= count_next;
            baud_tick_reg <= baud_tick_next; // 계속 같은 값을 업데이트
        end
    end

    always @(*) begin
        count_next = count_reg;
        baud_tick_next = 0; // 둘다 상관 없다. baud_tick_reg
        if (count_reg == BAUD_COUNT-1) begin
            count_next =0;
            baud_tick_next = 1'b1;
        end else begin
            count_next = count_reg + 1;
            baud_tick_next = 1'b0;
        end
    end

endmodule




/*
// 순차 논리 기반
module baudrate(
    input clk,
    input rst,
    output baud_tick
);
    // clk 100MHz,
    parameter BAUD = 9600;
    parameter BAUD_COUNT = 100_000_000/BAUD;
    reg [$clog2(BAUD_COUNT)-1:0] count_reg, count_next; // f/f로부터 next 현재값을 피드백 받아서 값을 전달하기 위해 (피드백 구조이기 때문에 next 필요요)
    reg baud_tick_reg, baud_tick_next;

    assign baud_tick = baud_tick_reg;


    always @(posedge clk, posedge rst) begin
        if (rst) begin
            count_reg <=0;
            baud_tick_reg <=0;
        end else begin
            count_reg <= count_next;
            baud_tick_reg <= baud_tick_next; // 계속 같은 값을 업데이트
        end
    end

    always @(*) begin
        count_next = count_reg;
        baud_tick_next = 0; // 둘다 상관 없다. baud_tick_reg
        if (count_reg == BAUD_COUNT-1) begin
            count_next =0;
            baud_tick_next = 1'b1;
        end else begin
            count_next = count_reg + 1;
            baud_tick_next = 1'b0;
        end
    end

endmodule
*/

/*
// FSM 기반
module baudrate(
    input clk,
    input rst,
    output baud_tick
);
    // clk 100MHz,
    parameter BAUD = 9600;
    parameter BAUD_COUNT = 100_000_000/BAUD;
    reg [$clog2(BAUD_COUNT)-1:0] count_reg;  
    wire [$clog2(BAUD_COUNT)-1:0] count_next;

    assign count_next = (count_reg == BAUD_COUNT -1) ? 0 : count_reg +1;
    assign baud_tick = (count_reg == BAUD_COUNT -1) ? 1'b1 : 1'b0;

    always @(posedge clk, posedge rst) begin
        if (rst) begin
            count_reg <=0;
        end else begin
            count_reg <= count_next; 
        end
    end
endmodule

*/


