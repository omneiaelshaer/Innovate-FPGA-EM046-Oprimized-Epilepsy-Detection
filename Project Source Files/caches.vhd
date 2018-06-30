Library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

Entity caches is
Generic (Cache_Width : integer := 23;--23 bit(11,12)
	CacheAcc_Width : integer := 27;--25 bit(13,12)
	CacheAvg_Width : integer := 16;--16 bit(9,7)--same for alphaBeta since they are multiplied
	Ctild_Width : integer := 10;
	 address_width:integer :=10;
	alphabeta_width:integer :=16;--16 bit (4,12)
		n : integer := 16); --lamda and AvgCounter
port ( clk : in std_logic;
write_enable_cache1 : in std_logic;
read_enable_cache1 : in std_logic;
----------------------------------------------------------------
datain_cache_kernal : in std_logic_vector(n-1 downto 0); --16 bit (4,12)
Inew: in std_logic_vector(9 downto 0);--(16,0) Input form CV 
Jnew: in std_logic_vector(9 downto 0); --(16,0) Input from CV
MuxAddress_selc1: in std_logic;-- address in increment 0 or new 1
-------------------------------------------------------------------
reg_enable_cache1:in std_logic;
reg_reset_cache1:in std_logic;
mux_selc_DataIn_cache1:in std_logic_vector(1 downto 0);
----------------------------------------------------------------
write_enable_cache2: in std_logic;
read_enable_cache2: in std_logic;
reg_enable_cache2:in std_logic;
reg_reset_cache2:in std_logic;
mux_selc_DataIn_cache2:in std_logic_vector(1 downto 0); 
MuxAddress_selc2: in std_logic;
----------------------------------------------------------------
----ctild part-----------------
 Lamda   : in std_logic_vector(n-1 downto 0);
 Ctilde  : in std_logic_vector(Ctild_Width-1 downto 0);
mux_SelecDataOut:in std_logic;
------------------------------------------------------------------
--- get max and min
reg_enableMax:in std_logic;    -- reg for getting max enable
reg_resetMax:in std_logic; 
addressMax: out std_logic_vector(9 downto 0);  -- output from get max and min 
MinValueCache1:out std_logic_vector(Cache_Width-1 downto 0);--it's 23 bit but we only take 16 bit to send to wk block
reg_enableMin:in std_logic;     --- reg enable for getting min no reset for min
reg_resetMin:in std_logic;
addressMin: out std_logic_vector(9 downto 0);
MaxValueCache2:out std_logic_vector(Cache_Width-1 downto 0);--it's 23 bit but we only take 16 bit to send to wk block
-------------------------------------- mirna added new 
sig_adjustMax_address:in std_logic;
sig_adjustMin_address:in std_logic;
---------------------------------------------------------------------------------

---------------------------------------Omnia Avg Calc------------------------------
------------------------------------------------first Acc-Avg cache----------------------------------
write_enable_cachAcc_Avg1 : in std_logic;
read_enable_cachAcc_Avg1  : in std_logic;

reg_reset_cachAcc_Avg1   : in std_logic;  --reg for the address form Acc Avg cache
reg_enable_cachAcc_Avg1   : in std_logic;   
  	
MuxDataIN_SeclAcc_Avg1  : in std_logic_vector(1 downto 0); --Mux before data in coming data or accu. data or avg data
------------------------------------------------second Acc-Avg cache----------------------------------
write_enable_cachAcc_Avg2 : in std_logic;
read_enable_cachAcc_Avg2  : in std_logic;

reg_reset_cachAcc_Avg2   : in std_logic;  --reg for the address form Acc Avg cache
reg_enable_cachAcc_Avg2   : in std_logic;   
  	
MuxDataIN_SeclAcc_Avg2  :in std_logic_vector(1 downto 0); --Mux before data in coming data or accu. data or avg data
-------------------------------------------------alphabeta---23-4----------------------------------
WkSelect: in std_logic_vector(1 downto 0);
average_enable_1: in std_logic;--must be rested at the beging of the code
average_enable_2: in std_logic;--must be rested at the beging of the code
CVcounter: in unsigned(9 downto 0); -- from CV
First_Run: in std_logic; --signal from CU to set first values in the alphabeta mem 

reset_AlphaBetaI : in std_logic ;
Datacounter_I: in unsigned(9 downto 0);  -- class i an j counter from cu 

copyTobackUp_enable_I: in std_logic;
CV_Point_addressI: in std_logic_vector(9 downto 0); --(16,0) cv address
read_enable_AlphaBeta_AvrgI: in std_logic; --1 start rading from avg mem o calculate norm avgc control uint  control this signal
read_enable_BackUp_I: in std_logic;
alpha_beta_wake_up_I: in std_logic;--from CU to indicate start using for alphabeta then set to zero as rest

------------------------------------------------
reset_AlphaBetaJ : in std_logic ;
Datacounter_J: in unsigned(9 downto 0);  -- class i an j counter from cu 

copyTobackUp_enable_J: in std_logic;
CV_Point_addressJ: in std_logic_vector(9 downto 0); --(16,0) cv address
read_enable_AlphaBeta_AvrgJ: in std_logic; --1 start rading from avg mem o calculate norm avgc control uint  control this signal
read_enable_BackUp_J: in std_logic;
alpha_beta_wake_up_J: in std_logic;--from CU to indicate start using for alphabeta then set to zero as rest

-------------------------------------------------avgNorm-23-4--------------------------------------
Mux_Select_Avg1_or_Avg2: in std_logic; -- select which avg data to enter norm avg
Mux_Select_alpha_NormAvg: in std_logic_vector(1 downto 0); --select which alphabeta to enter norm avg
Reg_reset_adder_AvgNorm : in std_logic; --reset adder reg in avg norm
Reg_Enable_adder_AvgNorm : in std_logic;--enable adder reg in avg norm
Mux_Select_AvgNorm_Que_in: in std_logic; --select data in queue -- new value or feedback

Reset_fifo_AvgNorm: in std_logic;
WriteEnable_fifo_AvgNorm: in std_logic;
ReadEnable_fifo_AvgNorm: in std_logic;
FifoEmpty_fifo: out std_logic;
FifoFull_fifo: out std_logic;
Reg_reset_Queu_AvgNorm : in std_logic;
Reg_Enable_Queu_AvgNorm : in std_logic;

Reset_square : in std_logic;
Last_Termination_condition:out std_logic_vector(1 downto 0); ---01 cosserror >1  00&10 cosserror<1  make sure you handle two case 00 10
reg_reset_Min_b        : in std_logic;
reg_enable_Min_b       : in std_logic;
reg_reset_Max_b        : in std_logic;
reg_enable_Max_b       : in std_logic;
b			:out std_logic_vector(CacheAvg_Width-1 downto 0)


);
end entity caches;

architecture archcaches of caches is

component cacheAcc_Avg is
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
end component;

-------------------------------------------------------------------------
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
component reg is
generic(n:integer);
port(clk,rst,wenable:in std_logic;
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
-------------------------------------------------------------------------
component N_bitfulladder is
Generic (n : integer := 16);
port
(a,b:in std_logic_vector(n-1 downto 0);
f:out std_logic_vector(n-1 downto 0);
cout:out std_logic
);
end component;
--------------------------------------------------------------------------
component CtildeUpdate IS 
Generic (Ctild_Width : integer := 10;   
         n : integer := 16;
	Cache_Width : integer := 23);   --Size of  Ctilde_Update_Output in bits
		PORT (
                      CacheDataOut: in std_logic_vector(Cache_Width-1 downto 0);
                      Lamda   : in std_logic_vector(n-1 downto 0);
		      Ctilde  : in std_logic_vector(Ctild_Width-1 downto 0);
                      sub_add_Select: IN std_logic; -- It is 1 when there is Seizure (performs addition) and 0 when there is no seizure (performs subtraction) 
         	      Ctilde_Update_Output : OUT std_logic_vector(Cache_Width-1 downto 0)--check if we need overflow
);    
END component;
---------------------------------------------------------------------------
component mux2x1 is
Generic (n:integer);
port(
d1:in std_logic_vector(n-1 downto 0);
d2:in std_logic_vector(n-1 downto 0);
s:in std_logic;
q:out std_logic_vector(n-1 downto 0)
);
end component mux2x1;
------------------------------------------------------------------------------
------------------------------------------------------------------
component GetMin is
Generic (n:integer:=16;
address_width:integer :=10);
port(
Clk,Rst,enable : in std_logic;
addressj: in std_logic_vector(9 downto 0);
In2new:in std_logic_vector(n-1 downto 0);
addressMin: out std_logic_vector(address_width-1  downto 0);
minCache1:out std_logic_vector(n-1 downto 0);
sig_adjustMin_address:in std_logic
);
end component;
------------------------------------------------------------------
component GetMax is
Generic (n:integer:=16;
address_width:integer :=10);
port(
Clk,Rst,enable: in std_logic;
addressi: in std_logic_vector(address_width-1 downto 0);
In2new:in std_logic_vector(n-1 downto 0);
addressMax: out std_logic_vector(address_width-1 downto 0);
maxCache2:out std_logic_vector(n-1 downto 0);
sig_adjustMax_address:in std_logic
);
end component;
---------------------------------------------------------------------------------
---------------------------------------------------------------------------------
component Norm_avg is
Generic (Data_Width : integer := 16);
port (
clk: in std_logic;
DataOut_cachAvg1 :in std_logic_vector(Data_Width-1 downto 0);--coming data from Avg cache from certain adddress (9,7)
DataOut_cachAvg2 :in std_logic_vector(Data_Width-1 downto 0);--coming data from Avg cache from certain adddress (9,7)
Mux_Select_Avg1_or_Avg2: in std_logic;-- data coming from avg1 or avg2

i_Old_alphabeta:in std_logic_vector(Data_Width-1 downto 0);--coming data from avg alpha old from certain adddress (4,12)
j_Old_alphabeta:in std_logic_vector(Data_Width-1 downto 0);--coming data from avg alpha old from certain adddress (9,7)

i_new_alphabeta:in std_logic_vector(Data_Width-1 downto 0);--coming data from avg alpha old from certain adddress:in std_logic_vector(n-1 downto 0);--coming data from avg alpha new from certain adddress
j_new_alphabeta:in std_logic_vector(Data_Width-1 downto 0);-- (9,7)
Mux_Select_alpha: in std_logic_vector(1 downto 0);

Reg_reset_AvgNorm : in std_logic;
Reg_Enable_AvgNorm : in std_logic;


Mux_Select_AvgNorm_Que_in: in std_logic;
Reset_fifo_AvgNorm: in std_logic;
WriteEnable_fifo_AvgNorm: in std_logic;
ReadEnable_fifo_AvgNorm: in std_logic;
FifoEmpty_fifo: out std_logic;
FifoFull_fifo: out std_logic;


Reg_reset_Queu_AvgNorm : in std_logic;
Reg_Enable_Queu_AvgNorm : in std_logic;

Reset_square : in std_logic;
Last_Termination_condition:out std_logic_vector(1 downto 0)


);
end component;
---------------------------------------------------------------------------------
component alphabetaMem is
Generic (Addr_Width    : integer := 4;
	 Data_Width    : integer := 16;
		n      : integer := 16);
port(
	clk : in std_logic;
	reset: in std_logic;--from control rest one then set to zero next clk
	WkSelect: in std_logic_vector(1 downto 0);
	lamda: in std_logic_vector(n-1 downto 0);
	CV_Point_address: in std_logic_vector(9 downto 0); --(16,0) cv address
	CVcounter: in unsigned(9 downto 0);
	Datacounter: in unsigned(9 downto 0);
	weight_one: in std_logic_vector(Data_Width-1 downto 0);--must be send ya aghbya
	average_enable: in std_logic;--must be rested at the beging of the code
	copyTobackUp_enable: in std_logic;
	--read_enable_address_new: in std_logic;
	read_enable_norm_avg: in std_logic; --1 start rading from avg mem o calculate norm avgc control uint  control this signal
	read_enable_BackUp: in std_logic;
	alpha_beta_wake_up: in std_logic;--from CU to indicate start using for alphabeta then set to zero as rest
	First_Run: in std_logic; --signal from CU to set first values in the alphabeta mem 
	Out_alphabeta_average: out std_logic_vector(Data_Width-1 downto 0);
	OutBackUp: out std_logic_vector(Data_Width-1 downto 0)
	

	
);
end component alphabetaMem;

Component Mem_23x900 IS
	PORT
	(
		clock		: IN STD_LOGIC  := '1';
		wren		: IN STD_LOGIC ;
		rden		: IN STD_LOGIC  := '1';
		address		: IN STD_LOGIC_VECTOR (9 DOWNTO 0);
		data		: IN STD_LOGIC_VECTOR (22 DOWNTO 0);
		q		: OUT STD_LOGIC_VECTOR (22 DOWNTO 0)
	);
END Component;

------------------------------------------------------------------------------
signal Sig_datain_cache_kernal: std_logic_vector(Cache_Width-1 downto 0);
signal Sig_MinValueCache1: std_logic_vector(Cache_Width-1 downto 0);
signal Sig_MaxValueCache2: std_logic_vector(Cache_Width-1 downto 0);


signal adderinc1 :std_logic_vector(9 downto 0); ---reg input
signal addrs1 :std_logic_vector(9 downto 0);  -- reg output 
signal address1_muxOut:std_logic_vector(9 downto 0); --- address input after mux 
signal datainCache1: std_logic_vector(Cache_Width-1 downto 0);
signal cout: std_logic;

signal adderinc2 :std_logic_vector(9 downto 0); ---reg input
signal addrs2 :std_logic_vector(9 downto 0);  -- reg output 
signal address2_muxOut:std_logic_vector(9 downto 0);  --- address input after mux 
signal datainCache2: std_logic_vector(Cache_Width-1 downto 0);

signal DataOut_cache1: std_logic_vector(Cache_Width-1 downto 0); 
signal DataOut_cache2: std_logic_vector(Cache_Width-1 downto 0);
signal DataOut_cache_Mux2:std_logic_vector(Cache_Width-1 downto 0); --23 bit(11,12) but we use only 16 bit(4,12)
signal datain_cacheCtildUpdate : std_logic_vector(Cache_Width-1 downto 0);

signal os  :std_logic;
signal Mult1_out : std_logic_vector(33 downto 0);
signal Mult2_out : std_logic_vector(38 downto 0); --39 bit (19,20)
signal lamda_decrement : std_logic_vector(n-1 downto 0);
signal datain_cacheUpdate : std_logic_vector(38 downto 0);--39 bit (19,20) taken downto 23 bit (11,12)
-----------------------------------------------------------23-4 alphabeta ad normavg------------------------------------

signal Out_alphabeta_average_I:std_logic_vector(alphabeta_width-1 downto 0);--coming data from avg alpha old from certain adddress (4,12)
signal Out_alphabeta_average_J: std_logic_vector(alphabeta_width-1 downto 0);--coming data from avg alpha old from certain adddress (4,12)
signal OutBackUp_I:std_logic_vector(alphabeta_width-1 downto 0);
signal OutBackUp_J: std_logic_vector(alphabeta_width-1 downto 0);	
signal DataOut_cachAcc_Avg1 :std_logic_vector(CacheAvg_Width-1 downto 0);--coming data from Avg cache from certain adddress (9,7)
signal DataOut_cachAcc_Avg2 :std_logic_vector(CacheAvg_Width-1 downto 0);--coming data from Avg cache from certain adddress (9,7)

signal sig_b:std_logic_vector(CacheAvg_Width-1 downto 0);
signal Sig_Last_Termination_condition:std_logic_vector(1 downto 0);

---------------------------------min avg1 and max avg2 to get b-----------
signal Out_addressIn_cachAcc_Avg1:std_logic_vector(9 downto 0);--just for the component ip
signal Out_addressIn_cachAcc_Avg2:std_logic_vector(9 downto 0);

signal address_Min_b :std_logic_vector(9 downto 0); --not used in this file
signal address_Max_b :std_logic_vector(9 downto 0); --not used in this file

signal Min_CacheAvg1_b:std_logic_vector(CacheAvg_Width-1 downto 0);-- min value in class 1
signal Max_CacheAvg2_b:std_logic_vector(CacheAvg_Width-1 downto 0);--max value in class 2
signal diffe_Max_Min:std_logic_vector(CacheAvg_Width-1 downto 0);--max value in class 2

signal negativ_diffe_Max_Min:signed(CacheAvg_Width-1 downto 0);

begin

Sig_datain_cache_kernal<="0000000"&datain_cache_kernal; --23 bit(11,12) to send to cache in case of not point on seg, we conc. to send cache with width 23

-----------------------------------------------update cache when point on seg------------------------------------------------------
lamda_decrement<=std_logic_vector("100000000"-unsigned (Lamda));
Mult1_out <= std_logic_vector( signed(Lamda(Lamda'HIGH)&Lamda) * signed(datain_cache_kernal(datain_cache_kernal'HIGH)&datain_cache_kernal));
Mult2_out <= std_logic_vector( signed(lamda_decrement) * signed(DataOut_cache_Mux2));--39 bit (19,20)
datain_cacheUpdate<=std_logic_vector(signed (Mult1_out)+signed (Mult2_out)); --39 bit (19,20) taken downto (11,12) (30 downto 8)
--------------------------------------------------------------- cache1 -------------------------------------------------------------
muxCache1: mux4x1 generic map (n => Cache_Width) port map(Sig_datain_cache_kernal,datain_cacheUpdate(30 downto 8), datain_cacheCtildUpdate ,"00000000000000000000000",mux_selc_DataIn_cache1,datainCache1);
adder1:  N_bitfulladder generic map(n => 10) port map(addrs1,"0000000001", adderinc1,cout);--must be modified when change the address
reg1: reg generic map(n => 10) port map(clk,reg_reset_cache1,reg_enable_cache1,adderinc1, addrs1);

---------address cache1----
mux_address1: mux2x1 generic map(n => 10) port map(addrs1,Inew,MuxAddress_selc1,address1_muxOut);
cache1 : Mem_23x900 port map(clk,write_enable_cache1, read_enable_cache1,address1_muxOut,datainCache1,DataOut_cache1);

---------------------------------------------------------------- cache2 -------------------------------------------------------------
muxCache2: mux4x1 generic map (n => Cache_Width) port map(Sig_datain_cache_kernal,datain_cacheUpdate(30 downto 8), datain_cacheCtildUpdate ,"00000000000000000000000",mux_selc_DataIn_cache2,datainCache2);
adder2:  N_bitfulladder generic map (n => 10) port map(addrs2,"0000000001", adderinc2, cout);--must be modified when change the address
reg2: reg generic map(n => 10) port map(clk,reg_reset_cache2,reg_enable_cache2,adderinc2, addrs2);
---------address cache2----
mux_address2: mux2x1 generic map(n => 10) port map(addrs2,Jnew,MuxAddress_selc2,address2_muxOut);
cache2 : Mem_23x900 port map(clk,write_enable_cache2, read_enable_cache2,address2_muxOut,datainCache2,DataOut_cache2);
-----------------------------------------------------------------Ctild ---------------------------------------------------------------------
mux_DataOut_cache1and2: mux2x1 generic map(n => Cache_Width) port map( DataOut_cache1, DataOut_cache2,mux_SelecDataOut,DataOut_cache_Mux2) ; --- selc=0 cache1 , add for cache1 
Ctildpart :CtildeUpdate generic map(Ctild_Width=>Ctild_Width,Cache_Width=>Cache_Width,n => n) port map(DataOut_cache_Mux2,lamda,Ctilde,mux_SelecDataOut,datain_cacheCtildUpdate);
-----------------------------get max------------------------------------------------------------------------
---------signal getmin to class1 , signal get max ro class2 
MaxValue : GetMax  generic map(n => Cache_Width,address_width=>10) port map(clk,reg_resetMax,reg_enableMax,address2_muxOut,DataOut_cache2,addressMax,Sig_MaxValueCache2,sig_adjustMax_address);
MinValue : GetMin  generic map(n => Cache_Width,address_width=>10) port map(clk,reg_resetMin,reg_enableMin,address1_muxOut,DataOut_cache1,addressMin,Sig_MinValueCache1,sig_adjustMin_address);

MinValueCache1<=Sig_MinValueCache1;  ---- changed new 
MaxValueCache2<=Sig_MaxValueCache2;


-------------------------------------------Acc Avg cache 1 and 2----------------------------------------------------
cacheAcc_Avg1: cacheAcc_Avg generic map(CacheAcc_Width=>CacheAcc_Width,Cache_Width=>Cache_Width,CacheAvg_Width=>CacheAvg_Width ,address_width=>10,n=>n)
port map(clk,CVcounter,write_enable_cachAcc_Avg1,read_enable_cachAcc_Avg1,DataOut_cache1,DataOut_cachAcc_Avg1,Out_addressIn_cachAcc_Avg1,reg_reset_cachAcc_Avg1,reg_enable_cachAcc_Avg1,MuxDataIN_SeclAcc_Avg1);

cacheAcc_Avg2: cacheAcc_Avg generic map(CacheAcc_Width=>CacheAcc_Width,Cache_Width=>Cache_Width,CacheAvg_Width=>CacheAvg_Width ,address_width=>address_width,n=>n)
port map(clk,CVcounter,write_enable_cachAcc_Avg2,read_enable_cachAcc_Avg2,DataOut_cache2,DataOut_cachAcc_Avg2,Out_addressIn_cachAcc_Avg2,reg_reset_cachAcc_Avg2,reg_enable_cachAcc_Avg2,MuxDataIN_SeclAcc_Avg2);
------------------------------------------------------min avg1 and max avg2 form b------------------------------------
Min_b : GetMin  generic map(n => CacheAvg_Width,address_width=>10) port map(clk,reg_reset_Min_b,reg_enable_Min_b,Out_addressIn_cachAcc_Avg1,DataOut_cachAcc_Avg1,address_Min_b,Min_CacheAvg1_b,sig_adjustMin_address);
Max_B : GetMax  generic map(n => CacheAvg_Width,address_width=>10) port map(clk,reg_reset_Max_b,reg_enable_Max_b,Out_addressIn_cachAcc_Avg2,DataOut_cachAcc_Avg2,address_Max_b,Max_CacheAvg2_b,sig_adjustMax_address);

diffe_Max_Min<=std_logic_vector(signed(Max_CacheAvg2_b) - signed(Min_CacheAvg1_b));--get the difference between max and min
negativ_diffe_Max_Min<="0000000000000000"-signed(diffe_Max_Min);

sig_b<=std_logic_vector(diffe_Max_Min(diffe_Max_Min'High)&diffe_Max_Min(diffe_Max_Min'High downto 1));--divide the difference by 2 --shift to right 17 bit(10,7)

-----------------------------------------alphaBeta blocks-23-4--------------------------------------------------------------
LABEL_ALPHA : alphabetaMem generic map(Addr_Width=> 10,Data_Width=>alphabeta_width,n=> 16) port map(clk,reset_AlphaBetaI,WkSelect,lamda,CV_Point_addressI,CVcounter,Datacounter_I,"0001000000000000",average_enable_1,
copyTobackUp_enable_I,read_enable_AlphaBeta_AvrgI,read_enable_BackUp_I,alpha_beta_wake_up_I,First_Run,Out_alphabeta_average_I,OutBackUp_I);


LABEL_BETA: alphabetaMem generic map(Addr_Width=> address_width,Data_Width=>alphabeta_width,n=> 16) port map(clk,reset_AlphaBetaJ,WkSelect,lamda,CV_Point_addressJ,CVcounter,Datacounter_J,"1111000000000000",average_enable_2,
copyTobackUp_enable_J,read_enable_AlphaBeta_AvrgJ,read_enable_BackUp_J,alpha_beta_wake_up_J,First_Run,Out_alphabeta_average_J,OutBackUp_J);


LABLE_AVGNORM:Norm_avg generic map (Data_Width=>CacheAvg_Width) port map(clk,DataOut_cachAcc_Avg1,DataOut_cachAcc_Avg2,Mux_Select_Avg1_or_Avg2,Out_alphabeta_average_I,Out_alphabeta_average_J,OutBackUp_I,OutBackUp_J
,Mux_Select_alpha_NormAvg,Reg_reset_adder_AvgNorm ,Reg_Enable_adder_AvgNorm ,Mux_Select_AvgNorm_Que_in
,Reset_fifo_AvgNorm,WriteEnable_fifo_AvgNorm ,ReadEnable_fifo_AvgNorm , FifoEmpty_fifo ,FifoFull_fifo ,Reg_reset_Queu_AvgNorm,
Reg_Enable_Queu_AvgNorm,Reset_square,Sig_Last_Termination_condition);

b<=sig_b when Sig_Last_Termination_condition="01";--cosserror>1
Last_Termination_condition<=Sig_Last_Termination_condition;

 end architecture archcaches;

