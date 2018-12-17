library verilog;
use verilog.vl_types.all;
entity glf is
    generic(
        CNT1US          : integer := 107;
        CNT1MS          : integer := 1000;
        CNT1S           : integer := 1000
    );
    port(
        clk             : in     vl_logic;
        rst_n           : in     vl_logic;
        en              : in     vl_logic;
        s_in            : in     vl_logic;
        s_out           : out    vl_logic
    );
    attribute mti_svvh_generic_type : integer;
    attribute mti_svvh_generic_type of CNT1US : constant is 1;
    attribute mti_svvh_generic_type of CNT1MS : constant is 1;
    attribute mti_svvh_generic_type of CNT1S : constant is 1;
end glf;
