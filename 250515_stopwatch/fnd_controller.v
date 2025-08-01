`timescale 1ns / 1ps

module fnd_controller (
    input clk,
    input reset,
    input [6:0] msec,
    input [5:0] sec,
    output [7:0] fnd_data,
    output [3:0] fnd_com
);

    wire [3:0] w_bcd, w_msec_1, w_msec_10, w_sec_1, w_sec_10;
    wire w_oclk;
    wire [1:0] fnd_sel;
    
    // fnd_sel 연결하기
    clk_devider U_CLK_Div (
        .clk(clk),
        .reset(reset),
        .o_clk(w_oclk)
    );

    counter_4 U_Counter_4 ( 
        .clk(w_oclk), 
        .reset(reset),
        .fnd_sel(fnd_sel)
    );

    decoder_2x4 U_Decoder_2x4 (
        .fnd_sel(fnd_sel),
        .fnd_com(fnd_com)
    );

    //
    digit_splitter #(
    .BIT_WIDTH(7) 
    ) U_DS_MSEC (
        .time_data(msec),
        .digit_1(w_msec_1),
        .digit_10(w_msec_10)
    );

    digit_splitter #(
    .BIT_WIDTH(6) 
    ) U_DS_SEC (
        .time_data(sec),
        .digit_1(w_sec_1),
        .digit_10(w_sec_10)
    );
    //

    mux_4x1 U_MUX_4x1 (
        .sel(fnd_sel),
        .digit_1(w_msec_1),
        .digit_10(w_msec_10),
        .digit_100(w_sec_1),
        .digit_1000(w_sec_10),
        .bcd(w_bcd)
    );

    bcd U_BCD (
        .bcd(w_bcd),
        .fnd_data(fnd_data)
    );

endmodule

//clk divider
// ->1kHz
module clk_devider (
    input clk,
    input reset,
    output o_clk
);
    // clk 100_000_000, r_count 100_000 (1KHZ) -> 17bit 필요
    //reg [16:0] r_counter;  // 모듈안에서는 다른 모듈에서 선언한 변수 이름 사용 가능 (c와 같음)
    reg [$clog2(100_000)-1:0] r_counter; 
    reg r_clk;

    assign o_clk = r_clk; // always 안에있는 r 클럭을 밖에 있는 아웃풋 O 클럭과 연결 이어줌.
    always @(posedge clk, posedge reset) begin
        if (reset) begin
            r_counter <= 0;
            r_clk <= 1'b0; // 신호 관련은 비트수를 나타내는 것으로 표현. 
        end else begin
            if (r_counter == 100_000-1) begin // 1KHz preiod
                r_counter <= 0;
                r_clk <= 1'b1;
            end else begin
               r_counter <= r_counter +1;
               r_clk <= 1'b0; 
            end 
        end
    end
endmodule

//4진 카운터
module counter_4 ( // 1KHz->1msec, 1MHz->1usec, 1GHz->1nsec
    input clk, // 100MHz(system clk), 25MHZ(4로나눈) 그래도 너무 빠름. clk 줄이고 싶음 -> 분주(2번 들어올 때마다 바꿔주고 싶음(2분주기). / 반복행위는 곧 순차회로로), clk devider를 4진 카운터 앞에 한 번 설계 (reset은  devider와 카운터에 각각들어감.) =>12.5MHZ당 값이 증가하는 카운터로 change
    input reset,
    output [1:0] fnd_sel
);
    reg [1:0] r_counter;
    assign fnd_sel =r_counter;
    //
    always @(posedge clk, posedge reset) begin // 상승하는 경계마다 매번 count 하고 싶음. '<=' : non-block, '=' : block
        if (reset) begin
            r_counter <= 0; // 일반적으로 논리를 간략화 하기 위해 넌블락 사용 
        end else begin
            r_counter <= r_counter +1; // verilog에서는 ++이 없기 때문에 원하는 증가량 만큼 직접 코딩.
        end
    end
    // 비동기식 reset (reset은 clk에 동기되어 있지 않음. ','가 OR의 의미를 가짐) -> asic에서 사용(?)   
    // 비동기식 : 어떤 것에도 영향을 받지 x, 동기식 : 어떤 것에도(기준점) 영향이 있을 때    
    //순차회로 : '<='(non-block), 조합회로 : '='(block)
    //positive edge(rising) : 상승, negative edge(falling) : 하강

endmodule

module decoder_2x4 (
    input [1:0] fnd_sel,
    output reg [3:0] fnd_com
);
    always @(fnd_sel) begin
        case (fnd_sel)
            2'b00: begin
                fnd_com = 4'b1110;  // fnd 1의 자리 on,
            end
            2'b01:   fnd_com = 4'b1101;
            2'b10:   fnd_com = 4'b1011;
            2'b11:   fnd_com = 4'b0111;
            default: fnd_com = 4'b1111;
        endcase
    end

endmodule

//mux는 입력과 출력의 비트수 동일함.
module mux_4x1 (
    input  [1:0] sel,
    input  [3:0] digit_1,
    input  [3:0] digit_10,
    input  [3:0] digit_100,
    input  [3:0] digit_1000,
    output [3:0] bcd
);

    //always문 출력 내보낼 때 reg 타입

    reg [3:0] r_bcd;
    assign bcd = r_bcd;

    // 4:1 mux, always
    always @(*) begin // (*): *은 입력 모두 감시, 감시 대상 많으면 *, 많지 않다면 x / 괄호안에 sel이든 *이든 상관x
        case (sel)
            2'b00: r_bcd = digit_1;
            2'b01: r_bcd = digit_10;
            2'b10: r_bcd = digit_100;
            2'b11: r_bcd = digit_1000;
        endcase
    end

endmodule

module digit_splitter #(
    parameter BIT_WIDTH = 7 
) (
    input  [BIT_WIDTH-1:0] time_data,
    output [3:0] digit_1,
    output [3:0] digit_10
);
    assign digit_1 = time_data % 10;  // 연산할 때 보통 assig문
    assign digit_10 = (time_data / 10) % 10;
   
endmodule


module bcd (
    input  [3:0] bcd,
    output [7:0] fnd_data
);

    // 조합논리 -> assign, always, gate primitive
    // 값을 저장하기 위해서는 wire가 아닌 reg
    reg [7:0] r_fnd_data;

    // always 입력:wire, 출력:reg(반드시는 x, 대게 값을 저장하기 위해서) / assign 입력:wire, 출력:wire 
    assign fnd_data = r_fnd_data;

    // 조합논리 combinational, 행위수준 모델링
    always @(bcd) begin // 항상 (신호) 괄호안 이벤트! begin ~end 실행라라 , 항상 bcd 값에 변화가 생기면 비긴 루프 진행. 안의 내용 실행
        case (bcd)
            4'h00:   r_fnd_data = 8'hc0;
            4'h01:   r_fnd_data = 8'hf9;
            4'h02:   r_fnd_data = 8'ha4;
            4'h03:   r_fnd_data = 8'hb0;
            4'h04:   r_fnd_data = 8'h99;
            4'h05:   r_fnd_data = 8'h92;
            4'h06:   r_fnd_data = 8'h82;
            4'h07:   r_fnd_data = 8'hf8;
            4'h08:   r_fnd_data = 8'h80;
            4'h09:   r_fnd_data = 8'h90;
            default: r_fnd_data = 8'hff;
        endcase
    end

endmodule
