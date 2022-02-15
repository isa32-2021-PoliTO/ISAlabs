library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;
use WORK.all;

entity register_file is
  generic ( NBIT : integer := 32;  --Parallelism of the arch
            NREG : integer := 32); --Numbers of registers in RF
 port (
   CLK:     IN std_logic;
   RESET: 	IN std_logic;
	 RD1: 		IN std_logic;
	 RD2: 		IN std_logic;
	 WR: 		IN std_logic;
	 ADD_WR: 	IN std_logic_vector(4 downto 0);
	 ADD_RD1: 	IN std_logic_vector(4 downto 0);
	 ADD_RD2: 	IN std_logic_vector(4 downto 0);
	 DATAIN: 	IN std_logic_vector(NBIT-1 downto 0);
   OUT1: 		OUT std_logic_vector(NBIT-1 downto 0);
	 OUT2: 		OUT std_logic_vector(NBIT-1 downto 0));
end register_file;

architecture A of register_file is

        -- suggested structures
   subtype REG_ADDR is natural range 0 to NREG-1; -- using natural type
	type REG_ARRAY is array(REG_ADDR) of std_logic_vector(NBIT-1 downto 0);
	signal REGISTERS : REG_ARRAY;


begin

	reg_p: process (RESET, CLK, WR, RD1, RD2, ADD_WR, DATAIN, ADD_RD1, ADD_RD2)
	begin
		-- Reset loop
		if ( RESET='0') then
			REGISTERS(0) <= ( others => '0' );
			for j in 0 to NBIT-1 loop
				for i in 1 to NREG-1 loop
					REGISTERS(i)(j) <= '0';
				end loop;
				OUT1(j) <= '0';
				OUT2(j) <= '0';
			end loop;

    else
			-- Write bit check
			if (WR='1' AND (CLK'event AND CLK='1') ) then
				REGISTERS(CONV_INTEGER(ADD_WR)) <= DATAIN;
			end if;

			-- Read 1 check
			if (RD1='1') then
				OUT1 <= REGISTERS(CONV_INTEGER(ADD_RD1));
			else
				OUT1 <= REGISTERS(0);
			end if;

			-- Read 2 check
			if (RD2='1') then
				OUT2 <= REGISTERS(CONV_INTEGER(ADD_RD2));
			else
				OUT2 <= REGISTERS(0);
			end if;

      -- Bypass to read 1
      if (( ADD_WR = ADD_RD1 ) AND ( WR='1' AND RD1='1' )) then
        OUT1 <= DATAIN;
      end if;

      -- Bypass to read 2
      if (( ADD_WR = ADD_RD2 ) AND ( WR='1' AND RD2='1' )) then
        OUT2 <= DATAIN;
      end if;
      
		end if;

	end process reg_p;


end A;

----


configuration CFG_RF_BEH of register_file is
  for A
  end for;
end configuration;
