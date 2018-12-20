library verilog;
use verilog.vl_types.all;
entity switch is
    generic(
        CNT1US          : integer := 81;
        CNT1MS          : integer := 1000;
        CNT1S           : integer := 1000;
        PATMIN          : vl_logic_vector(0 to 7) := (Hi0, Hi1, Hi1, Hi1, Hi1, Hi1, Hi1, Hi1);
        PATMAX          : vl_logic_vector(0 to 7) := (Hi1, Hi1, Hi1, Hi1, Hi1, Hi1, Hi1, Hi1)
    );
    port(
        en_p14v         : out    vl_logic;
        en_n14v         : out    vl_logic;
        en_gvddp        : out    vl_logic;
        en_gvddn        : out    vl_logic;
        clk             : in     vl_logic;
        rst_n           : in     vl_logic;
        sw1             : in     vl_logic;
        sw2             : in     vl_logic;
        dis_sn          : out    vl_logic_vector(7 downto 0)
    );
    attribute mti_svvh_generic_type : integer;
    attribute mti_svvh_generic_type of CNT1US : constant is 1;
    attribute mti_svvh_generic_type of CNT1MS : constant is 1;
    attribute mti_svvh_generic_type of CNT1S : constant is 1;
    attribute mti_svvh_generic_type of PATMIN : constant is 1;
    attribute mti_svvh_generic_type of PATMAX : constant is 1;
end switch;
