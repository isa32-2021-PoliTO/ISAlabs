library verilog;
use verilog.vl_types.all;
entity IIR_filter is
    port(
        CLK             : in     vl_logic;
        RST_n           : in     vl_logic;
        VIN             : in     vl_logic;
        VOUT            : out    vl_logic;
        DIN             : in     vl_logic_vector(13 downto 0);
        A_1             : in     vl_logic_vector(13 downto 0);
        B_0             : in     vl_logic_vector(13 downto 0);
        B_1             : in     vl_logic_vector(13 downto 0);
        DOUT            : out    vl_logic_vector(13 downto 0)
    );
end IIR_filter;
