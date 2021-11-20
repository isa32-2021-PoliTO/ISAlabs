package CONSTANTS is

	constant NBIT_OVF : integer := 15;
	constant NBIT_OUT : integer := 14;
	constant NBIT_CON : integer := 13;
	
	constant SHIFT    : integer := 13;
	
	constant ADD : integer := 14;
	
	constant MULT_IN1 : integer := 15;
	constant MULT_IN2 : integer := 13;
	constant MULT_OUT : integer := MULT_IN1 + MULT_IN2;
	
end CONSTANTS;