Library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

ENTITY ImmediateGenerator IS
generic(N: integer );
PORT (
		input: in std_logic_vector ;
		output: out unsigned(N-1 downto 0)
);
END ENTITY;

ARCHITECTURE structural OF ImmediateGenerator IS

signal imm_I: unsigned(N-1 downto 0);
signal imm_S: unsigned(N-1 downto 0);
signal imm_B: unsigned(N-1 downto 0);
signal imm_U: unsigned(N-1 downto 0);
signal imm_J: unsigned(N-1 downto 0);


begin

imm_I <= resize( unsigned(input (24 downto 13)),N); 
imm_S <= resize( unsigned(input (24 downto 18) & input (4 downto 0)),N); 
imm_B <= resize( unsigned(input (24) & input (0) & input (23 downto 18) & input (4 downto 0) & '0'),N); 
imm_U <= resize( unsigned(input (23 downto 18)), N); 
imm_J <= resize( unsigned(input (24) & input (12 downto 5) & input (13) & input (23 downto 14) & '0'),N);   



end architecture;
