`timescale 1ns / 1ps


module tb_fifo ();

    reg clk, rst, push, pop;
    reg  [7:0] push_data;
    wire [7:0] pop_data;
    wire full, empty;

    fifo dut (
        .clk(clk),
        .rst(rst),
        .push(push),
        .pop(pop),
        .push_data(push_data),
        .full(full),
        .empty(empty),
        .pop_data(pop_data)
    );

    always #5 clk = ~clk;

    integer i;
    reg rand_push;
    reg rand_pop;
    reg [7:0] compare_data[0:16-1];  // fifo 크기만큼 설정
    integer push_count, pop_count;  // push count, pop count

    initial begin
        #0;
        clk = 0;
        rst = 1;
        push = 0;
        pop = 0;
        push_data = 0;
        #20;
        rst = 0;

        // full test
        for (i = 0; i < 17; i = i + 1) begin
            #10;
            push = 1;
            push_data = i;
        end
        #10;
        push = 0;

        // empty test
        for (i = 0; i < 17; i = i + 1) begin
            #10;
            pop = 1;
        end
        #10;
        pop = 0;

        // 동시 push, pop
        for (i = 0; i < 20; i = i + 1) begin
            #10;
            push = 1;
            pop = 1;
            push_data = i + 1;
        end
        #10;
        push =0;
        #10;
        pop = 0;
        $stop;
    end

endmodule
