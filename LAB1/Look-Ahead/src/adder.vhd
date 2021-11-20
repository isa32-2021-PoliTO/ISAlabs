library IEEE;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.constants_LA.all;

entity adder is
    Port ( IN1 : in  SIGNED (NBIT downto 0);
           IN2 : in  SIGNED (NBIT downto 0);
           SUM : out SIGNED (NBIT downto 0));
end adder;


architecture Behavioral of adder is

begin
		
      SUM <= IN1 + IN2;
	  	  
End Architecture Behavioral;