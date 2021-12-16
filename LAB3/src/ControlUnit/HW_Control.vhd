library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;
use work.opcodes.all;
use work.cu_types.all;
use work.alu_types.all;

entity HW_Control is
  port (
              -- IF PIPE STAGE OUTPUTS
              SPC    : out std_logic;               -- switch pc source
    		      -- ID PIPE STAGE OUTPUTS
              EN1    : out std_logic;               -- enables the register file and the pipeline registers ID/EX
              RF1    : out std_logic;               -- enables the read port 1 of the register file
              RF2    : out std_logic;               -- enables the read port 2 of the register file
              WF1    : out std_logic;               -- enables the write port of the register file
              SEL_MUX_1 : out std_logic;               -- enables the write port of the register file
              SEL_MUX_2 : out std_logic_vector(1 downto 0);               -- enables the write port of the register file
              -- EX PIPE STAGE OUTPUTS
              EN2    : out std_logic;               -- enables the pipe registers EX/MEM
              SALU     : out std_logic;               -- input selection of the ALU source
              ALUfunc   : out TYPE_OP;               -- WARNING! alu operator bus coded by ___constants.vhd___
              -- MEM PIPE STAGE OUTPUTS
              EN3    : out std_logic;               -- enables the memory and the pipeline registers MEM/WB
              RM     : out std_logic;               -- enables the read-out of t0he memory
              WM     : out std_logic;               -- enables the write-in of the memory
              -- WB PIPE STAGE OUTPUTS
              SWB     : out std_logic;               -- input selection of the multiplexer
              -- INPUTS
              OPCODE : in  std_logic_vector(OP_CODE_SIZE - 1 downto 0);
              FUNCT3   : in  std_logic_vector(FUNCT3_SIZE - 1 downto 0);
              FUNCT7   : in  std_logic_vector(FUNCT7_SIZE - 1 downto 0);
              ALUzero : in std_logic;
              Clk : in std_logic;
              Rst : in std_logic);
end HW_Control;


architecture Controlling of HW_Control is


  constant CW_SIZE : integer := 14;  -- Control Word Size

  type mem_array is array (integer range 0 to uC_SIZE - 1) of std_logic_vector(CW_SIZE - 1 downto 0);
  signal cw_mem : mem_array := ( --this is the control word code register it is addressed by the opcode
"11100010100010", -- oRTYPE
"11000111100010", -- oITYPE
"10001011100010", -- oUTYPE
"11000111000111", -- oLOAD
"11110011001000", -- oSTORE
"11100010110000", -- oBRANCH
); -- See CUBindings.gsheet

  signal cw   : std_logic_vector(CW_SIZE - 1 downto 0); -- full control word read from cw_mem
  signal BEQ     : out std_logic;               -- enables branch for SPC if zero
  signal ALUop : std_logic_vector(1 downto 0); --This signal goes to ALU control unit
  signal ALUfunc0 : TYPE_OP; --This siganl goes from ALUCU to ALU unit
  signal CUop : optype_t;

  -- control word is shifted to the correct stage
  signal cw1 : std_logic_vector(CW_SIZE - 1 - 6 downto 0); -- ex stage
  signal cw2 : std_logic_vector(CW_SIZE - 1 - 8 downto 0); -- mem stage
  signal cw3 : std_logic_vector(CW_SIZE - 1 - 12 downto 0); -- wb stage




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
      cw1 <= cw(CW_SIZE - 1 - 6 downto 0); -- the control word is passed to the first stage of the pipeline
      cw2 <= cw1(CW_SIZE - 1 - 8 downto 0); --the word is propogated to the next pipeline stages
      cw3 <= cw2(CW_SIZE - 1 - 12 downto 0);
	  ALUfunc<=ALUfunc0; -- next value for the alu is loaded to the alu so that the next instruction can be serviced
    end if;
  end process CW_PIPE;

---------------------------------------------
-- Combinational Part
  cw <= cw_mem(conv_integer(CUop)); -- the control word register is loaded with the correct value from the memory using ht opcode as an index

-- Bindings
  -- ID
  EN1       <= cw(CW_SIZE - 1 - 0);
  RF1       <= cw(CW_SIZE - 1 - 1);
  RF2       <= cw(CW_SIZE - 1 - 2);
  SEL_MUX_1 <= cw(CW_SIZE - 1 - 3);
  SEL_MUX_2 <= cw(CW_SIZE - 1 - 4 downto CW_SIZE - 1 - 5);
  -- EX
  EN2       <= cw1(CW_SIZE - 1 - 6);
  SALU      <= cw1(CW_SIZE - 1 - 7);
  -- MEM
  EN3       <= cw2(CW_SIZE - 1 - 8);
  BEQ        <= cw2(CW_SIZE - 1 - 9);
  WM        <= cw2(CW_SIZE - 1 - 10);
  RM        <= cw2(CW_SIZE - 1 - 11);
  -- WB
  WF1       <= cw3(CW_SIZE - 1 - 12);
  SWB       <= cw3(CW_SIZE - 1 - 13);

  BEQ_u : SPC <= ALUzero AND BEQ;

  -- OPCODE process unit
  OPCODE_P : process (OPCODE)
  begin
    case (OPCODE) is
    when LOAD => CUop <= oLOAD;
    when OP_IMM => CUop <= oITYPE;
    when AUIPC => CUop <= oUTYPE;
    when STORE => CUop <= oSTORE;
    when OP => CUop <= oRTYPE;
    when LUI => CUop <= oUTYPE;
    when BRANCH => CUop <= oBRANCH;
    when others => CUop <= oRTYPE;
  end case;
  end process OPCODE_P;

  -- purpose: Generation of ALU OpCode
  -- type   : combinational
  -- inputs : ALUop1, FUNCT3, FUNCT7
  -- outputs: ALUfunc0
   ALU_OP_CODE_P : process (OPCODE, FUNCT3, FUNCT7)
   begin  -- process ALU_OP_CODE_P
	  case conv_integer(unsigned(ALUop)) is
		when 0 => ALUfunc0 <= ADD;  -- LOAD or STORE
		when 1 => ALUfunc0 <= SUB;  -- BRANCH
		when 2 => case FUNCT3 is
      when c3ADD_SUB => case FUNCT7 is
        when c7ADD => ALUfunc0 <= ADD;
        when c7SUB => ALUfunc0 <= SUB;
        when others => ALUfunc0 <= ADD;
      end case;
      when c3AND => ALUfunc0 <= BITAND;
      when c3XOR => ALUfunc0 <= BITXOR;
      when others => ALUfunc0 <= ADD;
    end case;
    when others => ALUfunc0 <= ADD;
		end case;
	end process ALU_OP_CODE_P;


end Controlling;-- this is the end of the code
