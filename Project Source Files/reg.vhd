Library ieee;
Use ieee.std_logic_1164.all;

entity reg is
generic(n:integer:=16);
port(clk,rst,wenable:in std_logic;
d:in std_logic_vector(n-1 downto 0);
q:out std_logic_vector(n-1 downto 0)
);
end entity reg;

architecture archreg of reg is
begin
  Process (Clk,Rst,wenable)
  begin
    if (Rst='1') then
      q <=(others=>'0');
    elsif (rising_edge(Clk) and wenable='1') then
      q <=d;
    end if;
  end process;
end architecture archreg;