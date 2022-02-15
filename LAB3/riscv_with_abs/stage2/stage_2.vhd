library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity stage_2 is
port(
		--control unit input
		EN1    : in std_logic;                      -- enables the register file and the pipeline registers ID/EX
        RF1    : in std_logic;                      -- enables the read port 1 of the register file
        RF2    : in std_logic;                      -- enables the read port 2 of the register file
        WF1    : in std_logic;                      -- enables the write port of the register file
		Sel_Mux: in std_logic_vector(2 downto 0);    -- control signal for the immediate generator
	  SEL_MUX_RD:     in std_logic;                    -- drives the multiplexer to correct the RD

		--clk and rst
		CLK   : in std_logic;
        RST_N : in std_logic;

		--from stage 1
		OutPIPE_PC : in std_logic_vector(31 downto 0);
		OutPIPE_MemInstruction: in std_logic_vector(31 downto 0);
		--from stage 5
		WR_DATA : in std_logic_vector(31 downto 0);
		WR_ADDRESS : in std_logic_vector (4 downto 0);

		--output to stage 1
		BRANCH_ADDRESS : out std_logic_vector(31 downto 0);

		--output to stage 3
		IMM_GEN_OUT :out std_logic_vector(31 downto 0);

		DATA1_RF :out std_logic_vector(31 downto 0);
		DATA2_RF :out std_logic_vector(31 downto 0);
		PC_S2 :out std_logic_vector(31 downto 0);
		DestReg : OUT std_logic_vector(4 downto 0);

		--output to CU
		RS1: 		OUT std_logic_vector(4 downto 0);
		RS2: 		OUT std_logic_vector(4 downto 0);
		OUT_OPCODEtoCU : out std_logic_vector(6 downto 0);
		OUT_FUNC_3: out std_logic_vector(2 downto 0);
		OUT_FUNC_7: out std_logic_vector(6 downto 0);

		--output to Hazard unit
		EQ : out std_logic
		);
end entity;


architecture structure of stage_2 is

--signals

signal out_IMM_GEN: std_logic_vector(31 downto 0);
signal slv_out_imm: std_logic_vector(31 downto 0);


--two data from the register file
signal OUT_RF1: std_logic_vector(31 downto 0);
signal OUT_RF2: std_logic_vector(31 downto 0);


--signal for comaparator
signal XOR_RESULT: std_logic_vector(31 downto 0);



signal out_PC : std_logic_vector(31 downto 0);
signal out_adder : std_logic_vector(31 downto 0);
signal out_Instr_Mem : std_logic_vector(31 downto 0);

signal in_Pipe : std_logic_vector(142 downto 0);
signal out_Pipe : std_logic_vector(142 downto 0);


signal RD_signal : std_logic_vector(4 downto 0);
signal RD : std_logic_vector(4 downto 0);





component PipeRegisterNbit is
generic (N: integer);
port( 	clk : in std_logic;
	  rst_n : in std_logic;
		 en : in std_logic;
	  INPUT : in std_logic_vector(N-1 downto 0);
	 OUTPUT :out std_logic_vector(N-1 downto 0));
end component;


component ImmediateGenerator is
generic(N: integer );
PORT (
		MuxSel:in std_logic_vector(2 downto 0);
		input: in std_logic_vector(31 downto 7);
		output: out std_logic_vector(N-1 downto 0)
);
end component;

component XOR_Block is
generic(N: integer);
port (
		IN1 : in  std_logic_vector (N-1 downto 0) ;
        IN2 : in  std_logic_vector (N-1 downto 0) ;
        out_XOR  : out std_logic_vector (N-1 downto 0));
end component;



component register_file is
generic ( NBIT : integer := 32;  --Parallelism of the arch
          NREG : integer := 32); --Numbers of registers in RF
port (
	 CLK:     IN std_logic;
   RESET: 	IN std_logic;
	 RD1: 		IN std_logic;
	 RD2: 		IN std_logic;
	 WR: 		IN std_logic;
	 ADD_WR: 	IN std_logic_vector(4 downto 0);
	 ADD_RD1: 	IN std_logic_vector(4 downto 0);
	 ADD_RD2: 	IN std_logic_vector(4 downto 0);
	 DATAIN: 	IN std_logic_vector(NBIT-1 downto 0);
     OUT1: 		OUT std_logic_vector(NBIT-1 downto 0);
	 OUT2: 		OUT std_logic_vector(NBIT-1 downto 0));
end component;


component Adder_Nbit is
generic (N: integer);
port( 	IN1 : in std_logic_vector(N-1 downto 0);
		IN2 : in std_logic_vector(N-1 downto 0);
		SUM : out std_logic_vector(N-1 downto 0));
end component;







begin

IMM_GEN: ImmediateGenerator generic map(N => 32)
port map(
		MuxSel => Sel_Mux,
		input => OutPIPE_MemInstruction(31 downto 7),
		output => out_IMM_GEN
);



ADDER: Adder_Nbit generic map (N => 32)
port map(
		IN1 => OutPIPE_PC,
		IN2 => out_IMM_GEN,
		SUM => BRANCH_ADDRESS
		);


RF: register_file generic map( NBIT => 32,  --Parallelism of the arch
							   NREG => 32) --Numbers of registers in RF
port map(
   CLK => CLK,
     	 RESET => RST_N,
	 RD1 => RF1,
	 RD2 => RF2,
	 WR => WF1,
	 ADD_WR =>  WR_ADDRESS,
	 ADD_RD1 => OutPIPE_MemInstruction(19 downto 15),
	 ADD_RD2 =>OutPIPE_MemInstruction(24 downto 20),
	 DATAIN => WR_DATA,
   OUT1 => OUT_RF1,
	 OUT2 => OUT_RF2
	 );

COMPARATOR :XOR_Block generic map(N =>32)
port map(
		IN1 => OUT_RF1,
        IN2 => OUT_RF2,
        out_XOR => XOR_RESULT
		);



--camparison between the two data from the register file
-- EQ is 1 if IN1 and IN2 are equal
EQ <= NOT(	XOR_RESULT(0) OR XOR_RESULT(1) OR XOR_RESULT(2) OR XOR_RESULT(3) OR XOR_RESULT(4) OR XOR_RESULT(5) OR XOR_RESULT(6) OR XOR_RESULT(7) OR
		XOR_RESULT(8) OR XOR_RESULT(9) OR XOR_RESULT(10) OR XOR_RESULT(11) OR XOR_RESULT(12) OR XOR_RESULT(13) OR XOR_RESULT(14) OR XOR_RESULT(15) OR
		XOR_RESULT(16) OR XOR_RESULT(17) OR XOR_RESULT(18) OR XOR_RESULT(19) OR XOR_RESULT(20) OR XOR_RESULT(21) OR XOR_RESULT(22) OR XOR_RESULT(23) OR
		XOR_RESULT(24) OR XOR_RESULT(25) OR XOR_RESULT(26) OR XOR_RESULT(27) OR XOR_RESULT(28) OR XOR_RESULT(29) OR XOR_RESULT(30) OR XOR_RESULT(31));



slv_out_imm <= out_IMM_GEN;


in_Pipe(142 downto 111) <= OutPIPE_PC;
in_Pipe(110 downto 79) <= OUT_RF1;
in_Pipe(78 downto 47) <= OUT_RF2;
in_Pipe(46 downto 15) <= slv_out_imm;
in_Pipe(14 downto 10) <= OutPIPE_MemInstruction (24 downto 20); --RS2
in_Pipe(9 downto 5) <= OutPIPE_MemInstruction(19 downto 15); --RS1
in_Pipe(4 downto 0) <= RD_signal;

Pipe_ID_EX : PipeRegisterNbit generic map(N => 143)
port map(
		clk =>CLK,
	  rst_n =>RST_N,
		 en =>EN1,
	  INPUT => in_Pipe,
	 OUTPUT => out_Pipe
	 );


--input stage1
OUT_OPCODEtoCU <= OutPIPE_MemInstruction (6 downto 0);

-- Switch between zero and RD
MUX_RD_p: process( SEL_MUX_RD, OutPIPE_MemInstruction )
begin
	IF (SEL_MUX_RD = '1') THEN
		RD_signal <= (others => '0');
	ELSE
		RD_signal <= OutPIPE_MemInstruction (11 downto 7);
	END IF;
end process;

--output stage2
OUT_FUNC_3 <= OutPIPE_MemInstruction (14 downto 12);
OUT_FUNC_7 <= OutPIPE_MemInstruction (31 downto 25);

RD <= out_Pipe(4 downto 0); --to Hazard unit and Stage 2
RS1 <= out_Pipe(9 downto 5);
RS2 <= out_Pipe(14 downto 10);
IMM_GEN_OUT <= out_Pipe(46 downto 15);
DATA2_RF <= out_Pipe(78 downto 47);
DATA1_RF <= out_Pipe(110 downto 79);
PC_S2 <= out_Pipe (142 downto 111);

DestReg <= RD;
end architecture;
