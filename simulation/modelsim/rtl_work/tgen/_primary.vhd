library verilog;
use verilog.vl_types.all;
entity tgen is
    generic(
        DCODE_WHITE     : vl_logic_vector(0 to 7) := (Hi1, Hi1, Hi1, Hi1, Hi0, Hi0, Hi1, Hi0);
        DCODE_BLACK     : vl_logic_vector(0 to 7) := (Hi1, Hi0, Hi0, Hi0, Hi0, Hi1, Hi0, Hi1);
        DCODE_VCOM      : vl_logic_vector(0 to 7) := (Hi0, Hi1, Hi1, Hi1, Hi1, Hi1, Hi0, Hi0);
        DCODE_GND       : vl_logic_vector(0 to 7) := (Hi1, Hi0, Hi0, Hi0, Hi0, Hi0, Hi0, Hi0);
        DCODE_GRAY128   : vl_logic_vector(0 to 7) := (Hi1, Hi1, Hi0, Hi0, Hi0, Hi0, Hi1, Hi1);
        DCODE_GRAY64    : vl_logic_vector(0 to 7) := (Hi1, Hi0, Hi1, Hi1, Hi0, Hi1, Hi1, Hi0);
        DCODE_VCOMA     : vl_logic_vector(0 to 7) := (Hi1, Hi0, Hi0, Hi0, Hi0, Hi1, Hi0, Hi0);
        DCODE_VCOMB     : vl_logic_vector(0 to 7) := (Hi1, Hi0, Hi1, Hi0, Hi1, Hi0, Hi1, Hi0)
    );
    port(
        dis_sn          : in     vl_logic_vector(7 downto 0);
        clk             : in     vl_logic;
        rst_n           : in     vl_logic;
        da1_wr          : out    vl_logic;
        da1_a           : out    vl_logic_vector(1 downto 0);
        da1_din         : out    vl_logic_vector(7 downto 0)
    );
    attribute mti_svvh_generic_type : integer;
    attribute mti_svvh_generic_type of DCODE_WHITE : constant is 1;
    attribute mti_svvh_generic_type of DCODE_BLACK : constant is 1;
    attribute mti_svvh_generic_type of DCODE_VCOM : constant is 1;
    attribute mti_svvh_generic_type of DCODE_GND : constant is 1;
    attribute mti_svvh_generic_type of DCODE_GRAY128 : constant is 1;
    attribute mti_svvh_generic_type of DCODE_GRAY64 : constant is 1;
    attribute mti_svvh_generic_type of DCODE_VCOMA : constant is 1;
    attribute mti_svvh_generic_type of DCODE_VCOMB : constant is 1;
end tgen;
