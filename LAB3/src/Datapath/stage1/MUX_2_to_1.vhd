library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;

entity MUX_2_to_1 is
generic(N: integer );
port( IN1,IN2 : in std_logic_vector(N-1 downto 0);
          SEL : in std_logic;
       OUTPUT : out std_logic_vector(N-1 downto 0));

end MUX_2_to_1;

architecture Behavioral of MUX_2_to_1 is
begin


process(IN1,IN2,SEL)
begin
case SEL is
	when '0' => OUTPUT <= IN1;
	when '1' => OUTPUT <= IN2;
	when others => OUTPUT <= (others =>	'U');
	end case;
	END PROCESS;
	
end Behavioral;
	
