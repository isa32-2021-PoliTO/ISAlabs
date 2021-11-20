library IEEE;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity reg is
generic (N: integer);
port(    clk : in STD_LOGIC; 
	     rstn : in STD_LOGIC;
      enable : in std_logic;
	       a : in SIGNED(N-1 downto 0); --for generic statement use N-1 downto 0
	       b :out SIGNED(N-1 downto 0));
end reg;

architecture Behavioral of reg is
begin
process(clk, rstn)
begin
if (rstn = '0') then
	b <= (others=> '0');
elsif (clk'event and clk = '1') then
  if (enable='1') then
        b <= a;
  end if;
end if;
end process;
end Behavioral;