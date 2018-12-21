library verilog;
use verilog.vl_types.all;
entity clkrst is
    port(
        clk_in          : in     vl_logic;
        rst_n_in        : in     vl_logic;
        clk_sys         : out    vl_logic;
        rst_n_sys       : out    vl_logic
    );
end clkrst;
