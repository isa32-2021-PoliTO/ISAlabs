library ieee;
use ieee.std_logic_1164.all;

package opcodes is

-- Control unit input sizes
    constant OP_CODE_SIZE : integer :=  7;
    constant FUNCT3_SIZE : integer := 3;
    constant FUNCT7_SIZE : integer := 7;

-- First Row Instructions : opcode(6 downto 5)="00"
    constant LOAD : std_logic_vector(OP_CODE_SIZE - 1 downto 0) :=  "0000011";
    constant OP_IMM : std_logic_vector(OP_CODE_SIZE - 1 downto 0) :=  "0010011";
    constant AUIPC : std_logic_vector(OP_CODE_SIZE - 1 downto 0) :=  "0010111";

-- Second Row Instructions : opcode(6 downto 5)="01"
    constant STORE : std_logic_vector(OP_CODE_SIZE - 1 downto 0) :=  "0100011";
    constant OP : std_logic_vector(OP_CODE_SIZE - 1 downto 0) :=  "0110011";
    constant LUI : std_logic_vector(OP_CODE_SIZE - 1 downto 0) :=  "0110111";

-- Third Row Instructions : opcode(6 downto 5)="11"
    constant BRANCH : std_logic_vector(OP_CODE_SIZE - 1 downto 0) :=  "1100011";
    constant JAL : std_logic_vector(OP_CODE_SIZE - 1 downto 0) :=  "1101111";

---------------------------------------------------------
-- Funct3 codes
    constant c3ADD_SUB : std_logic_vector(FUNCT3_SIZE - 1 downto 0) := "000";
    constant c3AND : std_logic_vector(FUNCT3_SIZE - 1 downto 0) := "111";
    constant c3XOR : std_logic_vector(FUNCT3_SIZE - 1 downto 0) := "100";
    constant c3SRA : std_logic_vector(FUNCT3_SIZE - 1 downto 0) := "101";
    constant c3SLT : std_logic_vector(FUNCT3_SIZE - 1 downto 0) := "010";

-- Funct7 codes
    constant c7ADD : std_logic_vector(FUNCT7_SIZE - 1 downto 0) := "0000000";
    constant c7SUB : std_logic_vector(FUNCT7_SIZE - 1 downto 0) := "0100000";
end opcodes;

package cu_types is

-- These are the types stored in the ROM for different control signals behaviours
  constant uC_SIZE : integer := 9;  -- Micro Code Memory Size
  type optype_t is (oRTYPE, oITYPE, oJAL, oAUIPC, oLUI, oLOAD, oSTORE, oBRANCH, oSITYPE);

  function conv_integer( OP : optype_t ) return integer;

end cu_types;

package alu_types is
	type TYPE_OP is (ADD, SUB, MULT, BITAND, BITOR, BITXOR, FUNCSLT, FUNCLSL, FUNCLSR, FUNCRL, FUNCRR, FUNCSRA);
end alu_types;

package body cu_types is

  function conv_integer( OP : optype_t ) return integer is
  variable n : integer;
  begin
  case (OP) is
    when oRTYPE  => n := 0;
    when oITYPE  => n := 1;
    when oJAL    => n := 2;
    when oAUIPC  => n := 3;
    when oLUI    => n := 4;
    when oLOAD   => n := 5;
    when oSTORE  => n := 6;
    when oBRANCH => n := 7;
    when oSITYPE => n := 8;
    when others  => n := 0;
  end case;
  return n;
  end function;

end cu_types;
