`timescale 1ns / 1ps

//BRAM

module ram (
    input clk,
    input [7:0] addr,
    input [7:0] wdata,
    input wr,
    output reg [7:0] rdata
);

    //reg [7:0] bram_mem; // 저장이니까 reg로
    reg [7:0] mem[0:255]; // address가 8비트이므로

    // 조합 논리 출력
    // assign rdata = mem[addr]; // addr만 바뀌면 assign 바로 나감


    always @(posedge clk) begin
        if (wr) begin
            mem[addr] <= wdata;
        end else begin
            rdata <= mem[addr];
        end
    end

endmodule


/*
[조합]
module ram (
    input clk,
    input [7:0] addr,
    input [7:0] wdata,
    input wr,
    output [7:0] rdata
);

    reg [7:0] bram_mem; // 저장이니까 reg로
    reg [7:0] mem[0:255]; // address가 8비트이므로

    // 조합 논리 출력
    assign rdata = mem[addr]; // addr만 바뀌면 assign 바로 나감


    always @(posedge clk) begin
        if (wr) begin
            mem[addr] <= wdata;
        end 
    end

endmodule
*/