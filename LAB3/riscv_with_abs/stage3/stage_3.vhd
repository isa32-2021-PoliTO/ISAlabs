library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use WORK.alu_types.all;

entity stage_3 is
generic (N: integer := 32);
port(	     
	--control unit input
	EN2: in std_logic;               
    SALU1: in std_logic_vector(1 downto 0);
	SALU2: in std_logic_vector(1 downto 0);
    ALUfunc: in TYPE_OP;             
	ForwardA: in std_logic_vector(1 downto 0);
	ForwardB: in std_logic_vector(1 downto 0);
	
	--clk and rst
	CLK   : in std_logic;
    RST_N : in std_logic;
		
	--from stage 2
	D_IN_1: in std_logic_vector(N-1 downto 0);
	D_IN_2: in std_logic_vector(N-1 downto 0);
    RD_IN: in std_logic_vector(4 downto 0);
	PC: in std_logic_vector(N-1 downto 0);
	IMM_GEN_OUT: in std_logic_vector(N-1 downto 0);
	
	--from stage 4_5
	DATA_FROM_DM: in std_logic_vector(N-1 downto 0);
	
	--output to stage 4_5
	RD_OUT: out std_logic_vector(4 downto 0);
	ALU_OUT: out std_logic_vector(N-1 downto 0);
	OP2_OUT: out std_logic_vector(N-1 downto 0));
	
	
end stage_3;


architecture structure of stage_3 is

component PipeRegisterNbit is
generic (N: integer);
port( 	clk : in std_logic; 
	  rst_n : in std_logic;
		 en : in std_logic;
	  INPUT : in std_logic_vector(N-1 downto 0);
	 OUTPUT :out std_logic_vector(N-1 downto 0));
end component;

component ALU is
generic (N : integer := 32);
port 	 ( FUNC: IN TYPE_OP;
           DATA1, DATA2: IN std_logic_vector(N-1 downto 0);
           OUTALU: OUT std_logic_vector(N-1 downto 0));
end component;

component MUX_2_to_1 is
generic(N: integer );
port( IN1,IN2 : in std_logic_vector(N-1 downto 0);
          SEL : in std_logic;
       OUTPUT : out std_logic_vector(N-1 downto 0));
end component;

component MUX_4_to_1 is
generic(N: integer );
port( IN1,IN2,IN3,IN4 : in std_logic_vector(N-1 downto 0);
          SEL : in std_logic_vector(1 downto 0);
       OUTPUT : out std_logic_vector(N-1 downto 0));
end component;

SIGNAL RS1: std_logic_vector(N-1 downto 0);
SIGNAL RS2: std_logic_vector(N-1 downto 0);
SIGNAL OP1: std_logic_vector(N-1 downto 0);
SIGNAL OP2: std_logic_vector(N-1 downto 0);
SIGNAL RES: std_logic_vector(N-1 downto 0);
SIGNAL in_Pipe: std_logic_vector(68 downto 0);
SIGNAL out_Pipe: std_logic_vector(68 downto 0);

SIGNAL fourinteger: integer := 4;
SIGNAL four32bit: std_logic_vector(N-1 downto 0);
begin

-- Connection according to scheme in figure MUXmod.jpg in the folder

MuxForwardA:    MUX_4_to_1 GENERIC MAP (N => 32) 
                           PORT    MAP (IN1 => D_IN_1, 
										In2 => DATA_FROM_DM, 
										In3 => out_Pipe(68 downto 37), 
										IN4 => (others =>'U'), 
										SEL => ForwardA, 
										OUTPUT => RS1);
MuxForwardB:    MUX_4_to_1 GENERIC MAP (N => 32) 
                           PORT    MAP (IN1 => D_IN_2, 
										In2 => DATA_FROM_DM, 
										In3 => out_Pipe(68 downto 37), 
										IN4 => (others =>'U'), 
										SEL => ForwardB, 
										OUTPUT => RS2);
MuxOperandA:    MUX_4_to_1 GENERIC MAP (N => 32) 
                           PORT    MAP (IN1 => RS1, 
										In2 => PC, 
										IN3 => (others =>'0'), 
										IN4 => (others =>'U'),              
										SEL => SALU1, 
										OUTPUT => OP1);
MuxOperandB:    MUX_4_to_1 GENERIC MAP (N => 32) 
                           PORT    MAP (IN1 => RS2, 
										In2 => IMM_GEN_OUT, 
										IN3 => (others =>'0'), 
										IN4 => four32bit, 
										SEL => SALU2, 
										OUTPUT => OP2);
-- This is the number four on 32 bits for MuxOperandB input						
four32bit <= std_logic_vector(to_unsigned(fourinteger,N));
										
										
ArithLogicUnit: ALU        GENERIC MAP (N => 32) 
                           PORT    MAP (FUNC => ALUfunc, DATA1 => OP1, DATA2 => OP2, OUTALU => RES);

in_Pipe(4 downto 0) <= RD_IN; 
in_Pipe(36 downto 5) <= D_IN_2;
in_Pipe(68 downto 37) <= RES; 

IF_ID_Pipe : PipeRegisterNbit generic map (N => 69)
port map( 	clk => CLK, 
			rst_n => RST_N,
			en => EN2, 
			INPUT => in_Pipe,
			OUTPUT => out_Pipe
		);

RD_OUT <= out_Pipe(4 downto 0); 
OP2_OUT<= out_Pipe(36 downto 5); 
ALU_OUT<= out_Pipe(68 downto 37);

end structure;

