library ieee;
use ieee.std_logic_1164.all;

entity N_bitfulladder is
Generic (n : integer := 16);
port
(a,b:in std_logic_vector(n-1 downto 0);
f:out std_logic_vector(n-1 downto 0);
cout:out std_logic
);
end entity N_bitfulladder;

architecture N_bitfulladder_arch of N_bitfulladder is
component bithalfadder is
port
(a,b:in std_logic;
f,cout:out std_logic
);
end component bithalfadder;
component bitfulladder is
port
(a,b,cin:in std_logic;
f,cout:out std_logic
);
end component bitfulladder;
signal temp: std_logic_vector(n-1 downto 0);
begin
  f0: bithalfadder port map(a(0),b(0),f(0),temp(0));
  loop1: for i in 1 to n-1 generate
    fx:bitfulladder port map(a(i),b(i),temp(i-1),f(i),temp(i));
  end generate;
  cout<=temp(n-1);
end architecture N_bitfulladder_arch;
