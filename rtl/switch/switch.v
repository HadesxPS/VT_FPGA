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
    input                 sw3               ,
    input                 sw4               ,
    input                 Rx_Donesig        ,
	 input  [47:0]         Rx_data           ,
    output reg  [6:0]     dis_sn            ,
	 
	 output reg            FPGA_LED_Test     ,
    output reg            en_p14v           ,
    output reg            en_n14v           ,
    output reg            en_gvddp          ,
    output reg            en_gvddn          ,
    output reg            en_vgh            ,
    output reg            en_vgl            ,
	 
    output reg            mux_en1           ,
	 output reg            mux_en2           ,
	 output reg            mux_en3           ,
	 output reg            mux_en4           ,
	 output reg            mux_en_Test1      ,
	 output reg            mux_en_Test2      ,
	 output reg            en_uart           ,
	 output wire   [79:0]  read_data         ,
	 output reg 	[5:0]	  nummax				  ,
	 
    output reg            flag_black_on
);

//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
// parameters
//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
parameter       CNT1US                      = 81                ;  //1us timer
parameter       CNT1MS                      = 1000              ;  //1ms timer
parameter       CNT1S                       = 1000              ;  //1s timer

parameter       PATMIN                      = 7'd0              ;  //minimum pattern number
parameter       PATNUM                      = 7'd9              ;
parameter       PATMAX                      = PATMIN + PATNUM - 7'd1;

//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
// variable declaration
//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
wire                            sw1_f                           ;
wire                            sw2_f                           ;
wire                            sw3_f                           ;
wire                            sw4_f                           ;
wire                            flag_up                         ;
wire                            flag_down                       ;

wire                            flag_dis_chg                    ;  //display content change
reg                             igr_sw                          ;  //when display content lock, ignore button sw1/sw2
reg                             trig_lock_timer                 ;
wire                            flag_lock_timer                 ;
reg     [15:0]                  len_lock_timer                  ;
reg                             trig_pwr_timer                  ;
wire                            flag_pwr_timer                  ;
reg     [15:0]                  len_pwr_timer                   ;
reg                             flag_pwr                        ;  //1'b0 - power off; 1'b1 - power on
reg     [6:0]                   dis_sn_d1                       ;
reg    [79:0]                   data_rty                        ;
reg                             flag_ng                         ;



//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
// continuous assignment
//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
assign flag_up = (sw1_f == 1'b0);
assign flag_down = (sw2_f == 1'b0);
//assign flag_dis_chg = ((flag_up_d2 == 1'b1) || (flag_down_d2 == 1'b1));
assign flag_dis_chg = (dis_sn != dis_sn_d1);
assign read_data = data_rty ;


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

glf #(
    .CNT1US                     ( CNT1US                        ),
    .CNT1MS                     ( CNT1MS                        ),
    .CNT1S                      ( CNT1S                         )
) u2_glf (
    .clk                        ( clk                           ),
    .rst_n                      ( rst_n                         ),
    .en                         ( 1'b1                          ),
    .s_in                       ( sw3                           ),
    .s_out                      ( sw3_f                         )
);

glf #(
    .CNT1US                     ( CNT1US                        ),
    .CNT1MS                     ( CNT1MS                        ),
    .CNT1S                      ( CNT1S                         )
) u3_glf (
    .clk                        ( clk                           ),
    .rst_n                      ( rst_n                         ),
    .en                         ( 1'b1                          ),
    .s_in                       ( sw4                           ),
    .s_out                      ( sw4_f                         )
);


//timer for display content lock
timer #(
    .CNT1US                     ( CNT1US                        ),
    .CNT1MS                     ( CNT1MS                        ),
    .CNT1S                      ( CNT1S                         )
) u0_timer (
    .clk                        ( clk                           ),  //input
    .rst_n                      ( rst_n                         ),  //input
    .start                      ( trig_lock_timer               ),  //input
    .tunit                      ( 2'b01                         ),  //input       [1:0]
    .tlen                       ( len_lock_timer                ),  //input       [15:0]
    .tpulse                     ( flag_lock_timer               )   //output reg
);

//timer for power on/off control
timer #(
    .CNT1US                     ( CNT1US                        ),
    .CNT1MS                     ( CNT1MS                        ),
    .CNT1S                      ( CNT1S                         )
) u1_timer (
    .clk                        ( clk                           ),  //input
    .rst_n                      ( rst_n                         ),  //input
    .start                      ( trig_pwr_timer                ),  //input
    .tunit                      ( 2'b01                         ),  //input       [1:0]
    .tlen                       ( len_pwr_timer                 ),  //input       [15:0]
    .tpulse                     ( flag_pwr_timer                )   //output reg
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
        dis_sn <= 7'd0;
    end
    else
    begin
        if (sw3_f == 1'b0)
        begin
            dis_sn <= PATMIN;
        end
        else if ((sw4_f == 1'b0) || (flag_ng==1'b1) )
        begin
            dis_sn <= PATMAX;
        end
        else if (flag_up == 1'b1)
        begin
            if (dis_sn == PATMAX)
            begin
                dis_sn <= PATMAX;
            end
            else
            begin
                dis_sn <= dis_sn + 7'd1;
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
                dis_sn <= dis_sn - 7'd1;
            end
        end
        else
        begin
            dis_sn <= dis_sn;
        end
    end
end

//button filter process: when button is pressed, ignore button status until time T is reached
always @(posedge clk or negedge rst_n)
begin
    if (rst_n == 1'b0)
    begin
        trig_lock_timer <= 1'b0;
    end
    else
    begin
        if (flag_dis_chg == 1'b1)  //display content change
        begin
            trig_lock_timer <= 1'b1;//1'b1
        end
        else
        begin
            trig_lock_timer <= 1'b0;//1'b0
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
        if (flag_lock_timer == 1'b1)
        begin
            igr_sw <= 1'b0;
        end
        else if (trig_lock_timer == 1'b1)
        begin
            igr_sw <= 1'b1;
        end
        else
        begin
            igr_sw <= igr_sw;
        end
    end
end

//lock time length
always @(posedge clk or negedge rst_n)
begin
    if (rst_n == 1'b0)
    begin
        len_lock_timer <= 16'd300;
    end
    else
    begin
        if (flag_dis_chg == 1'b1)
        begin
            case (dis_sn[6:0])
                7'd0:
                begin
                    len_lock_timer <= 16'd3000;
                end
                7'd1,7'd4,:
                begin
                    len_lock_timer <= 16'd2000;
                end
                7'd2,7'd3,7'd5,7'd6,7'd7:
                begin
                    len_lock_timer <= 16'd1000;
                end
                default:
                begin
                    len_lock_timer <= 16'd1000;
                end
            endcase
        end
    end
end


//uart   //传输PC段信息更改
always @(posedge clk or negedge rst_n)
begin
	if (rst_n == 1'b0)
		begin
		en_uart <= 0;
		data_rty <=0;
		flag_ng<=0;
		nummax<=5'd0;
		end
	else
		begin		    
		  if (sw1_f == 1'b0)
		  begin		  
			  if(dis_sn==0)
			  begin
			  en_uart <= 1;
			  data_rty <= "*A08-2_V4#";     //传输的数据
			  nummax<=5'd10; 			   	  //传输的数据位数 
			  end
			  else if(dis_sn== PATMAX-1)
		     begin
			  nummax<=5'd3;
		     en_uart <= 1;
			  data_rty <= "*1#";			  
		     end
			  else
			  begin
			  en_uart <= 0;
			  data_rty <= data_rty;
			  end
		 end			
		 else if(sw4_f == 1'b0)
		 begin
		     en_uart <= 1;
			  nummax<=5'd3;
			  data_rty <= "*0#";
			  
		 end
		 else
	     begin
		  en_uart <= 0;
		  data_rty <= data_rty;
       end		 
		end		
end
//power on/off control
always @(posedge clk or negedge rst_n)
begin
    if (rst_n == 1'b0)
    begin
        trig_pwr_timer <= 1'b0;
        len_pwr_timer <= 16'd500;
        flag_pwr <= 1'b0;
    end
    else
    begin
        if ((dis_sn == PATMIN + 7'd1) && (flag_dis_chg == 1'b1))  //pattern 0->1, power on
        begin
            trig_pwr_timer <= 1'b1;
            len_pwr_timer <= 16'd500;
            flag_pwr <= 1'b1;
        end
        else if ((dis_sn == PATMAX) && (flag_dis_chg == 1'b1))  //pattern 10->11, power off
        begin
            trig_pwr_timer <= 1'b1;
            len_pwr_timer <= 16'd500;
            flag_pwr <= 1'b0;
        end
        else if ((dis_sn == PATMIN) && (flag_dis_chg == 1'b1))  //pattern change to 0, power off
        begin
            trig_pwr_timer <= 1'b1;
            len_pwr_timer <= 16'd10;
            flag_pwr <= 1'b0;
        end
        else
        begin
            trig_pwr_timer <= 1'b0;
        end
    end
end

always @(posedge clk or negedge rst_n)
begin
    if (rst_n == 1'b0)
    begin
		  en_p14v       <= 1'b1;
		  en_n14v       <= 1'b1;
		  en_gvddp      <= 1'b1;
		  en_gvddn      <= 1'b1;
		  en_vgh        <= 1'b1;
		  en_vgl        <= 1'b1;
//		  FPGA_LED_Test <= 1'b1;	  
		  
		  mux_en1       <= 1'b0;   
		  mux_en2       <= 1'b0;  
		  mux_en3       <= 1'b0;  
		  mux_en4       <= 1'b0;  
        mux_en_Test1  <= 1'b0;
        mux_en_Test2  <= 1'b0;	  
    end
    else
    begin
        if ((dis_sn == PATMIN + 7'd1) && (flag_pwr == 1'b0))
        begin
            en_p14v       <= 1'b0;
				en_n14v       <= 1'b0;
        end
        else if ((flag_pwr_timer == 1'b1) && (flag_pwr == 1'b1))  //power on
        begin
//				FPGA_LED_Test <= 1'b0;//LED on
				
				en_gvddp      <= 1'b0;
				en_gvddn      <= 1'b0;
				en_vgh        <= 1'b0;
				en_vgl        <= 1'b0;
				
				mux_en1       <= 1'b1;   
				mux_en2       <= 1'b1;  
				mux_en3       <= 1'b1;  
				mux_en4       <= 1'b1;  
				mux_en_Test1  <= 1'b1;
				mux_en_Test2  <= 1'b1;
        end
        else if ((flag_pwr_timer == 1'b1) && (flag_pwr == 1'b0))  //power off
        begin
//				FPGA_LED_Test <= 1'b1;//LED off
				
				en_p14v       <= 1'b1;
				en_n14v       <= 1'b1;
				en_gvddp      <= 1'b1;
				en_gvddn      <= 1'b1;
				en_vgh        <= 1'b1;
				en_vgl        <= 1'b1;
				                    
				mux_en1       <= 1'b0;   
				mux_en2       <= 1'b0;  
				mux_en3       <= 1'b0;  
				mux_en4       <= 1'b0;  
				mux_en_Test1  <= 1'b0;
				mux_en_Test2  <= 1'b0;
        end
    end
end

always @(posedge clk or negedge rst_n)
begin
    if (rst_n == 1'b0)
    begin
        flag_black_on <= 1'b0;
    end
    else
    begin
        if ((dis_sn == PATMIN) || (dis_sn == PATMAX))
        begin
            flag_black_on <= 1'b1;
        end
        else
        begin
            flag_black_on <= 1'b0;
        end
    end
end

always @(posedge clk or negedge rst_n)
begin
    if (rst_n == 1'b0)
    begin
        FPGA_LED_Test <= 1'b1;
    end
    else
    begin
	     if (trig_lock_timer == 1'b1)
		  begin
		      FPGA_LED_Test <= 1'b0;				
		  end
		  else if (flag_lock_timer == 1'b1)
		  begin
		      FPGA_LED_Test <= 1'b1;
		  end
	 end
end

endmodule