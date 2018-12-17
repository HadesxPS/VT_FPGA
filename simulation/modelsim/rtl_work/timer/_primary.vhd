library verilog;
use verilog.vl_types.all;
entity timer is
    generic(
        CNT1US          : integer := 108;
        CNT1MS          : integer := 1000;
        CNT1S           : integer := 1000
    );
    port(
        clk             : in     vl_logic;
        rst_n           : in     vl_logic;
        start           : in     vl_logic;
        tunit           : in     vl_logic_vector(1 downto 0);
        tlen            : in     vl_logic_vector(15 downto 0);
        tpulse          : out    vl_logic
    );
    attribute mti_svvh_generic_type : integer;
    attribute mti_svvh_generic_type of CNT1US : constant is 1;
    attribute mti_svvh_generic_type of CNT1MS : constant is 1;
    attribute mti_svvh_generic_type of CNT1S : constant is 1;
end timer;
