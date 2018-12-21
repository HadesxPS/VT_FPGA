library verilog;
use verilog.vl_types.all;
entity uart is
    generic(
        IDLE            : vl_logic_vector(0 to 3) := (Hi0, Hi0, Hi0, Hi0);
        RECIEVE         : vl_logic_vector(0 to 3) := (Hi0, Hi0, Hi0, Hi1);
        DATADIVE        : vl_logic_vector(0 to 3) := (Hi0, Hi0, Hi1, Hi0);
        SEND            : vl_logic_vector(0 to 3) := (Hi0, Hi0, Hi1, Hi1);
        SENDDELAY       : vl_logic_vector(0 to 3) := (Hi0, Hi1, Hi0, Hi0);
        WAIT_TX_TEST1   : vl_logic_vector(0 to 3) := (Hi0, Hi1, Hi0, Hi1);
        WAIT_TX_TEST2   : vl_logic_vector(0 to 3) := (Hi0, Hi1, Hi1, Hi0);
        WAIT_TX_TEST3   : vl_logic_vector(0 to 3) := (Hi0, Hi1, Hi1, Hi1);
        WAIT_TX_TEST4   : vl_logic_vector(0 to 3) := (Hi1, Hi0, Hi0, Hi0);
        WAIT_TX_TEST5   : vl_logic_vector(0 to 3) := (Hi1, Hi0, Hi0, Hi1)
    );
    port(
        clk             : in     vl_logic;
        en_uart         : in     vl_logic;
        sw1             : in     vl_logic;
        rst_n           : in     vl_logic;
        tx_rdy          : in     vl_logic;
        serial_data     : in     vl_logic_vector(79 downto 0);
        DATASENDTIME    : in     vl_logic_vector(5 downto 0);
        uart_data       : out    vl_logic_vector(7 downto 0);
        uart_wr         : out    vl_logic;
        FPGA_LED_Test   : out    vl_logic
    );
    attribute mti_svvh_generic_type : integer;
    attribute mti_svvh_generic_type of IDLE : constant is 1;
    attribute mti_svvh_generic_type of RECIEVE : constant is 1;
    attribute mti_svvh_generic_type of DATADIVE : constant is 1;
    attribute mti_svvh_generic_type of SEND : constant is 1;
    attribute mti_svvh_generic_type of SENDDELAY : constant is 1;
    attribute mti_svvh_generic_type of WAIT_TX_TEST1 : constant is 1;
    attribute mti_svvh_generic_type of WAIT_TX_TEST2 : constant is 1;
    attribute mti_svvh_generic_type of WAIT_TX_TEST3 : constant is 1;
    attribute mti_svvh_generic_type of WAIT_TX_TEST4 : constant is 1;
    attribute mti_svvh_generic_type of WAIT_TX_TEST5 : constant is 1;
end uart;
