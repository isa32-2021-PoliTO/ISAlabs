library verilog;
use verilog.vl_types.all;
entity IIR_filter_LA is
    port(
        CLK             : in     vl_logic;
        RST_n           : in     vl_logic;
        VIN             : in     vl_logic;
        VOUT            : out    vl_logic;
        DIN             : in     vl_logic_vector(13 downto 0);
        B0              : in     vl_logic_vector(13 downto 0);
        B1              : in     vl_logic_vector(13 downto 0);
        A1              : in     vl_logic_vector(13 downto 0);
        DOUT            : out    vl_logic_vector(13 downto 0)
    );
end IIR_filter_LA;
