
Library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

Entity cacheAcc_Avg is
Generic (CacheAcc_Width : integer := 27; --27 bit(15,12)
	 Cache_Width : integer := 23;--23 bit (11,12)
	CacheAvg_Width : integer := 16;--16 bit(9,7)
	address_width:integer :=10;
	n : integer := 16);
port (
	 clk : in std_logic;
	 CVcounter:in unsigned(9 downto 0);
   	 write_enable_cachAcc_Avg : in std_logic;
    	 read_enable_cachAcc_Avg : in std_logic;
    	 datain_cachAcc_Avg : in std_logic_vector(Cache_Width-1 downto 0);

   	 DataOut_cachAcc_Avg:out std_logic_vector(CacheAvg_Width-1 downto 0);

	Out_addressIn_cachAcc_Avg:out std_logic_vector(9 downto 0);

    	 reg_reset_cachAcc_Avg: in std_logic;
         reg_enable_cachAcc_Avg: in std_logic; --enable is one with write signal
	 MuxDataIN_SeclAcc_Avg  : in std_logic_vector(1 downto 0)--Mux before data in coming data or accu. data
);
end entity cacheAcc_Avg;

architecture cacheAcc_Avg_arch of cacheAcc_Avg is
component data_Memory is
	Generic (
	DATA_Mem_WIDTH: integer := 16;
	MeM_DEPTH: integer := 16
	);
port ( clk : in std_logic;
write_enable : in std_logic;
read_enable : in std_logic;
address: in std_logic_vector(MeM_DEPTH-1 downto 0);
datain : in std_logic_vector(DATA_Mem_WIDTH - 1  downto 0);
dataout : out std_logic_vector(DATA_Mem_WIDTH - 1 downto 0)
);
end component;
------------------------------------------------------------------
component N_bitfulladder is
Generic (n : integer := 16);
port
(a,b:in std_logic_vector(n-1 downto 0);
f:out std_logic_vector(n-1 downto 0);
cout:out std_logic
);
end component;
-----------------------------------------------------------------------
component reg is
generic(n:integer);
port(
	clk,rst,wenable:in std_logic;
	d:in std_logic_vector(n-1 downto 0);
	q:out std_logic_vector(n-1 downto 0)
);
end component;
------------------------------------------------------------------------
component mux4x1 is
Generic (n:integer);
port(
d1:in std_logic_vector(n-1 downto 0);
d2:in std_logic_vector(n-1 downto 0);
d3:in std_logic_vector(n-1 downto 0);
d4:in std_logic_vector(n-1 downto 0);
s:in std_logic_vector(1 downto 0);
q:out std_logic_vector(n-1 downto 0));
end component;
---------------------------------------------------------------------
Component divider is
Generic (input_width : integer := 16);
port(
	Q: in std_logic_vector(input_width-1 downto 0);
	M: in std_logic_vector(input_width-1 downto 0);
	Quo: out std_logic_vector(input_width-1 downto 0);
	Remi: out std_logic_vector(input_width-1 downto 0)
);
end Component divider;
-----------------------------------------------------------------
Component Mem_25x900 IS
	PORT
	(
		
		clock		: IN STD_LOGIC  := '1';
		wren		: IN STD_LOGIC ;
		rden		: IN STD_LOGIC  := '1';
		address		: IN STD_LOGIC_VECTOR (9 DOWNTO 0);
		data		: IN STD_LOGIC_VECTOR (26 DOWNTO 0);
		q		: OUT STD_LOGIC_VECTOR (26 DOWNTO 0)
	);
END component;

------------------------------------------------------------------------
signal addressIn_cachAcc_Avg :std_logic_vector(9 downto 0);--address in direct to memory
signal addreIncreas_cachAcc_Avg :std_logic_vector(9 downto 0); --address after increament


signal Sig_datain_cachAcc_Avg:std_logic_vector(CacheAcc_Width-1 downto 0);--data coming from cache
signal dataAcc_cachAcc_Avg :std_logic_vector( CacheAcc_Width-1 downto 0);-- data after being added to old data
signal data_AVG :std_logic_vector( CacheAcc_Width-1 downto 0);--data avg out form division
signal dataAcc_MuxOut_cachAcc_Avg :std_logic_vector( CacheAcc_Width-1 downto 0); --signal after Mux before data in coming data or accu. data or avg data

signal DataOutSignal_cachAcc_Avg :std_logic_vector( CacheAcc_Width-1 downto 0);
signal cout_10: std_logic;


signal SigAvg_Counter :std_logic_vector(CacheAcc_Width-1 downto 0);
signal Remn: std_logic_vector(CacheAcc_Width-1 downto 0);

begin

SigAvg_Counter<=std_logic_vector("00000000000000000"&CVcounter);--25 bit for division

Sig_datain_cachAcc_Avg<=datain_cachAcc_Avg(datain_cachAcc_Avg'High)&datain_cachAcc_Avg(datain_cachAcc_Avg'High)&datain_cachAcc_Avg(datain_cachAcc_Avg'High)&datain_cachAcc_Avg(datain_cachAcc_Avg'High)&datain_cachAcc_Avg;
dataAcc_cachAcc_Avg<=std_logic_vector(signed (Sig_datain_cachAcc_Avg)+signed(DataOutSignal_cachAcc_Avg));--27 bit(15,12)

  adderIcreasing:N_bitfulladder generic map(n => 10) port map(addressIn_cachAcc_Avg,"0000000001", addreIncreas_cachAcc_Avg, cout_10);
  regggg	: reg generic map(n => 10) port map(clk,reg_reset_cachAcc_Avg,reg_enable_cachAcc_Avg,addreIncreas_cachAcc_Avg,addressIn_cachAcc_Avg);
  cacheAcc_MeMo : Mem_25x900 port map(clk,write_enable_cachAcc_Avg, read_enable_cachAcc_Avg,addressIn_cachAcc_Avg,dataAcc_MuxOut_cachAcc_Avg,DataOutSignal_cachAcc_Avg);
  MuxDataIn	: mux4x1 generic map(n => CacheAcc_Width) port map(Sig_datain_cachAcc_Avg,dataAcc_cachAcc_Avg,data_AVG,"000000000000000000000000000",MuxDataIN_SeclAcc_Avg,dataAcc_MuxOut_cachAcc_Avg);   
  LABLE_Division: divider generic map(input_width=>CacheAcc_Width) port map(DataOutSignal_cachAcc_Avg,SigAvg_Counter,data_AVG,Remn);
 

DataOut_cachAcc_Avg<=DataOutSignal_cachAcc_Avg(20 downto 5);
Out_addressIn_cachAcc_Avg<=addressIn_cachAcc_Avg;
end architecture cacheAcc_Avg_arch;
