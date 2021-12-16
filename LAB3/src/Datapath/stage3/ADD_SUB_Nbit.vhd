library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.NUMERIC_STD.ALL;

entity ADD_SUB_Nbit is
generic(N: integer );
    Port ( IN_Adder1 : in  signed (N-1 downto 0);
           IN_Adder2 : in  signed (N-1 downto 0);
           SIGN : in std_logic;
           OUT_ADDER  : out signed (N-1 downto 0));
end ADD_SUB_Nbit;


architecture Behavioral of ADD_SUB_Nbit is
signal sign_var : std_logic; 

signal sum_var : signed (N-1 downto 0);

begin

sign_var <= SIGN;

process (sign_var, IN_Adder1, IN_Adder2)
variable sum_var : signed(N-1 downto 0);
    begin
			if SIGN = '0' then 
				sum_var := IN_Adder1 + IN_Adder2;
			else
				sum_var := IN_Adder1 - IN_Adder2;
			end if;
end process;  

OUT_ADDER <= sum_var;
End Behavioral;