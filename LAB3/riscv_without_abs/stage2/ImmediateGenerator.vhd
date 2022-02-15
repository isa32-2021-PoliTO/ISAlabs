Library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

ENTITY ImmediateGenerator IS
generic(N: integer );
PORT (
		MuxSel:in std_logic_vector(2 downto 0);
		input: in std_logic_vector(31 downto 7);
		output: out std_logic_vector(N-1 downto 0)
);
END ENTITY;

ARCHITECTURE structural OF ImmediateGenerator IS

signal imm_I:    std_logic_vector(N-1 downto 0);
signal imm_S:    std_logic_vector(N-1 downto 0);
signal imm_B:    std_logic_vector(N-1 downto 0);
signal imm_U:    std_logic_vector(N-1 downto 0);
signal imm_J:    std_logic_vector(N-1 downto 0);
signal imm_SRAI:    std_logic_vector(N-1 downto 0);

component MUX_8_to_1 is
generic(N: integer );
port(  IN1,IN2,IN3,IN4,IN5,IN6,IN7,IN8 : in std_logic_vector(N-1 downto 0);
          SEL : in std_logic_vector(2 downto 0);
       OUTPUT : out std_logic_vector(N-1 downto 0));
end component;


begin
-- discard opcode from instruction (31 downto 7) -- see RV21I Base Instruction in the folder
imm_I <= std_logic_vector(resize( signed(input (31 downto 20)),N)); 
imm_S <= std_logic_vector(resize( signed(input (31 downto 25) & input (11 downto 7)),N)); 
imm_B <= std_logic_vector(shift_left(resize( signed(input (31) & input (7) & input (30 downto 25) & input (11 downto 8)),N),1)); -- implements the shift left by one position
imm_U <= std_logic_vector(resize( signed(input (31 downto 12)) & "000000000000" , N)); 
imm_J <= std_logic_vector(shift_left(resize( signed(input (31) & input (19 downto 12) & input (20) & input (30 downto 21)),N),1)); -- implements the shift left by one position
imm_SRAI <= std_logic_vector(resize( unsigned(input (24 downto 20)),N)); 


MuxImmGen:    MUX_8_to_1 GENERIC MAP (N => 32) 
                           PORT    MAP (IN1 => imm_S, -- 000
										IN2 => imm_I, -- 001
										IN3 => imm_U, -- 010
										IN4 => imm_J, -- 011
										IN5 => imm_B, -- 100
										IN6 => imm_SRAI, -- 101
										IN7 => std_logic_vector(to_unsigned(0,N)), --110
										IN8 => std_logic_vector(to_unsigned(0,N)), --111
										SEL => MuxSel,
										OUTPUT => output);

end architecture;
