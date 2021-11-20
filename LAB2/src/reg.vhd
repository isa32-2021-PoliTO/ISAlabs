library IEEE;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity reg is
generic (n: natural);
port(    clk : in STD_LOGIC; 
	     a : in STD_LOGIC_VECTOR(N-1 downto 0);
	     b :out STD_LOGIC_VECTOR(N-1 downto 0));
end reg;

architecture Behavioral of reg is
begin
process(clk)
begin
	if (clk'event and clk = '1') then
		b <= a;
	end if;
end process;
end Behavioral;