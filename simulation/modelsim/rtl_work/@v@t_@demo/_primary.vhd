library verilog;
use verilog.vl_types.all;
entity VT_Demo is
    port(
        clk_in          : in     vl_logic;
        sw1             : in     vl_logic;
        sw2             : in     vl_logic;
        sw6             : in     vl_logic;
        en_p14v         : out    vl_logic;
        en_n14v         : out    vl_logic;
        en_gvddp        : out    vl_logic;
        en_gvddn        : out    vl_logic;
        da1_wr          : out    vl_logic;
        da1_a           : out    vl_logic_vector(1 downto 0);
        da1_din         : out    vl_logic_vector(7 downto 0)
    );
end VT_Demo;
