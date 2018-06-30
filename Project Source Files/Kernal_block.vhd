LIBRARY IEEE;
USE IEEE.std_logic_1164.all;
USE IEEE.numeric_std.all;

ENTITY Kernel_block IS 
Generic (n : integer := 17);
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

END ENTITY Kernel_block;

ARCHITECTURE Arch_Kernel_block OF Kernel_block IS



---------------------------------------------------------------------------------------------
component B4_Kernel is
Generic (n : integer := 17);
port (
clk : in std_logic;

Feature1_Class1_Data  : in std_logic_vector(n-1 downto 0);   --fx1
Feature2_Class1_Data  : in std_logic_vector(n-1 downto 0);   --fx2
Feature3_Class1_Data  : in std_logic_vector(n-1 downto 0);   --fx3

Feature1_Class2_Data  : in std_logic_vector(n-1 downto 0);   --fy1
Feature2_Class2_Data  : in std_logic_vector(n-1 downto 0);   --fy2
Feature3_Class2_Data  : in std_logic_vector(n-1 downto 0);   --fy3

----------------------Kernel Relative Point Features Reg Signals----------------------
reg_reset_Kernel_RelativePoint_F   : in std_logic;
reg_enable_Kernel_RelativePoint_F  : in std_logic;

Kernal_RelativePoint_Mux_3Feature_Selc : in std_logic_vector(1 downto 0); --choose which Feature to pass to kernel F1. F2 or F3
--------------------Kernel class Features Reg Signals-------------------------
Kernal_classF_Mux_Selc: in std_logic;

reg_reset_Kernel_classF    : in std_logic;
reg_enable_Kernel_classF   : in std_logic;

Kernal_class_Mux_3Feature_Selc : in std_logic_vector(1 downto 0); --choose which  class Feature to pass to kernel F1. F2 or F3
------ outputs------

Kernal_classFeature_Mux_dataOut: out std_logic_vector(n-1 downto 0);-- F1, F2 or F3 of the classes point
Kernal_RelativePoint_Mux_dataOut:out std_logic_vector(n-1 downto 0)-- F1, F2 or F3 of the relative point

);
end component B4_Kernel;
---------------------------------------------------------------------------------
component reg is
generic(n:integer:=16);
port(clk,rst,wenable:in std_logic;
d:in std_logic_vector(n-1 downto 0);
q:out std_logic_vector(n-1 downto 0)
);
end component;
----------------------------------------------------------------
component exp_lut is
port(
  i_x            : in  std_logic_vector( 15 downto 0);  --(4,12)
  o_exp          : out std_logic_vector( 15 downto 0)); --(4,12)
end component exp_lut;
-------------------------------------------------------------
signal count_3 : std_logic_vector(2 downto 0);
signal Kernal_classFeature_Mux_dataOutSig : std_logic_vector(n-1 downto 0);   --1st kernel input  Dataset f1 (x1)
signal Kernal_RelativePoint_Mux_dataOutSig : std_logic_vector(n-1 downto 0);   -- 2nd kernel input f1-f1
signal Kernal_output :  std_logic_vector(15 downto 0); -- kernal o/p
signal Kernal_ADDOutput_accuml : std_logic_vector(36 downto 0); -- addition accuml
signal Reg_buffer1,Reg_buffer2,Reg_buffer3 :  std_logic ;  -- fro delay purpose
signal difference : std_logic_vector(17 downto 0);
-------------------------------------------------------------------------
signal Kernal_class_Mux_3Feature_Selc_sig: std_logic_vector(1 downto 0); --choose which  class Feature to pass to kernel F1. F2 or F3
signal Kernal_RelativePoint_Mux_3Feature_Selc_sig:  std_logic_vector(1 downto 0); --choose which Feature to pass to kernel F1. F2 or 
signal sqred : std_logic_vector(35 downto 0);
signal Negative_Squared: signed(36 downto 0);
signal conc_for_Neg:std_logic_vector( 15 downto 0);
begin
input :B4_Kernel generic map (n=>17)port map(clk,Feature1_Class1_Data,Feature2_Class1_Data,Feature3_Class1_Data ,Feature1_Class2_Data,Feature2_Class2_Data ,Feature3_Class2_Data
,reg_reset_Kernel_RelativePoint_F,reg_enable_Kernel_RelativePoint_F,Kernal_RelativePoint_Mux_3Feature_Selc_sig
,Kernal_classF_Mux_Selc,reg_reset_Kernel_classF,reg_enable_Kernel_classF,Kernal_class_Mux_3Feature_Selc_sig
,Kernal_classFeature_Mux_dataOutSig,Kernal_RelativePoint_Mux_dataOutSig);


difference<= std_logic_vector(signed(Kernal_classFeature_Mux_dataOutSig(Kernal_classFeature_Mux_dataOutSig'HIGH)&Kernal_classFeature_Mux_dataOutSig)- signed(Kernal_RelativePoint_Mux_dataOutSig(Kernal_RelativePoint_Mux_dataOutSig'HIGH)&Kernal_RelativePoint_Mux_dataOutSig)); --- 13,24

sqred<= std_logic_vector(signed(difference)*signed(difference));  ---(8,24)
Negative_Squared <= to_signed(0,37) - signed( Kernal_ADDOutput_accuml );
conc_for_Neg<=std_logic_vector(Negative_Squared(Negative_Squared'HIGH)&Negative_Squared(26 downto 12)) when signed(Negative_Squared)>(-117440512)
		else "1000111111100100"; -- zabtana el output  --(eb2a garab 27 downto 13)

Exp: exp_lut port map ( conc_for_Neg ,  Kernal_output );

process(clk,reset,reg_enable_Kernel_classF)
begin 
	
	if reset='1' then
	count_3<="000";
	Kernal_ADDOutput_accuml <= (others=>'0');
	
	elsif (rising_edge(clk))then
		Reg_buffer1<=reg_enable_Kernel_classF;  -- staling part
		Reg_buffer2<= Reg_buffer1;
		--Reg_buffer3<=Reg_buffer2;
 		if(Reg_buffer2='1')then   ---check for synthesis
			 --Kernal_ADDOutput_accuml <=std_logic_vector(signed(difference(difference'HIGH)&difference)+signed(Kernal_ADDOutput_accuml));
			 Kernal_ADDOutput_accuml <=std_logic_vector('0'&signed(sqred)+signed(Kernal_ADDOutput_accuml)); --- 11,24
			count_3 <= std_logic_vector(unsigned(count_3)+1);
		end if;
		if count_3="011"then
		count_3<="000";
		 Kernal_ADDOutput_accuml <= (others=>'0');
		end if;
	   
	--Output_final <= Kernal_ADDOutput_accuml(15 downto 0);  shofy low 3ozty delay lel kernal output ma3 el cU fel read of data set
	end if;
  end process; 
Kernal_class_Mux_3Feature_Selc_sig<= count_3(1 downto 0);  -- set mux selectors
Kernal_RelativePoint_Mux_3Feature_Selc_sig<=count_3(1 downto 0) ; --set mux selectors
OutCountSig <='1' when  count_3="011" else
	      '0' ;
Output_final <= Kernal_output when count_3="011";
Count_TostartRead<=count_3;
--in CU every time count =3 , el CU teb3at signal reset      
END Arch_Kernel_block;
