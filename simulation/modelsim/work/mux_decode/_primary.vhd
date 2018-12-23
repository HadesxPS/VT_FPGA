library verilog;
use verilog.vl_types.all;
entity mux_decode is
    port(
        clk             : in     vl_logic;
        da              : in     vl_logic;
        db              : in     vl_logic;
        a               : out    vl_logic_vector(1 downto 0)
    );
end mux_decode;
