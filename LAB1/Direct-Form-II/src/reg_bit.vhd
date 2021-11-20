library IEEE;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity reg_bit is
port(    clk : in STD_LOGIC; 
	     rstn : in STD_LOGIC;
      enable : in STD_LOGIC;
	       a : in STD_LOGIC;
	       b :out STD_LOGIC);
end reg_bit;

architecture Behavioral of reg_bit is
begin
process(clk, rstn)
begin
if (rstn = '0') then
	b <= '0';
elsif (clk'event and clk = '1') then
  if (enable='1') then
        b <= a;
  end if;
end if;
end process;
end Behavioral;