Library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity XOR_Block is
generic(N: integer);
    Port ( IN1 : in  std_logic_vector (N-1 downto 0) ;
           IN2 : in  std_logic_vector (N-1 downto 0) ;
           out_XOR  : out std_logic_vector (N-1 downto 0));
end xor_Block;

architecture Behavioral of xor_Block is

begin
    
  GEN: for I in 0 to N-1 GENERATE
    out_XOR(I) <= IN1(I) xor IN2(I);
  end GENERATE;
    
End Behavioral;