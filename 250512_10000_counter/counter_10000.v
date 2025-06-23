// `timescale 1ns / 1ps

// module top_counter_10000 (
//     input clk,
//     input reset,
//     input [1:0] sw,
//     output [7:0] fnd_data,
//     output [3:0] fnd_com
// );

//     wire [13:0] w_count_data;
//     wire w_clk_1hz;

//     wire w_run_stop_clk;
//     wire w_clear;

//     assign w_run_stop_clk = clk & sw[0];
//     assign w_clear = reset | sw[1];

//     clk_div_100hz #(
//         .F_COUNT(100_000_000)
//     ) U_CLK_DIV_100 (
//         .clk(w_run_stop_clk),
//         .reset(w_clear),
//         .o_clk_100hz(w_clk_1hz)
//     );

//     counter_10000 U_COUNTER_10000 (
//         .clk(w_clk_1hz),
//         .reset(w_clear),
//         .count_data(w_count_data)
//     );

//     fnd_controller U_FND_CNTL (
//         .clk(clk),
//         .reset(reset),
//         .count_data(w_count_data),
//         .fnd_data(fnd_data),
//         .fnd_com(fnd_com)
//     );
// endmodule

// module clk_div_100hz #(
//     parameter F_COUNT = 1_000_000
// ) (
//     input  clk,
//     input  reset,
//     output o_clk_100hz
// );

//     // parameter F_COUNT = 1_000_000; ,인스턴스화 하면서 값을 건드려도 상관x
//     reg [$clog2(F_COUNT)-1:0] r_counter;
//     reg r_clk;
//     assign o_clk_100hz = r_clk;

//     always @(posedge clk, posedge reset) begin
//         if (reset) begin
//             r_counter <= 0;
//             r_clk <= 0;
//         end else begin
//             if (r_counter == F_COUNT - 1) begin
//                 r_counter <= 0;
//                 r_clk <= 1'b1;
//             end else if (r_counter >= F_COUNT/2) begin // duty비 절반으로 만들기 위함. (duty ratio 50%)
//                 r_counter <= r_counter + 1;
//                 r_clk <= 1'b0;
//             end else begin // 모든 case(경우의 수)를 다처리해주기. 합성기가 이상한 것을 넣을 수도 있기 때문에 + r_counter 증가가
//                 r_counter <= r_counter + 1;
//             end
//         end
//     end
// endmodule

// module counter_10000 (
//     input clk,
//     input reset,
//     output [13:0] count_data
// );

//     // 10000
//     reg [5:0] r_sec;
//     reg [3:0] r_min;

//     assign count_data = r_min * 100 + r_sec;

//     always @(posedge clk, posedge reset) begin
//         if (reset) begin
//             r_sec <= 0;
//             r_min <= 0;
//         end else begin
//             if (r_sec == 6'd59) begin  // 9999까지 가면 초기화화
//                 r_sec <= 0;
//                 if(r_min == 4'd9) begin
//                     r_min <= 0; 
//                 end else begin
//                     r_min <= r_min +1;
//                 end
//             end else begin
//                 r_sec = r_sec + 1;
//             end
//         end
//     end
// endmodule

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

`timescale 1ns / 1ps

module top_counter_10000 (
    input clk,
    input reset,
    input [1:0] sw,
    output [7:0] fnd_data,
    output [3:0] fnd_com
);

    wire [13:0] w_count_data;
    wire w_clk_100hz;

    wire w_run_stop_clk;
    wire w_clear;

    assign w_run_stop_clk = clk & sw[0];
    assign w_clear = reset | sw[1];

    clk_div_100hz #(
        .F_COUNT(100_000_000)
    ) U_CLK_DIV_100 (
        .clk(w_run_stop_clk),
        .reset(w_clear),
        .o_clk_100hz(w_clk_100hz)
    );

    counter_10000 U_COUNTER_10000 (
        .clk(w_clk_100hz),
        .reset(w_clear),
        .count_data(w_count_data)
    );

    fnd_controller U_FND_CNTL (
        .clk(clk),
        .reset(reset),
        .count_data(w_count_data),
        .fnd_data(fnd_data),
        .fnd_com(fnd_com)
    );
endmodule

module clk_div_100hz #(
    parameter F_COUNT = 1_000_000
) (
    input  clk,
    input  reset,
    output o_clk_100hz
);

    // parameter F_COUNT = 1_000_000; ,인스턴스화 하면서 값을 건드려도 상관x
    reg [$clog2(F_COUNT)-1:0] r_counter;
    reg r_clk;
    assign o_clk_100hz = r_clk;

    always @(posedge clk, posedge reset) begin
        if (reset) begin
            r_counter <= 0;
            r_clk <= 0;
        end else begin
            if (r_counter == F_COUNT - 1) begin
                r_counter <= 0;
                r_clk <= 1'b1; //clk high로 만들어줌, 한 주기의 전반부임.
            end else if (r_counter >= F_COUNT/2) begin // duty비 절반으로 만들기 위함. (duty ratio 50%)
                r_counter <= r_counter + 1;
                r_clk <= 1'b0; //clk low로 만들어줌, 한 주기의 후반부임.
            end else begin // 모든 case(경우의 수)를 다처리해주기. 합성기가 이상한 것을 넣을 수도 있기 때문에 + r_counter 증가가
                r_counter <= r_counter + 1;
            end
        end
    end
endmodule

module counter_10000 (
    input clk,
    input reset,
    output [13:0] count_data
);

    // 10000
    reg [13:0] r_counter;

    assign count_data = r_counter;

    always @(posedge clk, posedge reset) begin
        if (reset) begin
            r_counter <= 0;
        end else begin
            if (r_counter == 10000 - 1) begin  // 9999까지 가면 초기화
                r_counter <= 0;
            end else begin
                r_counter = r_counter + 1;
            end
        end
    end
endmodule

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// `timescale 1ns / 1ps

// module top_counter_10000 (
//     input clk,
//     input reset,
//     output [7:0] fnd_data,
//     output [3:0] fnd_com
// );

//     wire [13:0] w_count_data;

// counter_10000 U_COUNTER_10000(
//     .clk(clk),
//     .reset(reset),
//     .count_data(w_count_data)
// );

// fnd_controller U_FND_CNTL (
//     .clk(clk),
//     .reset(reset),
//     .count_data(w_count_data),
//     .fnd_data(fnd_data),
//     .fnd_com(fnd_com)
// );
// endmodule


// module counter_10000(
//     input clk,
//     input reset,
//     output [13:0] count_data
// );

//     // 10000
//     reg [13:0] r_counter;

//     assign count_data = r_counter;

//     always @(posedge clk, posedge reset) begin
//        if (reset) begin
//             r_counter <=0;
//        end else begin
//             if (r_counter == 10000-1) begin // 9999까지 가면 초기화화
//                 r_counter<=0;
//             end else begin
//                 r_counter = r_counter + 1;
//             end
//        end
//     end
// endmodule
