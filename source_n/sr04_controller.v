`timescale 1ns / 1ps

module sr04_controller (
    input clk,
    input rst,
    input start,
    input echo,
    output trig,
    output [9:0] dist,
    output dist_done
);

    wire w_tick;

    ila_0 U_ILA(
        .clk(clk),
        .probe0(trig)
    );

    start_trigger U_Start_trig (
        .clk(clk),
        .rst(rst),
        .i_tick(w_tick),
        .start(start),
        .echo(echo),   
        .dist(dist), 
        .dist_done(dist_done),  
        .o_sr04_trigger(trig)
    );

    tick_gen U_Tick_Gen (
        .clk(clk),
        .rst(rst),
        .o_tick_1mhz(w_tick)
    );
endmodule


module start_trigger (
    input  clk,
    input  rst,
    input  i_tick,          // 1MHz Tick (1us)
    input  start,           // Start pulse
    input  echo,
    output [9:0] dist,
    output dist_done,
    output o_sr04_trigger   // 10us HIGH 트리거 출력
);

reg [1:0] start_reg, start_next;
reg [3:0] count_reg, count_next;
reg sr04_trigg_reg, sr04_trigg_next;
reg [14:0]dist_count_reg, dist_count_next;
reg dist_done_reg, dist_done_next;


assign o_sr04_trigger = sr04_trigg_reg;
assign dist = dist_count_reg;
assign dist_done = dist_count_reg;

always @(posedge clk, posedge rst) begin
    if (rst) begin
        start_reg <= 0;
        sr04_trigg_reg <=0;
        count_reg <=0;
        dist_count_reg <=0;
        dist_done_reg <=0;
    end else begin
        start_reg <= start_next;
        sr04_trigg_reg <= sr04_trigg_next;
        count_reg <= count_next;
        dist_count_reg <= dist_count_next; // ??
        dist_done_reg <= dist_done_next;
    end
end

always @(*) begin
    start_next = start_reg;
    sr04_trigg_next = sr04_trigg_reg;
    count_next = count_reg;
    dist_count_next = dist_count_reg;
    dist_done_next = dist_done_reg;
    case (start_reg)
        0: begin // idel
            count_next=0;
            sr04_trigg_next =1'b0;
            dist_done_next =0;
            if (start) begin
                start_next =1;
                dist_count_next =0;
            end
        end 

        1: begin // start trig
            if (i_tick) begin
                sr04_trigg_next = 1'b1;
                count_next = count_reg +1;
                if (count_reg==10) begin
                    start_next =2;
                end
            end
        end

        2: begin // dist count
            if (echo & i_tick) begin
                dist_count_next = dist_count_reg +1;
            end else if (~echo) begin
                start_next = 3;
            end else begin
                dist_count_next = dist_count_reg;
            end
        end

        3: begin // dist cal
            dist_count_next = dist_count_reg / 58;
            start_next = 0;
            dist_done_next = 1'b1;
        end
    endcase
end
endmodule


module tick_gen (
    input  clk,
    input  rst,
    output o_tick_1mhz
);

    parameter F_COUNT = (100 - 1);

    reg [6:0] count;
    reg tick;

    assign o_tick_1mhz = tick;

    always @(posedge clk, posedge rst) begin
        if (rst) begin
            count <= 0;
            tick  <= 0;
        end else begin
            if (count == F_COUNT) begin
                count <= 0;
                tick  <= 1'b1;
            end else begin
                count <= count + 1;
                tick  <= 1'b0;
            end
        end
    end

endmodule
