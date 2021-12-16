LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE work.const_MEM.ALL;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_textio.all;
use ieee.math_real.all;

library std;
use std.textio.all;

-- Synchronous data memory

ENTITY data_MEM IS
   PORT
   (
		clock: IN   std_logic;
    rst: IN std_logic;
		din:  IN   std_logic_vector (DATA_LENGTH-1 DOWNTO 0);
		address:  IN   std_logic_vector (ADDRESS_LENGTH-1 DOWNTO 0);
		dout:     OUT  std_logic_vector (DATA_LENGTH-1 DOWNTO 0);
		we:    IN   std_logic;
		re:    IN   std_logic
   );
END data_MEM;
ARCHITECTURE beh OF data_MEM IS
	CONSTANT NCELL : natural := integer(ceil(real(DATA_LENGTH)/real(8)));
	TYPE mem IS ARRAY(0 TO 2**ADDRESS_LENGTH-1) OF std_logic_vector(7 DOWNTO 0);
	SIGNAL mem_words : mem;
BEGIN

	PROCESS (address, din, rst)
  variable i : natural;
  file fp : text open read_mode is "../code/instructions.txt";
  variable ptr : line;
  variable val : std_logic_vector(DATA_LENGTH-1 downto 0);

	BEGIN
    IF (RST'event AND RST='1') THEN
      FOR i IN 0 TO (2**ADDRESS_LENGTH)/NCELL-1 LOOP
        IF (NOT(endfile(fp))) THEN
          readline(fp, ptr);
          hread(ptr, val);
        ELSE
          val := (others => '0');
        END IF;
        FOR j IN 0 TO NCELL-1 LOOP
         mem_words(4*i+j) <= val((NCELL-j)*8-1 downto (NCELL-1-j)*8);
        END LOOP;
      END LOOP;
    END IF;
		IF (we = '1') THEN
      FOR j IN 0 TO NCELL-1 LOOP
       mem_words(4*i+j) <= din((NCELL-j)*8-1 downto (NCELL-1-j)*8);
      END LOOP;
		ELSIF (re = '1') THEN
      FOR j IN 0 TO NCELL-1 LOOP
       dout((NCELL-j)*8-1 downto (NCELL-1-j)*8) <= mem_words(CONV_INTEGER(UNSIGNED(address))+j);
      END LOOP;
		END IF;
	END PROCESS;
END beh;
