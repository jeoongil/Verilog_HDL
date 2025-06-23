`timescale 1ns / 1ps

module clk_div_test (
    input  clk,
    input  reset,
    output clk_div3
);

    reg [2:0] r_count, r_count_neg;

    assign clk_div3 = ((r_count==2) | (r_count_neg==2));

    // 분주위해서 플립플롭 써야함. always!
    always @(posedge clk, posedge reset) begin
        if (reset) begin
            r_count <=0;
        end else begin
            if (r_count==2) begin
                r_count <=0;
            end else begin
                r_count <= r_count + 1;    
            end
        end
    end

    always @(negedge clk, posedge reset) begin
        if (reset) begin
            r_count_neg <=0;
        end else begin
            if (r_count_neg==2) begin
                r_count_neg<=0;
            end else begin
                r_count_neg <= r_count_neg +1;    
            end
        end
    end
endmodule


// `timescale 1ns / 1ps

// module clk_div_test (
//     input  clk,
//     input  reset,
//     output clk_div2,
//     output clk_div4,
//     output clk_div8
// );

// // 분주위해서 플립플롭 써야함. always!

//     reg [2:0] r_count, r_count_neg;

//     assign clk_div2 = r_count[0];
//     assign clk_div4 = r_count[1];
//     assign clk_div8 = r_count[2];

//     always @(posedge clk, posedge reset) begin
//         if (reset) begin
//             r_count <=0;
//         end else begin
//             if (r_count==2) begin
//                 r_count <=0;
//             end
//                 r_count <= r_count + 1;
//         end
//     end

//     always @(negedge clk, posedge reset) begin
//         if (reset) begin
//             r_count_neg <=0;
//         end else begin
//             if (r_count_neg==2) begin
//                 r_count_neg =0;
//             end else begin
//                r_count_neg <= r_count_neg +1; 
//             end
//         end
//     end


// endmodule