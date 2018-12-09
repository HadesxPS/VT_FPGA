module tx_module(clk,txd,tx_data,rx_flag,tx_rdy,rst_n);
input clk,rx_flag,rst_n;
output reg txd,tx_rdy;
input [7:0] tx_data;
reg tx_flag;
reg [3:0]tx_bit;
reg [7:0]temp_data;
reg [15:0] bps_cnt;
reg bps_clk=0;
reg rx_flag_test0,rx_flag_test1,rx_flag_test2;
wire rx_flagneg;


always@(posedge clk)
begin
	rx_flag_test0<=rx_flag;
	rx_flag_test1<=rx_flag_test0;
	rx_flag_test2<=rx_flag_test1;
end
assign rx_flagneg=~rx_flag_test2 & rx_flag_test1;//侦测RX上升沿  对应的第二个上升沿
always@(posedge clk)//115200bps
begin
	if(!rst_n)
	begin
		bps_cnt<=0;
		bps_clk<=0;
	end
	else
	begin
		if(tx_flag)//tx处于空闲状态
			begin
				//if(bps_cnt==582)//434	50M	( 115200/67M----bps_cnt=67,000,000/115200=582 )//波特率传输，更改PCLK需动这里
				if(bps_cnt==1215)//434	50M	( 115200/67M----bps_cnt=67,000,000/115200=582 )//波特率传输，更改PCLK需动这里
						bps_cnt<=0;
				else
						bps_cnt<=bps_cnt+1'b1;
			end
		else	bps_cnt<=0;
		if(bps_cnt==608)
				bps_clk<=1;
		else
				bps_clk<=0;
	end
end
reg [19:0] rxd_rst_cnt;
reg rxd_rst;
always@(posedge clk)
begin
	if(!rst_n)
	begin
		rxd_rst_cnt<=0;
		rxd_rst<=0;
		tx_rdy<=1;   //tx初始状态为高
		temp_data<=8'd0;
		tx_flag<=0;
		tx_bit<=0;
		txd <=1'b1;
	end
	else
	begin
		if(!tx_flag)//tx处于空闲状态即tx已经将数据丢出去了
			begin
			if(rx_flagneg)//第二个上升沿来到
				begin
					tx_flag<=1;
					tx_rdy<=0;  //拉低，则开始传输
					temp_data<=tx_data;
				end
				else
				begin
					tx_rdy<=tx_rdy;
					tx_flag<=tx_flag;//上升沿没来到，保留状态无其他动作
				end
			end
		else //if(tx_flag)  为1则开始往下计数
			begin			    
				if(bps_clk)//时钟中点采样，减小采样误差
				begin
					tx_bit<=tx_bit+1;
					case(tx_bit)
								0			:	txd<=0;//起始位
						1,2,3,4,5,6,7,8:	txd<=temp_data[tx_bit-1];//开始传8bit数据
								9			:	begin txd<=1;	end//结束位
								10			:	begin	tx_flag<=0;tx_bit<=0;tx_rdy<=1;end //复位动作
						default :;
					endcase
				end
			end
	end
end
endmodule
