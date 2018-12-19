//*****************************************************************************
// COPYRIGHT (c) 2013, Xiamen Tianma Microelectronics Co, Ltd
//
// File name     :  tgen.v
// Module name   :  tgen
//
// Author        :  sijian_luo
// Email         :  sijian_luo@tianma.cn
// Version       :  v 1.0
//
// Author        :  weipeng_wang
// Email         :  weipeng_wang@tianma.cn
// Version       :  v 1.1
//
// Function      :  Generate VSR timing
// Called by     :  --
//
// ----------------------------------------------------------------------------
// Revison
// 2014-08-01    :  create file
//*****************************************************************************
module tgen(
	input				[7:0]		dis_sn				,
	input							clk               ,
	input							rst_n             ,
	output	reg				da1_wr            ,
	output	reg	[1:0]		da1_a             ,
	output	reg	[7:0]		da1_din				
);

//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
// parameters
//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
parameter			DCODE_WHITE			= 8'd242                    ;   //DA input for white (grayscale=255)
parameter			DCODE_BLACK			= 8'd133                    ;   //DA input for black (grayscale=0)
parameter			DCODE_VCOM			= 8'd124                    ;   //DA input for vcom
parameter			DCODE_GND			= 8'd128                    ;   //DA input for GND
parameter			DCODE_GRAY128		= 8'd195                    ;   //DA input for gray pattern
parameter			DCODE_GRAY64		= 8'd182                    ;   //DA input for gray pattern
parameter			DCODE_VCOMA			= 8'd132                    ;   //DA input for VCOMA
parameter			DCODE_VCOMB			= 8'd170                    ;   //DA input for VCOMB


//-----------------------------------------------------------------------------
// D/A processing - source data generation
//-----------------------------------------------------------------------------
always @(posedge clk or negedge rst_n)
begin
	if (rst_n == 1'b0)
	begin
		da1_wr <= 1'b1;
	end
	else
	begin
		da1_wr <= 1'b0;
	end
end


always @(posedge clk or negedge rst_n)
begin
	if (rst_n == 1'b0)
	begin
		da1_a <= 2'b00;
		da1_din <=8'd128;
	end
	else
	begin
		da1_din <=dis_sn;
	end
end
endmodule