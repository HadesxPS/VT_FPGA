//*****************************************************************************
// COPYRIGHT (c) 2015, Xiamen Tianma Microelectronics Co, Ltd
//
// File name     :  lcd_display.v
// Module name   :  lcd_display
//
// Author        :  weipeng_wang
// Email         :  weipeng_wang@tianma.cn
// Version       :  v 1.0
//
// Function      :  Display 
// Called by     :  --
//
// ----------------------------------------------------------------------------
// Revison
// 2015-06-25    :  create file
//*****************************************************************************
module lcd_display(
    input                 clk		               ,
    input                 rst_n            		,
	 
    output                lcd_rst               ,
    
	 output reg            lcd_clk               ,	 
    output reg            lcd_ce            		,
	 output reg            lcd_dc           		,
	 output reg            lcd_din         		   
	 
);

	reg[7:0] cnt;  //分频计数器
// reg clk_1M;    //分频时钟
	
	reg[1:0] p;  //状态机1定义
   reg[2:0] p2; //状态机2定义
   reg[2:0] p_back; //状态返回
	
   parameter clk_l=2'd0;
   parameter clk_h=2'd1;
   parameter clk_rising_edge=2'd2;
   parameter clk_falling_edge=2'd3;

   parameter idle=3'd0;
   parameter shift_data=3'd1;
   parameter shift_data1=3'd2;
   parameter clear_screen=3'd3;
   parameter set_xy=3'd4;
   parameter disp_char=3'd5;

   reg[7:0]  data_reg; //数据寄存器
   reg[3:0]  cnt2;     //移位计数器
   reg[15:0] cnt3;     //状态计数器
   reg[8:0]  cnt4;     //状态计数器
   reg[7:0]  char_reg; //字符寄存器

   reg[2:0] y_reg;   //坐标寄存器
   reg[6:0] x_reg;
 
   reg[0:47] mem[122:0];  //字符库
   reg[0:47] temp;       //字符暂存
   parameter ONN =1'b0;
   parameter OFF =1'b1;
   parameter CMD =1'b0;
   parameter DATA =1'b1;

////////////////////////////////////////////////
initial
  begin
		p=0;
   
	mem[32]= {8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00};   // 32  sp 
	mem[33]= {8'h00, 8'h00, 8'h00, 8'h2f, 8'h00, 8'h00};   // 33  !  
	 mem[34]= {8'h00, 8'h00, 8'h07, 8'h00, 8'h07, 8'h00};   // 34  ''
    mem[35]= {8'h00, 8'h14, 8'h7f, 8'h14, 8'h7f, 8'h14};   // 35  #
    mem[36]= {8'h00, 8'h24, 8'h2a, 8'h7f, 8'h2a, 8'h12};   // 36  $
    mem[37]= {8'h00, 8'h62, 8'h64, 8'h08, 8'h13, 8'h23};   // 37  %
    mem[38]= {8'h00, 8'h36, 8'h49, 8'h55, 8'h22, 8'h50};   //38  &
    mem[39]= {8'h00, 8'h00, 8'h05, 8'h03, 8'h00, 8'h00};   // 39  '
    mem[40]= {8'h00, 8'h00, 8'h1c, 8'h22, 8'h41, 8'h00};   // 40  (
    mem[41]= {8'h00, 8'h00, 8'h41, 8'h22, 8'h1c, 8'h00};   // 41  )
    mem[42]= {8'h00, 8'h14, 8'h08, 8'h3E, 8'h08, 8'h14};   // 42 *
    mem[43]= {8'h00, 8'h08, 8'h08, 8'h3E, 8'h08, 8'h08};   // 43 +
    mem[44]= {8'h00, 8'h00, 8'h00, 8'hA0, 8'h60, 8'h00};   // 44 ,
    mem[45]= {8'h00, 8'h08, 8'h08, 8'h08, 8'h08, 8'h08};   // 45 -
    mem[46]= {8'h00, 8'h00, 8'h60, 8'h60, 8'h00, 8'h00};   // 46 .
    mem[47]= {8'h00, 8'h20, 8'h10, 8'h08, 8'h04, 8'h02};   // 47 /
    mem[48]= {8'h00, 8'h3E, 8'h51, 8'h49, 8'h45, 8'h3E};   // 48 0
    mem[49]= {8'h00, 8'h00, 8'h42, 8'h7F, 8'h40, 8'h00};   // 49 1
    mem[50]= {8'h00, 8'h42, 8'h61, 8'h51, 8'h49, 8'h46};   // 50 2
    mem[51]= {8'h00, 8'h21, 8'h41, 8'h45, 8'h4B, 8'h31};   // 51 3
    mem[52]= {8'h00, 8'h18, 8'h14, 8'h12, 8'h7F, 8'h10};   // 52 4
    mem[53]= {8'h00, 8'h27, 8'h45, 8'h45, 8'h45, 8'h39};   // 53 5
    mem[54]= {8'h00, 8'h3C, 8'h4A, 8'h49, 8'h49, 8'h30};   // 54 6
    mem[55]= {8'h00, 8'h01, 8'h71, 8'h09, 8'h05, 8'h03};   // 55 7
    mem[56]= {8'h00, 8'h36, 8'h49, 8'h49, 8'h49, 8'h36};   // 56 8
    mem[57]= {8'h00, 8'h06, 8'h49, 8'h49, 8'h29, 8'h1E};   // 57 9
    mem[58]= {8'h00, 8'h00, 8'h36, 8'h36, 8'h00, 8'h00};   // 58 :
    mem[59]= {8'h00, 8'h00, 8'h56, 8'h36, 8'h00, 8'h00};   // 59 ;
    mem[60]= {8'h00, 8'h08, 8'h14, 8'h22, 8'h41, 8'h00};   // 60 <
    mem[61]= {8'h00, 8'h14, 8'h14, 8'h14, 8'h14, 8'h14};   // 61 =
    mem[62]= {8'h00, 8'h00, 8'h41, 8'h22, 8'h14, 8'h08};   // 62 >
    mem[63]= {8'h00, 8'h02, 8'h01, 8'h51, 8'h09, 8'h06};   // 63 ?
    mem[64]= {8'h00, 8'h32, 8'h49, 8'h59, 8'h51, 8'h3E};   // 64 @
    mem[65]= {8'h00, 8'h7C, 8'h12, 8'h11, 8'h12, 8'h7C};   // 65 A
    mem[66]= {8'h00, 8'h7F, 8'h49, 8'h49, 8'h49, 8'h36};   // 66 B
    mem[67]= {8'h00, 8'h3E, 8'h41, 8'h41, 8'h41, 8'h22};   // 67 C
    mem[68]= {8'h00, 8'h7F, 8'h41, 8'h41, 8'h22, 8'h1C};   // 68 D
    mem[69]= {8'h00, 8'h7F, 8'h49, 8'h49, 8'h49, 8'h41};   // 69 E
    mem[70]= {8'h00, 8'h7F, 8'h09, 8'h09, 8'h09, 8'h01};   // 70 F
    mem[71]= {8'h00, 8'h3E, 8'h41, 8'h49, 8'h49, 8'h7A};   // 71 G
    mem[72]= {8'h00, 8'h7F, 8'h08, 8'h08, 8'h08, 8'h7F};   // 72 H
    mem[73]= {8'h00, 8'h00, 8'h41, 8'h7F, 8'h41, 8'h00};   // 73 I
    mem[74]= {8'h00, 8'h20, 8'h40, 8'h41, 8'h3F, 8'h01};   // 74 J
    mem[75]= {8'h00, 8'h7F, 8'h08, 8'h14, 8'h22, 8'h41};   // 75 K
    mem[76]= {8'h00, 8'h7F, 8'h40, 8'h40, 8'h40, 8'h40};   // 76 L
    mem[77]= {8'h00, 8'h7F, 8'h02, 8'h0C, 8'h02, 8'h7F};   // 77 M
    mem[78]= {8'h00, 8'h7F, 8'h04, 8'h08, 8'h10, 8'h7F};   // 78 N
    mem[79]= {8'h00, 8'h3E, 8'h41, 8'h41, 8'h41, 8'h3E};   // 79 O
    mem[80]= {8'h00, 8'h7F, 8'h09, 8'h09, 8'h09, 8'h06};   // 80 P
    mem[81]= {8'h00, 8'h3E, 8'h41, 8'h51, 8'h21, 8'h5E};   // 81 Q
    mem[82]= {8'h00, 8'h7F, 8'h09, 8'h19, 8'h29, 8'h46};   // 82 R
    mem[83]= {8'h00, 8'h46, 8'h49, 8'h49, 8'h49, 8'h31};   // 83 S
    mem[84]= {8'h00, 8'h01, 8'h01, 8'h7F, 8'h01, 8'h01};   // 84 T
    mem[85]= {8'h00, 8'h3F, 8'h40, 8'h40, 8'h40, 8'h3F};   // 85 U
    mem[86]= {8'h00, 8'h1F, 8'h20, 8'h40, 8'h20, 8'h1F};   // 86 V
    mem[87]= {8'h00, 8'h3F, 8'h40, 8'h38, 8'h40, 8'h3F};   // 87 W
    mem[88]= {8'h00, 8'h63, 8'h14, 8'h08, 8'h14, 8'h63};   // 88 X
    mem[89]= {8'h00, 8'h07, 8'h08, 8'h70, 8'h08, 8'h07};   // 89 Y
    mem[90]= {8'h00, 8'h61, 8'h51, 8'h49, 8'h45, 8'h43};   // 90 Z
    mem[91]= {8'h00, 8'h00, 8'h7F, 8'h41, 8'h41, 8'h00};   // 91 [
	mem[93]= {8'h00, 8'h00, 8'h41, 8'h41, 8'h7F, 8'h00};   // 93 ]
    mem[94]= {8'h00, 8'h04, 8'h02, 8'h01, 8'h02, 8'h04};   // 94 ^
    mem[95]= {8'h00, 8'h40, 8'h40, 8'h40, 8'h40, 8'h40};   // 95 _
	 mem[96]= {8'h00, 8'h00, 8'h01, 8'h02, 8'h04, 8'h00};   // 96 `
    mem[97]= {8'h00, 8'h20, 8'h54, 8'h54, 8'h54, 8'h78};   // 97 a
    mem[98]= {8'h00, 8'h7F, 8'h48, 8'h44, 8'h44, 8'h38};   // 98 b
    mem[99]= {8'h00, 8'h38, 8'h44, 8'h44, 8'h44, 8'h20};   // 99 c
    mem[100]= {8'h00, 8'h38, 8'h44, 8'h44, 8'h48, 8'h7F};   // 100 d
    mem[101]= {8'h00, 8'h38, 8'h54, 8'h54, 8'h54, 8'h18};   // 101 e
    mem[102]= {8'h00, 8'h08, 8'h7E, 8'h09, 8'h01, 8'h02};   // 102 f
    mem[103]= {8'h00, 8'h18, 8'hA4, 8'hA4, 8'hA4, 8'h7C};   // 103 g
    mem[104]= {8'h00, 8'h7F, 8'h08, 8'h04, 8'h04, 8'h78};   // 104 h
    mem[105]= {8'h00, 8'h00, 8'h44, 8'h7D, 8'h40, 8'h00};   // 105 i
    mem[106]= {8'h00, 8'h40, 8'h80, 8'h84, 8'h7D, 8'h00};   // 106 j
    mem[107]= {8'h00, 8'h7F, 8'h10, 8'h28, 8'h44, 8'h00};   // 107 k
    mem[108]= {8'h00, 8'h00, 8'h41, 8'h7F, 8'h40, 8'h00};   // 108 l
    mem[109]= {8'h00, 8'h7C, 8'h04, 8'h18, 8'h04, 8'h78};   // 109 m
    mem[110]= {8'h00, 8'h7C, 8'h08, 8'h04, 8'h04, 8'h78};   // 110 n
    mem[111]= {8'h00, 8'h38, 8'h44, 8'h44, 8'h44, 8'h38};   // 111 o
    mem[112]= {8'h00, 8'hFC, 8'h24, 8'h24, 8'h24, 8'h18};   // 112 p
    mem[113]= {8'h00, 8'h18, 8'h24, 8'h24, 8'h18, 8'hFC};   // 113 q
    mem[114]= {8'h00, 8'h7C, 8'h08, 8'h04, 8'h04, 8'h08};   // 114 r
    mem[115]= {8'h00, 8'h48, 8'h54, 8'h54, 8'h54, 8'h20};   // 115 s
    mem[116]= {8'h00, 8'h04, 8'h3F, 8'h44, 8'h40, 8'h20};   // 116 t
    mem[117]= {8'h00, 8'h3C, 8'h40, 8'h40, 8'h20, 8'h7C};   // 117 u
    mem[118]= {8'h00, 8'h1C, 8'h20, 8'h40, 8'h20, 8'h1C};   // 118 v
    mem[119]= {8'h00, 8'h3C, 8'h40, 8'h30, 8'h40, 8'h3C};   // 119 w
    mem[120]= {8'h00, 8'h44, 8'h28, 8'h10, 8'h28, 8'h44};   // 120 x
    mem[121]= {8'h00, 8'h1C, 8'hA0, 8'hA0, 8'hA0, 8'h7C};   // 121 y
    mem[122]= {8'h00, 8'h44, 8'h64, 8'h54, 8'h4C, 8'h44};   // 122 z
   
  end 


assign lcd_rst = 1;


always@(posedge clk ) //时钟分频
begin
	if(!rst_n) 
     begin	
        cnt <= 8'd0;
		end
	else 
		begin
			cnt <= cnt + 8'd1;  
			if(cnt == 8'd148)   //产生1MHz时钟
				cnt <= 8'd0;
			if(cnt < 8'd74)  
				lcd_clk<=0;
			else
				lcd_clk<=1;
		end
  end



always@(posedge clk )//状态机1切换
begin
	if(!rst_n)  
    p<=clk_l;
    else
    case (p)
		 clk_l: 
		 begin
			  if (lcd_clk)
			  p<=clk_rising_edge;  //CLK低电平
			  else 
			  p<=clk_l;
		 end
		 
		 clk_rising_edge: 
		 begin
				p<=clk_h;  //CLK上升沿
		 end
		 
		 clk_h: 
		 begin                 
		  if (!lcd_clk)        //CLK高电平
			 p<=clk_falling_edge;
		  else p<=clk_h;
		 end 
		 
		clk_falling_edge: 
		begin
		 p<=clk_l;  //CLK下降沿
		end
		default;
	endcase
end

always@(posedge clk )      //状态机2切换
begin
	if(!rst_n) 
	begin 
    p2<=idle;
    lcd_ce<=OFF;
    cnt3 <= 16'd0;
    end
    else
    case (p2)
    idle: begin
	      lcd_ce<=OFF;
          cnt3 <= cnt3 + 16'd1;
          case(cnt3)
			0:  begin data_reg<=8'h21;lcd_dc<=CMD;p2<=shift_data;p_back<=idle; end
	      1:  begin data_reg<=8'hc8;lcd_dc<=CMD;p2<=shift_data;p_back<=idle; end
	      2:  begin data_reg<=8'h06;lcd_dc<=CMD;p2<=shift_data;p_back<=idle; end
	      3:  begin data_reg<=8'h13;lcd_dc<=CMD;p2<=shift_data;p_back<=idle; end
	      4:  begin data_reg<=8'h20;lcd_dc<=CMD;p2<=shift_data;p_back<=idle; end
	      5:  begin p2<=clear_screen;p_back<=clear_screen; end
	      6:  begin data_reg<=8'h0c;lcd_dc<=CMD;p2<=shift_data;p_back<=idle; end
	      7:  begin p2<=set_xy;p_back<=set_xy;y_reg<=3'b000; x_reg<=7'b0000110; end
			
			//*******************fxl******************************//
			8: begin p2<=disp_char;p_back<=disp_char;char_reg="T";  end
	      9: begin p2<=disp_char;p_back<=disp_char;char_reg="E"; 	end
			10: begin p2<=disp_char;p_back<=disp_char;char_reg="0";  end
	      11: begin p2<=disp_char;p_back<=disp_char;char_reg="6"; 	end
			12: begin p2<=disp_char;p_back<=disp_char;char_reg="3";  end
			13: begin p2<=disp_char;p_back<=disp_char;char_reg="X";  end
			14: begin p2<=disp_char;p_back<=disp_char;char_reg="V";  end
			15: begin p2<=disp_char;p_back<=disp_char;char_reg="X"; 	end
			16: begin p2<=disp_char;p_back<=disp_char;char_reg="S";  end
			17: begin p2<=disp_char;p_back<=disp_char;char_reg="0"; 	end
	      18: begin p2<=disp_char;p_back<=disp_char;char_reg="4"; 	end
	      //*******************fxl******************************//
	      19: begin p2<=set_xy;p_back<=set_xy;y_reg<=3'b011;x_reg<=7'b0000111; end		

	      20: begin p2<=disp_char;p_back<=disp_char;char_reg="1"; 	end
	      21: begin p2<=disp_char;p_back<=disp_char;char_reg="9"; 	end
	      22: begin p2<=disp_char;p_back<=disp_char;char_reg="D";  end
			23: begin p2<=disp_char;p_back<=disp_char;char_reg="O";  end
	      24: begin p2<=disp_char;p_back<=disp_char;char_reg="E"; 	end
	      25: begin p2<=disp_char;p_back<=disp_char;char_reg="-"; 	end
	      26: begin p2<=disp_char;p_back<=disp_char;char_reg="6";  end
			27: begin p2<=disp_char;p_back<=disp_char;char_reg="M"; 	end
	      28: begin p2<=disp_char;p_back<=disp_char;char_reg="U";  end
			29: begin p2<=disp_char;p_back<=disp_char;char_reg="X";  end
			30: begin p2<=set_xy;p_back<=set_xy;y_reg<=3'b011;x_reg<=7'b0000111; end		
			
	      31: begin p2<=disp_char;p_back<=disp_char;char_reg="V"; 	end
	      32: begin p2<=disp_char;p_back<=disp_char;char_reg="T"; 	end
	      33: begin p2<=disp_char;p_back<=disp_char;char_reg="2";  end
			34: begin p2<=disp_char;p_back<=disp_char;char_reg="_";  end
	      35: begin p2<=disp_char;p_back<=disp_char;char_reg="V"; 	end
	      36: begin p2<=disp_char;p_back<=disp_char;char_reg="1"; 	end
	      37: begin p2<=disp_char;p_back<=disp_char;char_reg="P";  end
			37: begin p2<=disp_char;p_back<=disp_char;char_reg="0";  end
	      38: begin cnt3 <= 16'd39; end
			 
	      default;
	      endcase
	      end
	      
    shift_data :     //下降沿数据输出
                begin
						if (p==clk_falling_edge)  
						if (cnt2 == 4'd8)  
							begin
								cnt2 <= 4'd0;
								p2<=p_back;
							end
						else
							begin
								p2<=shift_data1; 
								lcd_ce<=ONN;
								lcd_din<=data_reg[7];          //将数据寄存器最高位发出 
							end 
						else 
							p2<=shift_data;
	             end
    
    shift_data1:
                 begin                
						  if (p==clk_rising_edge)    //上升沿数据移位
							 begin  
							  data_reg<={data_reg[6:0], data_reg[7]};  //数据高位移位
							  cnt2 <= cnt2 + 4'd1;
							  p2<=shift_data;
							 end
						  else 
								p2<=shift_data1;
                 end
     
     
    clear_screen:           //清屏
                begin            
						data_reg<=8'h00;
						cnt4 <= cnt4 + 9'd1;
						lcd_ce<=OFF;
						lcd_dc<=DATA;
						if (cnt4 == 9'd504) 
							begin
							cnt4 <= 9'd0;
							p2<=idle;
							end
						else 
							p2<=shift_data;
					 end

     set_xy:           //设置X，Y方向坐标
              begin 
					cnt4<=cnt4+9'd1;
					lcd_ce<=OFF;
					lcd_dc<=CMD;
						case (cnt4)
							0 : begin data_reg<=(8'h40 | y_reg); p2<=shift_data; end
							1 : begin data_reg<=(8'h80 | x_reg); p2<=shift_data; end
							2 : begin p2<=idle; cnt4<=9'd0; end
						default;
						endcase
               end   
                  
     disp_char:        //字符从字符库读入
              begin
					cnt4<=cnt4+9'd1;
					lcd_ce<=OFF;
					lcd_dc<=DATA;
					if (cnt4==9'd6) 
						begin
							p2<=idle;
							cnt4<=9'd0; 
						end
					else 
						begin
								temp=mem[char_reg];
							case (cnt4)
							0 :  data_reg<=temp[0:7];
							1 :  data_reg<=temp[8:15];
							2 :  data_reg<=temp[16:23];
							3 :  data_reg<=temp[24:31];
							4 :  data_reg<=temp[32:39];
							5 :  data_reg<=temp[40:47];						
							default;
							endcase
								p2<=shift_data;
							end
              end    
     default;
     endcase
end

endmodule
