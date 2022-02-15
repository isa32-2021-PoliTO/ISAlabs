library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.ALL;


entity Adder_Nbit is
generic (N: integer);
port( 	IN1 : in std_logic_vector(N-1 downto 0);  
		IN2 : in std_logic_vector(N-1 downto 0);  
		SUM : out std_logic_vector(N-1 downto 0));
end entity;

architecture behavioural of Adder_Nbit is
begin

SUM <= IN1 + IN2; 

end behavioural;