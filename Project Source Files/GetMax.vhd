Library ieee;
Use ieee.std_logic_1164.all;

Entity GetMax is
Generic (n:integer:=23;
address_width:integer :=10);
port(
Clk,Rst,enable: in std_logic;
addressi: in std_logic_vector(9 downto 0);
In2new:in std_logic_vector(n-1 downto 0);
addressMax: out std_logic_vector(9 downto 0);
maxCache2:out std_logic_vector(n-1 downto 0);
sig_adjustMax_address:in std_logic
);
end entity GetMax;

Architecture archgetmax of GetMax is
component Comparator_Caches is
Generic (n : integer := 16);
port(   In1 : IN std_logic_vector(n-1 downto 0);
	In2 : IN std_logic_vector(n-1 downto 0); 
        Y : out std_logic_vector(1 downto 0)
	
	
);
end component Comparator_Caches;

 
component mux2x1 is
Generic (n:integer);
port(
d1:in std_logic_vector(n-1 downto 0);
d2:in std_logic_vector(n-1 downto 0);
s:in std_logic;
q:out std_logic_vector(n-1 downto 0)
);
end component mux2x1;

component reg is
generic(n : integer := 16);
port(clk,rst,wenable:in std_logic;
d:in std_logic_vector(n-1 downto 0);
q:out std_logic_vector(n-1 downto 0)
);
end component reg;

component MaximReg is
generic(n:integer:=16);
port(clk,rst,wenable:in std_logic;
d:in std_logic_vector(n-1 downto 0);
q:out std_logic_vector(n-1 downto 0)
);
end component MaximReg;

SIGNAL In1new_temp: std_logic_vector(n-1 downto 0);
SIGNAL In1new: std_logic_vector(n-1 downto 0);
SIGNAL maxSelector: std_logic_vector( 1 downto 0);
SIGNAL RegEnable: std_logic;
signal comp_selcMax: std_logic;
begin
comp_selcMax<= not maxSelector(0);
SelectMax: Comparator_Caches generic map (n=>n)port map(In1new,In2new,maxSelector);
RegAddress:reg generic map (n=>address_width)port map(Clk,Rst,RegEnable,addressi,addressMax);
MaxValue: mux2x1 generic map (n=>n)port map(In2new,In1new,maxSelector(0),In1new_temp);
RegIn1new: MaximReg generic map (n=>n)port map(Clk,Rst,enable,In1new_temp,In1new);
maxCache2<=In1new;
 --- default sig_sel=0 ,=1 when finish
RegEnable<= comp_selcMax when sig_adjustMax_address='0' else
		'0';
end;
