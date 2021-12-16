LIBRARY ieee;
USE ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_textio.all;
USE work.const_MEM.ALL;
use ieee.math_real.all;

LIBRARY std;
USE std.textio.ALL;

-- Asynchronous instruction memory

ENTITY inst_MEM IS
PORT(
    rst: IN std_logic;
    address:  IN   std_logic_vector (ADDRESS_LENGTH-1 DOWNTO 0);
    dout:     OUT  std_logic_vector (DATA_LENGTH-1 DOWNTO 0));
END inst_MEM;

ARCHITECTURE beh OF inst_MEM IS
	CONSTANT NCELL : natural := integer(ceil(real(DATA_LENGTH)/real(8)));
	TYPE mem IS ARRAY(0 TO 2**ADDRESS_LENGTH-1) OF STD_LOGIC_VECTOR(7 DOWNTO 0);
	SIGNAL mem_words: mem;

	BEGIN

	PROCESS (rst, address)
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
		FOR j IN 0 TO NCELL-1 LOOP
			 dout((NCELL-j)*8-1 downto (NCELL-1-j)*8) <= mem_words(CONV_INTEGER(UNSIGNED(address))+j);
		END LOOP;
   END PROCESS;

END beh;
