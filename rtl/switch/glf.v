//*****************************************************************************
// COPYRIGHT (c) 2013, Xiamen Tianma Microelectronics Co, Ltd
//
// File name     :  glf.v
// Module name   :  glf
//
// Author        :  sijian_luo
// Email         :  sijian_luo@tianma.cn
// Version       :  v 1.0
//
// Function      :  Glitch filter
// Called by     :  --
//
// ----------------------------------------------------------------------------
// Revison
// 2012-05-29    :  create file
//*****************************************************************************
module glf (
    input                 clk               ,
    input                 rst_n             ,
    input                 en                ,
    input                 s_in              ,
    output reg            s_out
);

//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
// parameters
//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
parameter       CNT1US                      = 107               ;  //1us timer
parameter       CNT1MS                      = 1000              ;  //1ms timer
parameter       CNT1S                       = 1000              ;  //1s timer

//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
// variable declaration
//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
reg                             s_in_d1                         ;
reg                             s_in_d2                         ;
reg                             s_in_d3                         ;

wire                            s_in_neg                        ;
wire                            flag_judge                      ;

//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
// continuous assignment
//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
assign s_in_neg = (s_in_d3 == 1'b1) && (s_in_d2 == 1'b0);  //detecting falling edge of s_in

//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
// module instantiation
//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
timer #(
    .CNT1US                     ( CNT1US                        ),
    .CNT1MS                     ( CNT1MS                        ),
    .CNT1S                      ( CNT1S                         )
) u1_timer (
    .clk                        ( clk                           ),  //input
    .rst_n                      ( rst_n                         ),  //input
    .start                      ( s_in_neg                      ),  //input
    .tunit                      ( 2'b00                         ),  //input       [1:0]
    .tlen                       ( 16'd30                        ),  //input       [15:0]
    .tpulse                     ( flag_judge                    )   //output reg
);

//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
// block statement
//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
always @(posedge clk or negedge rst_n)
begin
    if (rst_n == 1'b0)
    begin
        s_in_d1 <= 1'b0;
        s_in_d2 <= 1'b0;
        s_in_d3 <= 1'b0;
    end
    else
    begin
        if (en == 1'b1)
        begin
            s_in_d1 <= s_in;
            s_in_d2 <= s_in_d1;
            s_in_d3 <= s_in_d2;
        end
    end
end

always @(posedge clk or negedge rst_n)
begin
    if (rst_n == 1'b0)
    begin
        s_out <= 1'b1;
    end
    else
    begin
        if (flag_judge == 1'b1)
        begin
            if (s_in_d3 == 1'b0)
            begin
                s_out <= 1'b0;
            end
            else
            begin
                s_out <= 1'b1;
            end
        end
        else
        begin
            s_out <= 1'b1;
        end
    end
end

endmodule