Library ieee;
Use ieee.std_logic_1164.all;

entity MaximReg is
generic(n:integer:=16);
port(clk,rst,wenable:in std_logic;
d:in std_logic_vector(n-1 downto 0);
q:out std_logic_vector(n-1 downto 0)
);
end entity MaximReg;

architecture MaximReg_arch of MaximReg is
signal test:std_logic_vector(n-1 downto 0);

signal test2:std_logic_vector(n-3 downto 0);
begin
test2<=(others=>'1');
test<="10"&test2;
  Process (Clk,Rst)
  begin
    if (Rst='1') then
      q <=test;
	
    elsif (rising_edge(Clk) and wenable='1') then
      q <=d;
    end if;
  end process;
end architecture MaximReg_arch;
