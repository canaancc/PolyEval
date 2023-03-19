module arbitor
#(parameter WID_D = 32, 
  parameter WID_F = 32, 
  parameter ORD_NUM = 30, 
  parameter CNT_W = 5)
(
    input                       clk,
    input                       rst_n,

    // from input ctrl
    input       [WID_D-1:0]     input_a_left,
    input       [WID_D-1:0]     input_a_right,
    input                       input_dt_vld,

    // from queue
    input       [WID_D-1:0]     que_a_left,
    input       [WID_D-1:0]     que_a_right,
    input       [CNT_W-1:0]     que_order_cnt,
    input                       que_dt_vld, 
    output                      mux2que_rdy,

    // reg x write

    // to alu
    output      [WID_D-1:0]      a_left, 
    output      [WID_D-1:0]      a_right,  
    output      [WID_F-1:0]      factor,
    output      [CNT_W-1:0]      order_cnt,   
    output                       d_vld_o

);

reg     [CNT_W-1:0]         factor_t[ORD_NUM];

assign mux2que_rdy = !input_dt_vld;

// to ALU
assign a_left    = input_dt_vld ? input_a_left  : que_a_left;
assign a_right   = input_dt_vld ? input_a_right : que_a_right;
assign order_cnt = input_dt_vld ? 'd0 : que_order_cnt;
assign d_vld_o   = input_dt_vld || que_dt_vld;
assign factor    = factor_t[order_cnt];

//TODO , factor_t cal need to be done;

endmodule