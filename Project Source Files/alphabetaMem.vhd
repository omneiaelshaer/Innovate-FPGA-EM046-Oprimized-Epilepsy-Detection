Library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


--check max values from matlab max (range 16)
--bits from accu to avg please keep it (4,12) from avg mem and backup mem
Entity alphabetaMem is
Generic (Addr_Width    : integer := 10;
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
	copyTobackUp_enable: in std_logic;--to start copying the bcackup mem to cacl cosserror
	--read_enable_address_new: in std_logic;
	read_enable_norm_avg: in std_logic; --1 start rading from avg mem o calculate norm avgc control uint  control this signal
	read_enable_BackUp: in std_logic;
	alpha_beta_wake_up: in std_logic;--from CU to indicate start using for alphabeta then set to zero as rest
	First_Run: in std_logic; --signal from CU to set first values in the alphabeta mem 
	Out_alphabeta_average: out std_logic_vector(Data_Width-1 downto 0);
	OutBackUp: out std_logic_vector(Data_Width-1 downto 0)
	

	
);
end entity alphabetaMem;

architecture arch_alphabeta_Mem of alphabetaMem is

--------------------COMPONENTS INST:-------------------
Component Mem_16x900 IS
	PORT
	(
		clock		: IN STD_LOGIC  := '1';
		wren		: IN STD_LOGIC ;
		rden		: IN STD_LOGIC  := '1';
		address		: IN STD_LOGIC_VECTOR (9 DOWNTO 0);
		data		: IN STD_LOGIC_VECTOR (15 DOWNTO 0);
		q		: OUT STD_LOGIC_VECTOR (15 DOWNTO 0)
	);
END Component;


component data_Memory is
	Generic (
	DATA_Mem_WIDTH: integer := 16;
	MeM_DEPTH: integer := 16
);

port ( 
	clk 		: in std_logic;
	write_enable 	: in std_logic;
	read_enable 	: in std_logic;
	address 	: in std_logic_vector(MeM_DEPTH-1 downto 0);
	datain 		: in std_logic_vector(DATA_Mem_WIDTH-1  downto 0);

	dataout		: out std_logic_vector(DATA_Mem_WIDTH-1 downto 0)
);
end component data_Memory;

Component BoothTop is
port(
	M: in std_logic_vector(15 downto 0);
	Q: in std_logic_vector(15 downto 0);
	Z: out std_logic_vector(31 downto 0)
);
end Component BoothTop;

component divider is
generic(input_width: integer:=30);
port(

	Q: in std_logic_vector(input_width-1 downto 0);
	M: in std_logic_vector(input_width-1 downto 0);
	Quo: out std_logic_vector(input_width-1 downto 0);
	Remi: out std_logic_vector(input_width-1 downto 0)
);
end component;
-------------------------------------------------------------------------



TYPE State_type IS (OldPoint, NewPoint, SegmentPoint,Accumulation, CalcAvg,idle,ReadAlphaNew,CopyToBckUp,ReadBckUp );  -- Define the states
SIGNAL State : State_Type;

TYPE State_type_acc IS (read_acc,write_acc);  -- Define the states
SIGNAL State_acc : State_Type_acc;

TYPE State_type_avg IS (read_avg,write_avg);  -- Define the states
SIGNAL State_avg : State_Type_avg;

TYPE Alpha_Beta_Switch is (state_on,state_off);
SIGNAL Switch_ab : Alpha_Beta_Switch;


------------
SIGNAL reg_trigger: std_logic;
SIGNAL write_enable_alphabeta: std_logic;
SIGNAL read_enable_alphabeta: std_logic;
SIGNAL sigAddress: std_logic_vector(9 downto 0);
SIGNAL accCounter: unsigned(16-1 downto 0);
SIGNAL address_alphabeta: std_logic_vector(9 downto 0);
SIGNAL sigCVcounter: unsigned(9 downto 0);
SIGNAL R_W: std_logic; --Flag bit, when 0 => Read , when 1 => Write
SIGNAL siglamda: std_logic_vector(n-1 downto 0);
SIGNAL sigDataout32: std_logic_vector((2*Data_Width)-1 downto 0);
-----------------------------FSM------------------------------------
signal Data_in_FSMtoM: std_logic_vector(Data_Width-1 downto 0);--signal written to FSM from mem
signal Data_out_MtoFSM: std_logic_vector(Data_Width-1 downto 0);--signal read from mem to fsm
-------------------------------acc--avg-------------------------------
SIGNAL Data_in_Acc_Avg: std_logic_vector(Data_Width-1 downto 0);--signal written to acc_avg mem
SIGNAL Data_in_Acc_Avg_sig: std_logic_vector(Data_Width-1 downto 0);
SIGNAL Data_out_Acc_Avg: std_logic_vector(Data_Width-1 downto 0);--signal read from acc_avg mem
signal write_enable_Acc_Avg: std_logic;--write enable for acc_avg mem
signal read_enable_Acc_Avg: std_logic;--write enable for acc_avg mem
SIGNAL first_accumulation: std_logic; -- =1-> first time to accum 
SIGNAL first_copyToBackup: std_logic; -- =1-> first time to copy to backup
signal address_Acc_Avg:std_logic_vector(9 downto 0);
SIGNAL sigRead_enable_avg: std_logic;
SIGNAL address_Acc_Avg_sequen: unsigned(9 downto 0);
SIGNAL sigDataout_div: std_logic_vector(Data_Width-1 downto 0);
SIGNAL Acc_flag: std_logic;
SIGNAL sum_acc_MtoFSM: std_logic_vector(Data_Width-1 downto 0);
----------------------BkuP------------------------------------------
SIGNAL write_enable_BackUp: std_logic;
SIGNAL address_backup:std_logic_vector(9 downto 0);
SIGNAL address_backup_sequen: unsigned(9 downto 0);
SIGNAL Data_in_BckUp:std_logic_vector(Data_Width-1 downto 0);

signal first_run_sel: std_logic;   --- to mux ;
signal first_run_in: std_logic; -----  off the first sig 
signal cvCounter_conct: std_logic_vector(15 downto 0);
------------------------------------------------------------------------
Begin
cvCounter_conct<= "000000"& std_logic_vector(CVcounter); 
first_run_in<= first_run when first_run_sel='1' else 
		'0';

--State <= SegmentPoint when WkSelect= "00" and average_enable='0' and Acc_flag='0' and read_enable_norm_avg='0' and copyTobackUp_enable='0' and read_enable_BackUp='0' else
--	OldPoint when WKSelect="10" and average_enable='0' and Acc_flag='0' and read_enable_norm_avg='0' and copyTobackUp_enable='0' and read_enable_BackUp='0'else
--	NewPoint when WKSelect="11" and average_enable='0' and Acc_flag='0' and read_enable_norm_avg='0' and copyTobackUp_enable='0' and read_enable_BackUp='0'else
	--CalcAvg when average_enable='1' and Acc_flag='0' and read_enable_norm_avg='0' and copyTobackUp_enable='0' and read_enable_BackUp='0' else
	--Accumulation when Acc_flag='1' else
	--ReadAlphaNew when read_enable_norm_avg='1' else
	--CopyToBckUp when copyTobackUp_enable='1' else
	--ReadBckUp when read_enable_BackUp='1' else
	--idle;
State<= ReadAlphaNew when read_enable_norm_avg='1' else
	CopyToBckUp when copyTobackUp_enable='1' else
	ReadBckUp when read_enable_BackUp='1' else
	CalcAvg when average_enable='1' and Acc_flag='0' else
	Accumulation when Acc_flag='1' else
	SegmentPoint when WkSelect= "00" and average_enable='0' and Acc_flag='0' else
	OldPoint when WKSelect="10" and average_enable='0' and Acc_flag='0' and First_Run_in='0' else
	NewPoint when ((WKSelect="11" and average_enable='0' and Acc_flag='0') or First_Run_in='1')  else
	idle;
	
--(4,12) -> (9,7) 1111.1111111)11111
Data_in_Acc_Avg_sig<= std_logic_vector(resize(signed(Data_out_MtoFSM(Data_Width-1 downto 5)),16) ) when first_accumulation='1' else
		 Data_in_Acc_Avg;
		


siglamda<= std_logic_vector("0100000000" - (signed (lamda)));
--1 - lamda => (8,8) - (8,8) = (8,8)

multipI: BoothTop port map(siglamda,Data_out_MtoFSM,sigDataout32);
--(8,8)*(4,12)=(12'4',20) [32] 11111111(1111.111111111111)11111111
-----------------------DIVIDER ---------------------
--(9,7)/(16,0) => (9,7) *We want to reformat it down to (4,12)
div: divider generic map(input_width=>16) port map(Data_out_Acc_Avg,cvCounter_conct,sigDataout_div);


Memory_Alphabeta: Mem_16x900 port map(clk,write_enable_alphabeta, read_enable_alphabeta, address_alphabeta,Data_in_FSMtoM,Data_out_MtoFSM);
Memory_Acc_Average: Mem_16x900 port map(clk,write_enable_Acc_Avg, sigRead_enable_avg, address_Acc_Avg,Data_in_Acc_Avg_sig,Data_out_Acc_Avg);
Memory_BackUp: Mem_16x900 port map(clk,write_enable_BackUp, read_enable_BackUp, address_backup,Data_out_Acc_Avg,OutBackUp);

Out_alphabeta_average<=Data_out_Acc_Avg;

reg_trigger<= average_enable or copyTobackUp_enable or read_enable_norm_avg or
		read_enable_BackUp or alpha_beta_wake_up;
		

main_Proc:  process(clk,sigAddress,sigDataout32,reset,reg_trigger) is
  begin
	if(reset='1') then
		sigAddress<=(others=>'0');
		sigCVcounter<=(others=>'0');
		address_alphabeta<=(others=>'0');
		state_acc<=read_acc;
		state_avg<=read_avg;
		accCounter<=(others=>'0');
		first_accumulation<='1';
		--Data_out_Acc_Avg<=(others=>'0');
		R_W<='0';
		address_Acc_Avg_sequen<=(others=>'0');
		address_backup_sequen<=(others=>'0');
		Acc_flag<='0';
		address_backUp<=(others=>'0');
		Switch_ab<=state_off;
		first_run_sel<='1'; -- added new , dakhal signal form cu
		
	
	
	elsif rising_edge(clk) THEN 
CASE Switch_ab IS
	when state_off=>
	  if(reg_trigger='1') then
			Switch_ab<=state_on;
		else
			Switch_ab<=state_off;
			accCounter<=(others=>'0');
			address_backup_sequen<=(others=>'0');
			address_alphabeta<=(others=>'0');
		end if;
	
	when state_on=>
		CASE State IS
			when OldPoint=>
				
				write_enable_alphabeta<='0';
				read_enable_alphabeta<='1';


				sigRead_enable_avg<=read_enable_Acc_Avg;	
				--State<=Accumulation;
				Acc_flag<='1';
				state_avg<=read_avg;
				

			when NewPoint=>
				
				if accCounter < Datacounter then
					sigAddress<= std_logic_vector(unsigned (sigAddress)+1);
					Data_in_FSMtoM<=(others=>'0');
					write_enable_alphabeta<='1';
					accCounter<= accCounter+1;
					address_alphabeta<=sigaddress; -- da eli bybd2 be sefr

					
				elsif accCounter= Datacounter then
					
					
					Data_in_FSMtoM<= weight_one; --(1) (4,12)
					 --(-1) (9,7)
					accCounter<= accCounter+1;
					address_alphabeta<= CV_Point_address;--cv out
 					
					
					
				elsif accCounter=(Datacounter)+1 then
					write_enable_alphabeta<='0';
					accCounter<=(others=>'0');
					address_alphabeta<=(others=>'0');
					--read_enable_alphabeta<='1';
					sigAddress<=(others=>'0');
					sigRead_enable_avg<=read_enable_Acc_Avg;
					--State<= Accumulation;
					if(First_Run_in='1') then
						Acc_flag<='0';
						first_run_sel<='0';  --- turn off 
						--sigAddress<=(others=>'0');
						switch_ab<=state_off;
					else
						Acc_flag<='1';
						state_avg<=read_avg;
					end if;
					
							
				end if;
				

			when SegmentPoint=>
				-- try this after simulating with cv counter only and increment it in write only
				if accCounter < Datacounter then
					if R_W = '0' then --if read operation:  
						write_enable_alphabeta<='0';
						read_enable_alphabeta<='1';
						
						address_alphabeta<=sigAddress;	
						R_W <= '1'; -- Next operation is Write
				
					elsif R_W ='1' then -- if write operation
						write_enable_alphabeta<='1';
						read_enable_alphabeta<='0';

						Data_in_FSMtoM<=sigDataout32(23 downto 8);
						-- sigdataout32 is the result of multiplying 1-lamda* old alphabeta
						sigAddress<= std_logic_vector(unsigned (sigAddress)+1);
						accCounter<=accCounter+1;
						address_alphabeta<=sigAddress;
						R_W <= '0'; -- Next operation is Read
					end if;

  				elsif accCounter=Datacounter then
					write_enable_alphabeta<='1';
					read_enable_alphabeta<='1';
					-- do this + lamda * weight_one 
		
					accCounter<=accCounter+1;
					address_alphabeta<=CV_Point_address;
					

				elsif accCounter = (Datacounter+1) then -- check with adek bt3mel eh heina
			
					if (weight_one(weight_one'HIGH)='0') then
						Data_in_FSMtoM<= std_logic_vector(unsigned (Data_out_MtoFSM) + unsigned (lamda(8 downto 0)&"0000")); -- (4,12)+(8,8) 
					else
						Data_in_FSMtoM<= std_logic_vector(unsigned (Data_out_MtoFSM) - unsigned (lamda(8 downto 0)&"0000"));
					end if;
					write_enable_alphabeta<='1';
					 
					accCounter<=(others=>'0');
					read_enable_alphabeta<='1';
					sigRead_enable_avg<='1';
					--sigRead_enable_avg<=read_enable_Acc_Avg;
					--State<= Accumulation;
					sigAddress<=(others=>'0'); 
					Acc_flag<='1';
					state_acc<=read_acc;
					
				end if;
				
			WHEN CalcAvg=>
				case state_avg IS
					WHEN read_avg=>
						
						if accCounter < Datacounter then

						write_enable_Acc_Avg<='0';
						sigRead_enable_avg<='1';
						address_Acc_Avg<=sigaddress;
						state_avg<= write_avg;
						else
						state_avg<= read_avg;
						sigRead_enable_avg<='0';
						write_enable_Acc_Avg<='0';
						Switch_ab<=state_off;
						end if;

					WHEN write_avg=>
						if accCounter <Datacounter then
						write_enable_Acc_Avg<='1';
						sigRead_enable_avg<='0';
						address_Acc_Avg<=sigaddress;
						--(9,7) -> (4,12) 111111111.1111111
						Data_in_Acc_Avg<=( sigDataout_div(sigDataout_div'HIGH)&sigDataout_div(9 downto 0)&"00000");
						sigAddress<= std_logic_vector(unsigned (sigAddress)+1);
 						accCounter<=accCounter+1;
						state_avg<= read_avg;
						else
						state_avg<= read_avg;
						sigRead_enable_avg<='0';
						write_enable_Acc_Avg<='0';
						Switch_ab<=state_off;
						end if;
				end case;
			WHEN Accumulation  =>
				case state_acc IS     
					WHEN read_acc=>
						if accCounter < Datacounter then
						write_enable_alphabeta<='0';
						write_enable_Acc_Avg<='0';
						address_alphabeta<=sigaddress;
						address_Acc_Avg<=sigaddress;
						read_enable_alphabeta<='1';
						sigRead_enable_avg<='1';
							
						
 						
						--accumulated value
						--Data_in_Acc_Avg<=std_logic_vector( signed(Data_out_Acc_Avg) + signed(Data_out_MtoFSM));
						--Data_in_Acc_Avg<= sum_acc_MtoFSM;
						state_acc<= write_acc;
						else
						write_enable_Acc_Avg<='0';
                                                read_enable_alphabeta<='0';
						sigRead_enable_avg<='0';
						accCounter<=(others=>'0');
						sigAddress<=(others=>'0');
						first_accumulation<='0';
						Acc_flag<='0';
						Switch_ab<=state_off;
						end if;

					WHEN write_acc=>
						if accCounter < Datacounter then
				--[31-5]	--we want the accumalation format to be (9,7) but the avg format to be (4,12)
						Data_in_Acc_Avg<=std_logic_vector(  signed(Data_out_Acc_Avg) + resize(signed(Data_out_MtoFSM(Data_Width-1 downto 5)),16)  );

						write_enable_Acc_Avg<='1';
						--read_enable_alphabeta<='0';
						--sigRead_enable_avg<='0';
						sigaddress<= std_logic_vector(unsigned (sigAddress)+1);
						
						--address_alphabeta<=sigaddress;
						--address_Acc_Avg<=sigaddress;
						accCounter<=accCounter+1;
						state_acc<= read_acc;
						else -- accu finished
						state_acc<= read_acc;
						write_enable_Acc_Avg<='0';
                                                read_enable_alphabeta<='0';
						sigRead_enable_avg<='0';
						accCounter<=(others=>'0');
						sigAddress<=(others=>'0');
						first_accumulation<='0';
						Acc_flag<='0';
						Switch_ab<=state_off;
						end if;
				end case;
			WHEN ReadAlphaNew =>
				if(read_enable_norm_avg='1' and accCounter<Datacounter) then
					sigRead_enable_avg<='1';
					address_backup_sequen<= address_backup_sequen+1;
					address_Acc_Avg<=std_logic_vector(address_backup_sequen);
					accCounter<= accCounter+1;
				else
					address_Acc_Avg_sequen<=(others=>'0');
					Switch_ab<=state_off;
		
				end if;
			WHEN CopyToBckUp=>
				if(copyTobackUp_enable='1' and accCounter<Datacounter) then
					sigRead_enable_avg<='1';
					write_enable_BackUp<='1';
					address_backup_sequen<= address_backup_sequen+1;
					address_Acc_Avg<=std_logic_vector(address_backup_sequen);
					address_backUp<=std_logic_vector(address_backup_sequen);

					accCounter<=accCounter+1;
				else
					address_backup_sequen<=(others=>'0');
					Switch_ab<=state_off;
		
		
				end if;
	                WHEN ReadBckUp=>
				if(read_enable_BackUp='1' and accCounter<Datacounter) then
		
					address_backup_sequen<= address_backup_sequen+1;
					address_backUp<=std_logic_vector(address_backup_sequen);
					accCounter<=accCounter+1;
				else
					address_backup_sequen<=(others=>'0');
					Switch_ab<=state_off;
		
				end if;
			WHEN idle=>
		sigAddress<=(others=>'0');
		sigCVcounter<=(others=>'0');
		address_alphabeta<=(others=>'0');
		state_acc<=read_acc;
		state_avg<=read_avg;
		accCounter<=(others=>'0');
		first_accumulation<='1';
		--Data_out_Acc_Avg<=(others=>'0');
		R_W<='0';
		address_Acc_Avg_sequen<=(others=>'0');
		address_backup_sequen<=(others=>'0');
		Acc_flag<='0';
		Switch_ab<=state_off;
				--accCounter<=(others=>'0');
			WHEN others =>
				--State <= OldPoint;
		end CASE;
end Case;
	end if;
				
end process;




end architecture arch_alphabeta_Mem;