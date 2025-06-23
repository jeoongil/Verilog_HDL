`timescale 1ns / 1ps

module pwm_dcmotor (
    input clk,   // 100MHz clock input 
    input rst,
    input increase_duty_btn,   // input to increase 10% duty cycle 
    input decrease_duty_btn,   // input to decrease 10% duty cycle 
    input [1:0] motor_direction,  // sw0 sw1 : motor direction
    input timer_mode_sw,        // sw3: 타이머 모드 선택
    input timer_start_btn,      // 가운데 스위치: 타이머 시작
    output PWM_OUT,       // 10MHz PWM output signal 
    output PWM_OUT_LED,
    output [1:0] in1_in2,  // motor direction switch sw[0] sw[1]
    output [3:0] an,    // anode signals of the 7-segment LED display
    output [6:0] seg,    // cathode patterns of the 7-segment LED display
    output dp
    /*
      in1   in2
        0    1   :  역방향 회전
        1    0   :  정방향 회전
        1    1   :  브레이크
    */
    );

    wire w_debounced_inc_btn;
    wire w_debounced_dec_btn;
    wire w_debounced_timer_start;
    wire [3:0] w_DUTY_CYCLE;
    wire [6:0] w_timer_seconds;
    wire w_timer_running;
    wire w_motor_enable;
    wire w_clk_1hz;

     btn_debounce_10ms u_debounce_timer_start(
        .clk(clk),
        .rst(rst),
        .i_btn(timer_start_btn),
        .o_btn(w_debounced_timer_start)
    );

    btn_debounce_10ms u_debounce_inc(
        .clk(clk),
        .rst(rst),
        .i_btn(increase_duty_btn), // input to increase 10% duty cycle 
        .o_btn(w_debounced_inc_btn) // debounce inc button
    );

    btn_debounce_10ms u_debounce_dec(
        .clk(clk),  // 100MHz clock input 
        .rst(rst),
        .i_btn(decrease_duty_btn), // input to decrease 10% duty cycle 
        .o_btn(w_debounced_dec_btn) // debounce dec button
    );

    clk_divider_1hz u_clk_div(
        .clk(clk),
        .rst(rst),
        .clk_1hz(w_clk_1hz)
    );
    

        // 타이머 설정 모듈
    timer_setting u_timer_setting (
        .clk(clk),
        .rst(rst),
        .timer_mode(timer_mode_sw),
        .inc_btn(w_debounced_inc_btn),
        .dec_btn(w_debounced_dec_btn),
        .start_btn(w_debounced_timer_start),
        .clk_1hz(w_clk_1hz),
        .timer_seconds(w_timer_seconds),
        .timer_running(w_timer_running)
    );


    // 모터 활성화 제어
    assign w_motor_enable = timer_mode_sw ? w_timer_running : 1'b1;

   

    // PWM 제어 모듈 (모터 활성화 신호 추가)
    pwm_duty_cycle_control u_pwm_duty_cycle_control (
        .clk(clk),
        .rst(rst),
        .motor_enable(w_motor_enable),
        .duty_inc(timer_mode_sw ? 1'b0 : w_debounced_inc_btn),
        .duty_dec(timer_mode_sw ? 1'b0 : w_debounced_dec_btn),
        .DUTY_CYCLE(w_DUTY_CYCLE),
        .PWM_OUT(PWM_OUT),
        .PWM_OUT_LED(PWM_OUT_LED)
    );

    // 디스플레이 모듈 (타이머 모드 지원)
    fnd_display u_fnd_display (
        .clk(clk),
        .timer_mode(timer_mode_sw),
        .timer_seconds(w_timer_seconds),
        .in1_in2(in1_in2),
        .display_number(w_DUTY_CYCLE),
        .an(an),
        .seg(seg),
        .dp(dp)
    );

    assign in1_in2 = motor_direction;
endmodule



