Library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity AND_Block is
generic(N: integer );
    Port ( IN_AND1 : in  STD_LOGIC_VECTOR (N-1 downto 0) ;
           IN_AND2 : in  STD_LOGIC_VECTOR (N-1 downto 0) ;
           OUT_AND  : out STD_LOGIC_VECTOR (N-1 downto 0));
end AND_Block;

architecture Behavioral of AND_Block is

begin
    
  GEN: for I in 0 to N-1 GENERATE
    OUT_AND(I) <= IN_AND1(I) and IN_AND2(I);
  end GENERATE;
    
End Behavioral;
