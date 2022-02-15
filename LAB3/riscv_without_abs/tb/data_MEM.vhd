LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE work.const_MEM.ALL;
use ieee.numeric_std.ALL;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_textio.all;
use ieee.math_real.all;

library std;
use std.textio.all;

-- Asynchronous data memory

ENTITY data_MEM IS
   PORT
   (
		clock: IN   std_logic;
		rst_n: IN std_logic;
		din:  IN   std_logic_vector (DATA_LENGTH-1 DOWNTO 0);
		address:  IN   std_logic_vector (ADDRESS_LENGTH_IN-1 DOWNTO 0);
		dout:     OUT  std_logic_vector (DATA_LENGTH-1 DOWNTO 0);
		we:    IN   std_logic;
		re:    IN   std_logic
   );
END data_MEM;
ARCHITECTURE beh OF data_MEM IS
	CONSTANT NCELL : natural := integer(ceil(real(DATA_LENGTH)/real(8)));
	TYPE mem IS ARRAY(0 TO 2**ADDRESS_LENGTH-1) OF std_logic_vector(7 DOWNTO 0); -- (7 DOWNTO 0) stands for 1 byte
	SIGNAL mem_words : mem;

BEGIN

	PROCESS (address, din, rst_n, we, re) -- added we and re to the sensitivity list
		variable i : natural;
		file fp : text open read_mode is "../tb/data/data.hex";
		variable ptr : line;
		variable val : std_logic_vector(DATA_LENGTH-1 downto 0);


		variable DATA_BASE_ADDRESS: integer := 8192;
		variable TEMP: integer;
	BEGIN
		IF (rst_n'event AND rst_n='0') THEN
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

		-- addresses from simulator data memory must be shifted from a data_base_address since:
		-- simulator implements a unique memory for instructions and data (instructions start from zero while data start from 0x00002000)
		-- while we have two different memories that both starts from address zero
		-- TEMP is the integer representation of the address minus the offset
		-- to make it simple instead of doing a subtraction, which would be:
		   --TEMP := to_integer(UNSIGNED(address)-to_UNSIGNED(DATA_BASE_ADDRESS,ADDRESS_LENGTH_IN));
		-- we direclty truncate the address which results in the drop of the offset
		TEMP := to_integer(UNSIGNED(address(ADDRESS_LENGTH-1 DOWNTO 0)));

		IF (we = '1') THEN
			FOR j IN 0 TO NCELL-1 LOOP
				mem_words(TEMP+j) <= din((NCELL-j)*8-1 downto (NCELL-1-j)*8);
			END LOOP;
		END IF;
		IF (re = '1') THEN
			FOR j IN 0 TO NCELL-1 LOOP

				IF (TEMP+j < 2**ADDRESS_LENGTH) THEN
					dout((NCELL-j)*8-1 downto (NCELL-1-j)*8) <= mem_words(TEMP+j);
				ELSE
					dout((NCELL-j)*8-1 downto (NCELL-1-j)*8) <= (others => '0');
				END IF;

			END LOOP;
    		ELSE
      			dout <= (others => '0');
		END IF;
	END PROCESS;



END beh;
