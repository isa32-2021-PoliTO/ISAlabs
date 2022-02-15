library ieee;
use ieee.std_logic_1164.all;
use WORK.alu_types.all;
use work.opcodes.all;

entity riscv is
port(
	CLK   : in std_logic;
    RST_N : in std_logic;

	--INSTRUCTION MEMORY testbench
	IMem_IN : in std_logic_vector(31 downto 0);    -- content from INSTRUCTION memory
	PC_OUT  : out std_logic_vector(31 downto 0);  -- address to INSTRUCTION memory

	-- DATA MEMORY testbench
	RM_OUT     : out std_logic;                    -- read enable to DATA memory
    WM_OUT     : out std_logic;                    -- write enable to DATA memory
	DM_ADD: out std_logic_vector(31 downto 0);    -- address to DATA memory
	DM_DIN: out std_logic_vector(31 downto 0);    -- content to DATA memory
	DM_DOUT: in std_logic_vector(31 downto 0)    -- content from DATA memory

	);
end riscv;


architecture structure of riscv is

component stage_1 is
generic (N: integer := 32);
port(
	CLK   : in std_logic;
	RST_N : in std_logic;
	-- from CU and Hazard unit
	EN_PC : in std_logic;
	EN_IF_ID : in std_logic;
	IF_Flush : in std_logic;
	MuxSel   : in std_logic;
	-- from stage2
	AddrJump: in std_logic_vector(31 downto 0);
	-- to stage2
	OutPIPE_MemInstruction: out std_logic_vector(31 downto 0);
	PC_S1 : out std_logic_vector(31 downto 0);
	-- to CU
	IF_ID_RS1: out std_logic_vector(4 downto 0);
	IF_ID_RS2: out std_logic_vector(4 downto 0);

	--INSTRUCTION MEMORY testbench
	IMem_IN : in std_logic_vector(31 downto 0);
	PC_OUT  : out std_logic_vector(31 downto 0));
end component;

component stage_2 is
port(
	--control unit input
	EN1    : in std_logic;               -- enables the register file and the pipeline registers ID/EX
	RF1    : in std_logic;               -- enables the read port 1 of the register file
	RF2    : in std_logic;               -- enables the read port 2 of the register file
	WF1    : in std_logic;               -- enables the write port of the register file
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
	EQ : out std_logic);
end component;

component stage_3 is
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
end component;

component stage_4_5 is
generic (N: integer := 32);
port(
	--control unit input
	-- Stage 4
	EN3    : in std_logic;               -- enables the memory and the pipeline registers MEM/WB
    RM     : in std_logic;               -- enables the read-out of t0he memory
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

	-- DATA MEMORY testbench
	RM_OUT     : out std_logic;
    WM_OUT     : out std_logic;
	DM_ADD: out std_logic_vector(N-1 downto 0);
	DM_DIN: out std_logic_vector(N-1 downto 0);
	DM_DOUT: in std_logic_vector(N-1 downto 0);

	--output to stage2 and CU
	RD_OUT: out std_logic_vector(4 downto 0);
	--output to stage2 and stage 3
	WRITE_BACK: out std_logic_vector(N-1 downto 0));
end component;

component HW_Control is
port (
	Clk : in std_logic;
	Rst : in std_logic;
    -- to stage1
	en_PC:          out std_logic;                        -- to prevent the updating of program counter
	en_IF_ID:     	out std_logic;                     	  -- to prevent the updating of IF/ID pipe register
	SPC: 			out std_logic;                  	  -- switch pc source
	IF_flush:		out std_logic;                        -- it is equal to en_STALL

	-- to stage2
	RF1:            out std_logic;              		  -- enables the read port 1 of the register file
	RF2:            out std_logic;              		  -- enables the read port 2 of the register file
	WF1:            out std_logic;              		  -- enables the write port of the register file
	Sel_Mux:        out std_logic_vector(2 downto 0);     -- control signal for the immediate generator
	SEL_MUX_RD:     out std_logic;                    -- drives the multiplexer to correct the RD

	-- to stage3
	SALU1:          out std_logic_vector(1 downto 0);     -- input selection of the ALU source
	SALU2:          out std_logic_vector(1 downto 0);     -- input selection of the ALU source
	ALUfunc:        out TYPE_OP;             			  -- WARNING! alu operator bus coded by ___constants.vhd___

	-- to stage 4_5
	RM:             out std_logic;           		      -- enables the read-out of t0he memory
	WM:             out std_logic;            	    	  -- enables the write-in of the memory
	SWB:            out std_logic;          		      -- input selection of the multiplexer

	-- from stage2
	FUNCT3:         in  std_logic_vector(FUNCT3_SIZE - 1 downto 0);
	FUNCT7:         in  std_logic_vector(FUNCT7_SIZE - 1 downto 0);
	OPCODE:         in  std_logic_vector(OP_CODE_SIZE - 1 downto 0);
	ISEQ:           in std_logic;                         -- Flag if rs1==rs2

	-- INPUTS
	-- FW unit
	-- from stage2
	ID_EX_RS1:      in std_logic_vector(4 downto 0);      -- Address of source operand1 in ID/EX pipe register
	ID_EX_RS2:      in std_logic_vector(4 downto 0);      -- Address of source operand2 in ID/EX pipe register
	-- from stage3
	EX_MEM_RD:      in std_logic_vector(4 downto 0);      -- Address of destination reg in EX/MEM pipe register
	-- from stage4_5
	MEM_WB_RD:      in std_logic_vector(4 downto 0);
	-- to stage3
	forwardA:       out std_logic_vector(1 downto 0);     -- mux selection signal for operand1
	forwardB:       out std_logic_vector(1 downto 0);     -- mux selection signal for operand2

	-- HD unit
	-- from stage2
	IF_ID_RS1:      in std_logic_vector(4 downto 0);      -- Address of source operand1 in IF/ID pipe register
	IF_ID_RS2:      in std_logic_vector(4 downto 0);      -- Address of source operand2 in IF/ID pipe register
	ID_EX_RD:       in std_logic_vector(4 downto 0)       -- Address of destination reg in ID/EX pipe register

	);

end component;

-- Signals take their names from the starting stage (NOT FOR CU)

-- from stage 1 to stage2
SIGNAL OutPIPE_MemInstruction: std_logic_vector(31 downto 0);
SIGNAL PC_S1: std_logic_vector(31 downto 0);
-- from stage1 to CU (Hazard detection Unit)
SIGNAL IF_ID_RS1: std_logic_vector(4 downto 0);
SIGNAL IF_ID_RS2: std_logic_vector(4 downto 0);

-- from stage2 to stage 1
SIGNAL BRANCH_ADDRESS: std_logic_vector(31 downto 0);

-- from stage2 to stage 3
SIGNAL IMM_GEN_OUT: std_logic_vector(31 downto 0);
SIGNAL DATA1_RF: std_logic_vector(31 downto 0);
SIGNAL DATA2_RF: std_logic_vector(31 downto 0);
SIGNAL PC_S2: std_logic_vector(31 downto 0);
SIGNAL DestReg: std_logic_vector(4 downto 0);

-- from stage2 to CU
SIGNAL ID_EX_RS1: std_logic_vector(4 downto 0);
SIGNAL ID_EX_RS2: std_logic_vector(4 downto 0);
SIGNAL EQ: std_logic;
SIGNAL OUT_OPCODEtoCU: std_logic_vector(6 downto 0);
SIGNAL Sel_Mux: std_logic_vector(2 downto 0);
SIGNAL SEL_MUX_RD:     std_logic;
SIGNAL OUT_FUNC_3: std_logic_vector(2 downto 0);
SIGNAL OUT_FUNC_7: std_logic_vector(6 downto 0);

-- from stage3 to stage4_5
SIGNAL RD_OUT: std_logic_vector(4 downto 0);
SIGNAL ALU_OUT: std_logic_vector(31 downto 0);
SIGNAL OP2_OUT: std_logic_vector(31 downto 0);

-- from stage4_5 to stage 2 and CU
SIGNAL RD_BACK: std_logic_vector(4 downto 0);
-- from stage4_5 to stage 2 and 3
SIGNAL WRITE_BACK: std_logic_vector(31 downto 0);

-- from CU to stage1
SIGNAL EN_PC: std_logic;
SIGNAL en_IF_ID: std_logic;
SIGNAL SPC: std_logic;
SIGNAL IF_flush: std_logic;

-- from CU to stage2
SIGNAL RF1: std_logic;
SIGNAL RF2: std_logic;
SIGNAL WF1: std_logic;

--from CU to stage3
SIGNAL SALU1 : std_logic_vector(1 downto 0);
SIGNAL SALU2 : std_logic_vector(1 downto 0);
SIGNAL ALUfunc : TYPE_OP;
SIGNAL forwardA : std_logic_vector(1 downto 0);
SIGNAL forwardB : std_logic_vector(1 downto 0);

-- from CU to stage 4_5
SIGNAL RM  : std_logic;
SIGNAL WM  : std_logic;
SIGNAL SWB : std_logic;


begin

STAGE1 : stage_1  GENERIC   MAP(N                         => 32)
                  PORT      MAP(CLK                       => CLK,
								RST_N                     => RST_N,
								-- from CU and Hazard unit
								EN_PC                     => EN_PC,
								EN_IF_ID                  => en_IF_ID,
								IF_Flush                  => IF_flush,
								MuxSel                    => SPC,
								-- from stage2
								AddrJump                  => BRANCH_ADDRESS,
								-- to stage2
								OutPIPE_MemInstruction    => OutPIPE_MemInstruction,
								PC_S1                     => PC_S1,
								-- to CU
								IF_ID_RS1                 => IF_ID_RS1,
								IF_ID_RS2                 => IF_ID_RS2,
								--INSTRUCTION MEMORY testbench
								IMem_IN                   => IMem_IN,
								PC_OUT                    => PC_OUT
								);


STAGE2 : stage_2  PORT      MAP(CLK                       => CLK,
								RST_N                     => RST_N,
								-- control unit input
								EN1                       => '1',               -- enables the register file and the pipeline registers ID/EX   --always active
								RF1                       => RF1,               -- enables the read port 1 of the register file
								RF2                       => RF2,               -- enables the read port 2 of the register file
								WF1                       => WF1,               -- enables the write port of the register file
								Sel_Mux                   => Sel_Mux,           -- control signal for the immediate generator
								SEL_MUX_RD								=> SEL_MUX_RD,				-- control signal to drive the multiplexer to correct the RD
								-- from stage 1
								OutPIPE_PC                => PC_S1,
								OutPIPE_MemInstruction    => OutPIPE_MemInstruction,
								-- from stage 5
								WR_DATA                   => WRITE_BACK,
								WR_ADDRESS                => RD_BACK,
								-- output to stage 1
								BRANCH_ADDRESS            => BRANCH_ADDRESS,
								-- output to stage 3
								IMM_GEN_OUT               => IMM_GEN_OUT,
								DATA1_RF                  => DATA1_RF,
								DATA2_RF                  => DATA2_RF,
								PC_S2                     => PC_S2,
								DestReg                   => DestReg,
								-- output to CU
								RS1                       => ID_EX_RS1,
								RS2                       => ID_EX_RS2,
								OUT_OPCODEtoCU            => OUT_OPCODEtoCU,
								OUT_FUNC_3                => OUT_FUNC_3,
								OUT_FUNC_7                => OUT_FUNC_7,
								EQ                        => EQ
								);

STAGE3 : stage_3  GENERIC   MAP(N                         => 32)
                  PORT      MAP(CLK                       => CLK,
								RST_N                     => RST_N,
								--control unit input
								EN2                       => '1',     --always active
								SALU1                     => SALU1,
								SALU2                     => SALU2,
								ALUfunc                   => ALUfunc,
								ForwardA                  => forwardA,
								ForwardB                  => forwardB,
								--from stage 2
								D_IN_1                    => DATA1_RF,
								D_IN_2                    => DATA2_RF,
								RD_IN                     => DestReg,
								PC                        => PC_S2,
								IMM_GEN_OUT               => IMM_GEN_OUT,

								--from stage 4_5
								DATA_FROM_DM              => WRITE_BACK,

								--output to stage 4_5
								RD_OUT                    => RD_OUT,
								ALU_OUT                   => ALU_OUT,
								OP2_OUT                   => OP2_OUT
								);

STAGE4_5: stage_4_5 GENERIC MAP(N                         => 32)
                    PORT    MAP(CLK                       => CLK,
								RST_N                     => RST_N,
								-- control unit input
								-- Stage 4
								EN3                       => '1',             -- enables the memory and the pipeline registers MEM/WB --always active
								RM                        => RM,            -- enables the read-out of t0he memory
								WM                        => WM,            -- enables the write-in of the memory
								-- Stage 5
								SWB                       => SWB,            -- input selection of the multiplexer

								--from stage 3
								RD_IN                     => RD_OUT,
								ALU_OUT                   => ALU_OUT,
								OP2_OUT                   => OP2_OUT,

								-- DATA MEMORY testbench
								RM_OUT                    => RM_OUT,
								WM_OUT                    => WM_OUT,
								DM_ADD                    => DM_ADD,
								DM_DIN                    => DM_DIN,
								DM_DOUT                   => DM_DOUT,

								--output to stage2 and CU
								RD_OUT                    => RD_BACK,
								--output to stage2 and stage 3
								WRITE_BACK                => WRITE_BACK
								);

CU: HW_Control 		PORT    MAP(Clk                       => CLK,
								Rst                       => RST_N,
								-- to stage1
								en_PC                     => EN_PC,                     -- to prevent the updating of program counter
								SPC                       => SPC,        				-- switch pc source
								en_IF_ID             	  => en_IF_ID,                  -- to prevent the updating of IF/ID pipe register
								IF_flush                  => IF_flush,                  -- it is equal to en_STALL
								--to stage2
								RF1                       => RF1,      			     	-- enables the read port 1 of the register file
								RF2                       => RF2,     					-- enables the read port 2 of the register file
								WF1                       => WF1,   					-- enables the write port of the register file
								Sel_Mux                   => Sel_Mux,      			  	-- switch the mux of the imm gen
								SEL_MUX_RD								=> SEL_MUX_RD,				-- control signal to drive the multiplexer to correct the RD

								-- to stage3
								SALU1                     => SALU1,  				    -- input selection of the ALU source
								SALU2                     => SALU2,    				    -- input selection of the ALU source
								ALUfunc                   => ALUfunc, 					-- WARNING! alu operator bus coded by ___constants.vhd___
								-- to stage4_5
								RM                        => RM,  				        -- enables the read-out of t0he memory
								WM                        => WM,					    -- enables the write-in of the memory
								SWB                       => SWB,			 		    -- input selection of the multiplexer

								-- from stage2
								FUNCT3                    => OUT_FUNC_3,
								FUNCT7                    => OUT_FUNC_7,
								OPCODE                    => OUT_OPCODEtoCU,
								ISEQ                      => EQ,


								-- FW unit
								-- from stage2
								ID_EX_RS1                 => ID_EX_RS1, 		      -- Address of source operand1 in ID/EX pipe register
								ID_EX_RS2                 => ID_EX_RS2,   			  -- Address of source operand2 in ID/EX pipe register
								-- from stage3
								EX_MEM_RD                 => RD_OUT, 				  -- Address of destination reg in EX/MEM pipe register
								-- from stage4_5
								MEM_WB_RD                 => RD_BACK,
								-- to stage3
								forwardA                  => forwardA,   			 -- mux selection signal for operand1
								forwardB                  => forwardB, 				 -- mux selection signal for operand2

								-- HD unit
								-- from stage1
								IF_ID_RS1                 => IF_ID_RS1,   	   	 -- Address of source operand1 in IF/ID pipe register
								IF_ID_RS2                 => IF_ID_RS2,  		 -- Address of source operand2 in IF/ID pipe register
								-- from stage2
								ID_EX_RD                  => DestReg   			 -- Address of destination reg in ID/EX pipe register
	);
end structure;
