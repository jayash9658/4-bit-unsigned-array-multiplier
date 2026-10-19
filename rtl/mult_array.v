`include "full_adder.v" 

module mult_array (
    input        clk,
    input        rst_n,
    input  [3:0] a,
    input  [3:0] b,
    output reg [7:0] p
);

    reg [3:0] a_r, b_r;
    wire [7:0] p_comb;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            a_r <= 4'b0;
            b_r <= 4'b0;
            p   <= 8'b0;
        end else begin
            a_r <= a;
            b_r <= b;
            p   <= p_comb;
        end
    end

    wire C1R1, C2R1, C3R1, C4R1, C2R2, C3R2, C4R2, C5R2, C3R3, C4R3, C5R3;
    wire S2R1, S3R1, S4R1, S3R2, S4R2, S5R2;

    assign p_comb[0] = a_r[0] & b_r[0];

    full_adder fa1  (.a(a_r[1]&b_r[0]), .b(a_r[0]&b_r[1]), .cin(1'b0), .sum(p_comb[1]), .cout(C1R1));

    full_adder fa2  (.a(a_r[2]&b_r[0]), .b(a_r[1]&b_r[1]), .cin(C1R1), .sum(S2R1),      .cout(C2R1));
    full_adder fa3  (.a(S2R1),          .b(a_r[0]&b_r[2]), .cin(1'b0), .sum(p_comb[2]), .cout(C2R2));

    full_adder fa4  (.a(a_r[3]&b_r[0]), .b(a_r[2]&b_r[1]), .cin(C2R1), .sum(S3R1),      .cout(C3R1));
    full_adder fa5  (.a(S3R1),          .b(a_r[1]&b_r[2]), .cin(C2R2), .sum(S3R2),      .cout(C3R2));
    full_adder fa6  (.a(S3R2),          .b(a_r[0]&b_r[3]), .cin(1'b0), .sum(p_comb[3]), .cout(C3R3));

    full_adder fa7  (.a(1'b0),          .b(a_r[3]&b_r[1]), .cin(C3R1), .sum(S4R1),      .cout(C4R1));
    full_adder fa8  (.a(S4R1),          .b(a_r[2]&b_r[2]), .cin(C3R2), .sum(S4R2),      .cout(C4R2));
    full_adder fa9  (.a(S4R2),          .b(a_r[1]&b_r[3]), .cin(C3R3), .sum(p_comb[4]), .cout(C4R3));

    full_adder fa10 (.a(C4R1),          .b(a_r[3]&b_r[2]), .cin(C4R2), .sum(S5R2),      .cout(C5R2));
    full_adder fa11 (.a(S5R2),          .b(a_r[2]&b_r[3]), .cin(C4R3), .sum(p_comb[5]), .cout(C5R3));

    full_adder fa12 (.a(C5R2),          .b(a_r[3]&b_r[3]), .cin(C5R3), .sum(p_comb[6]), .cout(p_comb[7]));

endmodule