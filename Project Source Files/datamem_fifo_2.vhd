library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
Entity data_Memory_fifo2 is
generic (n: integer := 16);
port ( clk : in std_logic;
write_enable : in std_logic;
read_enable : in std_logic;
address : in std_logic_vector(1 downto 0);
datain : in std_logic_vector(n-1 downto 0);
dataout : out std_logic_vector(n-1 downto 0)

);
end entity data_Memory_fifo2;

architecture archdata_Memory of data_Memory_fifo2 is
  type ram_type is array (0 to 1) of std_logic_vector(n-1 downto 0); 
  signal ram : ram_type;
begin
  process(clk,read_enable,write_enable) is
  begin
    if (rising_edge(clk)) then
		if (write_enable = '1') then
	     ram(to_integer(unsigned(address)))<=datain;
		else
		end if;
	end if;
	if(read_enable = '1') then
		  dataout <= ram(to_integer(unsigned(address)));
	 else
    end if;
	 
  end process;
end architecture archdata_Memory;

