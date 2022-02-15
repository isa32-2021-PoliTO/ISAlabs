library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;

entity MUX_4_to_1 is
generic(N: integer );
port( IN1,IN2,IN3,IN4 : in std_logic_vector(N-1 downto 0);
          SEL : in std_logic_vector(1 downto 0);
       OUTPUT : out std_logic_vector(N-1 downto 0));
end MUX_4_to_1;

architecture Behavioral of MUX_4_to_1 is
begin


process(IN1,IN2,IN3,IN4,SEL)
begin
case SEL is
	when "00" => OUTPUT <= IN1;
	when "01" => OUTPUT <= IN2;
	when "10" => OUTPUT <= IN3;
	when "11" => OUTPUT <= IN4;
	when others => OUTPUT <= (others =>	'U');
	end case;
	END PROCESS;
	
end Behavioral;
	
