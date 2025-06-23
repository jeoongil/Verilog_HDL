`timescale 1ns / 1ps

module clk_divider_1hz (
    input clk,          // 100MHz input clock
    input rst,          // Reset
    output reg clk_1hz  // 1Hz output clock pulse
);

    parameter MAX_COUNT = 100_000_000 - 1; // for 100MHz -> 1Hz
    reg [26:0] count;  // 27 bits can count up to 134M

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            count <= 27'd0;
            clk_1hz <= 1'b0;
        end else begin
            if (count >= MAX_COUNT) begin
                count <= 27'd0;
                clk_1hz <= 1'b1;  // 1-cycle pulse
            end else begin
                count <= count + 1;
                clk_1hz <= 1'b0;
            end
        end
    end

endmodule
