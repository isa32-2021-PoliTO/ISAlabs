library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;
use work.opcodes.all;
use work.cu_types.all;
use work.alu_types.all;

entity HW_Control is
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
	SEL_MUX:        out std_logic_vector(2 downto 0);     -- switch the mux of the imm gen
  SEL_MUX_RD:     out std_logic;                    -- drives the multiplexer to correct the RD

	-- to stage3
	SALU1:          out std_logic_vector(1 downto 0);     -- input selection of the ALU source1
	SALU2:          out std_logic_vector(1 downto 0);     -- input selection of the ALU source2
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
	-- from stage1
	IF_ID_RS1:      in std_logic_vector(4 downto 0);      -- Address of source operand1 in IF/ID pipe register
	IF_ID_RS2:      in std_logic_vector(4 downto 0);      -- Address of source operand2 in IF/ID pipe register
	-- from stage2
	ID_EX_RD:       in std_logic_vector(4 downto 0)      -- Address of destination reg in ID/EX pipe register
	);
end HW_Control;


architecture Controlling of HW_Control is

  constant ID_SIZE :  integer := 9;--ID pipe dimension
  constant EX_SIZE :  integer := 4;--EX pipe dimension
  constant MEM_SIZE : integer := 2;--MEM pipe dimension
  constant WB_SIZE :  integer := 2;--WB pipe dimension
	--Control word pipe dimensions (CWi)
  constant CW_SIZE : integer := ( ID_SIZE + EX_SIZE + MEM_SIZE + WB_SIZE );  -- Control Word Size

  constant CW1_SIZE : integer := (CW_SIZE - (ID_SIZE));  -- Control Word 1 Size
  constant CW2_SIZE : integer := (CW_SIZE - (ID_SIZE + EX_SIZE));  -- Control Word 1 Size
  constant CW3_SIZE : integer := (CW_SIZE - (ID_SIZE + EX_SIZE + MEM_SIZE));  -- Control Word 1 Size

  signal cw : std_logic_vector(CW_SIZE - 1 downto 0); -- full control word read from cw_mem

  type mem_array is array (integer range 0 to uC_SIZE - 1) of std_logic_vector(CW_SIZE - 1 downto 0);
  constant cw_mem : mem_array := ( --this is the control word code register it is addressed by the opcode
				"11000001000000010", -- oRTYPE
				"10001001101000010", -- oITYPE
				"00011010011010010", -- oJAL
				"00010000001010010", -- oAUIPC
				"00010000001100010", -- oLUI
				"10001000001000111", -- oLOAD
				"11000000001001000", -- oSTORE
				"11100100000000000", -- oBRANCH
				"10101001101000010"  -- oSITYPE
				);
  signal CHANGE_PC_SRC: std_logic;
  signal JMP  : std_logic; --enable the MUX on program counter directly
  signal BEQ  : std_logic;               -- enables branch for SPC if zero
  signal ALUop : std_logic_vector(1 downto 0); --This signal goes to ALU control unit
  signal ALUfunc0 : TYPE_OP; --This siganl goes from ALUCU to ALU unit

  signal CUop : optype_t;

  -- CU tells to HD if data is read from data memory with this
  signal ID_EX_MR : std_logic;

  -- CU tells if data is written in two different stages
  signal EX_MEM_RW : std_logic;
  signal MEM_WB_RW : std_logic;

  -- control word is shifted to the correct stage
  signal cw1 : std_logic_vector(CW1_SIZE - 1 downto 0); -- ex+mem+wb stage controls
  signal cw2 : std_logic_vector(CW2_SIZE - 1 downto 0); -- mem+wb stage controls
  signal cw3 : std_logic_vector(CW3_SIZE - 1 downto 0); -- wb stage controls

  -- generated from Hazard detection unit
  signal en_STALL:std_logic;


begin
----------------------------------------------
-- Sequential Part
 -- process to pipeline control words
  CW_PIPE: process (Clk, Rst)
  begin  -- process Clk
    if Rst = '0' then                   -- asynchronous reset (active low)
      cw1 <= (others => '0'); -- all sections of the pipeline are reset to 0 () ()
      cw2 <= (others => '0'); --                                             ('o')
      cw3 <= (others => '0');
    elsif Clk'event and Clk = '1' then  -- rising clock edge
      cw1 <=  cw(CW1_SIZE - 1 downto 0); -- the control word is passed to the first stage of the pipeline
      cw2 <= cw1(CW2_SIZE - 1 downto 0); --the word is propogated to the next pipeline stages
      cw3 <= cw2(CW3_SIZE - 1 downto 0);
	  ALUfunc<=ALUfunc0; -- next value for the alu is loaded to the alu so that the next instruction can be serviced

    end if;
  end process CW_PIPE;

---------------------------------------------
-- Combinational Part

  -- Mux for stalling
  MUX_p: process(CUop, en_STALL)
  begin
    if (en_STALL = '1') then
      cw <= std_logic_vector(conv_unsigned(0, CW_SIZE)); -- Put zero if stall
    else
      cw <= cw_mem(conv_integer(CUop)); -- the control word register is loaded with the correct value from the memory using ht opcode as an index
    end if;
  end process;
-- Bindings of the signals controlled by the CW
  -- ID
  RF1       <= cw(CW_SIZE - 1 - 0);
  RF2       <= cw(CW_SIZE - 1 - 1);
  SEL_MUX   <= cw(CW_SIZE - 1 - 2 downto CW_SIZE - 1 - 4);
  BEQ       <= cw(CW_SIZE - 1 - 5);
  JMP       <= cw(CW_SIZE - 1 - 6);
  ALUop     <= cw(CW_SIZE - 1 - 7 downto CW_SIZE - 1 - 8);
  -- EX
  SALU2     <= cw1(CW1_SIZE - 1 - 0 downto CW1_SIZE - 1 - 1);
  SALU1     <= cw1(CW1_SIZE - 1 - 2 downto CW1_SIZE - 1 - 3);
  -- MEM
  WM        <= cw2(CW2_SIZE - 1 - 0);
  RM        <= cw2(CW2_SIZE - 1 - 1);
  -- WB
  WF1       <= cw3(CW3_SIZE - 1 - 0);
  SWB       <= cw3(CW3_SIZE - 1 - 1);

  -- HW Bindings
  ID_EX_MR  <= cw1(CW2_SIZE - 1 - 1); -- The same of RM but taken the stage before

  -- FW Bindings
  EX_MEM_RW <= cw2(CW3_SIZE - 1 - 0);
  MEM_WB_RW <= cw3(CW3_SIZE - 1 - 0);

  -- This is the unit controlling the MUX on PC
  CHANGE_PC_SRC <= (ISEQ AND BEQ) OR JMP;
  JandB_u : SPC <= CHANGE_PC_SRC;

  -- OPCODE process unit
  OPCODE_P : process (OPCODE)
  begin
    case (OPCODE) is
    when LOAD =>
      CUop <= oLOAD;
    when OP_IMM =>
      if ( FUNCT3(1 downto 0) = "01" ) then -- If arithmetic operation is shift
        CUop <= oSITYPE; --Shift immediate type
      else
        CUop <= oITYPE;  --Operation immediate type
      end if;
    when AUIPC =>
      CUop <= oAUIPC;
    when STORE =>
      CUop <= oSTORE;
    when OP =>
      CUop <= oRTYPE;
    when LUI =>
      CUop <= oLUI;
    when BRANCH =>
      CUop <= oBRANCH;
    when JAL =>
      CUop <= oJAL;
    when others => CUop <= oRTYPE;
  end case;
  end process OPCODE_P;

  -- purpose: Generation of ALU OpCode
  -- type   : combinational
  -- inputs : ALUop1, FUNCT3, FUNCT7
  -- outputs: ALUfunc0
   ALU_OP_CODE_P : process (ALUop, FUNCT3, FUNCT7)
   begin  -- process ALU_OP_CODE_P
	  case conv_integer(unsigned(ALUop)) is
		when 0 => ALUfunc0 <= ADD;  -- LOAD or STORE or NOP
		when 2 => case FUNCT3 is    -- OP
        when c3ADD_SUB => case FUNCT7 is
            when c7ADD => ALUfunc0 <= ADD;
            when c7SUB => ALUfunc0 <= SUB;
            when others => ALUfunc0 <= ADD;
          end case;
        when c3SLT => ALUfunc0 <= FUNCSLT;
        when c3SRA => ALUfunc0 <= FUNCSRA;
        when c3AND => ALUfunc0 <= BITAND;
        when c3XOR => ALUfunc0 <= BITXOR;
        when others => ALUfunc0 <= ADD;
      end case;
    when 3 => case FUNCT3 is    -- OP IMM
        when c3ADD_SUB => ALUfunc0 <= ADD;
	when c3ABS => ALUfunc0 <= FUNCABS;
        when c3SLT => ALUfunc0 <= FUNCSLT;
        when c3SRA => ALUfunc0 <= FUNCSRA;
        when c3AND => ALUfunc0 <= BITAND;
        when c3XOR => ALUfunc0 <= BITXOR;
        when others => ALUfunc0 <= ADD;
      end case;
    when others => ALUfunc0 <= ADD;
		end case;
	end process ALU_OP_CODE_P;

-- Forwarding unit
  FWU_p : process(ID_EX_RS1, ID_EX_RS2, EX_MEM_RD, MEM_WB_RD, EX_MEM_RW, MEM_WB_RW)
	begin
		-- Forwarding for operand1

		-- if destination register in second to last pipe (EX/MEM) is equal to source register in second_pipe (ID/EX)
		-- need to forward the ALU input from EX/MEM pipeline reg
		-- but only if destination register is different from x0 and its instruction is going to write on register file
		IF ((EX_MEM_RD = ID_EX_RS1) AND (EX_MEM_RD /= std_logic_vector(conv_unsigned(0, 5)) AND (EX_MEM_RW = '1'))) THEN
			forwardA <= "10";

		-- if destination register in last pipe (MEM/WB) is equal to source register in second_pipe (ID/EX)
		-- need to forward the ALU input from MEM/WB pipeline reg
		-- but only if destination register is different from x0 and its instruction is going to write on register file
		ELSIF ((MEM_WB_RD = ID_EX_RS1) AND (MEM_WB_RD /= std_logic_vector(conv_unsigned(0, 5)) AND (MEM_WB_RW = '1'))) THEN
			forwardA <= "01";
		-- otherwise do not forward anything
		ELSE
			forwardA <= "00";
		END IF;

		-- Forwarding for operand2

		-- if destination register in second to last pipe (EX/MEM) is equal to source register in second_pipe (ID/EX)
		-- need to forward the ALU input from EX/MEM pipeline reg
		-- but only if destination register is different from x0 and its instruction is going to write on register file
		IF ((EX_MEM_RD = ID_EX_RS2) AND (EX_MEM_RD /= std_logic_vector(conv_unsigned(0, 5)) AND (EX_MEM_RW = '1'))) THEN
			forwardB <= "10";

		-- if destination register in last pipe (MEM/WB) is equal to source register in second_pipe (ID/EX)
		-- need to forward the ALU input from MEM/WB pipeline reg
		-- but only if destination register is different from x0 and its instruction is going to write on register file
		ELSIF ((MEM_WB_RD = ID_EX_RS2) AND (MEM_WB_RD /= std_logic_vector(conv_unsigned(0, 5)) AND (MEM_WB_RW = '1'))) THEN
			forwardB <= "01";
		-- otherwise do not forward anything
		ELSE
			forwardB <= "00";
		END IF;

	end process;

  -- Hazard detection unit
  HDU_p : process(opCODE, IF_ID_RS1, IF_ID_RS2, ID_EX_MR, Rst, ID_EX_RD, EX_MEM_RD, MEM_WB_RD)
	begin



	IF ((opCODE = BRANCH) AND (
							  ( ((ID_EX_RD  = IF_ID_RS1) OR (ID_EX_RD  = IF_ID_RS2)) AND (ID_EX_RD  /= std_logic_vector(conv_unsigned(0, 5))))
					    OR    ( ((EX_MEM_RD = IF_ID_RS1) OR (EX_MEM_RD = IF_ID_RS2)) AND (EX_MEM_RD /= std_logic_vector(conv_unsigned(0, 5))))
					    OR    ( ((MEM_WB_RD = IF_ID_RS1) OR (MEM_WB_RD = IF_ID_RS2)) AND (MEM_WB_RD /= std_logic_vector(conv_unsigned(0, 5))))
		)) THEN
		en_STALL <= '1';
		en_IF_ID <= '0';
		en_PC <= '0';

	-- LOAD AND USE HAZARD
	-- only if instruction will read from the data memory
	-- AND
	-- the destination register of the previous instruction is equal to one of the source register of the next instruction
	ELSIF (ID_EX_MR = '1' AND (
								((ID_EX_RD = IF_ID_RS1)  OR (ID_EX_RD = IF_ID_RS2))  AND ID_EX_RD /= std_logic_vector(conv_unsigned(0, 5))
							  )
		  )THEN
		en_STALL <= '1';   -- if hazard is detected the mux is set to one and 0 will be provided to all CU signals
		en_IF_ID <= '0';   -- if hazard is detected the IF/ID pipe register will be frozen
		en_PC <= '0';      -- if hazard is detected the Program counter will be frozen
	ELSE
		en_STALL <= '0';
		en_IF_ID <= '1';
		en_PC <= '1';
	END IF;

	IF Rst='0' THEN
		en_STALL <= '0';
		en_IF_ID <= '1';
		en_PC <= '1';
	END IF;



	end process;

  -- Need to flush when there is a jump
	IF_flush <= CHANGE_PC_SRC;

  -- If operation is branch or store then no need to pipeline RD because it does not exist
  MUX_RD_CONTROL_p: process( OPCODE )
  begin
    IF ((OPCODE = BRANCH) OR (OPCODE = STORE)) THEN
      SEL_MUX_RD <= '1';
    ELSE
      SEL_MUX_RD <= '0';
    END IF;
  end process;

end Controlling;-- this is the end of the code
