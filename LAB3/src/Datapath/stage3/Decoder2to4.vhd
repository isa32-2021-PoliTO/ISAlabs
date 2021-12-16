Library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity Decoder2to4 is
port(
     SEL1 : in std_logic;
     SEL2 : in std_logic;

     EN_SRAI : out std_logic;
     EN_XOR: out std_logic;
     EN_ADD : out std_logic;
     EN_ANDI : out std_logic);
 
end Decoder2to4;

architecture Behavioral  of Decoder2TO4 is
begin

  EN_SRAI <= (NOT(SEL1) and NOT(SEL2));
  EN_XOR <= (NOT(SEL1) and (SEL2));
  EN_ADD <= ((SEL1) and NOT(SEL2));
  EN_ANDI<= (SEL1 and SEL2);
  
end Behavioral;