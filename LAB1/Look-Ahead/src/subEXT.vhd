library IEEE;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.constants_LA.all;

entity subEXT is
    Port ( IN1 : in  SIGNED (NBIT-1 downto 0);
           IN2 : in  SIGNED (NBIT-1 downto 0);
           SUB : out SIGNED (NBIT downto 0));
end subEXT;


architecture Behavioral of subEXT is

begin
		
      SUB <= (IN1(NBIT-1) & IN1) - (IN2(NBIT-1) & IN2);
	  	  
End Architecture Behavioral;