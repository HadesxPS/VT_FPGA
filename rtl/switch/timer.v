
module timer(
    input                 clk               ,
    input                 rst_n             ,
    input                 start             ,
    input       [1:0]     tunit             ,  //2'b00 - us; 2'b01 - ms; 2'b10 - s; 2'b11 - reserved
    input       [15:0]    tlen              ,  //timing length, when time equal to tlen, tpulse valid
    output reg            tpulse
);

//parameters
parameter       CNT1US                     = 108                ;
parameter       CNT1MS                     = 1000               ;
parameter       CNT1S                      = 1000               ;

//internal variable declaration
reg                             t_cnt_en                        ;
reg                             pulse_1us                       ;
reg                             pulse_1ms                       ;
reg                             pulse_1s                        ;
reg     [15:0]                  cnt_clk                         ;
reg     [15:0]                  cnt_us                          ;
reg     [15:0]                  cnt_ms                          ;
reg     [15:0]                  cnt_s                           ;

wire                            timeout                         ;

assign timeout = (((tunit == 2'b00) && (cnt_us >= tlen - 10'b1) && (pulse_1us == 1'b1))
                     || ((tunit == 2'b01) && (cnt_ms >= tlen - 10'b1) && (pulse_1ms == 1'b1))
                     || ((tunit == 2'b10) && (cnt_s >= tlen - 10'b1) && (pulse_1s == 1'b1)));

always @(posedge clk or negedge rst_n)
begin
    if (rst_n == 1'b0)
    begin
        t_cnt_en <= 1'b0;
    end
    else
    begin
        if (timeout == 1'b1)
        begin
            t_cnt_en <= 1'b0;
        end
        else if (start == 1'b1)
        begin
            t_cnt_en <= 1'b1;
        end
        else
        begin
            t_cnt_en <= t_cnt_en;
        end
    end
end

always @(posedge clk or negedge rst_n)
begin
    if (rst_n == 1'b0)
    begin
        tpulse <= 1'b0;
    end
    else
    begin
        if (timeout == 1'b1)
        begin
            tpulse <= 1'b1;
        end
        else
        begin
            tpulse <= 1'b0;
        end
    end
end

always @(posedge clk or negedge rst_n)
begin
    if (rst_n == 1'b0)
    begin
        cnt_clk   <= 16'b0;
        pulse_1us <= 1'b0;
    end
    else if (timeout == 1'b1)
    begin
        cnt_clk   <= 16'b0;
        pulse_1us <= 1'b0;
    end
    else if (t_cnt_en == 1'b1)
    begin
        if (cnt_clk == (CNT1US - 1))
        begin
            cnt_clk   <= 16'b0;
            pulse_1us <= 1'b1;
        end
        else
        begin
            cnt_clk   <= cnt_clk + 16'b1;
            pulse_1us <= 1'b0;
        end
    end
end

always @(posedge clk or negedge rst_n)
begin
    if (rst_n == 1'b0)
    begin
        cnt_us <= 16'b0;
        pulse_1ms <= 1'b0;
    end
    else if (timeout == 1'b1)
    begin
        cnt_us <= 16'b0;
        pulse_1ms <= 1'b0;
    end
    else if (t_cnt_en == 1'b1)
    begin
        if (pulse_1us == 1'b1)
        begin
            if (tunit == 2'b00)
            begin
                pulse_1ms <= 1'b0;
                if (cnt_us == (tlen - 16'd1))
                begin
                    cnt_us <= 16'b0;
                end
                else
                begin
                    cnt_us <= cnt_us + 16'b1;
                end
            end
            else
            begin
                if (cnt_us == (CNT1MS - 16'd1))
                begin
                    cnt_us <= 16'b0;
                    pulse_1ms <= 1'b1;
                end
                else
                begin
                    cnt_us <= cnt_us + 16'b1;
                    pulse_1ms <= 1'b0;
                end
            end
        end
        else
        begin
            pulse_1ms <= 1'b0;
        end  
    end
end

always @(posedge clk or negedge rst_n)
begin
    if (rst_n == 1'b0)
    begin
        cnt_ms  <= 16'b0;
        pulse_1s <= 1'b0;
    end
    else if (timeout == 1'b1)
    begin
        cnt_ms  <= 16'b0;
        pulse_1s <= 1'b0;
    end
    else if (t_cnt_en == 1'b1)
    begin
        if (pulse_1ms == 1'b1)
        begin
            if (tunit == 2'b01)
            begin
                pulse_1s <= 1'b0;
                if (cnt_ms == (tlen - 16'd1))
                begin
                    cnt_ms  <= 16'b0;
                end
                else
                begin
                    cnt_ms  <= cnt_ms + 16'b1;
                end
            end
            else
            begin
                if (cnt_ms == (CNT1S - 16'd1))
                begin
                    cnt_ms  <= 16'b0;
                    pulse_1s <= 1'b1;
                end
                else
                begin
                    cnt_ms  <= cnt_ms + 16'b1;
                    pulse_1s <= 1'b0;
                end
            end
        end
        else
        begin
            cnt_ms  <= cnt_ms;
            pulse_1s <= 1'b0;
        end
    end
end

always @(posedge clk or negedge rst_n)
begin
    if (rst_n == 1'b0)
    begin
        cnt_s  <= 16'b0;
    end
    else if (timeout == 1'b1)
    begin
        cnt_s  <= 16'b0;
    end
    else if (t_cnt_en == 1'b1)
    begin
        if (pulse_1s == 1'b1)
        begin
            if (tunit == 2'b10)
            begin
                if (cnt_s == (tlen - 16'd1))
                begin
                    cnt_s  <= 16'b0;
                end
                else
                begin
                    cnt_s  <= cnt_s + 16'b1;
                end
            end
            else
            begin
                cnt_s  <= cnt_s + 16'b1;
            end
        end
        else
        begin
            cnt_s  <= cnt_s;
        end
    end
end

endmodule