library IEEE;
use IEEE.std_logic_1164.all;

entity ABSU is
  generic(
    N: integer := 32
  );
  port(
    X: in  std_logic_vector(N-1 downto 0);
    Y: out std_logic_vector(N-1 downto 0)
  );
end ABSU;

architecture RCA of ABSU is
  signal A : std_logic_vector(N-2 downto 0);
  signal C : std_logic_vector(N-1 downto 0);
begin

  C(0)   <= X(N-1); --Cin is equal to MSB
  Y(N-1) <= C(N-1); --Y(N-1) has in input zero because it has to be positive by hypothesis

  HA_i: for i in 0 to N-2 generate
      A(i) <= X(N-1) XOR X(i);
    -------
    --HA
      Y(i)   <= A(i) XOR C(i); --after 10ps*i;	--Se volete divertirvi coi delay
      C(i+1) <= A(i) AND C(i); --after 10ps*i;  --Se volete divertirvi coi delay
    -------
  end generate;

end architecture;
