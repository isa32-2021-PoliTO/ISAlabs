library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.constants.all;

entity IIR_filter is
	port(
		CLK, RST_n, VIN: in std_logic;
		VOUT: out std_logic;
		DIN, A_1, B_0, B_1:	in signed(NBIT_OUT-1 downto 0);
		DOUT: out signed(NBIT_OUT-1 downto 0));
end IIR_filter;

architecture FSM of IIR_filter is

signal RSTN: std_logic;
signal RC1out,fullFILTER: std_logic;
signal B_0_INN, B_1_INN, A_1_INN: signed(NBIT_CON-1 downto 0);
signal P1,P2,POUT: signed(NBIT_OVF-1 downto 0);
signal POUT_RED: signed(NBIT_OUT-1 downto 0);
signal PIN: signed(ADD-1 downto 0);
signal P3,P4,P5: signed(MULT_OUT-1 downto 0);
signal P5shifted,P3shifted, P4shifted: signed(MULT_OUT-1 downto 0);

component reg_bit is
port(    clk : in STD_LOGIC; 
	     rstn : in STD_LOGIC;
      enable : in STD_LOGIC;
	       a : in STD_LOGIC; 
	       b :out STD_LOGIC);
end component;

component reg is
generic (N: integer);
port(    clk : in STD_LOGIC; 
	     rstn : in STD_LOGIC;
      enable : in std_logic;
	       a : in SIGNED(N-1 downto 0);
	       b :out SIGNED(N-1 downto 0));
end component;

component adder is
	Port ( IN1 : in  SIGNED (ADD-1 downto 0);
           IN2 : in  SIGNED (ADD-1 downto 0);
           SUM : out SIGNED (ADD downto 0));
end component;

component subtractor is
	Port ( IN1 : in  SIGNED (ADD-1 downto 0);
           IN2 : in  SIGNED (ADD-1 downto 0);
           SUB : out SIGNED (ADD downto 0));
end component;

component multiplier is
	Port ( IN1 : in  SIGNED (MULT_IN1-1 downto 0); 
           IN2 : in  SIGNED (MULT_IN2-1 downto 0);
           MULT: out SIGNED (MULT_OUT-1 downto 0));
end component;

begin
	
-- Control registers
-- Their aim is to control the filling state of the filter registers

RSTN<=RST_n;

R_Control_1: reg_bit 
	port map(
		clk => CLK,
		rstn => RSTN,
		enable => VIN,
		a => '1',
		b => RC1out
	);	

R_Control_2: reg_bit 
	port map(
		clk => CLK,
		rstn => RSTN,
		enable => VIN,
		a => RC1out,
		b => fullFILTER
	);	
	
VOUT <= fullFILTER and VIN; -- Only if filter registers are full and VIN is active we will have valid outputs

RIN: reg generic map (N => NBIT_OUT)
	port map(
		clk => CLK,
		rstn => RSTN,
		enable => VIN,
		a => DIN,
		b => PIN
	);

R1: reg generic map (N => NBIT_OVF)
	port map(
		clk => CLK,
		rstn => RSTN,
		enable => VIN,
		a => P1,
		b => P2
	);

POUT_RED <= resize(POUT,NBIT_OUT);
ROUT: reg generic map (N => NBIT_OUT)
	port map(
		clk => CLK,
		rstn => RSTN,
		enable => VIN,
		a => POUT_RED, -- truncate 1 LSB according to the external dynamic
		b => DOUT
	);

P5shifted <= shift_right(P5, SHIFT); -- shift_right operation in c code
S1: subtractor port map(
		IN1 => PIN, 
		IN2 => P5shifted(ADD-1 DOWNTO 0), -- truncate MSBs
		SUB => P1
	);

P3shifted <= shift_right(P3, SHIFT); -- shift_right operation in c code
P4shifted <= shift_right(P4, SHIFT); -- shift_right operation in c code
A1: adder port map(
		IN1 => P3shifted(ADD-1 DOWNTO 0), -- truncate MSBs
		IN2 => P4shifted(ADD-1 DOWNTO 0), -- truncate MSBs
		SUM => POUT
	);

B_0_INN <= resize(B_0, NBIT_CON); -- expand
M1: multiplier -- y
	port map(
		IN1 => P1,
		IN2 => B_0_INN,
		MULT => P3
	);

B_1_INN <= resize(B_1, NBIT_CON); -- expand
M2: multiplier -- feed-forward branch (ff)
	port map(
		IN1 => P2,
		IN2 => B_1_INN,
		MULT => P4
	);

A_1_INN <= resize(A_1, NBIT_CON); -- expand
M3: multiplier -- feed-back branch (fb)
	port map(
		IN1 => P2,
		IN2 => A_1_INN,
		MULT => P5 
	);
	
end architecture;
