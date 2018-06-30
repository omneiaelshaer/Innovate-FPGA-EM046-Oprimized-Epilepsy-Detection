
Library ieee;
Use ieee.std_logic_1164.all;
USE IEEE.numeric_std.all;

Entity ControlUnit_seq is
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
reg_enable_class1_Address:out std_logic;-- for class 1

reg_reset_class2_Address   : out std_logic;
reg_enable_class2_Address:out std_logic;-- for class 1 
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
reg_resetMin :out std_logic; -- never use it 
----------- added new mirna 
sig_adjustMax_address:out std_logic;
sig_adjustMin_address:out std_logic;
------------------cache1------------------------------------------------
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
----------------------------------------------------------------------------------------
-----------------CV---------------------------------------

enable_ireg: out std_logic;  
PointRepeated : in std_logic;
CVcounter: in unsigned( 9 downto 0);
flag_newIJ: out std_logic;
read_CVi_enable: out std_logic;
read_CVj_enable: out std_logic;
CV_DataOut_Selc: out std_logic ;--- added new 
reset_CV_counters_after_avrg: out std_logic; 

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
average_enable_2: out std_logic;
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
end entity  ControlUnit_seq;

Architecture controlUnit_arch of  ControlUnit_seq is
TYPE State_type IS (ideal_1,classes,resett,kernel_init,kernel_start_C1,kernel_start_C2,norm_lamda_start,Delay_fullFlagReady,check_Full_ORkernel,state_fifo,
Acc_cache1,write_acc1,read_acc1,Acc_cache2,write_acc2,read_acc2,
Read_cacheAcc_Avg1,Write_cacheAcc_Avg1,Read_cacheAcc_Avg2,Write_cacheAcc_Avg2,start_AvrgNorm1,start_AvrgNorm2,Queue_Avrg_Norm,Read_NormAvg_from_queue,
cacheAvg_Multi_Backup_1,cacheAvg_Multi_Backup_2,off_write,state_read,state_write,read_ctild,write_ctild,Get_min,CV_write
,state_read_2,state_write_2,read_ctild_2,write_ctild_2,CV_write_2,Get_max,Kernel_init2,prepare_for_NormAvg,
prepare_NormAvg2_reset_NormAvg1,delay_for_alphabeta_I_sig,delay_for_alphabeta_J_sig,last_termination,delay_for_alpha_avg
,delay_for_beta_avg,CV_Write_final,copying_to_backup,off_write_2);  -- Define the states
----------------------------------------------------------------------------------------

	SIGNAL State : State_Type;    -- Create a signal that uses 

	signal Sigrepeat_alphabeta: std_logic;
	signal counter_readQueue:  std_logic;	
	signal acc_first_time1: std_logic;
	signal acc_first_time2: std_logic;
	signal  SigWkBlock_Casses : std_logic_vector(1 downto 0);
--------------signals el count---------------------------------------
	signal CV_counter_CU :  unsigned(9 downto 0);
	signal Count_CacheI_CU: unsigned(9 downto 0);
	signal Count_CacheJ_CU: unsigned(9 downto 0);
	
	-- Count_1024 and others_one are for classes state not used currently
	signal Count_1024: signed(9 downto 0);  -------- count to enter 900 data entery 
	signal others_one :signed(9 downto 0);
	signal flag_1stAvrgCalc : std_logic; ---- set at the begining of the code to 1 , else always equal zero 
	signal flag_1stReadAvrgCalc: std_logic_vector(1 downto 0); ----- flag to read the 1st time with reg enable =1 , else reg enable=0
	signal reset_internal :std_logic;
	signal Flag_2nd_norm: std_logic;
	signal First_Run_sig: std_logic;
	signal flag_read_fifo: std_logic;
	signal flag_first_alphaBeta: std_logic;
	signal flag_2nd_iteration: std_logic; 
--------1-6 for copytobackup
	signal first_avg_done:std_logic;--set to 0 till first avg round is done then set to 1
	
BEGIN 
First_Run<=First_Run_sig; 
SigWkBlock_Casses<= WkBlock_Casses_selector when WkBlock_Casses_selector="00" or WkBlock_Casses_selector="10" or WkBlock_Casses_selector="11" else
 			"11"; -- default new point, ye3ml cache 
  PROCESS (clk, reset,reset_internal) 
  BEGIN 

    IF rising_edge(clk) THEN    -- if there is a rising edge of the
	 -- clock, then do the stuff below
 
	-- The CASE statement checks the value of the State variable,
	-- and based on the value and any other control signals, changes
	-- to a new state.
	CASE State IS
		When ideal_1=>
			    If reset = '1'THEN            -- Upon reset, set the state to A
				State <= resett;
			    end if;
		
 
		-- If the current state is A and P is set to 1, then the
		-- next state is B
		WHEN resett => 
			reg_reset_class1_Address<='1';
			reg_enable_class1_Address<='0';

			reg_reset_class2_Address<='1';
			reg_enable_class2_Address<='0';

			Reset_fifo_Norm_wkblock<='1';
			reg_reset_WkBlock<='1';
			reg_reset_cache1<='1';
			reg_reset_cache2<='1';
			counter_readQueue<='0';
			acc_first_time1<='0';
			acc_first_time2<='0';
			enable_ireg<='0';
			Sigrepeat_alphabeta<='0';
			Reg_reset_AvgNorm <='1';

			reg_resetMax<='1';
			reg_resetMin<='1';

			count_reset<='1';
			Count_1024<=(others=>'0');
			others_one<=(others=>'1');

			reg_reset_Max_b<='1';
			reg_enable_Max_b<='0';

			reg_reset_Min_b<='1';
			reg_enable_Min_b<='0';

			reset_AlphaBetaI<='1';  ---- signals to run first alphabeta 
			reset_AlphaBetaJ<='1'; 

			copyTobackUp_enable_I<='0';
			copyTobackUp_enable_J<='0';

			read_enable_AlphaBeta_AvrgI<='0';
			read_enable_AlphaBeta_AvrgJ<='0';

			read_enable_BackUp_I<='0'; 
			read_enable_BackUp_J<='0';
			Reset_fifo_AvgNorm<='1';
			Reg_reset_Queu_AvgNorm<='1';
			Reg_Enable_Queu_AvgNorm<='0';
			Count_reset<='1';

			flag_1stAvrgCalc<='1';   -- set at the begining of the code to 1 , else always equal zero 
			flag_1stReadAvrgCalc<="01"; -- flag to read the 1st time with reg enable =1 , else reg enable=0
			
			reset_internal<='0';
			Flag_2nd_norm<='1';
			
			 CV_counter_CU<= (others=>'0'); --- addded new 
			 Count_CacheI_CU<=(others=>'0');
			 Count_CacheJ_CU<=(others=>'0');
			
			
			flag_read_fifo<='0'; --- added new mirna 
			reg_enableMax<='0';
			reg_enableMin<='0';
			reg_reset_Kernel_classF<='0';  ---  de lazem nestkhdemo 
			reg_enable_cache2<='0';
			reset_count_kernel<='1';
			on_sig<='0'; 
			Reset_square<='1';

			CV_DataOut_Selc<='0';  -- added new 
			max_min_enable<='0'; -- added new 
			reset_CV_counters_after_avrg<='1'; --- added new , reset all cv fel awal 
			---------------- read enable ----------------
				Read_enable_C1<='0'; 
				Read_enable_C2<='0'; 
				
				enable_ireg<='0'; 
				flag_newIJ<='0'; 
				
				read_CVi_enable<='0'; 
				read_CVj_enable<='0'; 
				WriteEnable_fifo_Norm_wkblock<='0'; 
				ReadEnable_fifo_Norm_wkblock<='0'; 
				write_enable_cache1<='0'; 
				read_enable_cache1<='0'; 
				write_enable_cache2<='0'; 
				read_enable_cache2<='0'; 

				

				write_enable_cachAcc_Avg1<='0'; 
				read_enable_cachAcc_Avg1<='0'; 

				reg_reset_cachAcc_Avg1<='1';  --reg for the address form Acc Avg cache
				reg_enable_cachAcc_Avg1<='0';   
  	
				MuxDataIN_SeclAcc_Avg1 <="00";  --Mux before data in coming data or accu. data or avg data

				write_enable_cachAcc_Avg2<='0'; 
				read_enable_cachAcc_Avg2<='0'; 

				reg_reset_cachAcc_Avg2<='1';  --reg for the address form Acc Avg cache
				reg_enable_cachAcc_Avg2<='0';   
  	
				MuxDataIN_SeclAcc_Avg2 <="00"; --Mux before data in coming data or accu. data or avg data

				WriteEnable_fifo_AvgNorm<='0'; 
				ReadEnable_fifo_AvgNorm<='0'; 

				read_enable_AlphaBeta_AvrgI<='0'; 
				read_enable_BackUp_I<='0'; 

				read_enable_AlphaBeta_AvrgJ<='0'; 
				read_enable_BackUp_J<='0'; 
				flag_read_fifo<='0';

		------------------------- reg enables---------------------------

			reg_enable_Min_b <='0'; 
			reg_enable_Max_b <='0'; 
			reg_enable_cache2<='0'; 
			reg_enable_cache1<='0'; 
			reg_reset_Kernel_classF <='0'; 
			reg_enable_Kernel_classF<='0'; 
			reg_reset_Kernel_RelativePoint_F<='0'; 
			reg_enable_Kernel_RelativePoint_F<='0';  
			reg_enable_WkBlock<='0';
			Reg_Enable_Queu_AvgNorm<='0'; 
			Reg_Enable_AvgNorm<='0'; 

		----------------------------muxs--------------------------------------
			addressSel_Class<='0'; -- read inew address
			addressSel_Class<='0'; 
			Select_Norm_queueIn<='1';
			MuxAddress_selc1<='0'; 
			mux_selc_DataIn_cache1<="00"; 
			MuxAddress_selc2<='0'; 
			mux_selc_DataIn_cache2<="00";
			mux_SelecDataOut<='0';
			Mux_Select_Avg1_or_Avg2<='0'; 
			Mux_Select_alpha_NormAvg<="00"; 
			sig_adjustMax_address<='1'; 
			sig_adjustMin_address<='1';
			Kernal_classF_Mux_Selc<='0'; 
			Mux_Select_AvgNorm_Que_in<='0'; 

			first_avg_done<='0';

			------------------------------------------------

			 flag_first_alphaBeta<='1';
			--State <= classes;  ------ awel mara yekteb khales fel classes , ana 3ayza a2olo yekteb
 			State <= norm_lamda_start;
		
		WHEN classes=>  ------write classes for the first time in your fucking life 
			
			reset_AlphaBetaI<='0';
			reset_AlphaBetaJ<='0';

			count_reset<='0'; -- haga for classes S
			addressSel_Class<='1'; --- pass the incremented address 
			on_sig<='1';
			reg_reset_class1_Address<='0';
			reg_reset_class2_Address<='0';

			if incidacte_address_class='0' then -- class 1
				reg_enable_class1_Address<='1';
				reg_enable_class2_Address<='0';
			elsif incidacte_address_class='1' then 
				reg_enable_class1_Address<='0';
				reg_enable_class2_Address<='1';
			
			elsif( Count_1024=others_one)then 
			
					reg_reset_class1_Address <='1';
					reg_enable_class1_Address<='0';

					reg_reset_class2_Address<='1';
					reg_enable_class2_Address<='0';
					on_sig<='0';
					State <= norm_lamda_start;  --- state reeeeeeeeaaaaaaaadddddd  
				end if;
		WHEN norm_lamda_start =>   ---- reading class1 and class2 feauture and activating norm  we kernel 
			Reset_fifo_Norm_wkblock<='0';
			-------------------------------
			reset_CV_counters_after_avrg<='0';
			read_CVi_enable<='1'; --- first time 0
			read_CVj_enable<='1';

			CV_DataOut_Selc<='1';  --- enbale to store inew and j  new;
			-----------alpha beta mem is filled with initial data in the CV address i=0 j=0 -------------------------

			addressSel_Class<='0'; -- read inew address
			Read_enable_C1<='1';  --read point 1 clss1 
			Read_enable_C2<='1';  --- read point 1 class2 

			WriteEnable_fifo_Norm_wkblock <='1';  -- write norm in fifo 
			ReadEnable_fifo_Norm_wkblock<='0';  
			Select_Norm_queueIn<='1';  
			reg_enable_Kernel_RelativePoint_F<='1';  -- enable reg before krenel to store point 
			reset_count_kernel<='0';
			flag_newIJ<='0'; --- make sure that write signal to CV is off
			
			---------fe condition en low gat point repeated yehesb mara wahda 
			reg_reset_class1_Address<='1';
			Kernal_classF_Mux_Selc<='0'; ---class 1 only
			----- as signal full comes with delay 1 cycle, momken ahot state yeshof 
			------feha ba3d ma katb el norm hal howa full wala la2 we low kda yeroh el kernel 
			
			state<= Delay_fullFlagReady;
		
		when  Delay_fullFlagReady=>
	------------------------ alpha beta------------------
				
			if  flag_first_alphaBeta='1' then
			
				First_Run_sig<='1';
				flag_first_alphaBeta<='0';
				alpha_beta_wake_up_J<='1'; --- close hen, check this signal
				alpha_beta_wake_up_I<='1'; --- close hen, check this signal
			end if; 
			average_enable_1<='0';
			average_enable_2<='0';

			reset_AlphaBetaI<='0';
			reset_AlphaBetaJ<='0';

			average_enable_1<='0';
			copyTobackUp_enable_I<='0';
			read_enable_BackUp_I<='0';  ---- read memory alpha backup
			read_enable_AlphaBeta_AvrgI<='0';
			
			average_enable_2<='0';
			copyTobackUp_enable_J<='0';
			read_enable_BackUp_J<='0';  ---- read memory alpha backup
			read_enable_AlphaBeta_AvrgJ<='0';
				
			
			----------------------------------------------------------
			WriteEnable_fifo_Norm_wkblock <='0';  -- write norm in fifo off
			reg_enable_Kernel_RelativePoint_F<='0';
			Read_enable_C1<='0';  --read point 1 clss1 
			Read_enable_C2<='0';  --- read point 1 class2

			read_CVi_enable<='0'; --- first time 0
			read_CVj_enable<='0';
			CV_DataOut_Selc<='0'; --- to store inew and jnew value 
			state<=check_Full_ORkernel;

		when  check_Full_ORkernel=>
			read_CVi_enable<='0'; --- first time 0
			read_CVj_enable<='0';
			--CV_DataOut_Selc<='1';
			------------- alpha beta ------
				--First_Run_sig<='0';
				--flag_first_alphaBeta<='0';
				--alpha_beta_wake_up_J<='0'; --- close hen, check this signal
				--alpha_beta_wake_up_I<='0'; --- close hen, check this signal
			--------------------------------------
			if FifoFull_fifo_Norm_wkblock='1'  then 
				state<= state_fifo; -- lamda block conti
			elsif FifoFull_fifo_Norm_wkblock='0'then  ---change it to else
				state<= kernel_init;--to prepare the mux and reg for kernel
			end if;

		when state_fifo =>	
		
			CV_DataOut_Selc<='0'; ---open only fe goz2 lamda block and norm 
			
			read_CVi_enable<='0';--we need to send CV address to alphabeta but assuing address will remain on the signal
			read_CVj_enable<='0';	
			Read_enable_C1<='0';
			Read_enable_C2<='0';
			reg_reset_class2_Address<='0';
				--preparing the reg before WK block
				--this counter is used to indicate first tiime then you can read
				--wite the FB norm back in queue and setting the mux to zero to pass this FB
				--lamda and WKselc are ready 
				IF counter_readQueue='0'and  FifoEmpty_fifo_Norm_wkblock='0' and flag_read_fifo='0' then
					WriteEnable_fifo_Norm_wkblock <='0';
					ReadEnable_fifo_Norm_wkblock<='1';
					reg_enable_WkBlock<='1';
					reg_reset_WkBlock<='0';
					max_min_enable<='0';  
					 counter_readQueue <='1';
				
				elsif  counter_readQueue='1' and  FifoEmpty_fifo_Norm_wkblock='0' and flag_read_fifo='0' then
					reg_enable_WkBlock<='0';
					ReadEnable_fifo_Norm_wkblock<='1';
					counter_readQueue<='0';
					max_min_enable<='1'; -- pass the max and min value in the first read, to be ready with the 2nd read
					flag_read_fifo<='1'; --- reset to 1 before calc here

				elsif FifoEmpty_fifo_Norm_wkblock='1' and flag_read_fifo='1' then   -- terminating condtition 
					--------------------- alphabeta------------------------------------
					alpha_beta_wake_up_J<='1'; --- close hen, check this signal
					alpha_beta_wake_up_I<='1'; --- close hen, check this signal
					First_Run_sig<='0';
					flag_first_alphaBeta<='0';
				
					average_enable_1<='0';
					copyTobackUp_enable_I<='0';
					read_enable_BackUp_I<='0';  ---- read memory alpha backup
					read_enable_AlphaBeta_AvrgI<='0';
					reset_AlphaBetaI<='0';

					average_enable_2<='0';
					copyTobackUp_enable_J<='0';
					read_enable_BackUp_J<='0';  ---- read memory alpha backup
					read_enable_AlphaBeta_AvrgJ<='0';
					reset_alphaBetaJ<='0';
				
			-----------------------------------------------------
					flag_read_fifo<='0'; --- reset to 0 before calc here 
					WriteEnable_fifo_Norm_wkblock <='1';
					reset_count_kernel<='1'; --- always reset kernel count before starting 
					ReadEnable_fifo_Norm_wkblock<='0';
					reg_enable_WkBlock<='0';
					max_min_enable<='0';  
					Select_Norm_queueIn<='0'; --- write point el gya men wksig 
					if WkBlock_Casses_selector="10" then
					state<=Acc_cache1 ; -- for old point ---> go accumlate 3alatol
					else 
					State <= kernel_init;  -- yeroh lr kernel intial el awal 
					end if; 
	
				else 
					state <= state_fifo;
				end if;
				


		when kernel_init=>
				CV_DataOut_Selc<='0';
				read_CVi_enable<='0';
				read_CVj_enable<='0';
				WriteEnable_fifo_Norm_wkblock<='0';
				ReadEnable_fifo_Norm_wkblock<='0';
				reg_enable_Kernel_RelativePoint_F<='0';
				Read_enable_C2<='0';  --- read point 1 class2 
				Read_enable_C1<='1';  --read point 1 clss1 
				reg_reset_class1_Address<='0'; --- reset address classes to start reading dataset 
				reg_enable_class1_Address<='1';
				addressSel_Class<='1'; -- read inc address of dataset
				Kernal_classF_Mux_Selc<='0';
				reg_enable_Kernel_classF<='1';--- to read data set 
				reset_count_kernel<='1';
				State <= kernel_start_C1; -- kernal for very first point 
				-----------------------------------------------------------------						
	when kernel_start_C1 => 
			reset_count_kernel<='0';  
			reg_reset_cache1<='0';
			alpha_beta_wake_up_I<='0';  
			alpha_beta_wake_up_J<='0'; 
			read_CVi_enable<='0';--we need to send CV address to alphabeta but assuing address will remain on the signal
			read_CVj_enable<='0'; ---read CV point off after reading point 	
 
			reg_enable_Kernel_RelativePoint_F<='0'; -- da ma2fol ba2et haytyyyy
			reg_enable_Kernel_classF<='1';
			Read_enable_C1<='0'; -- khargly 3 feature we 3ayza aketbhom fe reg 
			
			
			reg_reset_class1_Address <='0';
			reg_enable_class1_Address<='0'; 

			Kernal_classF_Mux_Selc <='0'; -- start with class1 
			WriteEnable_fifo_Norm_wkblock <='0';
			write_enable_cache1<='0';
			reg_enable_cache1<='0';

			if Count_TostartRead="010" and (count_CacheI_CU< (Count_ClassI-1))  and  ( SigWkBlock_Casses="11" ) then --- condition el count 3ashan may3melsh read le garbage fel value el akhera a el read byhsal able l count 
				Read_enable_C1<='1'; -- khargly 3 feature of new point we 3ayza aketbhom fe reg 
			else 
				Read_enable_C1<='0'; -- khargly 3 feature we 3ayza aketbhom fe reg 
			end if;
				if (sigCountKernel='1' and  (SigWkBlock_Casses="11" ))then     --case  new write in cache 
			
				---aftah read new point from data set
				count_CacheI_CU<=count_CacheI_CU+1;
				addressSel_Class<='1'; -- inc address of class1 
				reg_enable_Kernel_classF<='1';
				reg_enable_class1_Address<='1';
				-----------------------------------------------------------------
				write_enable_cache1<='1';
				--Count_CacheI_CU<=Count_CacheI_CU+1;
				mux_selc_DataIn_cache1<="00";
				MuxAddress_selc1<='0';  -- address inc 
				reg_enable_cache1<='1';
				reg_resetMin<='0';
				
				elsif (sigCountKernel='1' and  SigWkBlock_Casses="00")then     --case alpha/beta
				addressSel_Class<='1'; -- inc address of class1
				-----------------------------------------------------------------------
				mux_SelecDataOut<='0'; --read from cache to calc kernel in case of point on seg
				MuxAddress_selc1<='0';
					
					state<=state_read;  --- Start reading

				elsif count_CacheI_CU = Count_ClassI then    --- khalasana class 1 elhumdellah go read class2 
					--------conditon ehna alpha/beta ctild update or input 3ady 

					reg_reset_class1_Address <='1'; -- after finishing kernel rest the class address
					reg_enable_class1_Address<='0';
					
					Read_enable_C1<='0';
					count_CacheI_CU<=(others=>'0');
					write_enable_cache1<='0';
					if SigWkBlock_Casses="00" then
						state<= read_ctild;
					else 	
					
          				---------------- kernel part---------------------------
					reg_reset_class1_Address<='1'; --- reset address classes to start reading dataset 
					reg_enable_class1_Address<='0';
					Kernal_classF_Mux_Selc<='1';---- to pass hagat class 2
					reset_count_kernel<='1'; --- reset counter of kernel for cache 2
						state<=kernel_init2; -- changed new, ba3d kernel  2 gt min and max sawa 
					end if;

				else		---- check low else hatbawz ***elsif (count_CacheI_CU<Count_ClassI )and flag_term<='0' then																																																																																																														
				State <= kernel_start_C1;
				end if; --- ending condition writing cahe 1 is done
---------------------------------------------------------------------------------
				when  state_read=>
					Read_enable_Cache1<='1';
					reg_enable_cache1<='0';
					mux_SelecDataOut<='0'; --- read data out cache 
					reset_count_kernel<='1';  --- reset kernel to get new point sah
					state<= state_write ;
				 when state_write=>
				       if (count_CacheI_CU< (Count_ClassI-1)) then 
						Read_enable_C1<='1'; ---check low condition el fo2 bybawz fel heta de 
					else 
						Read_enable_C1<='0';	
					end if;
					reset_count_kernel<='1';
					Read_enable_Cache1<='0';
					reg_enable_cache1<='1';
					mux_SelecDataOut<='0'; --- read data out cache  
					reg_enable_Kernel_classF<='1';---aftah enable new point from data set
					reg_enable_class1_Address<='1';	
					write_enable_cache1<='1';
					count_CacheI_CU<=count_CacheI_CU+1;
					reg_enable_cache1<='1';
					mux_selc_DataIn_cache1<="01";
					State <= kernel_start_C1;
			
				when read_ctild=>
						enable_ireg<='0'; ---- make sure reg that store max value of i is off CV
						Read_enable_Cache1<='1';
						mux_SelecDataOut<='0';
						MuxAddress_selc1<='1';   ---- to let address inew pass 
						read_CVi_enable<='1';  --- read the i new point 
						state<= write_ctild;
				when write_ctild=>
						read_CVi_enable<='1';
						write_enable_cache1<='1';
						Read_enable_Cache1<='0';  
 						MuxAddress_selc1<='1'; --- address i
						--reg_enable_cache1<='1';
						mux_selc_DataIn_cache1<="10";
						reg_reset_cache1<='1';
						sig_adjustMin_address<='1'; -- new 
						reg_resetMin<='1'; --- reset min value stored everytime before getting the min
						state<= kernel_init2; --- changed new  
					
                     ------------------------------------------------------------------------------		
				
		when Kernel_init2 =>
				write_enable_cache1<='0';
				Read_enable_Cache1<='0';
			-------------------------------------
				read_CVi_enable<='0';
				read_CVj_enable<='0';
			-----------------------------------
				enable_ireg<='0'; ---- make sure reg that store max value of i is off
				reset_count_kernel<='1';
				reg_reset_cache2<='0';
				reg_enable_cache2<='0';
				reg_enable_Kernel_RelativePoint_F<='0';
			------------------------------------------------
				Read_enable_C2<='1';  --read point 1 clss1  le awel mara 
				Read_enable_C1<='0';
				reg_reset_class2_Address<='0'; --- reset address classes to start reading dataset 
				reg_enable_class2_Address<='1';
				addressSel_Class<='1'; -- read inc address 
			----------------------------------------------
				
				Kernal_classF_Mux_Selc<='1';---- to pass hagat class 2
				reg_enable_Kernel_classF<='1';--- to read data set 
				State <= kernel_start_C2; -- kernal for very first point 
				-----------------------------------------------------------------
									

							
		when kernel_start_C2 =>      ---- start kernal for class 2 
			reset_count_kernel<='0';
			reg_reset_class2_Address<='0';
			reg_enable_class2_Address<='0';

			addressSel_Class<='1'; -- inc address of class
			reg_enable_Kernel_RelativePoint_F<='0'; -- da ma2fol ba2et haytyyyy
			Read_enable_C2<='0';
			reg_reset_cache2<='0';
			reg_enable_Kernel_classF<='1';
			Kernal_classF_Mux_Selc <='1'; -- start with class2
			
			write_enable_cache2<='0';
			reg_enable_cache2<='0';
			reg_resetMax <='0';  --- close reset el reg el 3and el max 
			if Count_TostartRead="010" and (count_CacheJ_CU< Count_ClassJ-1)and (SigWkBlock_Casses="11" )  then --- check low hatboz fel 
				Read_enable_C2<='1'; -- khargly 3 feature of new point we 3ayza aketbhom fe reg 
			end if;
				if sigCountKernel='1' and  (SigWkBlock_Casses="11" )then     --case new write in cache 
				
				count_CacheJ_CU<=count_CacheJ_CU+1; -- check 3ala count ba3den zawed el count we etl3 e3ml el kernel tany
				reg_enable_class2_Address<='1';
				reg_enable_Kernel_classF<='1';
				-----------------------------------------------------------------------
				write_enable_cache2<='1';
				mux_selc_DataIn_cache2<="00";
				MuxAddress_selc2<='0'; -- inc address
				reg_enable_cache2<='1'; --- enable cache2 address 
				reg_resetMax<='0';

				elsif (sigCountKernel='1' and  SigWkBlock_Casses="00")then     --case alpha/beta
					addressSel_Class<='1'; -- inc address of class1
					mux_SelecDataOut<='1';  ---- cache 2 output
					MuxAddress_selc2<='0';
						
						State<= state_read_2;

				elsif count_CacheJ_CU =Count_ClassJ then    --- khalasana class 2 elhumdellah go read class2 
					--------conditon ehna alpha/beta ctild update or input 3ady 
					count_CacheJ_CU<=(others=>'0');
					write_enable_cache2<='0';
					reg_enable_cache2<='0';	
					
					if SigWkBlock_Casses="00" then
						State <= read_ctild_2;
					else 
						reg_reset_cache2<='1'; --- reset addres when finished 
						reg_resetMax<='1';-- reset the last max value stored 
						sig_adjustMax_address<='0'; ---- to let the enable be the enable of comp
						
						reg_resetMin<='1';   --- reset last min value 
						reg_reset_cache1<='1';
						sig_adjustMin_address<='0'; --- khaly enable el addres howa el comp

						State<= Get_min; ---- start from the begining :D
					end if;
				else          ----- Count_CacheJ_CU < Count_ClassJ then --- check low khalenaha else donia hatboz wala la2 
				State <= kernel_start_C2;
				end if; --- ending condition writing cahe 1 is done
				------------------------------------------------------------------------------------
				
					when  state_read_2=>
						Read_enable_Cache2<='1';
						mux_SelecDataOut<='1';
						--reg_reset_cache2<='0';
						reg_enable_cache2<='0';
						reset_count_kernel<='1'; --- reset count to start calc kernel correct 
						State <= state_write_2 ;

					when state_write_2 =>
					 if (count_CacheJ_CU< (Count_ClassJ-1)) then 
						Read_enable_C2<='1'; -- check low condition el fo2 bybawz fel heta de 
					else 
						Read_enable_C2<='0';
					end if;			
						reg_enable_class2_Address<='1';
						reg_enable_Kernel_classF<='1';	
						mux_SelecDataOut<='1';
						reset_count_kernel<='1';
						--------- kol da gowa condition kernal count=3 gat we matensesh te2fely read el classes for 3 cycles 
						write_enable_cache2<='1';
						count_CacheJ_CU<=count_CacheJ_CU+1;
						Read_enable_Cache2<='0';
						reg_enable_cache2<='1';
						mux_selc_DataIn_cache2<="01";
						State <= kernel_start_C2;

					when read_ctild_2 =>
						read_CVj_enable<='1';
						Read_enable_Cache2<='1';
						mux_SelecDataOut<='1';
						MuxAddress_selc2<='1';
						State<= write_ctild_2;
					when write_ctild_2 =>
						read_CVj_enable<='1';
						write_enable_cache2<='1';
						Read_enable_Cache2<='0';
 						MuxAddress_selc2<='1';
						mux_selc_DataIn_cache2<="10";

						reg_reset_cache2<='1';
						reg_enable_cache2<='0';	
						reg_resetMax<='1';
						sig_adjustMax_address<='1';  -- added new 

						reg_resetMin<='1';   --- reset last min value 
						reg_reset_cache1<='1';
						reg_enable_cache1<='0';
						State<= Get_min;					
					-------------------------------------------

					 when Get_min=>

					reset_AlphaBetaI<='0';
					reset_AlphaBetaJ<='0';

					reset_CV_counters_after_avrg<='0'; --- close rset cv to write address min and max
					-----------------------------------------
						write_enable_cache1<='0';
						write_enable_cache1<='0';  --added new 
					----------------------------------------
						read_CVi_enable<='0';
						sig_adjustMin_address<='0'; -- khaly enbale el addres el comp sig
						reg_enable_Kernel_classF<='0';
						reg_resetMin<='0';
						reg_enableMin<='1';  --always =1 3ashan ye3dy el min value 
						reg_reset_cache1<='0';
						reg_enable_cache1<='1';
						Read_enable_Cache2<='0';
						Read_enable_Cache1<='1';
						write_enable_cache1<='0';
						MuxAddress_selc1<='0'; --- pass inc value 
						
						---- if condition eno khalas el read el memory kolaha
							if count_CacheI_CU =Count_ClassI then
								count_CacheI_CU <=(others=>'0');
								Read_enable_Cache1<='0';
								Reg_enable_cache1<='0';
								sig_adjustMin_address<='1'; --- e2fely enable el addres min , to store correct addres 
								Reg_reset_cache1<='1'; --- check to close later if needed 
								state<= CV_write;
							elsif count_CacheI_CU < Count_ClassI then
								
								count_CacheI_CU<=count_CacheI_CU+1; -- check 3ala count ba3d condition el termination
								state<= Get_min;
							end if;

					when CV_write=>
						enable_ireg<='1';
						Read_enable_C1<='0';
						reg_enableMin<='0'; -- added new close enable after finishing get min 
						state<= Get_max; 
				--------------------------------------------------------------------------------
					when Get_max=>
						enable_ireg<='0';
						read_CVj_enable<='0';
						sig_adjustMax_address<='0';  -- added new
						reg_resetMax<='0';
						reg_reset_cache2<='0';
		    				Read_enable_Cache2<='1';
						reg_enable_cache2<='1';	
						write_enable_cache2<='0';
						MuxAddress_selc2<='0';  
						mux_SelecDataOut<='1';           
						reg_enableMax<='1'; -- enable is always = 1
						---- if condition eno khalas el read el memory kolaha
							if count_CacheJ_CU =Count_ClassJ then  
								count_CacheJ_CU<=(others=>'0'); 
								Read_enable_Cache2<='0';
								sig_adjustMax_address<='1'; --- close reg addres max to store correct value 
								reg_reset_cache2<='1'; --- close down before necesary 
								reg_enable_cache2<='0';
							----------------------------------------
								if Flag_2nd_norm='1'or flag_2nd_iteration='1' then 		
								flag_newIJ<='1'; --- (***open early bec this enable gets registerd )start writing in CV memory both points i and j
								end if; 		
								State<= CV_write_2; 
							elsif count_CacheJ_CU <Count_ClassJ then
							count_CacheJ_CU<=count_CacheJ_CU+1; -- check 3ala count ba3d condition el termination
							State<= Get_max;  --- momken ahtaha fe else 
							end if; 
					--------------------------------------------------------------------------------
					when CV_write_2=>
						flag_newIJ<='0'; --- e2felaha fel accum --- start writing in CV memory both points i and j
						Read_enable_C2<='0';
						reg_reset_class2_Address <='1';
							if Flag_2nd_norm='1' or flag_2nd_iteration='1' then  -- 2nd-iteration-- de le awel mara ba3d el repeated point  
								Flag_2nd_norm<='0'; --- first run indicate 
								flag_2nd_iteration<='0';
								flag_newIJ<='0';
								reset_count_kernel<='1';  --- reset el count for netx kernels cycles , close fo2
								state <=  norm_lamda_start;
							else 
				
								Read_enable_Cache1<='0';
								write_enable_Cache1<='0';
								reg_enable_cache1<='0';
								reg_reset_cache1<='1' ;--- get ready for cache acc
								MuxAddress_selc1<='0';--to pass the inc. address of cache 
  	
								reg_reset_cachAcc_Avg1<='1';
								reg_enable_cachAcc_Avg1<='0';
								write_enable_cachAcc_Avg1<='0';
								read_enable_cachAcc_Avg1<='0';
		
								state <= Acc_cache1;
							end if;
						--------------------------------------------------------------
			when  Acc_cache1=>
				count_CacheI_CU<=(others=>'0');
		 		reg_reset_cachAcc_Avg1<='0';
				reg_reset_cache1<='0';
					if acc_first_time1='0' then  -- awel maraaa khalees -- khaleha be 0 kaman lama el cv tegelha point repeated 
						MuxDataIN_SeclAcc_Avg1<="00";

						Read_enable_Cache1<='1';
						write_enable_Cache1<='0';
						reg_enable_cache1<='1';
						MuxAddress_selc1<='0';

						read_enable_cachAcc_Avg1<='0';
						write_enable_cachAcc_Avg1<='1';
						reg_enable_cachAcc_Avg1<='1';

						if count_CacheI_CU = Count_ClassI then
							count_CacheI_CU<=(others=>'0');
							acc_first_time1<='1'; 
 
							Read_enable_Cache1<='0';
							write_enable_Cache1<='0';
							reg_enable_cache1<='0';
							reg_reset_cache1<='1'; 
							MuxAddress_selc1<='0';


							----this is the default values for cache Acc 1	
							read_enable_cachAcc_Avg1<='0';
							write_enable_cachAcc_Avg1<='0';
							reg_enable_cachAcc_Avg1<='0';
							reg_reset_cachAcc_Avg1<='1';
 
	
							Read_enable_Cache2<='0';
							write_enable_Cache2<='0';
							reg_enable_cache2<='0';
							reg_reset_cache2<='1'; 
							MuxAddress_selc2<='0';


							----this is the default values for cache Acc 2
							read_enable_cachAcc_Avg2<='0';
							write_enable_cachAcc_Avg2<='0';
							reg_enable_cachAcc_Avg2<='0';
							reg_reset_cachAcc_Avg2<='1';
						
							state<= Acc_cache2;

						else
							count_CacheI_CU <=count_CacheI_CU+1;
							state<=Acc_cache1;
						end if;
			
					else
						state<= read_acc1;
					end if; 
			
			
			when read_acc1 =>
					MuxDataIN_SeclAcc_Avg1<="01";--choose to pass values read from cache Acc

					Read_enable_Cache1<='1';	
					write_enable_Cache1<='0';
					reg_enable_cache1<='0';
					reg_reset_cache1<='0';
 					MuxAddress_selc1<='0';

					read_enable_cachAcc_Avg1<='1';
					write_enable_cachAcc_Avg1<='0'; 
					reg_reset_cachAcc_Avg1<='0';
					reg_enable_cachAcc_Avg1<='0'; 

					if count_CacheI_CU=Count_ClassI then
						count_CacheI_CU<=(others=>'0');

						acc_first_time1<='1'; 

						Read_enable_Cache1<='0';
						write_enable_Cache1<='0';
						reg_enable_cache1<='0';
						reg_reset_cache1<='1'; 
						MuxAddress_selc1<='0';

						----this is the default values for cache Acc 1	
						read_enable_cachAcc_Avg1<='0';
						write_enable_cachAcc_Avg1<='0';
						reg_enable_cachAcc_Avg1<='0';
						reg_reset_cachAcc_Avg1<='1';  
 

						Read_enable_Cache2<='0';
						write_enable_Cache2<='0';
						reg_enable_cache2<='0';
						reg_reset_cache2<='1';
						MuxAddress_selc2<='0';


						----this is the default values for cache Acc 2	
						read_enable_cachAcc_Avg2<='0';
						write_enable_cachAcc_Avg2<='0';
						reg_enable_cachAcc_Avg2<='0';
						reg_reset_cachAcc_Avg2<='1';
						
						state<= Acc_cache2;
					else
						state<= write_acc1;
					end if;
	
			when write_acc1=> 
					MuxDataIN_SeclAcc_Avg1<="01";--choose to pass values read from cache Acc 

					Read_enable_Cache1<='0';	
					write_enable_Cache1<='0';
					reg_enable_cache1<='1';
					reg_reset_cache1<='0';
					MuxAddress_selc1<='0';

					read_enable_cachAcc_Avg1<='0';
					write_enable_cachAcc_Avg1<='1';
					reg_enable_cachAcc_Avg1<='1';
					reg_reset_cachAcc_Avg1<='0';

					count_CacheI_CU <=count_CacheI_CU+1;
					state<= read_acc1;

					
		when Acc_cache2=>
			reg_reset_cachAcc_Avg2<='0';
			reg_reset_cache2<='0';

				if acc_first_time2='0' then
					MuxDataIN_SeclAcc_Avg2<="00";--to pass the values from cache 2 to cache Acc direct

					Read_enable_Cache2<='1';	
					write_enable_Cache2<='0';
					reg_enable_cache2<='1';	
					reg_reset_cache2<='0';	
					MuxAddress_selc2<='0';--pass the increased address	
		
					read_enable_cachAcc_Avg2<='0';
					write_enable_cachAcc_Avg2<='1';
					reg_enable_cachAcc_Avg2<='1';
					reg_reset_cachAcc_Avg2<='0';


					if count_CacheJ_CU=Count_ClassJ  then
						count_CacheJ_CU<=(others=>'0');
						acc_first_time2<='1'; --- e2feley awel ketaba
	
						write_enable_Cache2<='0';
						Read_enable_Cache2<='0';
						reg_reset_cache2<='1';
						reg_enable_cache2<='0';

						----this is the default values for cache Acc 2	
						read_enable_cachAcc_Avg2<='0';
						write_enable_cachAcc_Avg2<='0';
						reg_enable_cachAcc_Avg2<='0';
						reg_reset_cachAcc_Avg2<='1';

						--reset alpha not sure en de sa7
						average_enable_1<='0'; --make sure that they need both i and J at the same time
						read_enable_AlphaBeta_AvrgI<='0';
						copyTobackUp_enable_I<='0';
						read_enable_BackUp_I<='0';
						reset_AlphaBetaI<='0';
						alpha_beta_wake_up_I<='0';

				 
						 if PointRepeated='1' then  
							average_enable_1<='1'; --make sure that they need both i and J at the same time
									
							read_enable_AlphaBeta_AvrgI<='0';
							copyTobackUp_enable_I<='0';
							read_enable_BackUp_I<='0';
							reset_AlphaBetaI<='0';
							alpha_beta_wake_up_I<='0';

							state<= delay_for_alpha_avg;
					
						else
							flag_newIJ<='1';  --- open early , as it gets registered
							state<= CV_Write_final ;
							 
						end if;
					
					else
						count_CacheJ_CU <=count_CacheJ_CU+1;

						state<=Acc_cache2;
					end if;
			
				else
					state<= read_acc2;
				end if; 

		when CV_Write_final=>
			------- close CV write flag, write will be done here 
				flag_newIJ<='0';
				state<= norm_lamda_start;--de mafrod tt3ml 

	 	when read_acc2 =>

			MuxDataIN_SeclAcc_Avg2<="01";--pass the values from cache Acc back to cache Acc

			Read_enable_Cache2<='1';
			write_enable_Cache2<='0';
			reg_enable_cache2<='0';
			reg_reset_cache2<='0';
			MuxAddress_selc2<='0';--pass the increased address	
		

			read_enable_cachAcc_Avg2<='1';
			write_enable_cachAcc_Avg2<='0'; 
			reg_reset_cachAcc_Avg2<='0';
			reg_enable_cachAcc_Avg2<='0';
		

			if count_CacheJ_CU=Count_ClassJ then
					count_CacheJ_CU<=(others=>'0');

					write_enable_Cache2<='0';
					Read_enable_Cache2<='0';
					reg_enable_cache2<='0';
					reg_reset_cache2<='1';

	
					read_enable_cachAcc_Avg2<='0';
					write_enable_cachAcc_Avg2<='0';
					reg_enable_cachAcc_Avg2<='0';
					reg_reset_cachAcc_Avg2<='1';

				 
					if PointRepeated='1' then  --- fe terminatiing condition reset hagat mo3yana 3ashan el lafa el gya
						
						flag_2nd_iteration<='1'; -- set to 1 for 1st, 2nd iteration 
						
						average_enable_1<='1'; --make sure that they need both i and J at the same time
									-- when to close this sig sim
						read_enable_AlphaBeta_AvrgI<='0';
						copyTobackUp_enable_I<='0';
						read_enable_BackUp_I<='0';
						reset_AlphaBetaI<='0';
						alpha_beta_wake_up_I<='0';

						state<= delay_for_alpha_avg;
					
					else
						flag_newIJ<='1';  --- open early , as it gets registered
						state<= CV_Write_final ;--de mafrod tt3ml 
					
					end if;
			else
				state<= write_acc2;
			end if;
	
		when write_acc2=>
			Read_enable_Cache2<='0';
			write_enable_Cache2<='0';
			reg_enable_cache2<='1';
			reg_reset_cache2<='0';
			MuxAddress_selc2<='0';--pass the increased address	
		

			read_enable_cachAcc_Avg2<='0';
			write_enable_cachAcc_Avg2<='1';
			reg_enable_cachAcc_Avg2<='1'; 
			reg_reset_cachAcc_Avg2<='0';
			MuxDataIN_SeclAcc_Avg2<="01";

			average_enable_1<='0'; 
									
			read_enable_AlphaBeta_AvrgI<='0';
			copyTobackUp_enable_I<='0';
			read_enable_BackUp_I<='0';
			reset_AlphaBetaI<='0';
			alpha_beta_wake_up_I<='0';

			count_CacheJ_CU <=count_CacheJ_CU+1;
			state<= read_acc2;

		when delay_for_alpha_avg=>
			average_enable_1<='1'; --make sure that they need both i and J at the same time
			read_enable_AlphaBeta_AvrgI<='0';
			copyTobackUp_enable_I<='0';
			read_enable_BackUp_I<='0';
			reset_AlphaBetaI<='0';
			alpha_beta_wake_up_I<='0';

			------get ready for  avg 1 in case PointRepeated='1'-----
			read_enable_cachAcc_Avg1<='0';
			write_enable_cachAcc_Avg1<='0';
			reg_enable_cachAcc_Avg1<='0';
			reg_reset_cachAcc_Avg1<='1';
			
			MuxDataIN_SeclAcc_Avg1<="10";-- to pass the avg value and save it in the acc avg cache

			state<=Read_cacheAcc_Avg1;

						
		when Read_cacheAcc_Avg1 => 
			average_enable_1<='1'; 
			read_enable_AlphaBeta_AvrgI<='0';
			copyTobackUp_enable_I<='0';
			read_enable_BackUp_I<='0';
			reset_AlphaBetaI<='0';
			alpha_beta_wake_up_I<='0';

			read_enable_cachAcc_Avg1<='1'; --read from cache acc1 in state then go to the next state to write
			write_enable_cachAcc_Avg1<='0';
			reg_enable_cachAcc_Avg1<='0';
			reg_reset_cachAcc_Avg1<='0';

			MuxDataIN_SeclAcc_Avg1<="10";--to pass the avg value and save it in the Acc avg cache

			----resting signals of beta for getting the avg this is not important
			average_enable_2<='0'; 
			read_enable_AlphaBeta_AvrgJ<='0';
			copyTobackUp_enable_J<='0';
			read_enable_BackUp_J<='0';
			reset_alphaBetaJ<='0';
			alpha_beta_wake_up_J<='0';

			if count_CacheI_CU =Count_ClassI then
				count_CacheI_CU<=(others=>'0');

				average_enable_1<='0'; 
				read_enable_AlphaBeta_AvrgI<='0';
				copyTobackUp_enable_I<='0';
				read_enable_BackUp_I<='0';
				reset_AlphaBetaI<='0'; --reset alpha
				alpha_beta_wake_up_I<='0';

				------resting avg 1 and acc 1-----------------
				read_enable_cachAcc_Avg1<='0'; 
				write_enable_cachAcc_Avg1<='0';
				reg_enable_cachAcc_Avg1<='0';
				reg_reset_cachAcc_Avg1<='1';


				average_enable_2<='1'; --avg of beta
				read_enable_AlphaBeta_AvrgJ<='0';
				copyTobackUp_enable_J<='0';
				read_enable_BackUp_J<='0';
				reset_AlphaBetaJ<='0';
				alpha_beta_wake_up_J<='0';

				state<=delay_for_beta_avg ;

			else
				state<=Write_cacheAcc_Avg1;
			end if;


		when Write_cacheAcc_Avg1=>
			read_enable_cachAcc_Avg1<='0'; 
			write_enable_cachAcc_Avg1<='1';
			reg_enable_cachAcc_Avg1<='1';
			reg_reset_cachAcc_Avg1<='0';
			count_CacheI_CU<=count_CacheI_CU+1;
			state<=Read_cacheAcc_Avg1;


		when delay_for_beta_avg=>
				average_enable_2<='1'; --avg of beta
				read_enable_AlphaBeta_AvrgJ<='0';
				copyTobackUp_enable_J<='0';
				read_enable_BackUp_J<='0';
				reset_AlphaBetaJ<='0';
				alpha_beta_wake_up_J<='0';

				--------preparing avg2 and acc2------------------
				read_enable_cachAcc_Avg2<='0';
				write_enable_cachAcc_Avg2<='0';
				reg_enable_cachAcc_Avg2<='0';
				reg_reset_cachAcc_Avg2<='1';

				MuxDataIN_SeclAcc_Avg2<="10";--to pass the avg value and save it in the Acc avg cache


			state<=Read_cacheAcc_Avg2;	

		when Read_cacheAcc_Avg2 =>
			
			average_enable_2<='1'; --avg of beta
			read_enable_AlphaBeta_AvrgJ<='0';
			copyTobackUp_enable_J<='0';
			read_enable_BackUp_J<='0';
			reset_AlphaBetaJ<='0';
			alpha_beta_wake_up_J<='0';

				--since it's two clk delayed just resting all signals
				read_enable_AlphaBeta_AvrgI<='0';
				average_enable_1<='0';
				copyTobackUp_enable_I<='0';
				read_enable_BackUp_I<='0';
				reset_AlphaBetaI<='0';
				alpha_beta_wake_up_I<='0';

			read_enable_cachAcc_Avg2<='1';
			write_enable_cachAcc_Avg2<='0';
			reg_enable_cachAcc_Avg2<='1';
			reg_reset_cachAcc_Avg2<='0';

			MuxDataIN_SeclAcc_Avg2<="10";--to pass the avg value and save it in the Acc avg cache


			if count_CacheJ_CU =Count_ClassJ then
				count_CacheI_CU<=(others=>'0');
				count_CacheJ_CU<=(others=>'0');

				average_enable_2<='0'; 
				read_enable_AlphaBeta_AvrgJ<='0';
				copyTobackUp_enable_J<='0';
				read_enable_BackUp_J<='0';
				reset_AlphaBetaJ<='0';
				alpha_beta_wake_up_J<='0';

				read_enable_cachAcc_Avg2<='0';
				write_enable_cachAcc_Avg2<='0';
				reg_enable_cachAcc_Avg2<='0';
				reg_reset_cachAcc_Avg2<='1';
			
				state<=prepare_for_NormAvg;
			
			else
				state<=Write_cacheAcc_Avg2;
			end if;

		when Write_cacheAcc_Avg2=>
			read_enable_cachAcc_Avg2<='0';
			write_enable_cachAcc_Avg2<='1';
			reg_enable_cachAcc_Avg2<='1';
			reg_reset_cachAcc_Avg2<='0';
			count_CacheJ_CU<=count_CacheJ_CU+1;
			state<=Read_cacheAcc_Avg2;

		
		when prepare_for_NormAvg =>--this state must not be deleted as it's used to synchronize alpha with av cache
			reset_CV_counters_after_avrg<='1';  --- reset point repeated and counter in cv 
			---------------------------------------
			average_enable_1<='0';
			read_enable_AlphaBeta_AvrgI<='1';
			copyTobackUp_enable_I<='0';
			read_enable_BackUp_I<='0';
			reset_AlphaBetaI<='0';
			alpha_beta_wake_up_I<='0';
			
			----------avgNrom1--------------
			read_enable_cachAcc_Avg1<='0';
			write_enable_cachAcc_Avg1 <='0';
			reg_enable_cachAcc_Avg1 <='0';
			reg_reset_cachAcc_Avg1 <='1';--rest the address b4 reading

			Reg_reset_AvgNorm<='1'; -- hya de kant zero  bs msh moktan3a sara7a hya lazem 1
			Reg_Enable_AvgNorm<='0'; 

			Reset_fifo_AvgNorm<='0';
			Reg_reset_Queu_AvgNorm<='0';
			

			state<=start_AvrgNorm1;	

			---------average norm --------
		when start_AvrgNorm1=>
			Mux_Select_Avg1_or_Avg2<='0';
			Mux_Select_alpha_NormAvg<="00";--to pass i new

			Reg_reset_AvgNorm<='0';
			Reg_Enable_AvgNorm<='1'; -- for acc then addition e2efleh ba3d cache avrg 2 lama yekhalas  
			--- eftahy read memory alpha beta new

			read_enable_cachAcc_Avg1 <='1';
			write_enable_cachAcc_Avg1 <='0';
			reg_enable_cachAcc_Avg1 <='1';
			reg_reset_cachAcc_Avg1 <='0';

			average_enable_1<='0';
			read_enable_AlphaBeta_AvrgI<='1';
			copyTobackUp_enable_I<='0';
			read_enable_BackUp_I<='0';
			reset_AlphaBetaI<='0';
			alpha_beta_wake_up_I<='0';

			average_enable_2<='0'; 
			read_enable_AlphaBeta_AvrgJ<='0';
			copyTobackUp_enable_J<='0';
			read_enable_BackUp_J<='0';
			reset_AlphaBetaJ<='0';--since it's two clk delayed, this was already set to zero but to void latch
			alpha_beta_wake_up_J<='0';
				if count_CacheI_CU =Count_ClassI then  --- terminating 
	
					read_enable_cachAcc_Avg1 <='0';
					write_enable_cachAcc_Avg1 <='0';
					reg_enable_cachAcc_Avg1 <='0';
					reg_reset_cachAcc_Avg1 <='1';

					average_enable_1<='0';
					read_enable_AlphaBeta_AvrgI<='0';
					copyTobackUp_enable_I<='0';
					read_enable_BackUp_I<='0';
					reset_AlphaBetaI<='0';
					alpha_beta_wake_up_I<='0';

					Reg_Enable_AvgNorm<='0';--to keep the value for the next acc of beta anc cache avg2
					Reg_reset_AvgNorm<='0';

					reset_AlphaBetaJ<='0';
					read_enable_AlphaBeta_AvrgJ<='1';  ---- since it's deyaled by two clk
					average_enable_2<='0';
					copyTobackUp_enable_J<='0';
					read_enable_BackUp_J<='0';
					alpha_beta_wake_up_J<='0';

					state<=prepare_NormAvg2_reset_NormAvg1;
				
				else
					count_CacheI_CU<=count_CacheI_CU+1;
					state<=start_AvrgNorm1 ;
				end if;

		when prepare_NormAvg2_reset_NormAvg1=>--this state must not be deleted as it's used to synchronize alpha with av cache
				-----------------rest all signals for avg1 and alpha mem-------------
				count_CacheI_CU<=(others=>'0');
				------------prepare avg 2 and beta mem--------------------------
				 count_CacheJ_CU<=(others=>'0');

				reg_reset_cachAcc_Avg2<='1';
				reg_enable_cachAcc_Avg2<='0';
				read_enable_cachAcc_Avg2<='0';
				write_enable_cachAcc_Avg2<='0';

				read_enable_AlphaBeta_AvrgJ<='1';--to avoid latch
				average_enable_2<='0';
				copyTobackUp_enable_J<='0';
				read_enable_BackUp_J<='0';
				reset_AlphaBetaJ<='0';
				alpha_beta_wake_up_J<='0';
	
				Reg_Enable_AvgNorm<='0';--to keep the value for the next acc of beta anc cache avg2
				Reg_reset_AvgNorm<='0';

				state<=start_AvrgNorm2;  --- start norm avrg2
			
		when start_AvrgNorm2 =>
			Mux_Select_Avg1_or_Avg2<='1';
			Mux_Select_alpha_NormAvg<="01";--to pass i new
			
			reg_reset_cachAcc_Avg2<='0';
			reg_enable_cachAcc_Avg2<='1';
			read_enable_cachAcc_Avg2<='1';
			write_enable_cachAcc_Avg2<='0';

			read_enable_AlphaBeta_AvrgJ<='1';--to avoid latch
			average_enable_2<='0';
			copyTobackUp_enable_J<='0';
			read_enable_BackUp_J<='0';
			reset_AlphaBetaJ<='0';
			alpha_beta_wake_up_J<='0';

			Reg_Enable_AvgNorm<='1';
			Reg_reset_AvgNorm<='0';

			if count_CacheJ_CU =Count_ClassJ  then --- khalas norm avrg2 
				Reg_Enable_AvgNorm<='0';
				Reg_reset_AvgNorm<='0';

				count_CacheJ_CU<=(others=>'0');
				reg_reset_cachAcc_Avg2<='1';
				reg_enable_cachAcc_Avg2<='0';
				read_enable_cachAcc_Avg2<='0';

				average_enable_1<='0';
				read_enable_AlphaBeta_AvrgI<='0';
				copyTobackUp_enable_I<='0';
				read_enable_BackUp_I<='0';
				reset_AlphaBetaI<='0';
				alpha_beta_wake_up_I<='0';

				read_enable_AlphaBeta_AvrgJ<='0';--to avoid latch
				average_enable_2<='0';
				copyTobackUp_enable_J<='0';
				read_enable_BackUp_J<='0';
				reset_AlphaBetaJ<='0';
				alpha_beta_wake_up_J<='0';

				state<=Queue_Avrg_Norm ;
				
				
			else
				count_CacheJ_CU<=count_CacheJ_CU+1;
				state<=start_AvrgNorm2 ;
			end if;
---------------------------------------------------------------------------------------------------------

			when Queue_Avrg_Norm =>
				----- 3ayzen awel marten yedkhol khales yekon bykteb be mux 0 
					if flag_1stAvrgCalc='1' then  --- first time to write 
						flag_1stAvrgCalc<='0';

						average_enable_1<='0';
						copyTobackUp_enable_I<='0';
						read_enable_AlphaBeta_AvrgI<='0';
						read_enable_BackUp_I<='0';
						reset_AlphaBetaI<='0';
						alpha_beta_wake_up_I<='0';

						average_enable_2<='0';
						copyTobackUp_enable_J<='0';
						read_enable_AlphaBeta_AvrgJ<='0';
						read_enable_BackUp_J<='0';
						reset_AlphaBetaJ<='0';
						alpha_beta_wake_up_J<='0';

						Mux_Select_AvgNorm_Que_in<='0'; --to pass value from adder Reg
						WriteEnable_fifo_AvgNorm<='1'; --don't forget to close in off state
						ReadEnable_fifo_AvgNorm<='0';


					else
						Mux_Select_AvgNorm_Que_in<='0'; --to pass value from adder Reg
						WriteEnable_fifo_AvgNorm<='1'; --don't forget to close in off state
						ReadEnable_fifo_AvgNorm<='0';
					end if;
					-------- we ba3d el marten dol yekon bykteb mara mux 0 we mara  ,mux 1
					
					if first_avg_done='0' then
						state<=copying_to_backup;
					else
						state<=off_write; 
					end if;
				
					


			--copy to back first time avg
			when copying_to_backup=>--might need First_run to be zero 
				
	
				WriteEnable_fifo_AvgNorm<='0';
				ReadEnable_fifo_AvgNorm<='0';

				average_enable_1<='0';
				read_enable_AlphaBeta_AvrgI<='0';
				read_enable_BackUp_I<='0';
				reset_AlphaBetaI<='0';
				alpha_beta_wake_up_I<='0';

				average_enable_2<='0';
				read_enable_AlphaBeta_AvrgJ<='0';
				read_enable_BackUp_J<='0';
				reset_AlphaBetaJ<='0';
				alpha_beta_wake_up_J<='0';

				if count_CacheI_CU=Count_ClassI+2 then
					copyTobackUp_enable_I<='0';
				else 
					copyTobackUp_enable_I<='1';
					count_CacheI_CU<=count_CacheI_CU+1;
				end if;
		
				if count_CacheJ_CU=Count_ClassJ+2 then
					copyTobackUp_enable_J<='0';
					count_CacheI_CU<=(others=>'0');
					count_CacheJ_CU<=(others=>'0');

					if first_avg_done='0' then
						first_avg_done<='1';
						state<=off_write; 
					else
						reg_reset_cache2<='1';
						reg_enable_cache2<='0';	
						
						reg_reset_cache1<='1';
						reg_enable_cache1<='0';

						reg_resetMax<='1';
						reg_resetMin<='1';   --- reset last min value 
						
						reg_enableMax<='0';
						reg_enableMin<='0';   --- reset last min value 

						acc_first_time1<='0';--to acc first time in next iteration
						acc_first_time2<='0';
						state<=Get_min;
					end if;
						
				else 
					copyTobackUp_enable_J<='1';
					count_CacheJ_CU<=count_CacheJ_CU+1;
					state<=copying_to_backup; 
				end if;

				

			

			when off_write=>
				----rest all alpha beta enabls
				average_enable_1<='0';
				copyTobackUp_enable_I<='0';
				read_enable_AlphaBeta_AvrgI<='0';
				read_enable_BackUp_I<='0';
				reset_AlphaBetaI<='0';
				alpha_beta_wake_up_I<='0';

				average_enable_2<='0';
				copyTobackUp_enable_J<='0';
				read_enable_AlphaBeta_AvrgJ<='0';
				read_enable_BackUp_J<='0';
				reset_AlphaBetaJ<='0';
				alpha_beta_wake_up_J<='0';

				---------prepare the classes signal 
				reg_reset_class1_Address <='1';
				reg_enable_class1_Address<='0';

				reg_reset_class2_Address <='1';
				reg_enable_class2_Address<='0';


				WriteEnable_fifo_AvgNorm<='0';
				ReadEnable_fifo_AvgNorm<='0';
				
				state<=off_write_2;
	
			when off_write_2=>

				if FifoFull_fifo='1' then
					state <=Read_NormAvg_from_queue;
				else 
					reg_reset_cache2<='1';
					reg_enable_cache2<='0';	
						
					reg_reset_cache1<='1';
					reg_enable_cache1<='0';

					reg_resetMax<='1';
					reg_resetMin<='1';   --- reset last min value 
						
					reg_enableMax<='0';
					reg_enableMin<='0'; 

					acc_first_time1<='0';--to acc first time in next iteration
					acc_first_time2<='0';
					
					
					reset_AlphaBetaI<='1';--reset alpha to acc first time in next iteration
					reset_AlphaBetaJ<='1';

					Reset_square<='1';--reset square root for next iteration

					state <=Get_min ;  ---- check low akhleh akeno awel mara fel norm 3ashan ana hamsah el CV
				end if;

			when Read_NormAvg_from_queue=>
			 	----- open read for two cycles and wait for coserror signal 	
				if FifoEmpty_fifo='1' and flag_1stReadAvrgCalc="10"then --take care that this flag is two bits

					flag_1stReadAvrgCalc<="01";
					--write the FB into the queue and go to satet read alphabetabackup
					Reg_Enable_Queu_AvgNorm<='0';--pass the first Normavg written in queue
					Reg_reset_Queu_AvgNorm<='0';
					Mux_Select_AvgNorm_Que_in<='1';
					WriteEnable_fifo_AvgNorm<='1';
					ReadEnable_fifo_AvgNorm<='0';	

					--open read enable since there is a delay 1 clk  same for beta
					average_enable_1<='0';
					copyTobackUp_enable_I<='0';
					read_enable_AlphaBeta_AvrgI<='0';
					read_enable_BackUp_I<='1';
					reset_AlphaBetaI<='0';
					alpha_beta_wake_up_I<='0';
			
					average_enable_2<='0';
					copyTobackUp_enable_J<='0';
					read_enable_AlphaBeta_AvrgJ<='0';
					read_enable_BackUp_J<='0';
					reset_AlphaBetaJ<='0';
					alpha_beta_wake_up_J<='0';
					
					--reset the cache avg 1 tp be ready for next state
					reg_reset_cachAcc_Avg1<='1';
					reg_enable_cachAcc_Avg1<='0';
					read_enable_cachAcc_Avg1<='0';
					write_enable_cachAcc_Avg1<='0';

					--prepare the signals for GetMin blocks
					reg_reset_Min_b<='1';
					reg_enable_Min_b<='0';

					Reg_reset_AvgNorm<='1';
					Reg_Enable_AvgNorm<='0';
				
					flag_1stReadAvrgCalc<="01" ;--- add default value of signal, for next run (added new mirna)

					state<= delay_for_alphabeta_I_sig;
				
				elsif (flag_1stReadAvrgCalc="01" and FifoEmpty_fifo='0' )then	
					ReadEnable_fifo_AvgNorm<='1';
					WriteEnable_fifo_AvgNorm<='0';
					Reg_Enable_Queu_AvgNorm<='1';--pass the first Normavg written in queue
					Reg_reset_Queu_AvgNorm<='0';
					flag_1stReadAvrgCalc<="00";

					state<=Read_NormAvg_from_queue; --- to finish two reading 

				elsif (flag_1stReadAvrgCalc="00" and FifoEmpty_fifo='0' )then
					flag_1stReadAvrgCalc<="10";
					ReadEnable_fifo_AvgNorm<='1';
					WriteEnable_fifo_AvgNorm<='0';
					Reg_Enable_Queu_AvgNorm<='0';
					Reg_reset_Queu_AvgNorm<='0';

					average_enable_1<='0';

					copyTobackUp_enable_I<='0';
					read_enable_AlphaBeta_AvrgI<='0';
					read_enable_BackUp_I<='0';
					reset_AlphaBetaI<='0';
					alpha_beta_wake_up_I<='0';

					average_enable_2<='0';
					copyTobackUp_enable_J<='0';
					read_enable_AlphaBeta_AvrgJ<='0';
					read_enable_BackUp_J<='0';
					reset_AlphaBetaJ<='0';
					alpha_beta_wake_up_J<='0';
	
					Reset_square<='0';

					state<=Read_NormAvg_from_queue; --- to finish two reading 
				else 
					ReadEnable_fifo_AvgNorm<='0';
					WriteEnable_fifo_AvgNorm<='0';
					state<=Read_NormAvg_from_queue;--delay for the queue empty to be '0'					
				end if;
			when delay_for_alphabeta_I_sig=>
					WriteEnable_fifo_AvgNorm<='0';  ---- added new mirna 
					ReadEnable_fifo_AvgNorm<='0';
					average_enable_1<='0';
					copyTobackUp_enable_I<='0';
					read_enable_AlphaBeta_AvrgI<='0';
					read_enable_BackUp_I<='1';
					reset_AlphaBetaI<='0';
					alpha_beta_wake_up_I<='0';
				state<= cacheAvg_Multi_Backup_1;
				
--------------------------------------------------------------------------------------------------------------------
			when cacheAvg_Multi_Backup_1 =>
				WriteEnable_fifo_AvgNorm<='0';
				ReadEnable_fifo_AvgNorm<='0';
	
				Mux_Select_Avg1_or_Avg2<='0';
				Mux_Select_alpha_NormAvg<="10";--to pass i backup 
				--- eftahy read memory alpha beta new

				reg_reset_cachAcc_Avg1<='0';
				reg_enable_cachAcc_Avg1<='1';
				read_enable_cachAcc_Avg1<='1';
				write_enable_cachAcc_Avg1<='0';

				--prepare the signals for GetMin Block
				reg_reset_Min_b<='0';
				reg_enable_Min_b<='1';

				Reg_reset_AvgNorm<='0';
				Reg_Enable_AvgNorm<='1';
			
				--must set "not used" enable in alphabeta just in case 
				average_enable_1<='0';
				copyTobackUp_enable_I<='0';
				read_enable_BackUp_I<='1';  ---- read memory alpha backup
				read_enable_AlphaBeta_AvrgI<='0';
				reset_AlphaBetaI<='0';
				alpha_beta_wake_up_I<='0';
				
			 
				if count_CacheI_CU=Count_ClassI  then  --- terminating 
					count_CacheI_CU<=(others=>'0');
					read_enable_cachAcc_Avg1<='0';
					write_enable_cachAcc_Avg1<='0';
					reg_enable_cachAcc_Avg1<='0';
					reg_reset_cachAcc_Avg1<='1';


					reg_enable_Min_b<='0';--have the mini value
					reg_reset_Min_b<='0';

					Reg_reset_AvgNorm<='0';
					Reg_Enable_AvgNorm<='0';

					
					average_enable_1<='0';
					copyTobackUp_enable_I<='0';
					read_enable_BackUp_I<='0';  ---- read memory alpha backup
					read_enable_AlphaBeta_AvrgI<='0';
					reset_AlphaBetaI<='0';
					alpha_beta_wake_up_I<='0';
				
					--prepare beta signal 

					average_enable_2<='0';
					copyTobackUp_enable_J<='0';
					read_enable_BackUp_J<='1';  ---- read memory Beta
					read_enable_AlphaBeta_AvrgJ<='0';
					reset_AlphaBetaJ<='0';
					alpha_beta_wake_up_J<='0';
					state<=delay_for_alphabeta_J_sig;
				
				else
					count_CacheI_CU<=count_CacheI_CU+1;
					state<=cacheAvg_Multi_Backup_1 ;
				end if;
			
		when delay_for_alphabeta_J_sig=>

					average_enable_2<='0';
					copyTobackUp_enable_J<='0';
					read_enable_BackUp_J<='1';  ---- read memory Beta
					read_enable_AlphaBeta_AvrgJ<='0';
					reset_AlphaBetaJ<='0';
					alpha_beta_wake_up_J<='0';

					--prepare the signals of cache avg 2 reset the address
					read_enable_cachAcc_Avg2<='0';
					write_enable_cachAcc_Avg2<='0';
					reg_enable_cachAcc_Avg2<='0';
					reg_reset_cachAcc_Avg2<='1';

					--prepare the signals for GetMax 
					reg_reset_Max_b<='1';--rest the "GetMax" to make sure that we get the right vaue during the programme
					reg_enable_Max_b<='0';

					Reg_reset_AvgNorm<='0';
					Reg_Enable_AvgNorm<='0';

				state<= cacheAvg_Multi_Backup_2;
				
		when cacheAvg_Multi_Backup_2 =>
			Mux_Select_Avg1_or_Avg2<='1';
			Mux_Select_alpha_NormAvg<="11";--to pass i new
			Reg_Enable_AvgNorm<='1'; -- for acc then addition e2efleh ba3d cache avrg 2 lama yekhalas
			Reg_reset_AvgNorm<='0';  
			--- eftahy read memory alpha beta new


			read_enable_cachAcc_Avg2<='1';
			write_enable_cachAcc_Avg2<='0';
			reg_enable_cachAcc_Avg2<='1';
			reg_reset_cachAcc_Avg2<='0';

			reg_reset_Max_b<='0';
			reg_enable_Max_b<='1';

			Reg_reset_AvgNorm<='0';
			Reg_Enable_AvgNorm<='1';


			average_enable_2<='0';
			copyTobackUp_enable_J<='0';
			read_enable_BackUp_J<='1';  ---- read memory Beta
			read_enable_AlphaBeta_AvrgJ<='0';
			reset_AlphaBetaJ<='0';
			alpha_beta_wake_up_J<='0';

			if count_CacheJ_CU = Count_ClassJ  then
				 count_CacheJ_CU<=(others=>'0');

				read_enable_cachAcc_Avg2<='0';
				write_enable_cachAcc_Avg2<='0';
				reg_enable_cachAcc_Avg2<='0';
				reg_reset_cachAcc_Avg2<='1';

				reg_enable_Max_b<='0';--have the max value
				reg_enable_Max_b<='0';

				Reg_reset_AvgNorm<='0';
				Reg_Enable_AvgNorm<='0';


				average_enable_2<='0';
				copyTobackUp_enable_J<='0';
				read_enable_BackUp_J<='0';  ---- read memory Beta
				read_enable_AlphaBeta_AvrgJ<='0';
				reset_AlphaBetaJ<='1';
				alpha_beta_wake_up_J<='0';


				if   Last_Termination_condition="01"  then   ---- if condition not true nothing will happen as the code will continue with the same flow
					state<=last_termination ;
				else 
					state<=copying_to_backup;

				end if;


			else
				count_CacheJ_CU<=count_CacheJ_CU+1;
				state<=cacheAvg_Multi_Backup_2 ;
			end if;


		when last_termination=>
				-- out b automatically from caches to integration 
				--read mem w must open read alpha beta 
				--set internal rest
				reset_internal<='1'; --- signal to reset internal trial
				state<=ideal_1;

------------------------------------------------------------------------------------------------------		
		
	END CASE; 
    END IF; 
  END PROCESS;

end controlUnit_arch ;

