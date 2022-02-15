library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;
use IEEE.numeric_std.all;
use WORK.alu_types.all;

entity ALU is
  generic (N : integer := 32);
  port 	 ( FUNC: IN TYPE_OP;
           DATA1, DATA2: IN std_logic_vector(N-1 downto 0);
           OUTALU: OUT std_logic_vector(N-1 downto 0));
end ALU;

architecture BEHAVIOR of ALU is

begin

P_ALU: process (FUNC, DATA1, DATA2)
begin
    case FUNC is
	when ADD 		=> OUTALU <= DATA1 + DATA2 ;
	when SUB 		=> OUTALU <= DATA1 - DATA2 ;
	when BITAND 	=> OUTALU <= DATA1 and DATA2 ; -- bitwise operations
	when BITXOR 	=> OUTALU <= DATA1 xor DATA2 ;
	when FUNCSLT =>
	if ( to_integer(signed(DATA1)) < to_integer(signed(DATA2))) then
		OUTALU <= std_logic_vector(to_unsigned(1,N));
    	else
		OUTALU <= std_logic_vector(to_signed(0,N));
    	end if;
	when FUNCSRA => OUTALU <= std_logic_vector((shift_right(signed(DATA1),to_integer(unsigned(DATA2(4 downto 0))))));--arithmetic shift right
  	when others => OUTALU <= ( others => '0' ) ;
    end case;
end process P_ALU;

end BEHAVIOR;

configuration CFG_ALU_BEHAVIORAL of ALU is
  for BEHAVIOR
  end for;
end CFG_ALU_BEHAVIORAL;
