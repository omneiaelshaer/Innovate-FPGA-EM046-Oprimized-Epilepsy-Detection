
LIBRARY IEEE;
USE IEEE.std_logic_1164.all;
USE IEEE.numeric_std.all;

ENTITY NormCalculate IS 
Generic (Feature_Width : integer := 17;
	 Ctild_Width : integer := 10;
	 Norm_Width : integer := 23; 
         Cache_Width : integer := 23;
		n     : integer := 16
);  
PORT (
					 clk  : in std_logic;
		     Reset_fifo_Norm_wkblock  : in std_logic;
	       WriteEnable_fifo_Norm_wkblock  : in std_logic;
		ReadEnable_fifo_Norm_wkblock  : in std_logic;

	         FifoEmpty_fifo_Norm_wkblock  : out std_logic; --signal
	          FifoFull_fifo_Norm_wkblock  : out std_logic; 

    	 		   reg_reset_WkBlock  : in std_logic;
			  reg_enable_WkBlock  : in std_logic;


				Ctilde	      : in std_logic_vector(Ctild_Width-1 downto 0); 
			Feature1_Class1_Data  : in std_logic_vector(Feature_Width-1 downto 0);   --fx1
                        Feature2_Class1_Data  : in std_logic_vector(Feature_Width-1 downto 0);   --fx2
			Feature3_Class1_Data  : in std_logic_vector(Feature_Width-1 downto 0);   --fx3

			Feature1_Class2_Data  : in std_logic_vector(Feature_Width-1 downto 0);   --fy1
                        Feature2_Class2_Data  : in std_logic_vector(Feature_Width-1 downto 0);   --fy2
			Feature3_Class2_Data  : in std_logic_vector(Feature_Width-1 downto 0);   --fy3

			Select_Norm_queueIn   : in std_logic; --selection for mux b4 queue 0--> norm new , 1--> norm calculated

				Cache_i_max   : IN std_logic_vector(Cache_Width-1 downto 0);
                                Cache_j_min   : IN std_logic_vector(Cache_Width-1 downto 0);
			        WkSelect      : OUT std_logic_vector(1 downto 0);
                                      lamda   : OUT std_logic_vector(n-1 downto 0);
				max_min_enable: in std_logic
			
                     );

END ENTITY NormCalculate;


ARCHITECTURE Arch_NormCalculate OF NormCalculate IS

Component DotProduct IS 
Generic (Feature_Width: integer := 16);  
PORT (
    Input1  : in std_logic_vector(Feature_Width-1 downto 0);
    Input2  : in std_logic_vector(Feature_Width-1 downto 0);
    Input3  : in std_logic_vector(Feature_Width-1 downto 0);
    Input4  : in std_logic_vector(Feature_Width-1 downto 0);
    Input5  : in std_logic_vector(Feature_Width-1 downto 0);
    Input6  : in std_logic_vector(Feature_Width-1 downto 0);
    Result  : out std_logic_vector((2*Feature_Width)+1 downto 0)
);
end Component ;
------------------------------------------------------------------
Component mux2x1 is
Generic (n:integer);
port(
d1:in std_logic_vector(n-1 downto 0);
d2:in std_logic_vector(n-1 downto 0);
s:in std_logic;
q:out std_logic_vector(n-1 downto 0)
);
end Component;
-------------------------------------------------------------------
Component fifo2 is
	generic (m: integer:=16);
	Port ( 
		    Clk          : in std_logic;
		    Reset	 : in std_logic;
		    WriteEnable  : in std_logic;
		    ReadEnable   : in std_logic;
		    DataIn       : in std_logic_vector(m-1 downto 0);
		    DataOut      : out std_logic_vector(m-1 downto 0);
     		    FifoEmpty    : out std_logic;
		    FifoFull     : out std_logic
	    );
END Component;
----------------------------------------------------------------------
Component Wk_calculate is
Generic (
	Feature_Width	: integer := 16; 
	Cache_Width	: integer := 16; 
	Norm_Widht	: integer := 23; 
	n 		: integer := 16
);
port(  
	Cache_i_sig	: IN signed(Cache_Width-1 downto 0);-- (4,12)
        Cache_j_sig : IN signed(Cache_Width-1 downto 0); --(4,12)
	Wknorm2 : IN signed(Norm_Widht-1 downto 0); --(12,8)
	Norm2sij: IN signed(Norm_Widht-1 downto 0); --(12,8)
	WkSelect: OUT std_logic_vector(1 downto 0);
	lamda	: OUT std_logic_vector(n-1 downto 0);
	Wk : OUT std_logic_vector(Norm_Widht-1 downto 0);
	max_min_enable: in std_logic
); --20 bit handling the over all overflow	
	
end Component ;
----------------------------------------------------------------------
Component reg is
generic(n:integer:=16);
port(clk,rst,wenable:in std_logic;
d:in std_logic_vector(n-1 downto 0);
q:out std_logic_vector(n-1 downto 0)
);
end Component;
---------------------------------------------------------------------

signal X_Squared              : std_logic_vector((2*Feature_Width)+1 downto 0); --36 bits (12,24)
signal Y_Squared              : std_logic_vector((2*Feature_Width)+1 downto 0);
signal X_times_Y              : std_logic_vector((2*Feature_Width)+1 downto 0);
signal Two_times_X_times_Y    : std_logic_vector(Feature_Width+2 downto 0); --20 bit (13,7)
signal NormCalculated         : std_logic_vector(Feature_Width+4 downto 0);--22 bit(14,8) 
signal Two_Divide_Ctilde      : std_logic_vector(Ctild_Width downto 0); --11 bit after multi. by two

signal NormOfDot_toMux        : std_logic_vector(Norm_Width-1 downto 0);-- out of norm block  23 bit
signal Sig_Wk_new_point_norm  : std_logic_vector(Norm_Width-1 downto 0); -- norm out of Wk block back to mux b4 gueue
signal MuxOfNorm_ToQueue      : std_logic_vector(Norm_Width-1 downto 0);

signal NormQueueRegIn_Wkblock  : std_logic_vector(Norm_Width-1 downto 0); --out queue in reg & Normsig

signal NormQueueRegOut_NormOld  : std_logic_vector(Norm_Width-1 downto 0); --Wknorm


BEGIN
Two_times_X_times_Y <=X_times_Y(X_times_Y'HIGH downto Feature_Width)&'0';--  X_times_Y= (12,24) take downto (13,7) then put 0 at left for multi 2 
--
--NormCalculated <= std_logic_vector( signed('0'&X_Squared(X_Squared'HIGH downto Feature_Width)) 
--				  + signed('0'&Y_Squared(Y_Squared'HIGH downto Feature_Width)) 
--				  - signed(Two_times_X_times_Y(Two_times_X_times_Y'HIGH downto 0)) ); -- 18 bit 10,8

NormCalculated <= std_logic_vector( signed("00"&X_Squared(X_Squared'HIGH downto Feature_Width-1)) 
				  + signed("00"&Y_Squared(Y_Squared'HIGH downto Feature_Width-1)) 
				  - signed(Two_times_X_times_Y(Two_times_X_times_Y'High)&Two_times_X_times_Y(Two_times_X_times_Y'HIGH downto 0)&'0') ); -- 21 bit(13,8)--->22(14,8)

Two_Divide_Ctilde <= Ctilde&'0';--11 bit

NormOfDot_toMux <= std_logic_vector( signed(NormCalculated(NormCalculated'High)&NormCalculated) + signed("0000"&Two_Divide_Ctilde&"00000000") );-- 23bit (15,8)



  
LABEL1: DotProduct generic map (Feature_Width =>17) port map (Feature1_Class1_Data, Feature1_Class1_Data, Feature2_Class1_Data, Feature2_Class1_Data, Feature3_Class1_Data, Feature3_Class1_Data, X_Squared); --(10,24)
LABEL2: DotProduct generic map (Feature_Width =>17) port map (Feature1_Class2_Data, Feature1_Class2_Data, Feature2_Class2_Data, Feature2_Class2_Data, Feature3_Class2_Data, Feature3_Class2_Data, Y_Squared); --(10,24)
LABEL3: DotProduct generic map (Feature_Width =>17) port map (Feature1_Class1_Data, Feature1_Class2_Data, Feature2_Class1_Data, Feature2_Class2_Data, Feature3_Class1_Data, Feature3_Class2_Data, X_times_Y); --(10,24) => (10,6)
   
LABEL4: mux2x1 generic map(n=>Norm_Width) port map (Sig_Wk_new_point_norm ,NormOfDot_toMux,Select_Norm_queueIn,MuxOfNorm_ToQueue); --(15,8)
LABEL5: fifo2 generic map(m=>Norm_Width) port map (clk,Reset_fifo_Norm_wkblock,WriteEnable_fifo_Norm_wkblock,ReadEnable_fifo_Norm_wkblock,MuxOfNorm_ToQueue,NormQueueRegIn_Wkblock,FifoEmpty_fifo_Norm_wkblock,FifoFull_fifo_Norm_wkblock);
LABEL6: Wk_calculate generic map (Feature_Width=> Feature_Width,Cache_Width=> Cache_Width,Norm_Widht=>Norm_Width,n=>n)port map (signed(Cache_i_max),signed(Cache_j_min),signed(NormQueueRegOut_NormOld),signed(NormQueueRegIn_Wkblock),WkSelect ,lamda,Sig_Wk_new_point_norm,max_min_enable);
LABEL7: reg generic map(n=>Norm_Width)port map(clk,reg_reset_WkBlock,reg_enable_WkBlock,NormQueueRegIn_Wkblock,NormQueueRegOut_NormOld);


END Arch_NormCalculate;
