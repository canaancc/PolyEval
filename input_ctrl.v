module input_ctrl
#(parameter WID_D = 32)
(
    input                           clk,
    input                           rst_n,
    input           [WID_D-1:0]     data_i,
    input                           dt_vld_i,
    output  reg     [WID_D-1:0]     a_left,
    output  reg     [WID_D-1:0]     a_right,
    output  reg                     dt_vld_o
);
parameter U_DLY = 0.1;
reg [WID_D-1:0] dt_st[4]; // in order to ctrl convenient, use 4 reg
reg [1:0]       wr_ptr;

always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        wr_ptr <= #U_DLY 'd0;
    end
    else if(dt_vld_i) begin
        wr_ptr <= #U_DLY (wr_ptr == 2'd3) ? 2'd0 : (wr_ptr + 2'd1);
    end
end

genvar i; 
generate
    for (i = 0; i < 4 ; i++) begin:DATA_ST
        always @(posedge clk or negedge rst_n) begin
            if(!rst_n) begin
                dt_st[i] <= #U_DLY 'd0;
            end
            else if (dt_vld_i && (wr_ptr == i))begin
                dt_st[i] <= #U_DLY data_i;
            end
        end
    end
endgenerate

always @(posedge clk or negedge rst_n) begin // to generate vld signal
    if(!rst_n)                         dt_vld_o <= #U_DLY 'd0;
    else if (wr_ptr[0] && dt_vld_i)    dt_vld_o <= #U_DLY 1'b1;
    else                               dt_vld_o <= #U_DLY 1'b0; 
end

always @(*) begin
    if((dt_vld_o == 1)) begin // choose data0 and 1 or 2 and 3
        a_left  = wr_ptr[1] ? dt_st[0] : dt_st[2];
        a_right = wr_ptr[1] ? dt_st[1] : dt_st[3]; 
    end
    else begin
        a_left  =   'd0;
        a_right =   'd0;
    end
end


endmodule