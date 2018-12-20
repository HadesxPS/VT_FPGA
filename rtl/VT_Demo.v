//*****************************************************************************
// COPYRIGHT (c) 2015, Xiamen Tianma Microelectronics Co, Ltd
//
// File name     :  VT_Demo.v
// Module name   :  VT_Demo
//
// Author        :  sijian_luo
// Email         :  sijian_luo@tianma.cn
// Version       :  v 1.0
//
// Author        :  weipeng_wang
// Email         :  weipeng_wang@tianma.cn
// Version       :  v 1.1
//
// Function      :  Top module for VT Test
// Called by     :  --
//
// ----------------------------------------------------------------------------
// Revison
// 2015-06-17    :  create file
// 2015-11-17    :  modified for TED
//*****************************************************************************
module VT_Demo(
	input						clk_in            ,
	input						sw1               ,
	input						sw2               ,
	input						sw6					,
	output					en_p14v           ,
	output					en_n14v           ,
	output					en_gvddp          ,
	output					en_gvddn          ,
	output					da1_wr            ,
	output [1:0]			da1_a             ,
	output [7:0]			da1_din           
);

//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
// variable declaration
//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
wire                            clk_sys                         ;
wire                            rst_n_sys                       ;
wire    [7:0]                   dis_sn                          ;
//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
// continuous assignment
//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++


//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
// module instantiation
//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
clkrst u_clkrst(
    .clk_in                     ( clk_in                        ),  //input
    .rst_n_in                   ( sw6                           ),  //input
    .clk_sys                    ( clk_sys                       ),  //output
    .rst_n_sys                  ( rst_n_sys                     )   //output reg
);

switch u_switch (
		.en_p14v							(en_p14v									),
		.en_n14v							(en_n14v									),
		.en_gvddp						(gvddp									),
		.en_gvddn						(gvddn									),
		.clk                        ( clk_sys                       ),  //input
		.rst_n                      ( rst_n_sys                     ),  //input
		.sw1                        ( sw1                           ),  //input
		.sw2                        ( sw2                           ),  //input
		.dis_sn                     ( dis_sn                        )  //output reg
);                                                                                     

//tgen generatie timing
tgen u_tgen(
	.dis_sn								(dis_sn								),
	.clk                        ( clk_sys                       ),  //input
	.rst_n                      ( rst_n_sys                     ),  //input
	.da1_wr                     ( da1_wr                        ),  //output reg
	.da1_a                      ( da1_a                         ),  //output reg [1:0]
	.da1_din                    ( da1_din                       )  //output reg [7:0]
);

//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
// block statement
//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

//-----------------------------------------------------------------------------
// FSM
//-----------------------------------------------------------------------------
endmodule