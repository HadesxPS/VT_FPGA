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
    input                 clk               ,
    input                 rst_n             ,
    output reg            grst              ,
	 
	 output reg            VTCOMSW1          ,
	 output reg            VTCOMSW2          ,
	 
    output reg            u2d               ,
    output reg            d2u               ,
    output                stv1              ,
    output                stv2              ,
    output                ckv1              ,
    output                ckv2              ,
    output                ckv3              ,
    output                ckv4              ,
    output reg            ckhr              ,
    output reg            ckhg              ,
    output reg            ckhb              ,
//    output reg            xckhr             ,
//    output reg            xckhg             ,
//    output reg            xckhb             ,
    input      [6:0]      dis_sn            ,
	 
    output reg            da1_wr            ,
	 output reg            da2_wr            ,
	 output reg            da3_wr            ,
	 output reg            da4_wr            ,
	 
    output reg [1:0]      da1_a             ,
	 output reg [1:0]      da2_a             ,
	 output reg [1:0]      da3_a             ,
	 output reg [1:0]      da4_a             ,
	 
    output reg [7:0]      da1_din           ,
	 output reg [7:0]      da2_din           ,
	 output reg [7:0]      da3_din           ,
	 output reg [7:0]      da4_din           ,
	 
    input                 flag_black_on
);

//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
// parameters
//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//FSM
parameter       IDLE                = 3'd0                      ;
parameter       GRST                = 3'd1                      ;
parameter       VBP                 = 3'd2                      ;
parameter       PCH                 = 3'd3                      ;  //pre-charge
parameter       DISPLAY             = 3'd4                      ;
parameter       VFP                 = 3'd5                      ;

//for timing control
parameter       NUM_CLK_GRST        = 32'd5                     ;  //number of clocks during reset

parameter       H_ACT               = 12'd1080                  ;
parameter       H_BP                = 12'd45                    ;  //including HPW  95
parameter       H_FP                = 12'd45                    ;  //               50

parameter       V_BP                = 12'd12                    ;  //including VPW
parameter       V_FP                = 12'd7                     ;
parameter       V_ACT               = 12'd2340                   ; // for 6.3 FHD+ NMOS TED

parameter       V_PCH               = 12'd20                    ;//10

parameter       H_ABGN              = H_BP                      ;
parameter       H_AEND              = H_BP + H_ACT              ;
parameter       H_TOTAL             = H_BP + H_ACT + H_FP       ;

parameter       GAP_VDIV64          = 8'd30                     ;

parameter       STV1_WIDTH           = 12'd1                     ;   //stv width. unit: line
parameter       STV1_TOTAL_DIRE      = 1'b1                      ;   //1'b1 - stv shift left; 1'b0 - stv shift right
parameter       STV1_TOTAL_SHIFT     = 12'd3                     ;   //stv shift offset, unit: lines
parameter       STV1_RISE_DIRE       = 1'b1                      ;   //stv rising edge shift direction. 1'b1 - left; 1'b0 - right
parameter       STV1_RISE_SHIFT      = 12'd76                    ;   //stv rising edge shift offset. unit: pclk
parameter       STV1_FALL_DIRE       = 1'b1                      ;   //stv rising edge shift direction. 1'b1 - left; 1'b0 - right
parameter       STV1_FALL_SHIFT      = 12'd1                     ;   //stv rising edge shift offset. unit: pclk

parameter       STV2_WIDTH           = 12'd1                     ;   //stv width. unit: line
parameter       STV2_TOTAL_DIRE      = 1'b1                      ;   //1'b1 - stv shift left; 1'b0 - stv shift right
parameter       STV2_TOTAL_SHIFT     = 12'd2                     ;   //stv shift offset, unit: lines
parameter       STV2_RISE_DIRE       = 1'b1                      ;   //stv rising edge shift direction. 1'b1 - left; 1'b0 - right
parameter       STV2_RISE_SHIFT      = 12'd76                    ;   //stv rising edge shift offset. unit: pclk
parameter       STV2_FALL_DIRE       = 1'b1                      ;   //stv rising edge shift direction. 1'b1 - left; 1'b0 - right
parameter       STV2_FALL_SHIFT      = 12'd1                     ;   //stv rising edge shift offset. unit: pclk

parameter       CKV_RISE_SHIFT     = 12'd57                     ;   //ckv rising edge shift offset. unit: pclk. shift right
parameter       CKV_FALL_SHIFT     = 12'd57                     ;   //ckv falling edge shift offset. unit: pclk. shift left

parameter       CKH_PRE_GAP         = 12'd10                    ;   //gap befor CKH processing.
parameter       CKH_WIDTH           = 12'd300                   ;   //ckh width. unit: pclk
parameter       CKH_RISE_SHIFT      = 12'd45                    ;   //gap before rising edge of ckh. reference point: rising edge of ckv
parameter       CKH_FALL_SHIFT      = 12'd45                    ;   //gap after falling edge of ckh

//for pattern generation
parameter       DCODE_WHITE         = 8'd255                    ;   //DA input for white (grayscale=255)
parameter       DCODE_BLACK         = 8'd133                    ;   //DA input for black (grayscale=0)
parameter       DCODE_VCOM          = 8'd124                    ;   //DA input for vcom
parameter       DCODE_GND           = 8'd128                    ;   //DA input for GND
parameter       DCODE_GRAY128       = 8'd195                    ;   //DA input for gray pattern
parameter       DCODE_GRAY64        = 8'd182                    ;   //DA input for gray pattern

parameter       DCODE_VCOMA       	= 8'd132                    ;   //DA input for VCOMA
parameter       DCODE_VCOMB        	= 8'd242                    ;   //DA input for VCOMB
parameter       SRC_PCH_SHIFT       = 8'd100                    ;   //source precharge time
                                                                    //DA output tansition time: 1.4us, about 120 clk_sys period
                                                                    //constraint: 
                                                                    //1. (CKV1_RISE_SHIFT + CKH_PRE_GAP + CKH_RISE_SHIFT) > SRC_PCH_SHIFT
                                                                    //2. (CKH_RISE_SHIFT + CKH_FALL_SHIFT) > SRC_PCH_SHIFT
parameter       ODD_EVEN_TGAP       = 8'd5                      ;   //DA transition gap for odd and even source output


//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
// variable declaration
//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
reg     [2:0]                   cs_ctrl                         ;
reg     [2:0]                   ns_ctrl                         ;

wire                            en_hcnt                         ;
wire                            en_vblank                       ;
wire                            en_vact                         ;
wire                            flag_hend                       ;

reg     [11:0]                  num_vblank                      ;  //total lines for various blank area
reg     [11:0]                  hcnt                            ;
reg     [11:0]                  cnt_vblank                      ;
reg     [11:0]                  cnt_vact                        ;
reg     [31:0]                  cnt_clk_grst                    ;

reg     [7:0]                   cnt_vdiv64                      ;  //display area divided to 64 areas in vertical direction
reg     [5:0]                   num_vdiv64                      ;  //960/64=15  1920/64=30  2560/64=40

reg                             ckv1_pre                        ;
reg                             ckv2_pre                        ;
reg                             ckv3_pre                        ;
reg                             ckv4_pre                        ;
reg                             stv1_pre                        ;
reg                             stv2_pre                        ;
//for pattern generation
reg     [6:0]                   smp_dis_sn                      ;
wire                            flag_pch                        ;
reg     [23:0]                  pat_blc_wht_h                   ;  //1st half(up) black, 2nd half(down) white
reg     [23:0]                  pat_wht_blc_h                   ;  //1st half(up) white, 2nd half(down) black

reg     [7:0]                   r_data                          ;
reg     [7:0]                   g_data                          ;
reg     [7:0]                   b_data                          ;

reg                             flag_frm_pol                    ;  //frame is odd or even. 1'b0 - odd; 1'b1 - even


wire                            flag_rev_scan                   ;  //1'b1 - reverse scan ;  1'b0 - normal scan 
wire                            flag_TP_test_a                    ;  //1'b1 - TP_test_pattern ;  1'b0 - normal pattern
wire                            flag_TP_test_b                    ;  //1'b1 - TP_test_pattern ;  1'b0 - normal pattern
wire                            flag_inversion                  ;  //1'b1 - frame inversion ;  1'b0 - column inversion         

wire                            is_demux_all_on                 ;
wire                            is_sof_vblank                   ;

//wire                            flag_pat_r                      ;
//wire                            flag_pat_g                      ;
//wire                            flag_pat_b                      ;

//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
// continuous assignment
//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//assign u2d = 1'b1;
//assign d2u = 1'b0;

assign en_hcnt = (cs_ctrl == VBP) || (cs_ctrl == PCH) || (cs_ctrl == DISPLAY) || (cs_ctrl == VFP);
assign en_vblank = (cs_ctrl == VBP) || (cs_ctrl == PCH) || (cs_ctrl == VFP);
assign en_vact = (cs_ctrl == DISPLAY);
assign flag_hend = (hcnt == H_TOTAL - 12'd1);
assign flag_pch = (((smp_dis_sn == 7'd3) || (smp_dis_sn == 7'd4)) && (cnt_vact == 1170)); //for 6.3 FHD+ NMOS TED


//assign flag_pch = 1'b0;
assign is_sof_vblank = (cs_ctrl == PCH) && (cnt_vact == 12'd0);

//assign is_demux_all_on = (smp_dis_sn == 7'd2);
assign is_demux_all_on = 1'b0;

//assign flag_rev_scan = (smp_dis_sn == 7'd2) ;  //1'b1 - reverse scan ;  1'b0 - normal scan
assign flag_rev_scan = 1'b0; 
assign flag_TP_test_a = (smp_dis_sn == 7'd9) ;  //1'b1 - TP_test_pattern ;  1'b0 - normal pattern
assign flag_TP_test_b = (smp_dis_sn == 7'd10) ;  //1'b1 - TP_test_pattern ;  1'b0 - normal pattern
assign flag_inversion = 1'b0; 

assign ckv1 = (flag_rev_scan == 1'b0) ? ckv1_pre : ckv1_pre;
assign ckv2 = (flag_rev_scan == 1'b0) ? ckv2_pre : ckv2_pre;
assign ckv3 = (flag_rev_scan == 1'b0) ? ckv3_pre : ckv3_pre;
assign ckv4 = (flag_rev_scan == 1'b0) ? ckv4_pre : ckv4_pre;

assign stv1 = (flag_rev_scan == 1'b0) ? stv1_pre : stv1_pre;
assign stv2 = (flag_rev_scan == 1'b0) ? stv2_pre : stv2_pre;

//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
// module instantiation
//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
// block statement
//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

//-----------------------------------------------------------------------------
// FSM
//-----------------------------------------------------------------------------
always @(posedge clk or negedge rst_n)
begin
    if(rst_n == 1'b0)
    begin
        cs_ctrl <= IDLE;
    end
    else
    begin
        cs_ctrl <= ns_ctrl;
    end
end

always @(*)
begin
    case (cs_ctrl)
        IDLE:
        begin
            ns_ctrl = GRST;
        end
        GRST:
        begin
            if (cnt_clk_grst == NUM_CLK_GRST - 32'd1)
            begin
                ns_ctrl = VBP;
            end
            else
            begin
                ns_ctrl = GRST;
            end
        end
        VBP:
        begin
            if ((flag_hend == 1'b1) && (cnt_vblank == V_BP - 12'd1))
            begin
//                if (flag_pch == 1'b1)
//                begin
//                    ns_ctrl = PCH;
//                end
//                else
//                begin
//                    ns_ctrl = DISPLAY;
//                end
                ns_ctrl = PCH;
            end
            else
            begin
                ns_ctrl = VBP;
            end
        end
        PCH:
        begin
            if ((flag_hend == 1'b1) && (cnt_vblank == V_PCH - 12'd1))
            begin
                ns_ctrl = DISPLAY;
            end
            else
            begin
                ns_ctrl = PCH;
            end
        end
        DISPLAY:
        begin
            if (flag_hend == 1'b1)
            begin
                if (cnt_vact == V_ACT - 12'd1)
                begin
                    ns_ctrl = VFP;
                end
                else if (flag_pch == 1'b1)
                begin
                    ns_ctrl = PCH;
                end
                else
                begin
                    ns_ctrl = DISPLAY;
                end
            end
            else
            begin
                ns_ctrl = DISPLAY;
            end
        end
        VFP:
        begin
            if ((flag_hend == 1'b1) && (cnt_vblank == V_FP - 12'd1))
            begin
                ns_ctrl = VBP;
            end
            else
            begin
                ns_ctrl = VFP;
            end
        end
    endcase
end

//-----------------------------------------------------------------------------
// various counter for timing constrain
//-----------------------------------------------------------------------------
//horizontal counter
always @(posedge clk or negedge rst_n)
begin
    if (rst_n == 1'b0)
    begin
        hcnt <= 12'd0;
    end
    else
    begin
        if (en_hcnt == 1'b0)
        begin
            hcnt <= 12'd0;
        end
        else
        begin
            if (flag_hend == 1'b1)
            begin
                hcnt <= 12'd0;
            end
            else
            begin
                hcnt <= hcnt + 12'd1;
            end
        end
    end
end

//line counter for blank area
always @(*)
begin
    case (cs_ctrl)
        VFP:
        begin
            num_vblank = V_FP;
        end
        PCH:
        begin
            num_vblank = V_PCH;
        end
        VBP:
        begin
            num_vblank = V_BP;
        end
        default:
        begin
            num_vblank = 12'd1;
        end
    endcase
end

always @(posedge clk or negedge rst_n)
begin
    if (rst_n == 1'b0)
    begin
        cnt_vblank <= 12'd0;
    end
    else
    begin
        if (en_vblank == 1'b0)
        begin
            cnt_vblank <= 12'd0;
        end
        else
        begin
            if (flag_hend == 1'b1)
            begin
                if (cnt_vblank == num_vblank - 12'd1)
                begin
                    cnt_vblank <= 12'd0;
                end
                else
                begin
                    cnt_vblank <= cnt_vblank + 12'd1;
                end
            end
        end
    end
end

//line counter for active area
always @(posedge clk or negedge rst_n)
begin
    if (rst_n == 1'b0)
    begin
        cnt_vact <= 12'd0;
    end
    else
    begin
        if (en_vact == 1'b1)
        begin
            if (flag_hend == 1'b1)
            begin
                if (cnt_vact == V_ACT - 12'd1)
                begin
                    cnt_vact <= 12'd0;
                end
                else
                begin
                    cnt_vact <= cnt_vact + 12'd1;
                end
            end
        end
    end
end

always @(posedge clk or negedge rst_n)
begin
    if(rst_n == 1'b0)
    begin
        num_vdiv64 <= 6'd0;
        cnt_vdiv64 <= 8'd0;
    end
    else
    begin
        if (en_vact == 1'b1)
        begin
            if (flag_hend == 1'b1)
            begin
                if (cnt_vdiv64 == GAP_VDIV64 - 8'd1)
                begin
                    num_vdiv64 <= num_vdiv64 + 6'd1;
                    cnt_vdiv64 <= 8'd0;
                end
                else
                begin
                    num_vdiv64 <= num_vdiv64;
                    cnt_vdiv64 <= cnt_vdiv64 + 8'd1;
                end
            end
        end
    end
end

//counter for reset
always @(posedge clk or negedge rst_n)
begin
    if (rst_n == 1'b0)
    begin
        cnt_clk_grst <= 32'd0;
    end
    else
    begin
        if (cs_ctrl == GRST)
        begin
            if (cnt_clk_grst == NUM_CLK_GRST - 32'd1)
            begin
                cnt_clk_grst <= 32'd0;
            end
            else
            begin
                cnt_clk_grst <= cnt_clk_grst + 32'd1;
            end
        end
    end
end

//-----------------------------------------------------------------------------
// timing generation
//-----------------------------------------------------------------------------
//grst
always @(posedge clk or negedge rst_n)
begin
    if (rst_n == 1'b0)
    begin
        grst <= 1'b0;
    end
	 
	// for NMOS
	 else if ((flag_black_on == 1'b1)|| (is_demux_all_on == 1'b1))
    begin
       // stv1 <= 1'b1;
		  grst <= 1'b1;
    end
	 
	 
    else
    begin
        if (cs_ctrl == GRST)
        begin
            grst <= 1'b1;
        end
        else
        begin
            grst <= 1'b0;
        end
    end
end

//*********** VTCOMSW1
always @(posedge clk or negedge rst_n)
begin
    if (rst_n == 1'b0)
    begin
        VTCOMSW1 <= 1'b0;
    end
    else
    begin
        if (smp_dis_sn >= 7'd9)
        begin
            VTCOMSW1 <= 1'b0;
        end
        else
        begin
            VTCOMSW1 <= 1'b1;
        end
    end
end


//u2d
always @(posedge clk or negedge rst_n)
begin
    if (rst_n == 1'b0)
    begin
        u2d <= 1'b1;
    end
    else
    begin
        if (flag_rev_scan == 1'b1)
        begin
            u2d <= 1'b0;
        end
        else
        begin
            u2d <= 1'b1;
        end
    end
end

//d2u
always @(posedge clk or negedge rst_n)
begin
    if (rst_n == 1'b0)
    begin
        d2u <= 1'b0;
    end
    else
    begin
        if (flag_rev_scan == 1'b1)
        begin
            d2u <= 1'b1;
        end
        else
        begin
            d2u <= 1'b0;
        end
    end
end



//stv1
//referce point: end of VBP (start of DISPLAY)
always @(posedge clk or negedge rst_n)
begin
    if (rst_n == 1'b0)
    begin
        stv1_pre <= 1'b0;
    end
    else if ((flag_black_on == 1'b1)|| (is_demux_all_on == 1'b1))
    begin
        stv1_pre <= 1'b0;
    end
    else
    begin
        if (STV1_TOTAL_DIRE == 1'b1)  //stv shift left
        begin
            if (STV1_RISE_DIRE == 1'b1)  //rising edge shift left
            begin
                if ((is_sof_vblank == 1'b1) && (cnt_vblank == num_vblank - STV1_TOTAL_SHIFT - 12'd1) && (hcnt == H_TOTAL - 12'd1 - STV1_RISE_SHIFT))
                begin
                    stv1_pre <= 1'b1;
                end
            end
            else  //rising edge shift right
            begin
                if (STV1_TOTAL_SHIFT == 0)
                begin
                    if ((cs_ctrl == DISPLAY) && (cnt_vact == 12'd0) && (hcnt == STV1_RISE_SHIFT))
                    begin
                        stv1_pre <= 1'b1;
                    end
                end
                else
                begin
                    if ((is_sof_vblank == 1'b1) && (cnt_vblank == num_vblank - STV1_TOTAL_SHIFT) && (hcnt == STV1_RISE_SHIFT))
                    begin
                        stv1_pre <= 1'b1;
                    end
                end
            end
            
            if (STV1_FALL_DIRE == 1'b1)  //falling edge shift left
            begin
                if (STV1_WIDTH <= STV1_TOTAL_SHIFT)
                begin
                    if ((is_sof_vblank == 1'b1) && (cnt_vblank == num_vblank - STV1_TOTAL_SHIFT - 12'd1 + STV1_WIDTH) && (hcnt == H_TOTAL - 12'd1 - STV1_FALL_SHIFT))
                    begin
                        stv1_pre <= 1'b0;
                    end
                end
                else
                begin
                    if ((cs_ctrl == DISPLAY) && (cnt_vact == STV1_WIDTH - STV1_TOTAL_SHIFT - 12'd1) && (hcnt == H_TOTAL - 12'd1 - STV1_FALL_SHIFT))
                    begin
                        stv1_pre <= 1'b1;
                    end
                end
            end
            else  //falling edge shift right
            begin
                if (STV1_WIDTH < STV1_TOTAL_SHIFT)
                begin
                    if ((is_sof_vblank == 1'b1) && (cnt_vblank == num_vblank - STV1_TOTAL_SHIFT + STV1_WIDTH) && (hcnt == STV1_FALL_SHIFT))
                    begin
                        stv1_pre <= 1'b0;
                    end
                end
                else
                begin
                    if ((cs_ctrl == DISPLAY) && (cnt_vact == STV1_WIDTH - STV1_TOTAL_SHIFT) && (hcnt == STV1_FALL_SHIFT))
                    begin
                        stv1_pre <= 1'b0;
                    end
                end
            end
        end
        else  //stv shift right
        begin
            if (STV1_RISE_DIRE == 1'b1)  //rising edge shift left
            begin
                if (STV1_TOTAL_SHIFT == 0)
                begin
                    if ((is_sof_vblank == 1'b1) && (cnt_vblank == num_vblank -12'd1) && (hcnt == H_TOTAL - 12'd1 - STV1_RISE_SHIFT))
                    begin
                        stv1_pre <= 1'b1;
                    end
                end
                else
                begin
                    if ((cs_ctrl == DISPLAY) && (cnt_vact == STV1_TOTAL_SHIFT - 12'd1) && (hcnt == H_TOTAL - 12'd1 - STV1_RISE_SHIFT))
                    begin
                        stv1_pre <= 1'b1;
                    end
                end
            end
            else  //rising edge shift right
            begin
                if ((cs_ctrl == DISPLAY) && (cnt_vact == STV1_TOTAL_SHIFT) && (hcnt == STV1_RISE_SHIFT))
                begin
                    stv1_pre <= 1'b1;
                end
            end
            
            if (STV1_FALL_DIRE == 1'b1)  //falling edge shift left
            begin
                if ((cs_ctrl == DISPLAY) && (cnt_vact == STV1_TOTAL_SHIFT - 12'd1 + STV1_WIDTH) && (hcnt == H_TOTAL - 12'd1 - STV1_FALL_SHIFT))
                begin
                    stv1_pre <= 1'b0;
                end
            end
            else  //falling edge shift right
            begin
                if ((cs_ctrl == DISPLAY) && (cnt_vact == STV1_TOTAL_SHIFT - 12'd1 + STV1_WIDTH) && (hcnt == H_TOTAL - 12'd1 - STV1_FALL_SHIFT))
                begin
                    stv1_pre <= 1'b0;
                end
            end
        end
    end
end

//stv2
//referce point: end of VBP (start of DISPLAY)
always @(posedge clk or negedge rst_n)
begin
    if (rst_n == 1'b0)
    begin
        stv2_pre <= 1'b0;
    end
    else if ((flag_black_on == 1'b1)|| (is_demux_all_on == 1'b1))
    begin
        stv2_pre <= 1'b0;
    end
    else
    begin
        if (STV2_TOTAL_DIRE == 1'b1)  //stv shift left
        begin
            if (STV2_RISE_DIRE == 1'b1)  //rising edge shift left
            begin
                if ((is_sof_vblank == 1'b1) && (cnt_vblank == num_vblank - STV2_TOTAL_SHIFT - 12'd1) && (hcnt == H_TOTAL - 12'd1 - STV2_RISE_SHIFT))
                begin
                    stv2_pre <= 1'b1;
                end
            end
            else  //rising edge shift right
            begin
                if (STV2_TOTAL_SHIFT == 0)
                begin
                    if ((cs_ctrl == DISPLAY) && (cnt_vact == 12'd0) && (hcnt == STV2_RISE_SHIFT))
                    begin
                        stv2_pre <= 1'b1;
                    end
                end
                else
                begin
                    if ((is_sof_vblank == 1'b1) && (cnt_vblank == num_vblank - STV2_TOTAL_SHIFT) && (hcnt == STV2_RISE_SHIFT))
                    begin
                        stv2_pre <= 1'b1;
                    end
                end
            end
            
            if (STV2_FALL_DIRE == 1'b1)  //falling edge shift left
            begin
                if (STV2_WIDTH <= STV2_TOTAL_SHIFT)
                begin
                    if ((is_sof_vblank == 1'b1) && (cnt_vblank == num_vblank - STV2_TOTAL_SHIFT - 12'd1 + STV2_WIDTH) && (hcnt == H_TOTAL - 12'd1 - STV2_FALL_SHIFT))
                    begin
                        stv2_pre <= 1'b0;
                    end
                end
                else
                begin
                    if ((cs_ctrl == DISPLAY) && (cnt_vact == STV2_WIDTH - STV2_TOTAL_SHIFT - 12'd1) && (hcnt == H_TOTAL - 12'd1 - STV2_FALL_SHIFT))
                    begin
                        stv2_pre <= 1'b1;
                    end
                end
            end
            else  //falling edge shift right
            begin
                if (STV2_WIDTH < STV2_TOTAL_SHIFT)
                begin
                    if ((is_sof_vblank == 1'b1) && (cnt_vblank == num_vblank - STV2_TOTAL_SHIFT + STV2_WIDTH) && (hcnt == STV2_FALL_SHIFT))
                    begin
                        stv2_pre <= 1'b0;
                    end
                end
                else
                begin
                    if ((cs_ctrl == DISPLAY) && (cnt_vact == STV2_WIDTH - STV2_TOTAL_SHIFT) && (hcnt == STV2_FALL_SHIFT))
                    begin
                        stv2_pre <= 1'b0;
                    end
                end
            end
        end
        else  //stv shift right
        begin
            if (STV2_RISE_DIRE == 1'b1)  //rising edge shift left
            begin
                if (STV2_TOTAL_SHIFT == 0)
                begin
                    if ((is_sof_vblank == 1'b1) && (cnt_vblank == num_vblank -12'd1) && (hcnt == H_TOTAL - 12'd1 - STV2_RISE_SHIFT))
                    begin
                        stv2_pre <= 1'b1;
                    end
                end
                else
                begin
                    if ((cs_ctrl == DISPLAY) && (cnt_vact == STV2_TOTAL_SHIFT - 12'd1) && (hcnt == H_TOTAL - 12'd1 - STV2_RISE_SHIFT))
                    begin
                        stv2_pre <= 1'b1;
                    end
                end
            end
            else  //rising edge shift right
            begin
                if ((cs_ctrl == DISPLAY) && (cnt_vact == STV2_TOTAL_SHIFT) && (hcnt == STV2_RISE_SHIFT))
                begin
                    stv2_pre <= 1'b1;
                end
            end
            
            if (STV2_FALL_DIRE == 1'b1)  //falling edge shift left
            begin
                if ((cs_ctrl == DISPLAY) && (cnt_vact == STV2_TOTAL_SHIFT - 12'd1 + STV2_WIDTH) && (hcnt == H_TOTAL - 12'd1 - STV2_FALL_SHIFT))
                begin
                    stv2_pre <= 1'b0;
                end
            end
            else  //falling edge shift right
            begin
                if ((cs_ctrl == DISPLAY) && (cnt_vact == STV2_TOTAL_SHIFT - 12'd1 + STV2_WIDTH) && (hcnt == H_TOTAL - 12'd1 - STV2_FALL_SHIFT))
                begin
                    stv2_pre <= 1'b0;
                end
            end
        end
    end
end



//ckv1
always @(posedge clk or negedge rst_n)
begin
    if (rst_n == 1'b0)
    begin
        ckv1_pre <= 1'b0;
    end
    else if ((flag_black_on == 1'b1)|| (is_demux_all_on == 1'b1))
    begin
        ckv1_pre <= 1'b0;
    end
    else
    begin
        if ((hcnt >= CKV_RISE_SHIFT) && (hcnt <= H_TOTAL - 12'd1 - CKV_FALL_SHIFT))
        begin
		
		
		if (((cs_ctrl == PCH) && (cnt_vblank == num_vblank - 12'd3) && (cnt_vact == 12'd0)) || ((cs_ctrl == DISPLAY) && (cnt_vact%4== 12'd1))|| ((cs_ctrl == VFP) && (cnt_vblank == 12'd0)))
            	begin
                	ckv1_pre <= 1'b1;
		end
		else
		begin
			ckv1_pre <= 1'b0;
		end

	
	
	
	
	
	
	
	end
	else
	begin
		ckv1_pre <= 1'b0;
	end
    end
end


//ckv2
always @(posedge clk or negedge rst_n)
begin
    if (rst_n == 1'b0)
    begin
        ckv2_pre <= 1'b0;
    end
    else if ((flag_black_on == 1'b1)|| (is_demux_all_on == 1'b1))
    begin
    	ckv2_pre <= 1'b0;
    end
    else
    begin
        if ((hcnt >= CKV_RISE_SHIFT) && (hcnt <= H_TOTAL - 12'd1 - CKV_FALL_SHIFT))
        begin



		if (((cs_ctrl == PCH) && (cnt_vblank == num_vblank - 12'd2) && (cnt_vact == 12'd0)) || ((cs_ctrl == DISPLAY) && (cnt_vact%4== 12'd2))|| ((cs_ctrl == VFP) && (cnt_vblank == 12'd1))) 
		begin
                	ckv2_pre <= 1'b1;
            	end
            else
            begin
	    	ckv2_pre <= 1'b0;
	    end
	end
	else
	begin








            ckv2_pre <= 1'b0;
        end
    end
end

//ckv3
always @(posedge clk or negedge rst_n)
begin
	if (rst_n == 1'b0)
	begin
		ckv3_pre <= 1'b0;
	end
	else if ((flag_black_on == 1'b1)|| (is_demux_all_on == 1'b1))
	begin
		ckv3_pre <= 1'b0;
	end
	else
	begin
		if ((hcnt >= CKV_RISE_SHIFT) && (hcnt <= H_TOTAL - 12'd1 - CKV_FALL_SHIFT))
        	begin


				if ( ((cs_ctrl == PCH) && (cnt_vblank == num_vblank - 12'd1)&& (cnt_vact == 12'd0)) || ((cs_ctrl == DISPLAY) && (cnt_vact%4== 12'd3)) || ((cs_ctrl == VFP) && (cnt_vblank == 12'd2)))
				begin
					ckv3_pre <= 1'b1;
				end
				else
				begin
                			ckv3_pre <= 1'b0;
            			end
			end
			else
			begin
		
		
		
		
		



    			ckv3_pre <= 1'b0;
		end
	end
end


//ckv4
always @(posedge clk or negedge rst_n)
begin
	if (rst_n == 1'b0)
	begin
		ckv4_pre <= 1'b0;
	end
	else if ((flag_black_on == 1'b1)|| (is_demux_all_on == 1'b1))
	begin
		ckv4_pre <= 1'b0;
	end
	else
	begin
		if ((hcnt >= CKV_RISE_SHIFT) && (hcnt <= H_TOTAL - 12'd1 - CKV_FALL_SHIFT))
		begin
		
		
			if ( ((cs_ctrl == PCH) && (cnt_vblank == num_vblank - 12'd0)&& (cnt_vact == 12'd0)) || ((cs_ctrl == DISPLAY) && (cnt_vact%4== 12'd0)) || ((cs_ctrl == VFP) && (cnt_vblank == 12'd3)))
			begin
				ckv4_pre <= 1'b1;
			end
			else
			begin
				ckv4_pre <= 1'b0;
			end
		end
		else
		begin








			ckv4_pre <= 1'b0;
		end
	end
end

//ckhr, xckhr
always @(posedge clk or negedge rst_n)
begin
    if (rst_n == 1'b0)
    begin
        ckhr <= 1'b0;
//        xckhr <= 1'b1;
    end
    else
    begin
        if (is_demux_all_on == 1'b1)
        begin
           // ckhr <= 1'b1;
				ckhr <= 1'b0;
//            xckhr <= 1'b0;
        end
        else if ((cs_ctrl == PCH) || (cs_ctrl == DISPLAY))
        begin
            
            if ((hcnt >= (CKV_RISE_SHIFT + CKH_PRE_GAP + CKH_RISE_SHIFT)) && (hcnt <= (CKV_RISE_SHIFT + CKH_PRE_GAP + CKH_RISE_SHIFT + CKH_WIDTH)))
            begin
                ckhr <= 1'b1;
//                xckhr <= 1'b0;
            end
            else
            begin
                ckhr <= 1'b0;
//                xckhr <= 1'b1;
            end
        end
        else
        begin
            ckhr <= 1'b0;
//            xckhr <= 1'b1;
        end
    end
end

//ckhg, xckhg
always @(posedge clk or negedge rst_n)
begin
    if (rst_n == 1'b0)
    begin
        ckhg <= 1'b0;
//        xckhg <= 1'b1;
    end
    else
    begin
        if (is_demux_all_on == 1'b1)
        begin
           // ckhg <= 1'b1;
				ckhg <= 1'b0;
//            xckhg <= 1'b0;
        end
        else if ((cs_ctrl == PCH) || (cs_ctrl == DISPLAY))
        begin
            if ((hcnt >= (CKV_RISE_SHIFT + CKH_PRE_GAP + 2 * CKH_RISE_SHIFT + CKH_WIDTH + CKH_FALL_SHIFT))
             && (hcnt <= (CKV_RISE_SHIFT + CKH_PRE_GAP + 2 * CKH_RISE_SHIFT + 2 * CKH_WIDTH + CKH_FALL_SHIFT)))
            begin
                ckhg <= 1'b1;
//                xckhg <= 1'b0;
            end
            else
            begin
                ckhg <= 1'b0;
//                xckhg <= 1'b1;
            end
        end
        else
        begin
            ckhg <= 1'b0;
//            xckhg <= 1'b1;
        end
    end
end

//ckhb, xckhb
always @(posedge clk or negedge rst_n)
begin
    if (rst_n == 1'b0)
    begin
        ckhb <= 1'b0;
//        xckhb <= 1'b1;
    end
    else
    begin
        if (is_demux_all_on == 1'b1)
        begin
            //ckhb <= 1'b1;
				ckhb <= 1'b0;
//            xckhb <= 1'b0;
        end
        else if ((cs_ctrl == PCH) || (cs_ctrl == DISPLAY))
        begin
            if ((hcnt >= (CKV_RISE_SHIFT + CKH_PRE_GAP + 3 * CKH_RISE_SHIFT + 2 * CKH_WIDTH + 2 * CKH_FALL_SHIFT))
             && (hcnt <= (CKV_RISE_SHIFT + CKH_PRE_GAP + 3 * CKH_RISE_SHIFT + 3 * CKH_WIDTH + 2 * CKH_FALL_SHIFT)))
            begin
                ckhb <= 1'b1;
//                xckhb <= 1'b0;
            end
            else
            begin
                ckhb <= 1'b0;
//                xckhb <= 1'b1;
            end
        end
        else
        begin
            ckhb <= 1'b0;
//            xckhb <= 1'b1;
        end
    end
end

//-----------------------------------------------------------------------------
// pattern generation
//-----------------------------------------------------------------------------
always @(posedge clk or negedge rst_n)
begin
    if (rst_n == 1'b0)
    begin
        smp_dis_sn <= 7'd0;
    end
    else
    begin
        if ((cs_ctrl == VBP) && (cnt_vblank == 12'd0) && (hcnt == 12'd1))
        begin
            smp_dis_sn <= dis_sn;
        end
    end
end

always @(posedge clk or negedge rst_n)
begin
    if (rst_n == 1'b0)
    begin
        pat_blc_wht_h <= 24'b0;
    end
    else
    begin
        if (cnt_vact>=0&&cnt_vact<=1170)  //top half
        begin
            pat_blc_wht_h <= {DCODE_BLACK, DCODE_BLACK, DCODE_BLACK};
        end
        else  //bottom half
        begin
            pat_blc_wht_h <= {DCODE_WHITE, DCODE_WHITE, DCODE_WHITE};
        end
    end
end

always @(posedge clk or negedge rst_n)
begin
    if (rst_n == 1'b0)
    begin
        pat_wht_blc_h <= 24'b0;
    end
    else
    begin
        if (cnt_vact>=0&&cnt_vact<=1170)  //top half
        begin
            pat_wht_blc_h <= {DCODE_WHITE, DCODE_WHITE, DCODE_WHITE};
        end
        else  //bottom half
        begin
            pat_wht_blc_h <= {DCODE_BLACK, DCODE_BLACK, DCODE_BLACK};
        end
    end
end

always @(posedge clk or negedge rst_n)
begin
	if (rst_n == 1'b0)
	begin
		r_data <= 8'd0;
		g_data <= 8'd0;
		b_data <= 8'd0;
	end
	else
	begin
	case (smp_dis_sn)
		7'd0:
		begin
			r_data <= 8'd128;
			g_data <= 8'd128;
			b_data <= 8'd128;
		end
		7'd1:  //black
		begin
			r_data <= DCODE_BLACK;
                	g_data <= DCODE_BLACK;
                	b_data <= DCODE_BLACK;
		end
		7'd2:  //gray
		begin
			r_data <= DCODE_GRAY128;
			g_data <= DCODE_GRAY128;
			b_data <= DCODE_GRAY128;
		end
		7'd3:
		begin
			r_data <= pat_blc_wht_h[23:16];
			g_data <= pat_blc_wht_h[15:8];
			b_data <= pat_blc_wht_h[7:0];
		end
		7'd4:
		begin
			r_data <= pat_wht_blc_h[23:16];
			g_data <= pat_wht_blc_h[15:8];
			b_data <= pat_wht_blc_h[7:0];
		end
		7'd5:
		begin
			r_data <= DCODE_WHITE;
 			g_data <= DCODE_WHITE;
			b_data <= DCODE_WHITE;
            end
            7'd6:  //red
            begin
	                r_data <= DCODE_WHITE;
	                g_data <= DCODE_BLACK;
	                b_data <= DCODE_BLACK;
            end
            7'd7:  //green
            begin
	                r_data <= DCODE_BLACK;
	                g_data <= DCODE_WHITE;
	                b_data <= DCODE_BLACK;
            end
            7'd8:  //blue
            begin
	                r_data <= DCODE_BLACK;
	                g_data <= DCODE_BLACK;
	                b_data <= DCODE_WHITE;
            end
	    7'd9:  //TP senson short test VCOMA
            begin
	                r_data <= DCODE_GND;
	                g_data <= DCODE_GND;
	                b_data <= DCODE_GND;
            end
	    7'd10:  //TP senson short test VCOMB
            begin
	                r_data <= DCODE_GND;
	                g_data <= DCODE_GND;
	                b_data <= DCODE_GND;
            end
            7'd11:
            begin
	                r_data <= 8'd128;
	                g_data <= 8'd128;
	                b_data <= 8'd128;
            end
        endcase
    end
end

//-----------------------------------------------------------------------------
// D/A processing - source data generation
//-----------------------------------------------------------------------------
always @(posedge clk or negedge rst_n)
begin
	if (rst_n == 1'b0)
	begin
	        flag_frm_pol <= 1'b0;
	end
	else
	begin
		if ((cs_ctrl == VFP) && ((flag_hend == 1'b1) && (cnt_vblank == V_FP - 12'd1)))
		begin
			flag_frm_pol <= ~ flag_frm_pol;
		end
	end
end

always @(posedge clk or negedge rst_n)
begin
	if (rst_n == 1'b0)
	begin
		da1_wr <= 1'b1;
	        da2_wr <= 1'b1;
		da3_wr <= 1'b1;
		da4_wr <= 1'b1;
	end
	else
	begin
		da1_wr <= 1'b0;
	        da2_wr <= 1'b0;
		da3_wr <= 1'b0;
		da4_wr <= 1'b0;
	end
end


always @(posedge clk or negedge rst_n)
begin
	if (rst_n == 1'b0)
	begin
		da2_a <= 2'b00;
		da2_din <= DCODE_GND;
		da3_a <= 2'b00;
		da3_din <= DCODE_GND;
	end
	else
	begin
		if (is_demux_all_on == 1'b1)
		begin
			if (flag_frm_pol == 1'b0)  //odd frame
			begin
				if (hcnt == 1)
				begin
					if((flag_TP_test_a == 1'b0)&&(flag_TP_test_b == 1'b0))//normal pattern VCOM
					begin
						da2_a <= 2'b00;
						da2_din <= DCODE_VCOM;
						da3_a <= 2'b00;
						da3_din <= DCODE_VCOM;
					end
					else if(flag_TP_test_a == 1'b1)//TP_test_pattern VCOMA 
					begin
						da2_a <= 2'b00;
						da2_din <= DCODE_VCOMA;//VCOMA
						da3_a <= 2'b00;
						da3_din <= DCODE_VCOMB;//VCOMB
					end
					else if(flag_TP_test_b == 1'b1)//TP_test_pattern VCOMB 
					begin
						da2_a <= 2'b00;
						da2_din <= DCODE_VCOMB;//VCOMB
						da3_a <= 2'b00;
						da3_din <= DCODE_VCOMA;//VCOMA
					end		 
				end 
				else if (hcnt == (CKV_RISE_SHIFT + CKH_PRE_GAP + CKH_RISE_SHIFT - SRC_PCH_SHIFT))
				begin
					da1_a <= 2'b00;
					da1_din <= r_data;
				end
				else if (hcnt == (CKV_RISE_SHIFT + CKH_PRE_GAP + CKH_RISE_SHIFT - SRC_PCH_SHIFT + ODD_EVEN_TGAP))
				begin
					if(flag_inversion == 1'b0) //column inversion  
					begin
						da1_a <= 2'b01;
						da1_din <= ~r_data[7:0] + 8'd1;
					end
					else if(flag_inversion == 1'b1) //frame inversion
					begin
						da1_a <= 2'b01;
						da1_din <= r_data;
					end
				end
			end
			else  //even frame
			begin
				if (hcnt == 1)
				begin
					if((flag_TP_test_a == 1'b0)&&(flag_TP_test_b == 1'b0))//normal pattern VCOM
					begin
						da2_a <= 2'b00;
						da2_din <= DCODE_VCOM;
						da3_a <= 2'b00;
						da3_din <= DCODE_VCOM;
					end
					else if(flag_TP_test_a == 1'b1)//TP_test_pattern VCOMA 
					begin
						da2_a <= 2'b00;
						da2_din <= ~DCODE_VCOMA[7:0]+8'd1;//~VCOMA
						da3_a <= 2'b00;
						da3_din <= ~DCODE_VCOMB[7:0]+8'd1;//~VCOMB
					end	
					else if(flag_TP_test_b == 1'b1)//TP_test_pattern VCOMB 
					begin
						da2_a <= 2'b00;
						da2_din <= ~DCODE_VCOMB[7:0]+8'd1;//~VCOMB
						da3_a <= 2'b00;
						da3_din <= ~DCODE_VCOMA[7:0]+8'd1;//~VCOMA
					end	
				end 
				else if (hcnt == (CKV_RISE_SHIFT + CKH_PRE_GAP + CKH_RISE_SHIFT - SRC_PCH_SHIFT))
				begin
					da1_a <= 2'b00;
					da1_din <= ~r_data[7:0] + 8'd1;
				end
				else if (hcnt == (CKV_RISE_SHIFT + CKH_PRE_GAP + CKH_RISE_SHIFT - SRC_PCH_SHIFT + ODD_EVEN_TGAP))
				begin
					if(flag_inversion == 1'b0) //column inversion  
					begin
						da1_a <= 2'b01;
						da1_din <= r_data;
					end
					else if(flag_inversion == 1'b1) //frame inversion
					begin
						da1_a <= 2'b01;
						da1_din <= ~r_data[7:0] + 8'd1;
					end
				end
			end
		end
		
		else if ((cs_ctrl == PCH) || (cs_ctrl == DISPLAY))
		begin
			if (flag_frm_pol == 1'b0)  //odd frame
			begin
				if (hcnt == 1)
				begin
					if((flag_TP_test_a == 1'b0)&&(flag_TP_test_b == 1'b0))//normal pattern VCOM
					begin
						da2_a <= 2'b00;
						da2_din <= DCODE_VCOM;
						da3_a <= 2'b00;
						da3_din <= DCODE_VCOM;
					end
					else if(flag_TP_test_a == 1'b1)//TP_test_pattern VCOMA 
					begin
						da2_a <= 2'b00;
						da2_din <= DCODE_VCOM;//VCOMA
						da3_a <= 2'b00;
						da3_din <= DCODE_VCOMB;//VCOMB
					end
					else if(flag_TP_test_b == 1'b1)//TP_test_pattern VCOMB 
					begin
						da2_a <= 2'b00;
						da2_din <= DCODE_VCOM;//VCOMB
						da3_a <= 2'b00;
						da3_din <= DCODE_VCOMA;//VCOMA
					end	
				 end 
				 else if (hcnt == 10)
				 begin
				 	if((flag_TP_test_a == 1'b0)&&(flag_TP_test_b == 1'b0))//normal pattern VCOM
					begin
						da2_a <= 2'b01;
						da2_din <= DCODE_VCOM;
						da3_a <= 2'b01;
						da3_din <= DCODE_VCOM;
					end
					else if(flag_TP_test_a == 1'b1)//TP_test_pattern VCOMA 
					begin
						da2_a <= 2'b01;
						da2_din <= DCODE_VCOM;//VCOMA
						da3_a <= 2'b01;
						da3_din <= DCODE_VCOMA;//VCOMB
					end
					else if(flag_TP_test_b == 1'b1)//TP_test_pattern VCOMB
					begin
						da2_a <= 2'b01;
						da2_din <= DCODE_VCOM;//VCOMB
						da3_a <= 2'b01;
						da3_din <= DCODE_VCOMB;//VCOMA
					end
				 end
				 else if (hcnt == (CKV_RISE_SHIFT + CKH_PRE_GAP + CKH_RISE_SHIFT - SRC_PCH_SHIFT))
			         begin
				 	da1_a <= 2'b00;
					da1_din <= r_data;
			         end
			         else if (hcnt == (CKV_RISE_SHIFT + CKH_PRE_GAP + CKH_RISE_SHIFT - SRC_PCH_SHIFT + ODD_EVEN_TGAP))
			         begin
				 	if(flag_inversion == 1'b0) //column inversion  
					begin
						da4_a <= 2'b00;
						da4_din <= ~r_data[7:0] + 8'd1;
					end
					else if(flag_inversion == 1'b1) //frame inversion
					begin
						da1_a <= 2'b01;
						da1_din <= r_data;
					end
			                end
			                else if (hcnt == (CKV_RISE_SHIFT + CKH_PRE_GAP + 2 * CKH_RISE_SHIFT + CKH_WIDTH + CKH_FALL_SHIFT - SRC_PCH_SHIFT))
			                begin
						da1_a <= 2'b00;
						da1_din <= g_data;
			                end
			                else if (hcnt == (CKV_RISE_SHIFT + CKH_PRE_GAP + 2 * CKH_RISE_SHIFT + CKH_WIDTH + CKH_FALL_SHIFT - SRC_PCH_SHIFT + ODD_EVEN_TGAP))
			                begin
						if(flag_inversion == 1'b0) //column inversion  
						begin
							da4_a <= 2'b00;
							da4_din <= ~g_data[7:0] + 8'd1;
						end
						else if(flag_inversion == 1'b1) //frame inversion
						begin
							da1_a <= 2'b01;
							da1_din <= g_data;
						end
			                end
			                else if (hcnt == (CKV_RISE_SHIFT + CKH_PRE_GAP + 3 * CKH_RISE_SHIFT + 2 * CKH_WIDTH + 2 * CKH_FALL_SHIFT - SRC_PCH_SHIFT))
			                begin
						da1_a <= 2'b00;
						da1_din <= b_data;
			                end
			                else if (hcnt == (CKV_RISE_SHIFT + CKH_PRE_GAP + 3 * CKH_RISE_SHIFT + 2 * CKH_WIDTH + 2 * CKH_FALL_SHIFT - SRC_PCH_SHIFT + ODD_EVEN_TGAP))
			                begin
						if(flag_inversion == 1'b0) //column inversion  
						begin
							da4_a <= 2'b00;
							da4_din <= ~b_data[7:0] + 8'd1;
						end
						else if(flag_inversion == 1'b1) //frame inversion
						begin
							da1_a <= 2'b01;
							da1_din <= b_data;
						end
					end
				end
				else  //even frame
				begin
					if (hcnt == 1)
					begin
						if((flag_TP_test_a == 1'b0)&&(flag_TP_test_b == 1'b0))//normal pattern VCOM
						begin
							da2_a <= 2'b00;
							da2_din <= DCODE_VCOM;
							da3_a <= 2'b00;
							da3_din <= DCODE_VCOM;
						end
						else if(flag_TP_test_a == 1'b1)//TP_test_pattern VCOMA 
						begin
							da2_a <= 2'b00;
							da2_din <= DCODE_VCOM;//~VCOMA
							da3_a <= 2'b00;
							da3_din <= ~DCODE_VCOMB[7:0]+8'd1;//~VCOMB
						end
						else if(flag_TP_test_b == 1'b1)//TP_test_pattern VCOMB 
						begin
							da2_a <= 2'b00;
							da2_din <= DCODE_VCOM;//~VCOMB
							da3_a <= 2'b00;
							da3_din <= ~DCODE_VCOMA[7:0]+8'd1;//~VCOMA
						end
					end 
					else if (hcnt == 10)
					begin
						if((flag_TP_test_a == 1'b0)&&(flag_TP_test_b == 1'b0))//normal pattern VCOM
						begin
							da2_a <= 2'b01;
							da2_din <= DCODE_VCOM;
							da3_a <= 2'b01;
							da3_din <= DCODE_VCOM;
						end
						else if(flag_TP_test_a == 1'b1)//TP_test_pattern VCOMA 
						begin
							da2_a <= 2'b01;
							da2_din <= DCODE_VCOM;//VCOMA
							da3_a <= 2'b01;
							da3_din <= ~DCODE_VCOMA[7:0]+8'd1;//~VCOMB
						end
						else if(flag_TP_test_b == 1'b1)//TP_test_pattern VCOMB 
						begin
							da2_a <= 2'b01;
							da2_din <= DCODE_VCOM;//VCOMB
							da3_a <= 2'b01;
							da3_din <= ~DCODE_VCOMB[7:0]+8'd1;//~VCOMA
						end		 
					end 
					else if (hcnt == (CKV_RISE_SHIFT + CKH_PRE_GAP + CKH_RISE_SHIFT - SRC_PCH_SHIFT))
					begin
						da1_a <= 2'b00;
						da1_din <= ~r_data[7:0] + 8'd1;
					end
					else if (hcnt == (CKV_RISE_SHIFT + CKH_PRE_GAP + CKH_RISE_SHIFT - SRC_PCH_SHIFT + ODD_EVEN_TGAP))
					begin
						if(flag_inversion == 1'b0) //column inversion  
						begin
							da4_a <= 2'b00;
							da4_din <= r_data;
						end
						else if(flag_inversion == 1'b1) //frame inversion
						begin
							da1_a <= 2'b01;
							da1_din <= ~r_data[7:0] + 8'd1;
						end
					end
					else if (hcnt == (CKV_RISE_SHIFT + CKH_PRE_GAP + 2 * CKH_RISE_SHIFT + CKH_WIDTH + CKH_FALL_SHIFT - SRC_PCH_SHIFT))
					begin
						da1_a <= 2'b00;
						da1_din <= ~g_data[7:0] + 8'd1;
					end
					else if (hcnt == (CKV_RISE_SHIFT + CKH_PRE_GAP + 2 * CKH_RISE_SHIFT + CKH_WIDTH + CKH_FALL_SHIFT - SRC_PCH_SHIFT + ODD_EVEN_TGAP))
					begin
						if(flag_inversion == 1'b0) //column inversion  
						begin
							da4_a <= 2'b00;
							da4_din <= g_data;
						end
						else if(flag_inversion == 1'b1) //frame inversion
						begin
							da1_a <= 2'b01;
							da1_din <= ~g_data[7:0] + 8'd1;
						end
					end
					else if (hcnt == (CKV_RISE_SHIFT + CKH_PRE_GAP + 3 * CKH_RISE_SHIFT + 2 * CKH_WIDTH + 2 * CKH_FALL_SHIFT - SRC_PCH_SHIFT))
					begin
						da1_a <= 2'b00;
						da1_din <= ~b_data[7:0] + 8'd1;
					end
					else if (hcnt == (CKV_RISE_SHIFT + CKH_PRE_GAP + 3 * CKH_RISE_SHIFT + 2 * CKH_WIDTH + 2 * CKH_FALL_SHIFT - SRC_PCH_SHIFT + ODD_EVEN_TGAP))
					begin
						if(flag_inversion == 1'b0) //column inversion  
						begin
							da4_a <= 2'b00;
							da4_din <= b_data;
						end
						else if(flag_inversion == 1'b1) //frame inversion
						begin
							da1_a <= 2'b01;
							da1_din <= ~b_data[7:0] + 8'd1;
						end
					end
				end
			end
			else if (cs_ctrl == VFP)
			begin
				if (cnt_vblank == 12'd0)
				begin
					da1_a <= 2'b00;
					da1_din <= DCODE_GND;
				end
				else if (cnt_vblank == 12'd1)
				begin
					da4_a <= 2'b00;
					da4_din <= DCODE_GND;
				end
			end
		end
	end
endmodule