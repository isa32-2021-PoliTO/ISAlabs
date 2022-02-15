library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;

entity MUX_8_to_1 is
generic(N: integer );
port( IN1,IN2,IN3,IN4,IN5,IN6,IN7,IN8 : in std_logic_vector(N-1 downto 0);
          SEL : in std_logic_vector(2 downto 0);
       OUTPUT : out std_logic_vector(N-1 downto 0));
end MUX_8_to_1;

architecture Behavioral of MUX_8_to_1 is
begin


process(IN1,IN2,IN3,IN4,IN5,IN6,IN7,IN8,SEL)
begin
case SEL is
	when "000" => OUTPUT <= IN1;
	when "001" => OUTPUT <= IN2;
	when "010" => OUTPUT <= IN3;
	when "011" => OUTPUT <= IN4;
	when "100" => OUTPUT <= IN5;
	when "101" => OUTPUT <= IN6;
	when "110" => OUTPUT <= IN7;
	when "111" => OUTPUT <= IN8;
	when others => OUTPUT <= (others =>	'U');
	end case;
	END PROCESS;
	
end Behavioral;
	