library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;

entity PipeRegisterNbit is
generic (N: integer);
port( 	clk : in std_logic; 
	  rst_n : in std_logic;
		 en : in std_logic;
	  INPUT : in std_logic_vector(N-1 downto 0);
	 OUTPUT :out std_logic_vector(N-1 downto 0));
end PipeRegisterNbit;

architecture Behavioral of PipeRegisterNbit is
begin
process(clk, rst_n)
begin
if (rst_n = '0') then
	OUTPUT <= (others=> '0');
elsif (clk'event and clk = '1') then
  if (en='1') then
        OUTPUT <= INPUT;
  end if;
end if;
end process;
end Behavioral;