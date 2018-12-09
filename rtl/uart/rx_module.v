module rx_module(
input 							clk									,
input 							rst_n									,
input 							rxd									,
input 							rx_en_sig							,
output reg [47:0]					Rx_data								,
output reg						Rx_Donesig,
output reg BPS_clk,
output Rx_Donesig_pos
);

reg H2h_F0,H2h_F1,H2h_F2;
wire H2h_sig;
reg count_sig;
reg [3:0]rx_bit;
reg [47:0]rtemp_data;
reg [15:0] BPS_cnt;   //bps计数
reg [4:0] byte_cnt;   //byte计数
parameter		DATASENDTIME_rx		 =					3'd2					;






reg Rx_Donesig1;

assign Rx_Donesig_pos = (Rx_Donesig1== 1'b0) && (Rx_Donesig== 1'b1);

always@(posedge clk or negedge rst_n)
begin
	if(!rst_n)
	begin
		H2h_F0<=1'b0;
		H2h_F1<=1'b0;
		H2h_F2<=1'b0;		
	end
	else
	begin
		H2h_F0<=rxd;
		H2h_F1<=H2h_F0;
		H2h_F2<=H2h_F1;      //第二个下降沿
	end
end
assign H2h_sig = (H2h_F2 & (~H2h_F1));//侦测RX下降沿

always@(posedge clk or negedge rst_n)//115200bps
begin
	if(!rst_n)
	begin
		BPS_cnt<=0;
	end
	else
	begin
		if((BPS_cnt==1215)||((count_sig==1'b0)&&(H2h_sig == 1'b1)))
		begin
			BPS_cnt<=0;
		end
		else
		begin
			BPS_cnt<=BPS_cnt+1'b1;
		end
	end
end

always@(posedge clk or negedge rst_n)//115200bps
begin
	if(rst_n == 1'b0)
	begin
		BPS_clk <= 1'b0;
	end
	else if(BPS_cnt == 608)
	begin
		BPS_clk <= 1'b1;
	end
	else
	begin
		BPS_clk <= 1'b0;
	end
end




//always@(posedge clk or negedge rst_n)
//begin
// if(!rst_n)
// begin
//  Rx_Donesig<=0;
//  Rx_data<=8'h32;
//  count_sig<=0;
//  rx_bit<=0;
// end
// else 
// begin
//   case(rx_bit)
//	0:
//	 if(H2h_sig)begin rx_bit<=rx_bit+1;count_sig<=1;end
//	1:
//	 if(BPS_clk)begin  rx_bit<=rx_bit+1; end
//	2,3,4,5,6,7,8,9:
//	  if(BPS_clk)begin  rx_bit<=rx_bit+1;Rx_data[rx_bit-2]<=rxd; end
//	10:
//	 if(BPS_clk)begin  rx_bit<=rx_bit+1; end
//	11:
//	 if(BPS_clk)begin  rx_bit<=rx_bit+1; end
//	12:
//	 begin  rx_bit<=rx_bit+1; count_sig<=0;Rx_Donesig<=1;end
//	13:
//	 begin  Rx_Donesig<=0;rx_bit<=0;end
//	 endcase
// end
//end
//

always@(posedge clk or negedge rst_n)
begin
	if(!rst_n)
	begin
		Rx_data<=8'h00;
		count_sig<=0;
		rx_bit<=0;
		
	end
	else
	begin
		if((count_sig == 1'b0) && (H2h_sig == 1'b1))
		begin
			count_sig<=1'b1;
		end
		else if(count_sig == 1'b1)
		begin			    
			if(BPS_clk)
			begin
				rx_bit<=rx_bit+1;				
				case(rx_bit)		
					1,2,3,4,5,6,7,8:	begin	Rx_data[rx_bit-1]<=rxd; end		//逐位开始接收
					9:			begin	count_sig<=0;rx_bit<=0;Rx_Donesig<=1;	end  //接收完拉高Rx_Donesig
					
					
					
					
					
					
					
					
					
					default :;
				endcase
			end
			else
			begin
				Rx_Donesig<=0;
			end
		end
		else
		begin
			Rx_Donesig<=0;
		end
	end
end

always@(posedge clk or negedge rst_n)
begin
	if(rst_n == 1'b0)
	begin
		Rx_Donesig1 <= 1'b0;
	end
	else
	begin
		Rx_Donesig1 <= Rx_Donesig;
	end
	
	
	
	
end
endmodule
