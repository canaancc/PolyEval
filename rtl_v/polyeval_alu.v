module polyeval_alu
#(parameter WID_D = 32, 
  parameter WID_F = 32, 
  parameter CNT_W = 5, 
  parameter MOD_NUM = 30)
(
    input                           clk,
    input                           rst_n,
    input       [WID_D-1:0]         a_left,
    input       [WID_D-1:0]         a_right,
    input       [WID_F-1:0]         factor,
    input       [CNT_W-1:0]         order_cnt,
    input                           d_vld_in,
    output reg  [WID_D-1:0]         alu_o,
    output reg  [CNT_W-1:0]         order_cnt_o,
    output                          d_vld_o
);
parameter U_DLY = 0.1;

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        alu_o <= #U_DLY 'd0;
    end
    else if (d_vld_in) begin
        alu_o <= #U_DLY (a_left + a_right * factor) % MOD_NUM;
    end
end

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        order_cnt_o <= #U_DLY 'd0;
    end
    else if (d_vld_in) begin
        order_cnt_o <= #U_DLY order_cnt + 1;
    end 
end

endmodule