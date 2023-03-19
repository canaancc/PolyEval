module polyeval_top #(
    parameter WID_D = 32,
    parameter WID_F = 32,
    parameter ORD_NUM = 30,
) (
    input                    clk,
    input                    rst_n,

    input   [WID_D-1:0]     data_i,
    input                   data_vld_i,
    input   [WID_F-1:0]     factor,

    output  [WID_D-1:0]     data_cal_out,
    output                  data_vld_o,
);
parameter CNT_W = $clog2(ORD_NUM);

wire    [WID_D-1:0]     input_a_left;
wire    [WID_D-1:0]     input_a_right;
wire                    input_dt_vld;

wire    [WID_D-1:0]     que_a_left;
wire    [WID_D-1:0]     que_a_right;
wire                    que_dt_vld;
wire    [CNT_W-1:0]     que_order_cnt;

wire                    mux2que_rdy;

wire    [WID_D-1:0]     alu_a_left;
wire    [WID_D-1:0]     alu_a_right;
wire                    alu_dt_vld;
wire    [CNT_W-1:0]     alu_order_cnt;


input_ctrl#(
    .WID_D    ( WID_D)
)u_input_ctrl(
    .clk      ( clk      ),
    .rst_n    ( rst_n    ),
    .data_i   ( data_i   ),
    .dt_vld_i ( data_vld_i ),
    .a_left   ( input_a_left   ),
    .a_right  ( input_a_right  ),
    .dt_vld_o  ( input_dt_vld )
);


arbitor#(
    .WID_D         ( WID_D ),
    .WID_F         ( WID_F ),
    .ORD_NUM       ( ORD_NUM ),
    .CNT_W         ( CNT_W )
)u_arbitor(
    .clk           ( clk           ),
    .rst_n         ( rst_n         ),
    .input_a_left  ( input_a_left  ),
    .input_a_right ( input_a_right ),
    .input_dt_vld  ( input_dt_vld  ),
    .que_a_left    ( que_a_left    ),
    .que_a_right   ( que_a_right   ),
    .que_order_cnt ( que_order_cnt ),
    .que_dt_vld    ( que_dt_vld    ),
    .mux2que_rdy   ( mux2que_rdy   ),
    .a_left        ( alu_a_left    ),
    .a_right       ( alu_a_right   ),
    .factor        ( alu_factor    ),
    .order_cnt     ( alu_order_cnt ),
    .d_vld_o       ( alu_d_vld_i   )
);

polyeval_alu#(
    .WID_D       ( WID_D ),
    .CNT_W       ( CNT_W ),
    .MOD_NUM     ( MOD_NUM )
)u_polyeval_alu(
    .clk         ( clk         ),
    .rst_n       ( rst_n       ),
    .a_left      ( alu_a_left      ),
    .a_right     ( alu_a_right     ),
    .factor      ( alu_factor      ),
    .order_cnt   ( alu_order_cnt   ),
    .d_vld_in    ( alu_d_vld_i    ),
    .alu_o       ( alu_o       ),
    .order_cnt_o ( order_cnt_o ),
    .d_vld_o     ( d_vld_o     )
);

wire    [WID_D-1:0] alu_o;
wire    [CNT_W-1:0] order_cnt_o;
wire                d_vld_o;


que_ctrl#(
    .WID_D        ( WID_D ),
    .CNT_W        ( CNT_W ),
    .ORD_NUM      ( ORD_NUM )
)u_que_ctrl(
    .clk          ( clk          ),
    .rst_n        ( rst_n        ),
    .data_in      ( alu_o      ),
    .order_cnt    ( order_cnt_o    ),
    .dt_vld_in    ( d_vld_o    ),
    .mux2que_rdy  ( mux2que_rdy    ),
    .a_left       ( que_a_left     ),
    .a_right      ( que_a_right    ),
    .order_cnt_o  ( que_order_cnt  ),
    .dt_vld_o     ( que_dt_vld     ),
    .data_cal_out ( data_cal_out ),
    .data_out_vld  ( data_vld_o  )
);



    
endmodule
