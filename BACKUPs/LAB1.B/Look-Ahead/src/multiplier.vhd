library IEEE;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity multiplier is
generic (
		Nin1: integer;
		Nin2: integer
		);
    Port ( IN1 : in  SIGNED (Nin1-1 downto 0); 
           IN2 : in  SIGNED (Nin2-1 downto 0);
           MULT: out SIGNED (Nin1+Nin2-1 downto 0));
end multiplier;


architecture Behavioral of multiplier is

begin
   
      MULT <= IN1 * IN2;
   
End Architecture Behavioral;