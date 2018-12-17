library verilog;
use verilog.vl_types.all;
entity switch is
    generic(
        CNT1US          : integer := 81;
        CNT1MS          : integer := 1000;
        CNT1S           : integer := 1000;
        PATMIN          : vl_logic_vector(0 to 6) := (Hi0, Hi0, Hi0, Hi0, Hi0, Hi0, Hi0);
        PATNUM          : vl_logic_vector(0 to 6) := (Hi0, Hi0, Hi0, Hi1, Hi0, Hi1, Hi0);
        PATMAX          : vl_notype
    );
    port(
        clk             : in     vl_logic;
        rst_n           : in     vl_logic;
        sw1             : in     vl_logic;
        sw2             : in     vl_logic;
        sw3             : in     vl_logic;
        sw4             : in     vl_logic;
        Rx_Donesig      : in     vl_logic;
        Rx_data         : in     vl_logic_vector(47 downto 0);
        dis_sn          : out    vl_logic_vector(6 downto 0);
        FPGA_LED_Test   : out    vl_logic;
        en_p14v         : out    vl_logic;
        en_n14v         : out    vl_logic;
        en_gvddp        : out    vl_logic;
        en_gvddn        : out    vl_logic;
        en_vgh          : out    vl_logic;
        en_vgl          : out    vl_logic;
        mux_en1         : out    vl_logic;
        mux_en2         : out    vl_logic;
        mux_en3         : out    vl_logic;
        mux_en4         : out    vl_logic;
        mux_en_Test1    : out    vl_logic;
        mux_en_Test2    : out    vl_logic;
        en_uart         : out    vl_logic;
        read_data       : out    vl_logic_vector(79 downto 0);
        nummax          : out    vl_logic_vector(5 downto 0);
        flag_black_on   : out    vl_logic
    );
    attribute mti_svvh_generic_type : integer;
    attribute mti_svvh_generic_type of CNT1US : constant is 1;
    attribute mti_svvh_generic_type of CNT1MS : constant is 1;
    attribute mti_svvh_generic_type of CNT1S : constant is 1;
    attribute mti_svvh_generic_type of PATMIN : constant is 1;
    attribute mti_svvh_generic_type of PATNUM : constant is 1;
    attribute mti_svvh_generic_type of PATMAX : constant is 3;
end switch;
