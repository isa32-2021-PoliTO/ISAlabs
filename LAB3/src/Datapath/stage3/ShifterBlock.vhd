Library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity ShifterBlock is
  generic ( N: integer:= 32);
    Port ( SHIFT_IN : in  std_logic_vector(N-1 downto 0);
   SHIFT_Ctrl : in  std_logic_vector(4 downto 0); 
   SHIFT_OUT: out  std_logic_vector(N-1 downto 0)
  );
end ShifterBlock;



architecture Behavioral of ShifterBlock is

signal in_shift : unsigned(N-1 downto 0);
signal out_shift : unsigned(N-1 downto 0);

begin
in_shift <= unsigned(SHIFT_IN);
process(SHIFT_Ctrl)
begin
case(SHIFT_Ctrl) is
when "00000" => out_shift <= (shift_right(in_shift,0));
when "00001" => out_shift <= (shift_right(in_shift,1));
when "00010" => out_shift <= (shift_right(in_shift,2));
when "00011" => out_shift <= (shift_right(in_shift,3));
when "00100" => out_shift <= (shift_right(in_shift,4));
when "00101" => out_shift <= (shift_right(in_shift,5));
when "00110" => out_shift <= (shift_right(in_shift,6));
when "00111" => out_shift <= (shift_right(in_shift,7));
when "01000" => out_shift <= (shift_right(in_shift,8));
when "01001" => out_shift <= (shift_right(in_shift,9));
when "01010" => out_shift <= (shift_right(in_shift,10));
when "01011" => out_shift <= (shift_right(in_shift,11));
when "01100" => out_shift <= (shift_right(in_shift,12));
when "01101" => out_shift <= (shift_right(in_shift,13));
when "01110" => out_shift <= (shift_right(in_shift,14));
when "01111" => out_shift <= (shift_right(in_shift,15));
when "10000" => out_shift <= (shift_right(in_shift,16));
when "10001" => out_shift <= (shift_right(in_shift,17));
when "10010" => out_shift <= (shift_right(in_shift,18));
when "10011" => out_shift <= (shift_right(in_shift,19));
when "10100" => out_shift <= (shift_right(in_shift,20));
when "10101" => out_shift <= (shift_right(in_shift,21));
when "10110" => out_shift <= (shift_right(in_shift,22));
when "10111" => out_shift <= (shift_right(in_shift,23));
when "11000" => out_shift <= (shift_right(in_shift,24));
when "11001" => out_shift <= (shift_right(in_shift,25));
when "11010" => out_shift <= (shift_right(in_shift,26));
when "11011" => out_shift <= (shift_right(in_shift,27));
when "11100" => out_shift <= (shift_right(in_shift,28));
when "11101" => out_shift <= (shift_right(in_shift,29));
when "11110" => out_shift <= (shift_right(in_shift,30));
when "11111" => out_shift <= (shift_right(in_shift,31));
when others => out_shift <= (shift_right(in_shift,0));
end case;
end process;

end Behavioral;