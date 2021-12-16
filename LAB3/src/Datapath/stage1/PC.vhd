library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.ALL;


entity PC is
generic (N: integer);
port( 	clk : in std_logic; 
	  rst_n : in std_logic;
		 en : in std_logic;
		  a : in std_logic_vector(N-1 downto 0);
		  b : out std_logic_vector(N-1 downto 0));
end entity;

architecture behavioural of PC is
begin
process(clk, rst_n)
begin
if (rst_n = '0') then
	b <= (others=>'0');
elsif (clk'event and clk = '1') then
  if (en='1') then
			b <= a;
  end if;
end if;
end process;
end behavioural;