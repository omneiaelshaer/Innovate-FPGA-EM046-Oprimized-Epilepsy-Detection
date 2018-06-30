Library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity integration_final is 
 
PORT (
reset : in std_logic;
clk : in std_logic;    -- clk input 
--Y : in std_logic;      -- label input
--X1: in std_logic_vector((W-1) downto 0);  -- 3 features input 
--X2: in std_logic_vector((W-1) downto 0);
--X3: in std_logic_vector((W-1) downto 0);
--------------------------------------------
--Ctilde	      : in std_logic_vector(Ctild_Width-1 downto 0);  --- input men bara
b	 :out std_logic_vector(16-1 downto 0)





);
end entity integration_final;


ARCHITECTURE Arch_main1 OF integration_final IS
-----------------------------control unit-----------------------
component ControlUnit_seq is
Generic (n : integer := 16;
	address_width:integer :=10
);
port( 
------------------------Classes Enitity-----------------------------
---------------------classes signasl--------------------------------
clk,reset: in std_logic; 
Read_enable_C1: out std_logic; 
Read_enable_C2: out std_logic; 
incidacte_address_class: in std_logic;
addressSel_Class : out  std_logic; --- for both classes
reg_reset_class1_Address   : out std_logic; -- for class 1
reg_enable_class1_Address:out  std_logic;-- for class 1

reg_reset_class2_Address   : out std_logic;
reg_enable_class2_Address: out  std_logic;-- for class 1 
on_sig : out std_logic; --- signal read fel awal khaleeeeeeees lel codeee 
--------------------------Classes counter--------------
Count_ClassI : in unsigned (9 downto 0);
Count_ClassJ : in unsigned (9 downto 0);
Count_reset : out std_logic;



WkBlock_Casses_selector:in std_logic_vector(1 downto 0);--which case old- new - or point on segment
----------------------------NormCalc signals------------------------
Reset_fifo_Norm_wkblock  : out std_logic;
WriteEnable_fifo_Norm_wkblock : out std_logic;
ReadEnable_fifo_Norm_wkblock : out std_logic;
FifoEmpty_fifo_Norm_wkblock : in std_logic; --signal
FifoFull_fifo_Norm_wkblock  : in std_logic; 
reg_reset_WkBlock : out std_logic;
reg_enable_WkBlock :out std_logic;
Select_Norm_queueIn: out std_logic; --selection for mux b4 queue 0--> norm new , 1--> norm calculated
max_min_enable: out std_logic;
-----------------------------------------------------------------------
----------------------------caches-------------------------------------
----------------------cache1------------------------------------------
write_enable_cache1 : out std_logic;
read_enable_cache1 :out std_logic;
MuxAddress_selc1: out std_logic;-- address in increment or new
reg_enable_cache1:out std_logic;
reg_reset_cache1:out std_logic;
mux_selc_DataIn_cache1:out std_logic_vector(1 downto 0);
--------------------cache2-----------------------------------------------
write_enable_cache2:out std_logic;
read_enable_cache2:out std_logic;
MuxAddress_selc2: out std_logic;
reg_enable_cache2:out std_logic;
reg_reset_cache2:out std_logic;
mux_selc_DataIn_cache2:out std_logic_vector(1 downto 0); 
--------------ctild-----------------------------------------------
mux_SelecDataOut:out std_logic;
--------------get max and min -----------------------------
reg_enableMax:out std_logic;    -- reg for getting max enable
reg_resetMax: out std_logic;  
reg_enableMin:out std_logic;     --- reg enable for getting min no reset for min
reg_resetMin :out std_logic; -- n
------------------------------------------------------------------------
----------- added new mirna 
sig_adjustMax_address:out  std_logic;
sig_adjustMin_address: out std_logic;
------------------------------------------------first Acc-Avg cache----------------------------------
write_enable_cachAcc_Avg1 : out std_logic;
read_enable_cachAcc_Avg1  : out std_logic;

reg_reset_cachAcc_Avg1   : out std_logic;  --reg for the address form Acc Avg cache
reg_enable_cachAcc_Avg1   : out std_logic;   
  	
MuxDataIN_SeclAcc_Avg1  : out std_logic_vector(1 downto 0); --Mux before data in coming data or accu. data or avg data
------------------------------------------------second Acc-Avg cache----------------------------------
write_enable_cachAcc_Avg2 : out std_logic;
read_enable_cachAcc_Avg2  : out std_logic;

reg_reset_cachAcc_Avg2   : out std_logic;  --reg for the address form Acc Avg cache
reg_enable_cachAcc_Avg2   : out std_logic;   
  	
MuxDataIN_SeclAcc_Avg2  :out std_logic_vector(1 downto 0); --Mux before data in coming data or accu. data or avg data
-----------------CV---------------------------------------

enable_ireg: out std_logic;  
PointRepeated : in std_logic;
CVcounter: in unsigned( 9 downto 0);
flag_newIJ: out std_logic;
read_CVi_enable: out std_logic;
read_CVj_enable: out std_logic;
CV_DataOut_Selc: out std_logic ;--- added new 
reset_CV_counters_after_avrg: out std_logic; 
--reset_CV_after_Avrg: out std_logic;

-------------------------------------------------------------------------------------
------------avrg norm ---------------------------------------------------
Mux_Select_Avg1_or_Avg2: out std_logic;-- data coming from avg1 or avg2
Mux_Select_alpha_NormAvg: out std_logic_vector(1 downto 0); -- new or old alpha

Reg_reset_AvgNorm : out std_logic;
Reg_Enable_AvgNorm : out std_logic;

Mux_Select_AvgNorm_Que_in: out std_logic; --select data in queue -- new value or feedback
Reset_fifo_AvgNorm:out std_logic;
WriteEnable_fifo_AvgNorm: out std_logic;
ReadEnable_fifo_AvgNorm: out std_logic;
FifoEmpty_fifo: in std_logic;
FifoFull_fifo: in std_logic;

Reg_reset_Queu_AvgNorm : out std_logic;
Reg_Enable_Queu_AvgNorm : out std_logic;


Reset_square : out std_logic; ---- not used yet here 
Last_Termination_condition:in std_logic_vector(1 downto 0); ---01 cosserror >1  00&10 cosserror<1  make sure you handle two case 00 10


---------------------------------------------------------------------------------------------
---------------------------kernel----------------------------------------------------
----------------------Kernel Relative Point Features Reg Signals----------------------
reg_reset_Kernel_RelativePoint_F    : out std_logic;
reg_enable_Kernel_RelativePoint_F   : out std_logic;
--------------------Kernel class Features Reg Signals-------------------------
Kernal_classF_Mux_Selc: out std_logic;
reg_reset_Kernel_classF : out std_logic;
reg_enable_Kernel_classF: out std_logic;
sigCountKernel: in std_logic;
reset_count_kernel:out std_logic; -- added new 
----------------------------------------------------------------------------------------
-------------------------------------------------alphabeta---23-4----------------------------------
average_enable_1: out std_logic;--must be rested at the beging of the code
average_enable_2: out std_logic;--must be rested at the beging of the code
First_Run: out std_logic; --signal from CU to set first values in the alphabeta mem 

reset_AlphaBetaI : out std_logic ;
copyTobackUp_enable_I: out std_logic;
read_enable_AlphaBeta_AvrgI: out std_logic; --1 start rading from avg mem o calculate norm avgc control uint  control this signal
read_enable_BackUp_I: out std_logic;
alpha_beta_wake_up_I: out std_logic;--from CU to indicate start using for alphabeta then set to zero as rest

------------------------------------------------
reset_AlphaBetaJ : out std_logic ;

copyTobackUp_enable_J: out std_logic;
read_enable_AlphaBeta_AvrgJ:  out std_logic; --1 start rading from avg mem o calculate norm avgc control uint  control this signal
read_enable_BackUp_J: out std_logic;
alpha_beta_wake_up_J: out std_logic;--from CU to indicate start using for alphabeta then set to zero as rest
-----------------------------------------------------------------------------------
---------------------------- b
reg_reset_Min_b        : out std_logic;
reg_enable_Min_b       : out std_logic;
reg_reset_Max_b        : out std_logic;
reg_enable_Max_b       : out std_logic;
-----------------------------------------------
Count_TostartRead: in std_logic_vector (2 downto 0)

);
end component ControlUnit_seq;
------------------------------classes---------------------------------
component Classes is
Generic ( D : integer := 10;
	  W : integer := 17;
	Feature_Width : integer := 17;
	 Ctild_Width : integer := 10;
	 Norm_Width : integer := 23; 
         Cache_Width : integer := 23;
		n     : integer := 16
); 
port ( clk : in std_logic;
--Y : in std_logic; 
--X1: in std_logic_vector((W-1) downto 0);
--X2: in std_logic_vector((W-1) downto 0);
--X3: in std_logic_vector((W-1) downto 0);
Read_enable_C1: in std_logic; 
Read_enable_C2: in std_logic; 
--C1_addr_in: in std_logic_vector((D-1) downto 0);
--C2_addr_in: in std_logic_vector((D-1) downto 0);

addressSel_Class  : in std_logic; --- for both classes
reg_reset_class1_Address   : in std_logic; -- for class 1
reg_enable_class1_Address:in std_logic;-- for class 1

reg_reset_class2_Address   : in std_logic;
reg_enable_class2_Address:in std_logic;-- for class 1 

Address_i_new: in std_logic_vector(9 downto 0);
Address_j_new: in std_logic_vector(9 downto 0);

C1X1out: out std_logic_vector((W-1) downto 0); --class1 feature 1
C1X2out: out  std_logic_vector((W-1) downto 0);
C1X3out: out std_logic_vector((W-1) downto 0);
C2X1out: out  std_logic_vector((W-1) downto 0);
C2X2out: out std_logic_vector((W-1) downto 0);
C2X3out:  out std_logic_vector((W-1) downto 0);

----------------------------NormCalc signals-----
Reset_fifo_Norm_wkblock  : in std_logic;
WriteEnable_fifo_Norm_wkblock  : in std_logic;
ReadEnable_fifo_Norm_wkblock  : in std_logic;
FifoEmpty_fifo_Norm_wkblock  : out std_logic; --signal
FifoFull_fifo_Norm_wkblock  : out std_logic; 
reg_reset_WkBlock  : in std_logic;
reg_enable_WkBlock  : in std_logic;
Ctilde	      : in std_logic_vector(Ctild_Width-1 downto 0); 


Select_Norm_queueIn   : in std_logic; --selection for mux b4 queue 0--> norm new , 1--> norm calculated
Cache_i_min  : IN std_logic_vector(Cache_Width-1 downto 0);
Cache_j_max  : IN std_logic_vector(Cache_Width-1 downto 0);

WkSelect      : OUT std_logic_vector(1 downto 0);
lamda   : OUT std_logic_vector(n-1 downto 0);
max_min_enable: in std_logic;
---------------------------------------------------------------------
Count_ClassI : out unsigned (9 downto 0);
Count_ClassJ : out unsigned (9 downto 0);
Count_1024: out unsigned(9 downto 0);  -------- count to enter 900 data entery 
On_sig: in std_logic; 
Count_reset: in std_logic;
incidacte_address_class: out std_logic 
);
end component Classes;

-------------------------------------------------------------------------------------------
-------------------------------------kernel -----------------------------------------------
component  Kernel_block is 
Generic (n : integer := 16);
PORT (
clk,reset : in std_logic;
------------inputs------------------------------------------------------------------------------------
Feature1_Class1_Data  : in std_logic_vector(n-1 downto 0);   --fx1
Feature2_Class1_Data  : in std_logic_vector(n-1 downto 0);   --fx2
Feature3_Class1_Data  : in std_logic_vector(n-1 downto 0);   --fx3

Feature1_Class2_Data  : in std_logic_vector(n-1 downto 0);   --fy1
Feature2_Class2_Data  : in std_logic_vector(n-1 downto 0);   --fy2
Feature3_Class2_Data  : in std_logic_vector(n-1 downto 0);   --fy3

----------------------Kernel Relative Point Features Reg Signals----------------------
reg_reset_Kernel_RelativePoint_F    : in std_logic;
reg_enable_Kernel_RelativePoint_F   : in std_logic;
--------------------Kernel class Features Reg Signals-------------------------
Kernal_classF_Mux_Selc: in std_logic;
reg_reset_Kernel_classF    : in std_logic;
reg_enable_Kernel_classF   : in std_logic;

----------------------------------------------------------------------------------------------------------------
Output_final: out std_logic_vector(15 downto 0); -- (4,12)
OutCountSig: out std_logic;
Count_TostartRead: out std_logic_vector (2 downto 0)
 );

END component Kernel_block;
-----------------------------------caches --------------------------------------------------------------
component caches is
Generic (Cache_Width : integer := 23;--23 bit(11,12)
	CacheAcc_Width : integer := 27;--25 bit(13,12)
	CacheAvg_Width : integer := 16;--16 bit(9,7)--same for alphaBeta since they are multiplied
	Ctild_Width : integer := 10;
	 address_width:integer :=10;
		n : integer := 16);
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
---------------------------------------------------------------------------------
-------------------------------------- mirna added new 
sig_adjustMax_address:in std_logic;
sig_adjustMin_address:in std_logic;
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
end component caches;
------------------------------------------------------------------------------------------------
component CV is
Generic (n:integer:=10;
	d:integer:=10);
port( 
	clk : in std_logic;
	reset: in std_logic;

	enable_ireg: in std_logic;
	i: in std_logic_vector(9 downto 0);
	j: in std_logic_vector(9 downto 0);
	flag_newIJ: in std_logic;

	read_CVi_enable: in std_logic;
	read_CVj_enable: in std_logic;

	--Clear_CV: in std_logic;

	Repeated: out std_logic;
	i_output_Ready: out std_logic_vector(9 downto 0);
	j_output_Ready: out std_logic_vector(9 downto 0);

	CVcounter: out unsigned(9 downto 0);
	CV_DataOut_Selc: in std_logic

);
end component CV;
-----------------------signals---------------------------------------------
signal  Ctilde	 :  std_logic_vector(10-1 downto 0);  --- input men bara
 
----------classes----
signal C1X1out: std_logic_vector((17-1) downto 0);  --- out from classes 
signal C1X2out: std_logic_vector((17-1) downto 0);
signal C1X3out: std_logic_vector((17-1) downto 0);
signal C2X1out: std_logic_vector((17-1) downto 0);
signal C2X2out: std_logic_vector((17-1) downto 0);
signal C2X3out: std_logic_vector((17-1) downto 0); 
----classes counter 
signal Count_ClassI :  unsigned (9 downto 0);
signal Count_ClassJ :  unsigned (9 downto 0);
signal Count_1024: unsigned(9 downto 0);  -------- count to enter 900 data entery 
signal On_sig: std_logic; 
signal Count_reset:  std_logic ; ---- msh 3arfa ahotaha fen belzabt , 3erft khalas
signal incidacte_address_class:  std_logic ;--to indicate which class addres is increamented
------------------------------------------------
signal WkSelect_Sig:  std_logic_vector(1 downto 0); --- out from norm calc 
signal max_min_enable:  std_logic;
signal lamda_sig   :  std_logic_vector(16-1 downto 0); --- out from norm calc
signal kernal_Output_final:std_logic_vector(15 downto 0); -- (4,12)
signal OutCountSig: std_logic;
signal Last_Termination_condition: std_logic_vector(1 downto 0);---01 cosserror >1  00&10 cosserror<1  make sure you handle two case 00 10
---------------------------------------------------------
---------------------classes signasl--------------------------------
signal Read_enable_C1: std_logic; 
signal Read_enable_C2: std_logic; 
signal addressSel_Class : std_logic; --- for both classes

signal reg_reset_class1_Address   :std_logic; -- for class 1
signal reg_enable_class1_Address:std_logic;-- for class 1

signal reg_reset_class2_Address:std_logic;
signal reg_enable_class2_Address:std_logic;-- for class 1 

----------------------------NormCalc signals------------------------
signal Reset_fifo_Norm_wkblock  : std_logic;
signal WriteEnable_fifo_Norm_wkblock : std_logic;
signal ReadEnable_fifo_Norm_wkblock : std_logic;
signal FifoEmpty_fifo_Norm_wkblock : std_logic; --signal
signal FifoFull_fifo_Norm_wkblock  : std_logic; 
signal reg_reset_WkBlock : std_logic;
signal reg_enable_WkBlock : std_logic;
signal Select_Norm_queueIn: std_logic; --selection for mux b4 queue 0--> norm new , 1--> norm calculated
--------------get min and get max 
signal addressMax:  std_logic_vector(9 downto 0);  ---address for j
signal MinValueCache1: std_logic_vector(23-1 downto 0);--it's 23 bit but we only take 16 bit to send to wk block
signal addressMin: std_logic_vector(9 downto 0); --- address for i 
signal MaxValueCache2: std_logic_vector(23-1 downto 0);--it's 23 bit but we only take 16 bit to send to wk block
-------------------------------------------------------------------
--------------get max and min -----------------------------
signal reg_enableMax: std_logic;    -- reg for getting max enable
signal reg_resetMax:  std_logic;  
signal reg_enableMin: std_logic;     --- reg enable for getting min no reset for min
signal reg_resetMin : std_logic;  
signal sig_adjustMax_address:std_logic;
signal sig_adjustMin_address: std_logic;
-----------CV
signal CVcounter: unsigned(9 downto 0);
signal CV_DataOutI: std_logic_vector(9 downto 0);
signal CV_DataOutJ: std_logic_vector(9 downto 0);
signal enable_ireg:  std_logic;  
signal PointRepeated : std_logic;
signal flag_newIJ:  std_logic;
signal read_CVi_enable:  std_logic;
signal read_CVj_enable:  std_logic;
signal CV_DataOut_Selc:std_logic; --- added new 
signal reset_CV_counters_after_avrg: std_logic; 
--signal reset_CV_after_Avrg: std_logic;
----------------------------------------
------------avrg norm ---------------------------------------------------
signal Mux_Select_Avg1_or_Avg2: std_logic;-- data coming from avg1 or avg2
signal Mux_Select_alpha_NormAvg: std_logic_vector(1 downto 0); -- new or old alpha

signal Reg_reset_adder_AvgNorm:std_logic;
signal Reg_Enable_adder_AvgNorm:std_logic;

signal Mux_Select_AvgNorm_Que_in: std_logic; --select data in queue -- new value or feedback
signal Reset_fifo_AvgNorm: std_logic;
signal WriteEnable_fifo_AvgNorm:  std_logic;
signal ReadEnable_fifo_AvgNorm: std_logic;
signal FifoEmpty_fifo: std_logic;
signal FifoFull_fifo:std_logic;

signal Reg_reset_Queu_AvgNorm :  std_logic;
signal Reg_Enable_Queu_AvgNorm :  std_logic;


signal Reset_square :  std_logic; ---- not used yet here

--------------------first Acc-Avg cache---------------------------------
signal write_enable_cachAcc_Avg1 : std_logic;
signal read_enable_cachAcc_Avg1  : std_logic;

signal reg_reset_cachAcc_Avg1   : std_logic; --reg for the address form Acc Avg cache
signal reg_enable_cachAcc_Avg1  : std_logic;   
  	
signal MuxDataIN_SeclAcc_Avg1  :std_logic_vector(1 downto 0); --Mux before data in coming data or accu. data or avg data
------------------------------------------------second Acc-Avg cache----------------------------------
signal write_enable_cachAcc_Avg2 : std_logic;
signal read_enable_cachAcc_Avg2  : std_logic;

signal reg_reset_cachAcc_Avg2   : std_logic;  --reg for the address form Acc Avg cache
signal reg_enable_cachAcc_Avg2   : std_logic;   
  	
signal MuxDataIN_SeclAcc_Avg2  :std_logic_vector(1 downto 0); --Mux before data in coming data or accu. data or avg data
---------------------------------------------------------------------------------------------
----------------------cache1------------------------------------------
signal write_enable_cache1 : std_logic;
signal read_enable_cache1 : std_logic;
signal MuxAddress_selc1: std_logic;-- address in increment or new
signal reg_enable_cache1: std_logic;
signal reg_reset_cache1: std_logic;
signal mux_selc_DataIn_cache1: std_logic_vector(1 downto 0);
--------------------cache2-----------------------------------------------
signal write_enable_cache2: std_logic;
signal read_enable_cache2: std_logic;
signal MuxAddress_selc2: std_logic;
signal reg_enable_cache2: std_logic;
signal reg_reset_cache2: std_logic;
signal mux_selc_DataIn_cache2: std_logic_vector(1 downto 0); 
--------------ctild-----------------------------------------------
signal mux_SelecDataOut: std_logic;
---------------------------kernel----------------------------------------------------
----------------------Kernel Relative Point Features Reg Signals----------------------
signal reg_reset_Kernel_RelativePoint_F    :  std_logic;
signal reg_enable_Kernel_RelativePoint_F   : std_logic;
--------------------Kernel class Features Reg Signals-------------------------
signal Kernal_classF_Mux_Selc:  std_logic;
signal reg_reset_Kernel_classF :  std_logic;
signal reg_enable_Kernel_classF:  std_logic;
signal Count_TostartRead: std_logic_vector (2 downto 0);
signal reset_count_kernel:std_logic; -- added new 
-------------------------------------------------alphabeta---23-4----------------------------------
signal average_enable_1: std_logic;--must be rested at the beging of the code
signal average_enable_2: std_logic;--must be rested at the beging of the code
signal First_Run:std_logic; --signal from CU to set first values in the alphabeta mem 

signal reset_AlphaBetaI :  std_logic ;
signal  copyTobackUp_enable_I:  std_logic;
signal read_enable_AlphaBeta_AvrgI:  std_logic; --1 start rading from avg mem o calculate norm avgc control uint  control this signal
signal read_enable_BackUp_I:  std_logic;
signal alpha_beta_wake_up_I:  std_logic;--from CU to indicate start using for alphabeta then set to zero as rest

------------------------------------------------
signal reset_AlphaBetaJ : std_logic ;

signal copyTobackUp_enable_J:  std_logic;
signal read_enable_AlphaBeta_AvrgJ:  std_logic; --1 start rading from avg mem o calculate norm avgc control uint  control this signal
signal read_enable_BackUp_J:  std_logic;
signal alpha_beta_wake_up_J: std_logic;--from CU to indicate start using for alphabeta then set to zero as rest
---------------------------- b
signal reg_reset_Min_b        :  std_logic;
signal reg_enable_Min_b       :  std_logic;
signal reg_reset_Max_b        :  std_logic;
signal reg_enable_Max_b       :  std_logic;


begin 
---------------------------------------------------------------------------------------------
Controlunit_seq_int: ControlUnit_seq generic map(address_width=>9,n=>16) port map(clk,reset,Read_enable_C1,Read_enable_C2,incidacte_address_class,addressSel_Class,reg_reset_class1_Address,reg_enable_class1_Address,reg_reset_class2_Address,reg_enable_class2_Address,On_sig,
Count_ClassI,Count_ClassJ,Count_reset, WkSelect_Sig ,Reset_fifo_Norm_wkblock,WriteEnable_fifo_Norm_wkblock,ReadEnable_fifo_Norm_wkblock,FifoEmpty_fifo_Norm_wkblock,FifoFull_fifo_Norm_wkblock,reg_reset_WkBlock,reg_enable_WkBlock,
Select_Norm_queueIn,max_min_enable,write_enable_cache1,read_enable_cache1,MuxAddress_selc1,reg_enable_cache1,reg_reset_cache1,mux_selc_DataIn_cache1,write_enable_cache2,read_enable_cache2,MuxAddress_selc2,reg_enable_cache2,reg_reset_cache2,
mux_selc_DataIn_cache2,mux_SelecDataOut,reg_enableMax,reg_resetMax,reg_enableMin,reg_resetMin, sig_adjustMax_address,sig_adjustMin_address,write_enable_cachAcc_Avg1,read_enable_cachAcc_Avg1,reg_reset_cachAcc_Avg1,
reg_enable_cachAcc_Avg1,MuxDataIN_SeclAcc_Avg1,write_enable_cachAcc_Avg2,read_enable_cachAcc_Avg2,reg_reset_cachAcc_Avg2,reg_enable_cachAcc_Avg2,MuxDataIN_SeclAcc_Avg2,enable_ireg,PointRepeated,CVcounter,flag_newIJ,read_CVi_enable,read_CVj_enable,CV_DataOut_Selc,reset_CV_counters_after_avrg,Mux_Select_Avg1_or_Avg2,
Mux_Select_alpha_NormAvg,Reg_reset_adder_AvgNorm,Reg_Enable_adder_AvgNorm,Mux_Select_AvgNorm_Que_in,Reset_fifo_AvgNorm,WriteEnable_fifo_AvgNorm,ReadEnable_fifo_AvgNorm,FifoEmpty_fifo,FifoFull_fifo,Reg_reset_Queu_AvgNorm,Reg_Enable_Queu_AvgNorm,Reset_square,
Last_Termination_condition,reg_reset_Kernel_RelativePoint_F,reg_enable_Kernel_RelativePoint_F,Kernal_classF_Mux_Selc,reg_reset_Kernel_classF,reg_enable_Kernel_classF,OutCountSig,reset_count_kernel,
average_enable_1,average_enable_2,First_Run,reset_AlphaBetaI,copyTobackUp_enable_I,read_enable_AlphaBeta_AvrgI,read_enable_BackUp_I,alpha_beta_wake_up_I,reset_AlphaBetaJ,copyTobackUp_enable_J,read_enable_AlphaBeta_AvrgJ,read_enable_BackUp_J,alpha_beta_wake_up_J
,reg_reset_Min_b,reg_enable_Min_b,reg_reset_Max_b,reg_enable_Max_b,Count_TostartRead);
---------------------------------------------------------------------------------------------------------------------------------------------
classes_int: Classes generic map ( D =>10,W =>17,Feature_Width=>17,Ctild_Width=>10,Norm_Width=>23,Cache_Width=>23,n=>16) 
port map(clk,Read_enable_C1,Read_enable_C2,addressSel_Class,reg_reset_class1_Address,reg_enable_class1_Address,reg_reset_class2_Address,reg_enable_class2_Address,CV_DataOutI,CV_DataOutJ,C1X1out, C1X2out, C1X3out, C2X1out, C2X2out, C2X3out,
Reset_fifo_Norm_wkblock,WriteEnable_fifo_Norm_wkblock ,ReadEnable_fifo_Norm_wkblock,FifoEmpty_fifo_Norm_wkblock,FifoFull_fifo_Norm_wkblock ,reg_reset_WkBlock,reg_enable_WkBlock
,Ctilde,Select_Norm_queueIn,MinValueCache1,MaxValueCache2,WkSelect_Sig,lamda_sig,max_min_enable,Count_ClassI,Count_ClassJ,Count_1024,On_sig,Count_reset,incidacte_address_class);

-------------------------------------------------------------------------------------------------------------------------------------------
kernel_int: Kernel_block generic map (n => 17) port map(clk,reset_count_kernel,C1X1out, C1X2out, C1X3out, C2X1out, C2X2out, C2X3out,reg_reset_Kernel_RelativePoint_F,reg_enable_Kernel_RelativePoint_F,Kernal_classF_Mux_Selc,reg_reset_Kernel_classF,reg_enable_Kernel_classF,kernal_Output_final,OutCountSig,Count_TostartRead);
---------------------------------------------------------------------------------------------------------------------------------------------
caches_int: caches generic  map (Cache_Width=> 23,CacheAcc_Width=> 27,CacheAvg_Width=> 16,Ctild_Width=>10,address_width=>10,n=> 16)
port map(clk,write_enable_cache1,read_enable_cache1,kernal_Output_final,CV_DataOutI,CV_DataOutJ,MuxAddress_selc1,reg_enable_cache1,reg_reset_cache1,mux_selc_DataIn_cache1,write_enable_cache2,
read_enable_cache2,reg_enable_cache2,reg_reset_cache2,mux_selc_DataIn_cache2,MuxAddress_selc2,lamda_sig,Ctilde,mux_SelecDataOut,reg_enableMax,reg_resetMax,addressMax,MinValueCache1,reg_enableMin,reg_resetMin,addressMin,MaxValueCache2,
sig_adjustMax_address,sig_adjustMin_address,write_enable_cachAcc_Avg1,read_enable_cachAcc_Avg1,reg_reset_cachAcc_Avg1,reg_enable_cachAcc_Avg1,MuxDataIN_SeclAcc_Avg1,write_enable_cachAcc_Avg2,read_enable_cachAcc_Avg2,reg_reset_cachAcc_Avg2,reg_enable_cachAcc_Avg2,
MuxDataIN_SeclAcc_Avg2,WkSelect_Sig,average_enable_1,average_enable_2,CVcounter,First_Run,reset_AlphaBetaI,Count_ClassI,copyTobackUp_enable_I,CV_DataOutI,read_enable_AlphaBeta_AvrgI,read_enable_BackUp_I,alpha_beta_wake_up_I,
reset_AlphaBetaJ,Count_ClassJ,copyTobackUp_enable_J,CV_DataOutJ,read_enable_AlphaBeta_AvrgJ,read_enable_BackUp_J,alpha_beta_wake_up_J,
Mux_Select_Avg1_or_Avg2,Mux_Select_alpha_NormAvg,Reg_reset_adder_AvgNorm,Reg_Enable_adder_AvgNorm,Mux_Select_AvgNorm_Que_in,
Reset_fifo_AvgNorm,WriteEnable_fifo_AvgNorm,ReadEnable_fifo_AvgNorm,FifoEmpty_fifo,FifoFull_fifo,Reg_reset_Queu_AvgNorm,Reg_Enable_Queu_AvgNorm,Reset_square,Last_Termination_condition,
reg_reset_Min_b,reg_enable_Min_b,reg_reset_Max_b,reg_enable_Max_b,b);

-----------------------------------------------------------------------------------------------------------------------------------------------
CV_int :CV generic map(n=>10,d=>10) port map(clk,reset_CV_counters_after_avrg,enable_ireg,addressMin,addressMax,flag_newIJ,read_CVi_enable,read_CVj_enable,PointRepeated,CV_DataOutI,CV_DataOutJ,CVcounter,CV_DataOut_Selc);

-------------------------------------------------------------------------------------------------------------------

end Arch_main1;
