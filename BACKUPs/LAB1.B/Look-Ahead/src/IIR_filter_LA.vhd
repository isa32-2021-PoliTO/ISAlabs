library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.constants_LA.all;

entity IIR_filter_LA is
	port(
		CLK, RST_n, VIN: in std_logic;
		VOUT: out std_logic;
		DIN:	in signed(NBIT-1 downto 0);
		B0, B1, A1: in signed(NBIT-1 downto 0);
        -- A1A1: in signed(NBIT-1 downto 0);
		DOUT: out signed(NBIT-1 downto 0));
end IIR_filter_LA;

architecture FSM of IIR_filter_LA is

signal RSTN: std_logic;
signal RC1out,RC2out,RC3out,fullPIPE: std_logic;
signal P1,P2,P3,P11: signed(NBIT-1 downto 0);
signal P4,P5,P6,P8,P9,P10: signed(NBIT downto 0);
signal P4r,P5r: signed(NBIT downto 0);

signal A2out, A3out, A4out: signed(NBIT DOWNTO 0);

signal A1A1r, B0r, B1r, A1r: signed(MULT1_IN2-1 DOWNTO 0); -- resized constants

signal M1out: signed(MULT1_OUT-1 DOWNTO 0);
signal M3out, M4out: signed(MULT3_OUT-1 DOWNTO 0);
signal M2out: signed(MULT3_OUT-1 DOWNTO 0);
signal P3shifted: signed(MULT1_OUT-1 DOWNTO 0);
signal P9shifted, P10shifted: signed(MULT3_OUT-1 DOWNTO 0);
signal P8shifted: signed(MULT3_OUT-1 DOWNTO 0); 

-- this signal was added to avoid modifying the TOP ENTITY
signal A1A1: signed(NBIT-1 downto 0) := "00000011001110"; -- A1^2 = 206

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

component subEXT is
	Port ( IN1 : in  SIGNED (NBIT-1 downto 0);
           IN2 : in  SIGNED (NBIT-1 downto 0);
           SUB : out SIGNED (NBIT downto 0));
end component;
component adder is
	Port ( IN1 : in  SIGNED (NBIT downto 0);
           IN2 : in  SIGNED (NBIT downto 0);
           SUM : out SIGNED (NBIT downto 0));
end component;

component multiplier is
	generic (
		Nin1: integer;
		Nin2: integer
		);
    Port ( IN1 : in  SIGNED (Nin1-1 downto 0); 
           IN2 : in  SIGNED (Nin2-1 downto 0);
           MULT: out SIGNED (Nin1+Nin2-1 downto 0));
end component;

begin

-- Control registers
-- Their aim is to control the filling state of the pipe

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
		b => RC2out
	);	

R_Control_3: reg_bit 
	port map(
		clk => CLK,
		rstn => RSTN,
		enable => VIN,
		a => RC2out,
		b => RC3out
	);	
	
R_Control_4: reg_bit 
	port map(
		clk => CLK,
		rstn => RSTN,
		enable => VIN,
		a => RC3out,
		b => fullPIPE
	);	
	
VOUT <= fullPIPE and VIN; -- Only if pipe is full and VIN is active we will have valid outputs

	
RIN: reg generic map (N => NBIT)
	port map(
		clk => CLK,
		rstn => RSTN,
		enable => VIN, 
		a => DIN,
		b => P1
	);

R1: reg generic map (N => NBIT)
	port map(
		clk => CLK,
		rstn => RSTN,
		enable => VIN,
		a => P1,
		b => P2
	);
	
Rp1: reg generic map (N => NBIT+1)
	port map(
		clk => CLK,
		rstn => RSTN,
		enable => VIN,
		a => P4,
		b => P4r
	);
	
Rp2: reg generic map (N => NBIT+1)
	port map(
		clk => CLK,
		rstn => RSTN,
		enable => VIN,
		a => P5,
		b => P5r
	);
	
Rp3: reg generic map (N => NBIT+1)
	port map(
		clk => CLK,
		rstn => RSTN,
		enable => VIN,
		a => P5r,
		b => P6
	);
	
ROUT: reg generic map (N => NBIT)
	port map(
		clk => CLK,
		rstn => RSTN,
		enable =>VIN,
		a => P11,
		b => DOUT
	);

A2: subEXT port map(IN1 => P1, IN2 => P3, SUB => A2out);
P4 <= A2out;

A3: adder port map(IN1 => P4r, IN2 => P8, SUM => A3out);
P5  <= A3out;

A4: adder port map(IN1 => P10, IN2 => P9, SUM => A4out);
P11 <= resize(A4out, NBIT); -- according to the external dynamic

A1r <= resize(A1, MULT1_IN2);
M1: multiplier 
	generic map(Nin1 => MULT1_IN1, Nin2 => MULT1_IN2)
	port map(IN1 => P2, IN2 => A1r, MULT => M1out);
P3shifted <= shift_right(M1out, SHIFT);
P3 <= resize(P3shifted, NBIT);
	
A1A1r <= resize(A1A1, MULT3_IN2);
M2: multiplier 
	generic map(Nin1 => MULT3_IN1, Nin2 => MULT3_IN2)
	port map(IN1 => P6, IN2 => A1A1r, MULT => M2out);
P8shifted <= shift_right(M2out, SHIFT);
P8 <= resize(P8shifted, NBIT+1);

B0r <= resize(B0, MULT3_IN2);
M3: multiplier 
	generic map(Nin1 => MULT3_IN1, Nin2 => MULT3_IN2)
	port map(IN1 => P5r, IN2 => B0r, MULT => M3out);
P10shifted <= shift_right(M3out, SHIFT);
P10 <= resize(P10shifted, NBIT+1);

B1r <= resize(B1, MULT3_IN2);
M4: multiplier	
	generic map(Nin1 => MULT3_IN1, Nin2 => MULT3_IN2)
	port map(IN1 => P6, IN2 => B1r, MULT => M4out);
P9shifted <= shift_right(M4out, SHIFT);
P9 <= resize(P9shifted, NBIT+1);

	
end architecture;
