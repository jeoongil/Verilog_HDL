`timescale 1ns / 1ps

module tb_top ();

    reg clk, rst, sw0, sw1, sw2, sw3, sw4;
    reg btnL_clear, btnR_runstop, btnU_up, btnD_down;
    wire [3:0] led;
    wire [7:0] fnd_data;
    wire [3:0] fnd_com;

    // DUT
    top dut (
        .clk(clk),
        .rst(rst),
        .sw0(sw0),
        .sw1(sw1),
        .sw2(sw2),
        .sw3(sw3),
        .sw4(sw4),
        .btnL_clear(btnL_clear),
        .btnR_runstop(btnR_runstop),
        .btnU_up(btnU_up),
        .btnD_down(btnD_down),
        .led(led),
        .fnd_data(fnd_data),
        .fnd_com(fnd_com)
    );

    // Clock generation (100 MHz)
    always #5 clk = ~clk;

    initial begin
        // 초기화
        #0;
        clk = 0;
        rst = 1;
        sw0 = 0;
        sw1 = 0;
        sw2 = 0;
        sw3 = 0;
        sw4 = 0;
        btnL_clear = 0;
        btnR_runstop = 0;
        btnU_up = 0;
        btnD_down = 0;

        #100;  // 100ns 후 리셋 해제
        rst = 0;


        #10000000; 
        //btnR_runstop = 1;
        sw1 = 1;
        sw0 = 1;
        sw2 = 1;
        #50000000; 
        //btnR_runstop = 0;
        btnU_up = 1;

        #10000000; 
        //btnR_runstop = 1;
        btnU_up = 0;

        #50000000; 
        //btnR_runstop = 0;
        btnU_up =1;

        #10000000; 
        //btnL_clear = 1;
        btnU_up = 0;

        #50000000; 
        //btnL_clear = 0;


        
        // 종료
        #1000000;
        $stop;
    end

endmodule


/*
initial begin
        // 초기화
        #0;
        clk = 0;
        rst = 1;
        sw0 = 0;
        sw1 = 0;
        btnL_clear = 0;
        btnR_runstop = 0;
        btnU_up = 0;
        btnD_down = 0;

        #100;  // 100ns 후 리셋 해제
        rst = 0;


        #10000000; 
        btnR_runstop = 1;
        
        #50000000; 
        btnR_runstop = 0;

            #10000000; 
        btnR_runstop = 1;
        
        #50000000; 
        btnR_runstop = 0;
        
        #10000000; 
        btnL_clear = 1;
        #50000000; 
        btnL_clear = 0;


        
        // 종료
        #1000000;
        $stop;
    end
*/