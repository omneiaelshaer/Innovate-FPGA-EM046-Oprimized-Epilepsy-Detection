 Library ieee;
Use ieee.std_logic_1164.all;

Entity mux2x1 is
Generic (n:integer);
port(
d1:in std_logic_vector(n-1 downto 0);
d2:in std_logic_vector(n-1 downto 0);
s:in std_logic;
q:out std_logic_vector(n-1 downto 0)
);
end entity mux2x1;

Architecture archmux2x1 of mux2x1 is
begin
  q<=d1 when s='0' else 
     d2;   
end architecture archmux2x1;