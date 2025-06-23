`timescale 1ns / 1ps

module led (
    input sw0,
    input sw1,
    output reg [3:0] led
);

    always @(*) begin
        case ({sw1, sw0})
            2'b00:   led = 4'b0001;
            2'b01:   led = 4'b0010;
            2'b10:   led = 4'b0100;
            2'b11:   led = 4'b1000;
            default: led = 4'b0000;
        endcase

    end

endmodule
















