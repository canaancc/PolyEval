module que_ctrl
#(parameter WID_D = 32, 
  parameter CNT_W = 5, 
  parameter ORD_NUM = 30)
(
    input                       clk,
    input                       rst_n,

    input   [WID_D-1:0]         data_in,
    input   [CNT_W-1:0]         order_cnt,
    input                       dt_vld_in,

    input                       mux2que_rdy,

    output  [WID_D-1:0]         a_left, 
    output  [WID_D-1:0]         a_right,
    output  [CNT_W-1:0]         order_cnt_o,
    output                      dt_vld_o,

    // final cal out
    output  [WID_D-1:0]         data_cal_out,
    output                      data_out_vld

);
parameter U_DLY     = 0.1;
parameter FIFO_DEP  = ORD_NUM/2+2;
parameter ADDR_W    = $clog2(FIFO_DEP);

reg [WID_D-1:0]                 data_table[ORD_NUM]; // tmp is 30
reg                             dt_vld_flag[ORD_NUM];
reg [(2*WID_D+CNT_W-1):0]       que_fifo[FIFO_DEP]; 

reg [ADDR_W:0]     que_rd_ptr;
reg [ADDR_W:0]     que_wr_ptr;

/*final signal*/
assign data_cal_out = (order_cnt == ORD_NUM) ? data_in : 'd0;
assign data_out_vld = (order_cnt == ORD_NUM) && dt_vld_in;



/* store data into data_table*/
wire dt_vld_flag_ext = dt_vld_flag[order_cnt];
genvar j;
generate
for (j = 0; j<ORD_NUM ; j++) begin
    always @(posedge clk or negedge rst_n) begin
       if      (!rst_n)                                                 data_table[j] <= #U_DLY 'd0;
       else if (dt_vld_in && (!dt_vld_flag_ext) && (order_cnt == j))    data_table[j] <= #U_DLY data_in; // if not occupy
    end

    always @(posedge clk or negedge rst_n) begin
        if      (!rst_n)                          dt_vld_flag[j] <= #U_DLY 1'b0;
        else if (dt_vld_in && (order_cnt == j))   dt_vld_flag[j] <= #U_DLY !dt_vld_flag[j]; 
        // since when a new data come  the occupy state will flip.
    end
end
endgenerate


/* data from table to que*/
wire                            dt2que_vld;
wire  [(2*WID_D+CNT_W-1):0]     dt2que_ext;

assign dt2que_vld = dt_vld_in && dt_vld_flag[order_cnt]; // when pair success, data can go to que
assign dt2que_ext = dt2que_vld ? 'd0 : {data_table[order_cnt], data_in, order_cnt}; // {a_left, a_right, cnt}

genvar i;
generate
for (i = 0; i < FIFO_DEP ;i++ ) begin:QUE_FIFO
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            que_fifo[i] <= #U_DLY 'd0;
        end 
        else if (dt2que_vld && (!fifo_full) && (que_wr_ptr[ADDR_W-1:0] == i)) begin
            que_fifo[i] <= #U_DLY dt2que_ext; 
        end
    end
end
endgenerate

// data from que 2 mux
assign dt_vld_o = !fifo_emp;
assign {a_left,a_right,order_cnt_o} = que_fifo[que_rd_ptr[ADDR_W-1:0]];

// ptr cal
wire    fifo_full = (que_wr_ptr[ADDR_W] != que_rd_ptr[ADDR_W]) && (que_wr_ptr[ADDR_W-1:0] == que_rd_ptr[ADDR_W-1:0]);
wire    fifo_emp  = (que_wr_ptr[ADDR_W] == que_rd_ptr[ADDR_W]) && (que_wr_ptr[ADDR_W-1:0] == que_rd_ptr[ADDR_W-1:0]);

always @(posedge clk or negedge rst_n) begin // wr process
    if(!rst_n) begin
        que_wr_ptr <= #U_DLY 'd0;
    end
    else if (dt2que_vld && (!fifo_full)) begin
        que_wr_ptr[ADDR_W-1:0] <= #U_DLY (que_wr_ptr[ADDR_W-1:0] == (FIFO_DEP-1)) ? 'd0 : (que_wr_ptr[ADDR_W-1:0]+1);
        que_wr_ptr[ADDR_W]     <= #U_DLY (que_wr_ptr[ADDR_W-1:0] == (FIFO_DEP-1)) ? !que_wr_ptr[ADDR_W] : que_wr_ptr[ADDR_W];
    end
end

always @(posedge clk or negedge rst_n) begin // rd process
    if(!rst_n) begin
        que_rd_ptr <= #U_DLY 'd0;
    end
    else if (mux2que_rdy && (!fifo_emp)) begin
        que_rd_ptr[ADDR_W-1:0] <= #U_DLY (que_rd_ptr[ADDR_W-1:0] == (FIFO_DEP-1)) ? 'd0 : (que_rd_ptr[ADDR_W-1:0]+1);
        que_rd_ptr[ADDR_W]     <= #U_DLY (que_rd_ptr[ADDR_W-1:0] == (FIFO_DEP-1)) ? !que_rd_ptr[ADDR_W] : que_rd_ptr[ADDR_W];
    end
end

endmodule