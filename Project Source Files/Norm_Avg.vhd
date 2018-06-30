
Library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

Entity Norm_avg is
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
end entity Norm_avg;

architecture Norm_avg_arch of Norm_avg is
component reg is
generic(n:integer);
port(
	clk,rst,wenable:in std_logic;
	d:in std_logic_vector(n-1 downto 0);
	q:out std_logic_vector(n-1 downto 0)
);
end component;
-----------------------------------------------------------------
component mux2x1 is
Generic (n:integer);
port(
d1:in std_logic_vector(n-1 downto 0);
d2:in std_logic_vector(n-1 downto 0);
s:in std_logic;
q:out std_logic_vector(n-1 downto 0)
);
end component;
-----------------------------------------------------------------

component fifo2 is
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
END component;
-----------------------------------------------------------------
Component sqrt32 is
port(
clk: in  std_logic;
rdy:out std_logic;
reset:in  std_logic;
x:in std_logic_vector(31 downto 0);
acc:out std_logic_vector(15 downto 0)
);
end Component sqrt32;
--------------------------------------------------------------
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
-----------------------------------------------------------------
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
Component comparator is
Generic (n : integer := 16);
port(   In1 : IN std_logic_vector(n-1 downto 0);--top
	In2 : IN std_logic_vector(n-1 downto 0); --bot
        Y : out std_logic_vector(1 downto 0)
	
	
);
end Component;
-----------------------------------------------------------------
signal SigFromMuxTOQueuIN:std_logic_vector(Data_Width-1 downto 0); --signal out from queue back to queue in
signal SigModi_AvgNorm:std_logic_vector(Data_Width-1 downto 0);--downscale 32bit(13,19) downto  16 bit (6,10)

signal choosen_dataout_cachAvg:std_logic_vector(Data_Width-1 downto 0);--out form mux dataout cache avg1 or cache avg2
signal MultpOut_to_add_AvgNorm:std_logic_vector((2*Data_Width)-1 downto 0); -- out from multi each point of cachAvg and alphabeta
signal Add_to_Reg_AvgNorm:std_logic_vector((2*Data_Width)-1 downto 0); -- signal fromadder to following reg
signal AddReg_to_Multp_AvgNorm:std_logic_vector((2*Data_Width)-1 downto 0); -- signal from reg back to adder
signal alphaBeta_muxOut:std_logic_vector(Data_Width-1 downto 0); -- signal from mux to avg norm alpha old or new

signal DataOut_Queue_avgNorm:std_logic_vector(Data_Width-1 downto 0);--dataout of the queue avg norm
signal regQueu_DataOut:std_logic_vector(Data_Width-1 downto 0);--dataout from reg after queue

signal avgNorm1_Multp_avgNorm2:std_logic_vector((2*Data_Width)-1 downto 0);--avgnorm1 * agvgnorm2 32 bit(12,20)

signal singoutSquare:std_logic;
signal squareRoot_dataout:std_logic_vector(Data_Width-1 downto 0); --signal out fro square  into the reg still 32 bit
signal squareReg_dataOut:std_logic_vector(Data_Width-1 downto 0); -- signal from square root reg to divion still 32 bit

signal remOfDivision:std_logic_vector(Data_Width-1 downto 0);--not used just for ouyput
signal rdy:std_logic;--not used just for ouyput

signal Modifi_squareRoot_dataout:std_logic_vector(Data_Width-1 downto 0); --to take only integer part 
signal coserror:std_logic_vector(Data_Width-1 downto 0);-- coserror to terminate if it's greater than threshold

begin
MultpOut_to_add_AvgNorm <= std_logic_vector( signed(choosen_dataout_cachAvg) * signed(alphaBeta_muxOut));--32 bit (13,19)

Add_to_Reg_AvgNorm      <= std_logic_vector( signed(MultpOut_to_add_AvgNorm) + signed(AddReg_to_Multp_AvgNorm));--32 bit(13,19) 

avgNorm1_Multp_avgNorm2 <= std_logic_vector( signed(regQueu_DataOut) * signed(DataOut_Queue_avgNorm)); --16 bit (7,9)+ 16 bit (7,9 --32bit(14,18)

SigModi_AvgNorm<=AddReg_to_Multp_AvgNorm(25 downto 10) ; --16 bit (7,9) downscaled from 32 bit (13,19) 

Modifi_squareRoot_dataout<="000000000"&squareRoot_dataout(15 downto 9);--according to matlab more accuracy 16 bit (16,0)

LABLE_MUX4_alphaBeta: mux4x1 generic map(n => Data_Width) port map(i_Old_alphabeta,j_Old_alphabeta,i_new_alphabeta,j_new_alphabeta,
								Mux_Select_alpha,alphaBeta_muxOut); 

LABLE_MUX2_cacheAvg: mux2x1 generic map(n => Data_Width) port map(DataOut_cachAvg1,DataOut_cachAvg2,
								Mux_Select_Avg1_or_Avg2,choosen_dataout_cachAvg);

LABLE_AddToReg_AvgNorm:reg generic map(n => 2*Data_Width) port map(clk,Reg_reset_AvgNorm,Reg_Enable_AvgNorm,Add_to_Reg_AvgNorm,AddReg_to_Multp_AvgNorm);

LABLE_Queue:fifo2 generic map(m => Data_Width) port map(clk,Reset_fifo_AvgNorm,WriteEnable_fifo_AvgNorm,ReadEnable_fifo_AvgNorm,SigFromMuxTOQueuIN,DataOut_Queue_avgNorm,
					FifoEmpty_fifo,FifoFull_fifo);

LABLE_QueReg_ToQueIN: mux2x1 generic map(n =>  Data_Width) port map(SigModi_AvgNorm,DataOut_Queue_avgNorm,
								Mux_Select_AvgNorm_Que_in,SigFromMuxTOQueuIN);

LABLE_Queue_Reg:reg generic map(n => Data_Width) port map(clk,Reg_reset_Queu_AvgNorm,Reg_Enable_Queu_AvgNorm,DataOut_Queue_avgNorm,regQueu_DataOut);


LABLE_queue_to_square:sqrt32 port map(clk,rdy,Reset_square,avgNorm1_Multp_avgNorm2,squareRoot_dataout); -- 16 bit(6,10)
--LABLE_Square_reg:reg generic map(n =>Data_Width) port map(clk,Reg_reset_SquarRoot,Reg_Enable_SquarRoot,squareRoot_dataout,squareReg_dataOut);
LABLE_SquareRoot_Division:divider generic map(input_width => Data_Width) port map(SigModi_AvgNorm,Modifi_squareRoot_dataout,coserror,remOfDivision);--16 bit(6,10)/ 16 bit(16,0)--16 bit(6,10)
LABLE_Last_Termination_condition:comparator generic map(n => Data_Width) port map(coserror,"0000000111001100",Last_Termination_condition); --01 cosserror >1  00&10 cosserror<1

end architecture Norm_avg_arch;