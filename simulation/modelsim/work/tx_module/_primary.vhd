library verilog;
use verilog.vl_types.all;
entity tx_module is
    port(
        clk             : in     vl_logic;
        txd             : out    vl_logic;
        tx_data         : in     vl_logic_vector(7 downto 0);
        rx_flag         : in     vl_logic;
        tx_rdy          : out    vl_logic;
        rst_n           : in     vl_logic
    );
end tx_module;
