//*****************************************************************************
// COPYRIGHT (c) 2015, Xiamen Tianma Microelectronics Co, Ltd
//
// File name     :  uart.v
// Module name   :  uart
//
// Author        :  xiaomeng_chen
// Email         :  xiaomeng_chen@tianma.cn
// Version       :  v 1.0
//
// Function      :  uart for serial communication to tx
// Called by     :  --
//
// ----------------------------------------------------------------------------
// Revison
// 2016-03-14    :  create file
//*****************************************************************************
module uart(
input										clk								,
input 									en_uart							,
input 									sw1 					 		   ,
input 									rst_n								,
input 									tx_rdy							,//tx_busy signal    高有效
input  [79:0]                    serial_data                ,
input  [5:0]                     DATASENDTIME				   ,//0-10位
output [7:0]							uart_data						,
output 									uart_wr							,
output reg								FPGA_LED_Test 				
);

reg   [7:0]								rData								;
reg	[7:0]								bytenum							;//传送数据计数
reg	[3:0]								cstate							;
reg	[3:0]								nstate							;
reg 	[79:0]			            recdata							;
reg				                  send24bitend               ;
reg 										isEn								;
wire  									sw5_f							   ;
assign 		   uart_data			 =					rData					;
assign   	   uart_wr				 =					isEn					;
parameter 	   IDLE					 =					4'd0					;
parameter 	   RECIEVE				 =					4'd1					;
parameter 	   DATADIVE				 =					4'd2					;
parameter 		SEND					 =					4'd3					;
parameter 		SENDDELAY			 =					4'd4					;
parameter		WAIT_TX_TEST1		 =					4'd5					;
parameter		WAIT_TX_TEST2		 =					4'd6					;
parameter		WAIT_TX_TEST3		 =					4'd7					;
parameter		WAIT_TX_TEST4		 =					4'd8					;
parameter		WAIT_TX_TEST5		 =					4'd9					;


glf u1_glf (
    .clk                        ( clk                           ),
    .rst_n                      ( rst_n                         ),
    .en                         ( 1'b1                          ),
    .s_in                       ( sw1                           ),
    .s_out                      ( sw1_f                         )//防抖模块
);

always@(posedge clk or negedge rst_n)//时序逻辑，只有当上升沿时候才执行
begin
	if(rst_n == 1'b0)
	begin
		cstate <= IDLE;
	end
	else
	begin
		cstate <= nstate;
	end
end
always@(*)//*组合逻辑，任何时候只要状态变了就马上执行
begin
  case(cstate)
	  IDLE:			
		begin
			if(en_uart == 1'b0)
				nstate = IDLE;
			else if((send24bitend == 1'b1) && (en_uart == 1'b1))//串口使能端拉高，开始接收
				nstate = RECIEVE;
			else
				nstate = IDLE;
		end
		RECIEVE:		
		 begin
			nstate = DATADIVE;
		 end
		DATADIVE:	
		 begin
			nstate = WAIT_TX_TEST1;
		 end
		WAIT_TX_TEST1:			
		 begin
			nstate = WAIT_TX_TEST2;
		 end
		WAIT_TX_TEST2:			
		 begin
			nstate = WAIT_TX_TEST3;
		end
		WAIT_TX_TEST3:			
		 begin
			nstate = WAIT_TX_TEST4;
		 end
		WAIT_TX_TEST4:		
		 begin
			nstate = WAIT_TX_TEST5;
		 end
		WAIT_TX_TEST5:			
		 begin
			nstate = SENDDELAY;
		 end
	   SENDDELAY:	
	    begin
		if(tx_rdy == 1'b1)//高有效
		begin
			if(bytenum == DATASENDTIME-8'd1)//传送到最后一位，还没结束
			begin
				nstate = IDLE;				
			end
			else
			begin
				nstate = DATADIVE;//已经接收，没传送完，所以再次进行传送动作
			end
		end
		else
		begin
			nstate = SENDDELAY;		//tx_rdy为低，循环等待	
		end
	  end
	endcase
end
always@(posedge clk or negedge rst_n)
begin
  if (rst_n == 1'b0)
	  begin
		isEn  <= 1'b0;//检测得是上升沿
		rData <= 8'h00;
		recdata<= 80'h0000000000;
		FPGA_LED_Test <= 1'b1;//LED off
		send24bitend <= 1'b1;
	  end
  else 
	  begin
		  case(cstate)
			  IDLE:
				 begin
				 recdata <= recdata;
				 isEn  <= 1'b0;
				 send24bitend <= 1'b1;
				 end 
				RECIEVE:
			    begin
				 recdata <= serial_data;
             send24bitend <= 1'b0;
				end 
				DATADIVE:	
					begin					 					 
						isEn <= 1'b1;
						FPGA_LED_Test <= 1'b1;//LED on
					  case (DATASENDTIME)
						5'd1:
						begin
						 if(bytenum == 8'd0)
							rData <= recdata[7:0];
							else
							rData <= 8'hAA;
						end
						5'd2:
						begin
						if(bytenum == 8'd0)
							rData <= recdata[15:8];
						else if(bytenum == 8'd1)
							rData <= recdata[7:0];
						else
							rData <= 8'hAA;
						end
						5'd3:
						begin
						if(bytenum == 8'd0)     //高位开始传
							rData <= recdata[23:16];
						else if(bytenum == 8'd1)
							rData <= recdata[15:8];
						else if(bytenum == 8'd2)
							rData <= recdata[7:0];
						else
							rData <= 8'hAA;
						end
						5'd4:
						begin
						if(bytenum == 8'd0)
							rData <= recdata[31:24];
						else if(bytenum == 8'd1)
							rData <= recdata[23:16];
						else if(bytenum == 8'd2)
							rData <= recdata[15:8];
						else if(bytenum == 8'd3)
							rData <= recdata[7:0];
						else
							rData <= 8'hAA;
						end
						
						5'd5:
						begin
						if(bytenum == 8'd0)
							rData <= recdata[39:32];
						else if(bytenum == 8'd1)
							rData <= recdata[31:24];
						else if(bytenum == 8'd2)
							rData <= recdata[23:16];
						else if(bytenum == 8'd3)
							rData <= recdata[15:8];
						else if(bytenum == 8'd4)
							rData <= recdata[7:0];
						else
							rData <= 8'hAA;	
						end
						5'd6:
						begin
						if(bytenum == 8'd0)
							rData <= recdata[47:40];
						else if(bytenum == 8'd1)
							rData <= recdata[39:32];
						else if(bytenum == 8'd2)
							rData <= recdata[31:24];
						else if(bytenum == 8'd3)
							rData <= recdata[23:16];
						else if(bytenum == 8'd4)
							rData <= recdata[15:8];
						else if(bytenum == 8'd5)
							rData <= recdata[7:0];
						else
							rData <= 8'hAA;
						end
						5'd7:
						begin					
						if(bytenum == 8'd0)
							rData <= recdata[55:48];
						else if(bytenum == 8'd1)
							rData <= recdata[47:40];
						else if(bytenum == 8'd2)
							rData <= recdata[39:32];
						else if(bytenum == 8'd3)
							rData <= recdata[31:24];
						else if(bytenum == 8'd4)
							rData <= recdata[23:16];
						else if(bytenum == 8'd5)
							rData <= recdata[15:8];
						else if(bytenum == 8'd6)
							rData <= recdata[7:0];
						else						
							rData <= 8'hAA;					
						end
						5'd8:
						begin						
						if(bytenum == 8'd0)
							rData <= recdata[63:56];
						else if(bytenum == 8'd1)
							rData <= recdata[55:48];
						else if(bytenum == 8'd2)
							rData <= recdata[47:40];
						else if(bytenum == 8'd3)
							rData <= recdata[39:32];
						else if(bytenum == 8'd4)
							rData <= recdata[31:24];
						else if(bytenum == 8'd5)
							rData <= recdata[23:16];
						else if(bytenum == 8'd6)
							rData <= recdata[15:8];
						else if(bytenum == 8'd7)
							rData <= recdata[7:0];
						else						
							rData <= 8'hAA;													
						end
					5'd9:
						begin
						if(bytenum == 8'd0)
							rData <= recdata[71:64];
						else if(bytenum == 8'd1)
							rData <= recdata[63:56];
						else if(bytenum == 8'd2)
							rData <= recdata[55:48];
						else if(bytenum == 8'd3)
							rData <= recdata[47:40];
						else if(bytenum == 8'd4)
							rData <= recdata[39:32];
						else if(bytenum == 8'd5)
							rData <= recdata[31:24];
						else if(bytenum == 8'd6)
							rData <= recdata[23:16];
						else if(bytenum == 8'd7)
							rData <= recdata[15:8];
						else if(bytenum == 8'd8)
							rData <= recdata[7:0];
						else
							rData <= 8'hAA;
						end	
						5'd10:
						begin
						if(bytenum == 8'd0)
							rData <= recdata[79:72];
						else if(bytenum == 8'd1)
							rData <= recdata[71:64];
						else if(bytenum == 8'd2)
							rData <= recdata[63:56];
						else if(bytenum == 8'd3)
							rData <= recdata[55:48];
						else if(bytenum == 8'd4)
							rData <= recdata[47:40];
						else if(bytenum == 8'd5)
							rData <= recdata[39:32];
						else if(bytenum == 8'd6)
							rData <= recdata[31:24];
						else if(bytenum == 8'd7)
							rData <= recdata[23:16];
						else if(bytenum == 8'd8)
							rData <= recdata[15:8];
						else if(bytenum == 8'd9)
							rData <= recdata[7:0];
						else
							rData <= 8'hAA;
						end	
         endcase 	
             			
					end
				WAIT_TX_TEST1,
				WAIT_TX_TEST2,
				WAIT_TX_TEST3,
				WAIT_TX_TEST4,
				WAIT_TX_TEST5:
									begin
										isEn <= isEn;
									end
				SENDDELAY:	
				   begin
						isEn <= 1'b0;
						if(tx_rdy == 1'b1)//高开始计数
						begin
							if(bytenum == DATASENDTIME-8'd1)
							begin
								bytenum <= 8'd0;							
							end
							else
							begin
								bytenum <= bytenum + 8'd1;//传送数据计数
							end
						end
						else
						begin
							bytenum <= bytenum;//循环等待
					end
					end					
				
		  endcase
	  end
end

endmodule