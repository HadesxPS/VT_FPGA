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
    input                 clk_in            ,
    input                 sw1               ,
    input                 sw2               ,
    input                 sw3               ,
    input                 sw4               ,
	 input                 sw5               ,
    input                 sw6               ,
	
    output                FPGA_LED_Test     ,	
    output                en_p14v           ,
    output                en_n14v           ,
    output                en_gvddp          ,
    output                en_gvddn          ,
    output                en_vgh            ,
    output                en_vgl            ,
	 
	 output                mux_en_Test1      ,
    output                mux_en_Test2      ,
    output                mux_en1           ,
    output                mux_en2           ,
    output                mux_en3           ,
    output                mux_en4           ,	 
	 
    output [1:0]          mux_1             ,
    output [1:0]          mux_2             ,
    output [1:0]          mux_3             ,
    output [1:0]          mux_4             ,
    output [1:0]          mux_5             ,
    output [1:0]          mux_6             ,
    output [1:0]          mux_7             ,
    output [1:0]          mux_8             ,
    output [1:0]          mux_9             ,
    output [1:0]          mux_10            ,
    output [1:0]          mux_11            ,
    output [1:0]          mux_12            ,
    output [1:0]          mux_13            ,
    output [1:0]          mux_14            ,
    output [1:0]          mux_Test1         ,
    output [1:0]          mux_Test2         ,
	 
	 
	 output                da1_wr            ,
	 output                da2_wr            ,
	 output                da3_wr            ,
	 output                da4_wr            ,
	
    output [1:0]          da1_a             ,
	 output [1:0]          da2_a             ,
    output [1:0]          da3_a             ,
	 output [1:0]          da4_a             , 
	 
	 output [7:0]          da1_din           ,
	 output [7:0]          da2_din           ,
	 output [7:0]          da3_din           ,
	 output [7:0]          da4_din           ,
	 
	 
	 output                L_RST             ,
    output                L_CE              ,
    output                L_DC              ,
	 output                L_DIN             ,
    output                L_CLK             
	 
);

//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
// parameters
//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
parameter       PATMIN                      = 7'd0              ;  //minimum pattern number
parameter       PATNUM                      = 7'd12             ;

//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
// variable declaration
//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
wire                            clk_sys                         ;
wire                            rst_n_sys                       ;

wire    [6:0]                   dis_sn                          ;

wire                            grst                            ;
wire                            jdqi                            ;//jdqi

wire                            VTCOMSW1                            ;
wire                            VTCOMSW2                            ;


wire                            u2d                             ;
wire                            d2u                             ;
wire                            stv                             ;
//wire                            stv2                             ;
wire                            ckv1                            ;
wire                            ckv2                            ;
wire                            ckv3                            ;
wire                            ckv4                            ;
wire                            ckhr                            ;
wire                            ckhg                            ;
wire                            ckhb                            ;
//wire                            xckhr                           ;
//wire                            xckhg                           ;
//wire                            xckhb                           ;

wire                            flag_black_on                   ;

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

switch #(
    .CNT1US                     ( 16'd33                       ),
    .PATMIN                     ( PATMIN                        ),
    .PATNUM                     ( PATNUM                        )
) u_switch (
    .clk                        ( clk_sys                       ),  //input
    .rst_n                      ( rst_n_sys                     ),  //input
    .sw1                        ( sw1                           ),  //input
    .sw2                        ( sw2                           ),  //input
    .sw3                        ( sw3                           ),  //input
    .sw4                        ( sw4                           ),  //input
	 .sw5                        ( sw5                           ),  //input
	 
    .dis_sn                     ( dis_sn                        ),  //output reg
	 
	 .FPGA_LED_Test				  ( FPGA_LED_Test                 ),  //output reg
    .en_p14v                    ( en_p14v                       ),  //output reg    
    .en_n14v                    ( en_n14v                       ),  //output reg
    .en_gvddp                   ( en_gvddp                      ),  //output reg    
    .en_gvddn                   ( en_gvddn                      ),  //output reg   	 
    .en_vgh                     ( en_vgh                        ),  //output reg    
    .en_vgl                     ( en_vgl                        ),  //output reg    
  
    .mux_en1                    ( mux_en1                       ),  //output reg     
    .mux_en2                    ( mux_en2                       ),  //output reg       
    .mux_en3                    ( mux_en3                       ),  //output reg    
    .mux_en4                    ( mux_en4                       ),  //output reg   
    .mux_en_Test1               ( mux_en_Test1                  ),  //output reg   	 
    .mux_en_Test2               ( mux_en_Test2                  ),  //output reg   
    
    .flag_black_on              ( flag_black_on                 )   //output reg       
);                                                                                     

//tgen generatie timing
tgen u_tgen(
    .clk                        ( clk_sys                       ),  //input
    .rst_n                      ( rst_n_sys                     ),  //input
    .grst                       ( grst                          ),  //output
	 .jdqi                       ( jdqi                          ),  //output
	 
    .u2d                        ( u2d                           ),  //output
    .d2u                        ( d2u                           ),  //output
    .stv                        ( stv                           ),  //output
	 //.stv2                        ( stv2                           ),  //output
    .ckv1                       ( ckv1                          ),  //output
    .ckv2                       ( ckv2                          ),  //output
//    .ckv3                       ( ckv3                          ),  //output
//    .ckv4                       ( ckv4                          ),  //output
    .ckh1                       ( ckh1                          ),  //output
    .ckh2                       ( ckh2                          ),  //output
    .ckh3                       ( ckh3                          ),  //output
	 .ckh4                       ( ckh4                          ),  //output
    .ckh5                       ( ckh5                          ),  //output
    .ckh6                       ( ckh6                          ),  //output
    .dis_sn                     ( dis_sn                        ),  //input
	 
    .da1_wr                     ( da1_wr                        ),  //output reg
    .da2_wr                     ( da2_wr                        ),  //output reg
	 .da3_wr                     ( da3_wr                        ),  //output reg
	 .da4_wr                     ( da4_wr                        ),  //output reg
	 
	 .da1_a                      ( da1_a                         ),  //output reg [1:0]
	 .da2_a                      ( da2_a                         ),  //output reg [1:0]
	 .da3_a                      ( da3_a                         ),  //output reg [1:0]
	 .da4_a                      ( da4_a                         ),  //output reg [1:0]
	 
    .da1_din                    ( da1_din                       ),  //output reg [7:0]
	 .da2_din                    ( da2_din                       ),  //output reg [7:0]
	 .da3_din                    ( da3_din                       ),  //output reg [7:0]
	 .da4_din                    ( da4_din                       ),  //output reg [7:0]

    .flag_black_on              ( flag_black_on                 )   //input
);

mux_decode u1_mux_decode(
    .clk                        ( clk_sys                       ),  //input
    .da                         ( stv                           ),  //input
    .db                         ( stv                           ),  //input
    .a                          ( mux_1                         )   //output
);

mux_decode u2_mux_decode(
    .clk                        ( clk_sys                       ),  //input
    .da                         ( ckv1                          ),  //input
    .db                         ( ckv1                          ),  //input
    .a                          ( mux_2                         )   //output
);

mux_decode u3_mux_decode(
    .clk                        ( clk_sys                       ),  //input
    .da                         ( 1'b0                          ),  //input
    .db                         ( 1'b0                          ),  //input
    .a                          ( mux_3                         )   //output
);

mux_decode u4_mux_decode(
    .clk                        ( clk_sys                       ),  //input
    .da                         ( ckv2                          ),  //input
    .db                         ( ckv2                          ),  //input
    .a                          ( mux_4                         )   //output
);

mux_decode u5_mux_decode(
    .clk                        ( clk_sys                       ),  //input
    .da                         ( ckh1                          ),  //input
    .db                         ( 1'b0                          ),  //input
    .a                          ( mux_5                         )   //output
);

mux_decode u6_mux_decode(
    .clk                        ( clk_sys                       ),  //input
    .da                         ( ckh2                          ),  //input
    .db                         ( ckh3                          ),  //input
    .a                          ( mux_6                         )   //output
);

mux_decode u7_mux_decode(
    .clk                        ( clk_sys                       ),  //input
    .da                         ( ckh4                          ),  //input
    .db                         ( ckh5                          ),  //input
    .a                          ( mux_7                         )   //output
);

mux_decode u8_mux_decode(
    .clk                        ( clk_sys                       ),  //input
    .da                         ( ckh6                          ),  //input
    .db                         ( 1'b0                          ),  //input
    .a                          ( mux_8                         )   //output
);

mux_decode u9_mux_decode(
    .clk                        ( clk_sys                       ),  //input
    .da                         ( u2d                           ),  //input
    .db                         ( u2d                           ),  //input
    .a                          ( mux_9                         )   //output
);

mux_decode u10_mux_decode(
    .clk                        ( clk_sys                       ),  //input
    .da                         ( d2u                           ),  //input
    .db                         ( d2u                           ),  //input
    .a                          ( mux_10                        )   //output
);

mux_decode u11_mux_decode(
    .clk                        ( clk_sys                       ),  //input
    .da                         ( grst                          ),  //input
    .db                         ( grst                         ),  //input
    .a                          ( mux_11                        )   //output
);

mux_decode u12_mux_decode(
    .clk                        ( clk_sys                       ),  //input
    .da                         ( 1'b1                          ),  //input
    .db                         ( 1'b1                          ),  //input
    .a                          ( mux_12                        )   //output
);

//mux_decode u13_mux_decode(
//    .clk                        ( clk_sys                       ),  //input
//    .da                         ( 1'b1                          ),  //input
//    .db                         ( 1'b1                          ),  //input
//    .a                          ( mux_13                        )   //output
//);

mux_decode u13_mux_decode(
    .clk                        ( clk_sys                       ),  //input
    .da                         ( gas                           ),  //input
    .db                         ( gas                           ),  //input
    .a                          ( mux_13                        )   //output
);

//mux_decode u14_mux_decode(
//    .clk                        ( clk_sys                       ),  //input
//    .da                         ( 1'b1                          ),  //input
//    .db                         ( 1'b1                          ),  //input
//    .a                          ( mux_14                        )   //output
//);
mux_decode u14_mux_decode(
    .clk                        ( clk_sys                       ),  //input
    .da                         ( jdqi                          ),  //input
    .db                         ( 1'b0                          ),  //input
    .a                          ( mux_14                        )   //output
);

mux_decode u15_mux_decode(
    .clk                        ( clk_sys                       ),  //input
    .da                         ( 1'b1                          ),  //input
    .db                         ( 1'b1                          ),  //input
    .a                          ( mux_Test1                     )   //output
);

mux_decode u16_mux_decode(
    .clk                        ( clk_sys                       ),  //input
    .da                         ( 1'b1                          ),  //input
    .db                         ( 1'b1                          ),  //input
    .a                          ( mux_Test2                     )   //output
);


lcd_display u_lcd_display(
    .clk                    	  ( clk_sys                       ),  //input
    .rst_n                      ( rst_n_sys                     ),  //input
	 
	 .lcd_rst                    ( L_RST                     	 ),  //output
	 .lcd_clk                    ( L_CLK                     	 ),  //output
	 
	 .lcd_ce                     ( L_CE                     		 ),  //output
	 .lcd_dc	                    ( L_DC                     		 ),  //output
	 .lcd_din                    ( L_DIN                     	 )   //output

	 
);
//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
// block statement
//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

//-----------------------------------------------------------------------------
// FSM
//-----------------------------------------------------------------------------


endmodule