library IEEE;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.constants.all;

entity subtractor is
	Port ( IN1 : in  SIGNED (ADD-1 downto 0);
           IN2 : in  SIGNED (ADD-1 downto 0);
           SUB : out SIGNED (ADD downto 0));
end subtractor;


architecture Behavioral of subtractor is

begin

      SUB <= (IN1(ADD-1) & IN1) - (IN2(ADD-1) & IN2);
	  
End Architecture Behavioral;