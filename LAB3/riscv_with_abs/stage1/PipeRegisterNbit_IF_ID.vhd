library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;

entity PipeRegisterNbit_IF_ID is
generic (N: integer);
port( 	clk : in std_logic; 
	RST_N : in std_logic;
	  IF_FLUSH : in std_logic;
		 en : in std_logic;
	  INPUT : in std_logic_vector(N-1 downto 0);
	 OUTPUT :out std_logic_vector(N-1 downto 0));
end PipeRegisterNbit_IF_ID;

architecture Behavioral of PipeRegisterNbit_IF_ID is

signal zeros : std_logic_vector(N-8 downto 0) := (others => '0');

begin
process(clk, RST_N, IF_FLUSH)
begin
if (RST_N = '0') then
		OUTPUT <= ( others => '0' );
elsif (clk'event and clk = '1') then
	if (IF_FLUSH = '1') then
		OUTPUT (N-1 downto 0) <= zeros & "0010011"; -- NOP operation
	elsif (en='1') then
        OUTPUT <= INPUT;
	end if;
end if;
end process;
end Behavioral;