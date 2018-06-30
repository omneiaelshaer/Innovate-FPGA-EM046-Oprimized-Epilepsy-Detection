 Library ieee;
Use ieee.std_logic_1164.all;

Entity mux4x1 is
Generic (n:integer);
port(
d1:in std_logic_vector(n-1 downto 0);
d2:in std_logic_vector(n-1 downto 0);
d3:in std_logic_vector(n-1 downto 0);
d4:in std_logic_vector(n-1 downto 0);
s:in std_logic_vector(1 downto 0);
q:out std_logic_vector(n-1 downto 0));
end entity mux4x1;

Architecture archmux4x1 of mux4x1 is
begin
  q<=d1 when s="00" else 
     d2 when s="01" else
     d3 when s="10" else 
     d4;
end architecture archmux4x1;





