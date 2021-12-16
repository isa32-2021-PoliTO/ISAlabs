library ieee;
use ieee.std_logic_1164.all;

entity stage_1 is
generic (N: integer := 32);
port(	     CLK   : in std_logic;
             RST_N : in std_logic;
             EN_PC : in std_logic;
       EN_Pipe_Reg : in std_logic;
	      IF_Flush : in std_logic;
	      MuxSel   : in std_logic;
		AddrJump: in std_logic_vector(63 downto 0);
		OutPIPE_PC : out std_logic_vector(63 downto 0);	
OutPIPE_MemInstruction: out std_logic_vector(N-1 downto 0));
        	
end entity;


architecture structure of stage_1 is

--signals
signal out_Mux: std_logic_vector(63 downto 0);
signal out_PC : std_logic_vector(63 downto 0);
signal out_adder : std_logic_vector(63 downto 0);
signal out_Instr_Mem : std_logic_vector(N-1 downto 0);
signal out_Pipe : std_logic_vector(N-1 downto 0);
signal in_Pipe : std_logic_vector(95 downto 0);
  
  
component MUX_2_to_1 is
generic(N: integer );
port( IN1,IN2 : in std_logic_vector(N-1 downto 0);
          SEL : in std_logic;
       OUTPUT : out std_logic_vector(N-1 downto 0));
end component;


component PC is
generic (N: integer);
port( 	clk : in std_logic; 
	  rst_n : in std_logic;
		 en : in std_logic;
		  a : in std_logic_vector(N-1 downto 0);
		  b : out std_logic_vector(N-1 downto 0));
end component;


component PipeRegisterNbit is
generic (N: integer);
port( 	clk : in std_logic; 
	  rst_n : in std_logic;
		 en : in std_logic;
	  INPUT : in std_logic_vector(N-1 downto 0);
	 OUTPUT :out std_logic_vector(N-1 downto 0));
end component;


component Adder_4cells is
generic (N: integer);
port( 	IN1 : in std_logic_vector(N-1 downto 0);  
		SUM : out std_logic_vector(N-1 downto 0));
end component;
  
  
begin
Mux_1 : MUX_2_to_1 generic map (N => 64)
	port map(
		IN1 => out_adder, --sequetial address  
		IN2 => AddrJump, --jump address
        SEL => MuxSel,
     OUTPUT => out_Mux
	);
	
ProgramCounter: PC generic map (N => 64)
	port map(
		clk => CLK,
	  rst_n => RST_N,
		 en => EN_PC,
		  a => out_Mux,
		  b => out_PC
	);
	
	
Incrementer : Adder_4cells generic map (N => 64)
	port map( 	
		IN1 => out_PC, 
		SUM => out_adder
	);
	
in_Pipe <= out_PC & out_Instr_Mem;

IF_ID_Pipe : PipeRegisterNbit generic map (N => 96)
port map( 	clk => CLK, 
	  rst_n => RST_N,
		 en => EN_Pipe_Reg,
	  INPUT => in_Pipe,
	 OUTPUT => out_Pipe
	);


OutPIPE_PC <= out_Pipe(95 downto 32);  --Attenzione a questo !!!!!
OutPIPE_MemInstruction <= out_Pipe(31 downto 0);  --Attenzione a questo !!!!!

	
  end architecture;

