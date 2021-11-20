library IEEE;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.constants.all;

entity multiplier is
    Port ( IN1 : in  SIGNED (MULT_IN1-1 downto 0); 
           IN2 : in  SIGNED (MULT_IN2-1 downto 0);
           MULT: out SIGNED (MULT_OUT-1 downto 0));
end multiplier;


architecture Behavioral of multiplier is

begin
   
      MULT <= IN1 * IN2;
   
End Architecture Behavioral;