library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.ALL;


entity Adder_4cells is
generic (N: integer);
port( 	IN1 : in std_logic_vector(N-1 downto 0);  
		SUM : out std_logic_vector(N-1 downto 0));
end entity;

architecture behavioural of Adder_4cells is
begin

SUM <= IN1 + 4; 

end behavioural;