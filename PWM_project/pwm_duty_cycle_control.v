`timescale 1ns / 1ps

module pwm_duty_cycle_control (
    input clk,
    input rst,
    input motor_enable,
    input duty_inc,
    input duty_dec,
    output [3:0] DUTY_CYCLE,
    output PWM_OUT,
    output PWM_OUT_LED
); 
    reg [3:0] r_DUTY_CYCLE = 5;
    reg [3:0] r_counter_PWM = 0;

    always @(posedge clk or posedge rst) begin
        if (rst) r_DUTY_CYCLE <= 4'd5;
        else begin
            if (duty_inc && r_DUTY_CYCLE < 9)
                r_DUTY_CYCLE <= r_DUTY_CYCLE + 1;
            else if (duty_dec && r_DUTY_CYCLE > 0)
                r_DUTY_CYCLE <= r_DUTY_CYCLE - 1;
        end
    end

    always @(posedge clk or posedge rst) begin
        if (rst) r_counter_PWM <= 0;
        else if (r_counter_PWM >= 9)
            r_counter_PWM <= 0;
        else
            r_counter_PWM <= r_counter_PWM + 1;
    end

    assign PWM_OUT = motor_enable ? ((r_counter_PWM < r_DUTY_CYCLE) ? 1 : 0) : 1'b0;
    assign PWM_OUT_LED = PWM_OUT;
    assign DUTY_CYCLE = r_DUTY_CYCLE;
endmodule

