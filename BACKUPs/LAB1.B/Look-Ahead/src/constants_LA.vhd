package constants_LA is

	constant NBIT : integer := 14;

	constant NBIT_CON1 : integer := 13; -- for smaller MULT
	constant NBIT_CON2 : integer := 24; -- for larger MULT

	constant SHIFT    : integer := 13;

	-- smaller MULT
	constant MULT1_IN1 : integer := 14;
	constant MULT1_IN2 : integer := 13;
	constant MULT1_OUT : integer := MULT1_IN1 + MULT1_IN2;
	
	-- smaller MULT with EXT
	constant MULT3_IN1 : integer := 15;
	constant MULT3_IN2 : integer := 13;
	constant MULT3_OUT : integer := MULT3_IN1 + MULT3_IN2;

end constants_LA;
