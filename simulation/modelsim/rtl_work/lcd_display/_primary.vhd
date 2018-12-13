library verilog;
use verilog.vl_types.all;
entity lcd_display is
    generic(
        clk_l           : vl_logic_vector(0 to 1) := (Hi0, Hi0);
        clk_h           : vl_logic_vector(0 to 1) := (Hi0, Hi1);
        clk_rising_edge : vl_logic_vector(0 to 1) := (Hi1, Hi0);
        clk_falling_edge: vl_logic_vector(0 to 1) := (Hi1, Hi1);
        idle            : vl_logic_vector(0 to 2) := (Hi0, Hi0, Hi0);
        shift_data      : vl_logic_vector(0 to 2) := (Hi0, Hi0, Hi1);
        shift_data1     : vl_logic_vector(0 to 2) := (Hi0, Hi1, Hi0);
        clear_screen    : vl_logic_vector(0 to 2) := (Hi0, Hi1, Hi1);
        set_xy          : vl_logic_vector(0 to 2) := (Hi1, Hi0, Hi0);
        disp_char       : vl_logic_vector(0 to 2) := (Hi1, Hi0, Hi1);
        ONN             : vl_logic := Hi0;
        OFF             : vl_logic := Hi1;
        CMD             : vl_logic := Hi0;
        DATA            : vl_logic := Hi1
    );
    port(
        clk             : in     vl_logic;
        rst_n           : in     vl_logic;
        lcd_rst         : out    vl_logic;
        lcd_clk         : out    vl_logic;
        lcd_ce          : out    vl_logic;
        lcd_dc          : out    vl_logic;
        lcd_din         : out    vl_logic
    );
    attribute mti_svvh_generic_type : integer;
    attribute mti_svvh_generic_type of clk_l : constant is 1;
    attribute mti_svvh_generic_type of clk_h : constant is 1;
    attribute mti_svvh_generic_type of clk_rising_edge : constant is 1;
    attribute mti_svvh_generic_type of clk_falling_edge : constant is 1;
    attribute mti_svvh_generic_type of idle : constant is 1;
    attribute mti_svvh_generic_type of shift_data : constant is 1;
    attribute mti_svvh_generic_type of shift_data1 : constant is 1;
    attribute mti_svvh_generic_type of clear_screen : constant is 1;
    attribute mti_svvh_generic_type of set_xy : constant is 1;
    attribute mti_svvh_generic_type of disp_char : constant is 1;
    attribute mti_svvh_generic_type of ONN : constant is 1;
    attribute mti_svvh_generic_type of OFF : constant is 1;
    attribute mti_svvh_generic_type of CMD : constant is 1;
    attribute mti_svvh_generic_type of DATA : constant is 1;
end lcd_display;
