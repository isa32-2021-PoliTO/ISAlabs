library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_textio.all;
use work.constants.all;

library std;
use std.textio.all;

entity data_maker is  
  port (
    CLK     : in  std_logic;
    RST_n   : in  std_logic;
    VOUT    : out std_logic; --VIN
    DOUT    : out std_logic_vector(NBIT_OUT-1 downto 0); --DIN
    B0      : out std_logic_vector(NBIT_OUT-1 downto 0); --B0
    B1      : out std_logic_vector(NBIT_OUT-1 downto 0); --B1
    A1      : out std_logic_vector(NBIT_OUT-1 downto 0); --A1
    END_SIM : out std_logic);
end data_maker;

architecture beh of data_maker is

  constant tco : time := 20 ns;

  signal sEndSim : std_logic;
  signal END_SIM_i : std_logic_vector(0 to 10);  

begin  -- beh

  B0 <= conv_std_logic_vector(3447,NBIT_OUT);
  B1 <= conv_std_logic_vector(3447,NBIT_OUT); 
  A1 <= conv_std_logic_vector(-1298,NBIT_OUT); 

  process (CLK, RST_n)
    file fp_in : text open READ_MODE is "../tb/samples.txt";
    variable line_in : line;
    variable x : integer;
	variable stop_count :integer := 0;
	
  begin  -- process
    if RST_n = '0' then  -- asynchronous reset (active low)
      DOUT <= (others => '0') after tco;      
      VOUT <= '0' after tco;
      sEndSim <= '0' after tco;
    elsif CLK'event and CLK = '1' then  -- rising clock edge
	
	  stop_count := stop_count + 1;
	  if (stop_count = 9 or stop_count = 10 or stop_count = 13) then
		VOUT <= '0' after tco; 
	  else
	  
			if not endfile(fp_in) then
				readline(fp_in, line_in);
				read(line_in, x);
				DOUT <= conv_std_logic_vector(x, NBIT_OUT) after tco;
				VOUT <= '1' after tco;
				sEndSim <= '0' after tco;
			else
				VOUT <= '0' after tco;        
				sEndSim <= '1' after tco;
			end if;
			
		end if;
		
	end if;
  end process;

  process (CLK, RST_n)
  begin  -- process
    if RST_n = '0' then  -- asynchronous reset (active low)
      END_SIM_i <= (others => '0') after tco;
    elsif CLK'event and CLK = '1' then  -- rising clock edge
      END_SIM_i(0) <= sEndSim after tco;
      END_SIM_i(1 to 10) <= END_SIM_i(0 to 9) after tco;
    end if;
  end process;

  END_SIM <= END_SIM_i(10);  

end beh;
