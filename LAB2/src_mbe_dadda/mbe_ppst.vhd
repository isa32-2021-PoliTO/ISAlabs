library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- partial product selection table

-- partial_product = Multiplicand * triplet
--       pp        =      Y       * triplet
entity mbe_ppst is
  generic(N : natural := 32);
  port(triplet : in std_logic_vector(2 downto 0);--sign bit representation
       Y : in std_logic_vector(N-1 downto 0); -- Y is the multiplicand
       pp : out std_logic_vector(N downto 0); -- the pp has 1 bit more than Y
       S : out std_logic); 
end mbe_ppst;

architecture arch of mbe_ppst is
  
begin

  with triplet select pp <=            -- a certain pp will be select when triplet is...
    (others => '0') when "000" | "111",     -- null
    '0'&Y when "001" | "010",               -- + multiplicand
    Y&'0' when "011",                       -- + 2*multiplicand (left_shift = 2*)
    
	-- according to formula(5) in modified-booth.pdf you have to negate the number (1's complement) when MSB of triplet is negative...
	
    not ('0'&Y) when "110" | "101",         -- - multiplicand
    not (Y&'0') when "100",                 -- - 2*multiplicand (left_shift = 2*)
    (others => 'X') when others;            
  
	-- and then add the MSB of triplet to get the 2's complement ( it will be added in Dadda Tree according to Figure A5 in sign_extension_booth_mult.pdf)
	
  with triplet select S <=                                -- S is the sign bit (1 = negative, 0 = positive) and it is the MSB of triplet
    '0' when "000" | "111" | "001" | "010" | "011",       
    '1' when "110" | "101" | "100",                       -- you have to negate the pp if MSB of triplet is 1 (triplet is negative)
    'X' when others;
end architecture;
