library verilog;
use verilog.vl_types.all;
entity rx_module is
    generic(
        DATASENDTIME_rx : vl_logic_vector(0 to 2) := (Hi0, Hi1, Hi0)
    );
    port(
        clk             : in     vl_logic;
        rst_n           : in     vl_logic;
        rxd             : in     vl_logic;
        rx_en_sig       : in     vl_logic;
        Rx_data         : out    vl_logic_vector(47 downto 0);
        Rx_Donesig      : out    vl_logic;
        BPS_clk         : out    vl_logic;
        Rx_Donesig_pos  : out    vl_logic
    );
    attribute mti_svvh_generic_type : integer;
    attribute mti_svvh_generic_type of DATASENDTIME_rx : constant is 1;
end rx_module;
