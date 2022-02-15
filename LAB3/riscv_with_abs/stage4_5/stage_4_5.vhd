library ieee;
use ieee.std_logic_1164.all;

entity stage_4_5 is
generic (N: integer := 32);
port(	     
	--control unit input
	-- Stage 4
	EN3    : in std_logic;               -- enables the memory and the pipeline registers MEM/WB
    RM     : in std_logic;               -- enables the read-out of the memory
    WM     : in std_logic;               -- enables the write-in of the memory
	-- Stage 5
    SWB     : in std_logic;             -- input selection of the multiplexer
	
	--clk and rst
	CLK   : in std_logic;
    RST_N : in std_logic;
		
	--from stage 3
	RD_IN: in std_logic_vector(4 downto 0);
	ALU_OUT: in std_logic_vector(N-1 downto 0);
	OP2_OUT: in std_logic_vector(N-1 downto 0);
	
	-- DATA MEMORY
	RM_OUT     : out std_logic;
    WM_OUT     : out std_logic; 
	DM_ADD: out std_logic_vector(N-1 downto 0);
	DM_DIN: out std_logic_vector(N-1 downto 0);
	DM_DOUT: in std_logic_vector(N-1 downto 0);
	
	--output to stage2 and CU
	RD_OUT: out std_logic_vector(4 downto 0);
	--output to stage2 and stage 3
	WRITE_BACK: out std_logic_vector(N-1 downto 0));
	
	
	
end stage_4_5;


architecture structure of stage_4_5 is

component PipeRegisterNbit is
generic (N: integer);
port( 	clk : in std_logic; 
	  rst_n : in std_logic;
		 en : in std_logic;
	  INPUT : in std_logic_vector(N-1 downto 0);
	 OUTPUT :out std_logic_vector(N-1 downto 0));
end component;


component MUX_2_to_1 is
generic(N: integer );
port( IN1,IN2 : in std_logic_vector(N-1 downto 0);
          SEL : in std_logic;
       OUTPUT : out std_logic_vector(N-1 downto 0));
end component;

SIGNAL ALU_BYPASS: std_logic_vector(N-1 downto 0);
SIGNAL DM_CONTENT: std_logic_vector(N-1 downto 0);
SIGNAL in_Pipe: std_logic_vector(68 downto 0);
SIGNAL out_Pipe: std_logic_vector(68 downto 0);

begin

-- TOWARDS MEMORY CONNECTION
RM_OUT <= RM;
WM_OUT <= WM;
DM_ADD <= ALU_OUT;
DM_DIN <= OP2_OUT;

-- PIPE REG CONNECTION
in_Pipe(4 downto 0) <= RD_IN; 
in_Pipe(36 downto 5) <= ALU_OUT; 
in_Pipe(68 downto 37) <= DM_DOUT; 

IF_ID_Pipe : PipeRegisterNbit generic map (N => 69)
port map( 	clk => CLK, 
			rst_n => RST_N,
			en => EN3, 
			INPUT => in_Pipe,
			OUTPUT => out_Pipe
		);

RD_OUT <= out_Pipe(4 downto 0); 
ALU_BYPASS <= out_Pipe(36 downto 5); 
DM_CONTENT <= out_Pipe(68 downto 37);

-- SWB=0 for MEMORY bypass 
-- SWB=1 for MEMORY LOAD
Mux: MUX_2_to_1 GENERIC MAP (N => 32) PORT MAP(IN1 => ALU_BYPASS, In2 => DM_CONTENT, SEL => SWB, OUTPUT => WRITE_BACK); 

end structure;

