Library ieee;
Use ieee.std_logic_1164.all;

entity MinimReg is
generic(n:integer:=16);
port(clk,rst,wenable:in std_logic;
d:in std_logic_vector(n-1 downto 0);
q:out std_logic_vector(n-1 downto 0)
);
end entity MinimReg;

architecture archreg of MinimReg is
signal test:std_logic_vector(n-1 downto 0);

signal test2:std_logic_vector(n-2 downto 0);
begin
test2<=(others=>'1');
test<='0'&test2;
  Process (Clk,Rst)
  begin
    if (Rst='1') then
      q <=test;
	
    elsif (rising_edge(Clk) and wenable='1') then
      q <=d;
    end if;
  end process;
end architecture archreg;
