`timescale 1ns / 1ps

module tb_mystopwatch ();

    reg clk, rst, sw0, btnL_clear, btnR_runstop;
    wire [3:0] fnd_com;
    wire [7:0] fnd_data;

    stopwatch dut(
        .clk(clk),
        .rst(rst),
        .sw0(sw0),
        .btnL_clear(btnL_clear),
        .btnR_runstop(btnR_runstop),
        .fnd_com(fnd_com),
        .fnd_data(fnd_data)
    );

    always #5 clk = ~clk;

    integer i;

    initial begin
        // 초기값 설정
        #0;
        clk          = 0;
        rst          = 1;
        sw0          = 0;  
        btnR_runstop = 0;
        btnL_clear   = 0;

        #10;
        rst = 0;  

        // 시작
        #100;
        btnR_runstop = 1;
        #100_000;
        btnR_runstop = 0;

        // 정지
        #100;  
        btnR_runstop = 1;
        #100_000;
        btnR_runstop = 0;
    
        // clear 
        #100;   
        btnL_clear = 1;
        #100_000;
        btnL_clear = 0;

        // clear 
        #100;   
        btnL_clear = 1;
        #100_000;
        btnL_clear = 0;

        #100;   
        btnR_runstop = 1;
        #100_000;
        btnR_runstop = 0;
        
        for (i = 0; i < 1000000; i = i + 1) begin
        #100_000;
        sw0 = 1;
        #100_000;
        sw0 = 0;
        end

        #100_000;
        $stop;  // 시뮬레이션 종료
    end
endmodule


