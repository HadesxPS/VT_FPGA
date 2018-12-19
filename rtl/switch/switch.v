//*****************************************************************************
// COPYRIGHT (c) 2013, Xiamen Tianma Microelectronics Co, Ltd
//
// File name     :  switch.v
// Module name   :  switch
//
// Author        :  weipeng_wang
// Email         :  weipeng_wang@tianma.cn
// Version       :  v 1.0
//
// Function      :  Display control according to button status
// Called by     :  --
//
// ----------------------------------------------------------------------------
// Revison
// 2012-05-29    :  create file
//*****************************************************************************
module switch(
    input                 clk               ,
    input                 rst_n             ,
    input                 sw1               ,
    input                 sw2               ,
    output reg  [6:0]     dis_sn            
);

//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
// parameters
//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
parameter       CNT1US                      = 81						;  //1us timer
parameter       CNT1MS                      = 1000						;  //1ms timer
parameter       CNT1S                       = 1000						;  //1s timer
parameter       PATMIN                      = 8'd127					;  //minimum pattern number
parameter       PATMAX                      = 8'd255					;

//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
// variable declaration
//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
wire                            sw1_f                           ;
wire                            sw2_f                           ;
wire                            flag_up                         ;
wire                            flag_down                       ;

wire                            flag_dis_chg                    ;  //display content change
reg                             igr_sw                          ;  //when display content lock, ignore button sw1/sw2
reg     [7:0]                   dis_sn_d1                       ;

//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
// continuous assignment
//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
assign flag_up = (sw1_f == 1'b0);
assign flag_down = (sw2_f == 1'b0);
assign flag_dis_chg = (dis_sn != dis_sn_d1);


//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
// module instantiation
//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
glf #(
    .CNT1US                     ( CNT1US                        ),
    .CNT1MS                     ( CNT1MS                        ),
    .CNT1S                      ( CNT1S                         )
) u0_glf (
    .clk                        ( clk                           ),
    .rst_n                      ( rst_n                         ),
    .en                         ( ~ igr_sw                      ),
    .s_in                       ( sw1                           ),
    .s_out                      ( sw1_f                         )
);

glf #(
    .CNT1US                     ( CNT1US                        ),
    .CNT1MS                     ( CNT1MS                        ),
    .CNT1S                      ( CNT1S                         )
) u1_glf (
    .clk                        ( clk                           ),
    .rst_n                      ( rst_n                         ),
    .en                         ( ~ igr_sw                      ),
    .s_in                       ( sw2                           ),
    .s_out                      ( sw2_f                         )
);

always @(posedge clk or negedge rst_n)
begin
    if (rst_n == 1'b0)
    begin
        dis_sn_d1    <= PATMAX;
    end
    else
    begin
        dis_sn_d1    <= dis_sn;
    end
end

always @(posedge clk or negedge rst_n)
begin
    if (rst_n == 1'b0)
    begin
        dis_sn <= PATMIN;
    end
    else
    begin
        if (flag_up == 1'b1)
        begin
            if (dis_sn == PATMAX)
            begin
                dis_sn <= PATMAX;
            end
            else
            begin
                dis_sn <= dis_sn + 8'd1;
            end
        end
        else if (flag_down == 1'b1)
        begin
            if ((dis_sn == PATMIN) || (dis_sn == PATMAX))
            begin
                dis_sn <= dis_sn;
            end
            else
            begin
                dis_sn <= dis_sn - 8'd1;
            end
        end
        else
        begin
            dis_sn <= dis_sn;
        end
    end
end

always @(posedge clk or negedge rst_n)
begin
	if (rst_n == 1'b0)
	begin
		igr_sw <= 1'b0;
	end
	else
	begin
		igr_sw <= igr_sw;
	end
end

endmodule