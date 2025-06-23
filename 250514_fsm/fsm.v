`timescale 1ns / 1ps

module fsm (
    input clk,
    input reset,
    input [2:0] sw,
    output reg [2:0] led
);

    // (1) 제일 처음 할 일 : 상태 정의 하기.
    parameter IDLE= 3'b000, STATE1=3'b001, STATE2=3'b010, STATE3=3'b011, STATE4=3'b100, STATE5=3'b101;
    // (2-1) state 2개 : 현재, 다음
    reg [2:0] c_state, n_state; // c_state : current state, n_state : next state

    // (2) 그 다음 보통 state register 설계
    always @(posedge clk, posedge reset) begin
        if (reset) begin
            c_state <=3'b000; //reset 걸려면 항상 stop에 가있어라
        end else begin
            c_state <= n_state; // reset이 아니면 클럭마다 next를 current로!
        end
    end

    // (3) next state Combinational Logic
    always @(*) begin // *를 많이함. c_state만 보는 것은 위험
        n_state = c_state; // 다음 상태는 현재 상태임을 나타냄 계속. 그 반대의 경우는 issue.
        case (c_state)

            IDLE: begin
                // 입력조건에 따라 next state를 처리한다.
                if (sw == 3'b001) begin
                    n_state = STATE1; // 조합 논리에서는 Block, 위의 순차 논리회로에서는 non-block 사용.
                end else if(sw == 3'b111) begin
                    n_state = STATE3;
                end
            end 

            STATE1: begin
                if (sw == 3'b010) begin
                    n_state = STATE2;
                end else if(sw == 3'b100) begin
                    n_state = STATE4;
                end
            end

            STATE2: begin
                // 입력조건에 따라 next state를 처리한다.
                if (sw == 3'b011) begin
                    n_state = STATE3; // 조합 논리에서는 Block, 위의 순차 논리회로에서는 non-block 사용.
                end
            end 

            STATE3: begin
                if (sw == 3'b100) begin
                    n_state = STATE4;
                end
            end

            STATE4: begin
                // 입력조건에 따라 next state를 처리한다.
                if (sw == 3'b101) begin
                    n_state = STATE5; // 조합 논리에서는 Block, 위의 순차 논리회로에서는 non-block 사용.
                end
            end 
            
            STATE5: begin
                // 입력조건에 따라 next state를 처리한다.
                if (sw == 3'b110) begin
                    n_state = IDLE; // 조합 논리에서는 Block, 위의 순차 논리회로에서는 non-block 사용.
                end
            end 
            default: n_state = IDLE; // 제일 처음의 초기상태로 설정.
        endcase
    end

    // (4) Output Combinational Logic -> 특별하게 제약두지 않음. assign문도 사용 가능
    always @(*) begin
        led = 3'b000; // 무조건 초기 조건을 넣어라 이것은 아님, 초기화 또는 default 설정해줘야함 always문
        case (c_state)
            IDLE: begin
                led = 3'b000;
            end 
            STATE1: begin
                led = 3'b001;
            end
            STATE2: begin
                led = 3'b010;
            end
            STATE3: begin
                led = 3'b011;
            end
            STATE4: begin
                led = 3'b100;
            end
            STATE5: begin
                led = 3'b111;
            end 
        endcase
    end
    // assign led =(c_state == STOP) ? 2'b10 : 2'b01;

    // 각 모듈안의 input, output 초기화 해주기! 특히 output 초기화! default 보다 먼저 초기화가 중요! 그래야 Latch 안생김.

endmodule



////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

// `timescale 1ns / 1ps

// module fsm (
//     input clk,
//     input reset,
//     input sw,
//     output reg [1:0] led
// );

//     // (1) 제일 처음 할 일 : 상태 정의 하기.
//     parameter STOP = 1'b0, RUN = 1'b1;
//     // (2-1) state 2개 : 현재, 다음
//     reg c_state, n_state; // c_state : current state, n_state : next state

//     // (2) 그 다음 보통 state register 설계
//     always @(posedge clk, posedge reset) begin
//         if (reset) begin
//             c_state <=1'b0; //reset 걸려면 항상 stop에 가있어라
//         end else begin
//             c_state <= n_state; // reset이 아니면 클럭마다 next를 current로!
//         end
//     end

//     // (3) next state Combinational Logic
//     always @(*) begin // *를 많이함. c_state만 보는 것은 위험
//         n_state = c_state; // 다음 상태는 현재 상태임을 나타냄 계속. 그 반대의 경우는 issue.
//         case (c_state)
//             STOP: begin
//                 // 입력조건에 따라 next state를 처리한다.
//                 if (sw == 1) begin
//                     n_state = RUN; // 조합 논리에서는 Block, 위의 순차 논리회로에서는 non-block 사용.
//                 end
//             end 
//             RUN : begin
//                 if (sw == 1'b0) begin
//                     n_state = STOP;
//                 end
//             end
//             default: n_state = STOP; // 제일 처음의 초기상태로 설정.
//         endcase
//     end

//     // (4) Output Combinational Logic -> 특별하게 제약두지 않음. assign문도 사용 가능
//     always @(*) begin
//         led = 2'b10; // 무조건 초기 조건을 넣어라 이것은 아님, 초기화 또는 default 설정해줘야함 always문
//         case (c_state)
//             STOP: begin
//                 led = 2'b10;
//             end 
//             RUN: begin
//                 led = 2'b01;
//             end 
//         endcase
//     end
//     // assign led =(c_state == STOP) ? 2'b10 : 2'b01;

//     // 각 모듈안의 input, output 초기화 해주기! 특히 output 초기화! default 보다 먼저 초기화가 중요! 그래야 Latch 안생김.

// endmodule
