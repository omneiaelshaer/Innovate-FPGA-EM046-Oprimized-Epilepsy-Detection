library ieee;
	use ieee.std_logic_1164.all;
	use ieee.numeric_std.all;

Entity Classes is
Generic ( D : integer :=10;
	  W : integer := 17;
	Feature_Width : integer := 17;
	 Ctild_Width : integer := 10;
	 Norm_Width : integer := 23; 
         Cache_Width : integer := 23;
		n     : integer := 16
); 
port ( clk : in std_logic;
---Y : in std_logic; 
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

Address_i_new: in std_logic_vector(9 downto 0); --- from caches get max 
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
Cache_i_min   : IN std_logic_vector(Cache_Width-1 downto 0);
Cache_j_max   : IN std_logic_vector(Cache_Width-1 downto 0);

WkSelect      : OUT std_logic_vector(1 downto 0);
lamda   : OUT std_logic_vector(n-1 downto 0);
max_min_enable: in std_logic;
---------------------------------------------------------------------
-----------------counter classes 
Count_ClassI : out unsigned (9 downto 0);
Count_ClassJ : out unsigned (9 downto 0);
Count_1024: out unsigned(9 downto 0);  -------- count to enter 900 data entery 
On_sig: in std_logic; 
Count_reset: in std_logic;  ---- msh 3arfa ahotaha fen belzabt , 3erft khalas
incidacte_address_class:out std_logic
);
end entity Classes;


architecture Classes_arch of Classes is


--------------------------------COMPONENTS DECLERATION-------------------------------
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
--------------------------------------------------------------------------------------------
component NormCalculate IS 
Generic (Feature_Width : integer := 16;
	 Ctild_Width : integer := 10;
	 Norm_Width : integer := 20; 
         Cache_Width : integer := 16;
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
END  component;
----------------------------------------------------------------------------------------
------------------------------------------------------------------
component N_bitfulladder is
Generic (n : integer := 16);
port
(a,b:in std_logic_vector(n-1 downto 0);
f:out std_logic_vector(n-1 downto 0);
cout:out std_logic
);
end component;
--------------------------------------------------------------------
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
---------------------------------------------------
Component C1X1_Mem IS
	PORT
	(
		clock		: IN STD_LOGIC  := '1';
		wren		: IN STD_LOGIC ;
		rden		: IN STD_LOGIC  := '1';
		address		: IN STD_LOGIC_VECTOR (9 DOWNTO 0);
		data		: IN STD_LOGIC_VECTOR (16 DOWNTO 0);
		q		: OUT STD_LOGIC_VECTOR (16 DOWNTO 0)
	);
END component;

Component C1X2_Mem IS
	PORT
	(
		clock		: IN STD_LOGIC  := '1';
		wren		: IN STD_LOGIC ;
		rden		: IN STD_LOGIC  := '1';
		address		: IN STD_LOGIC_VECTOR (9 DOWNTO 0);
		data		: IN STD_LOGIC_VECTOR (16 DOWNTO 0);
		q		: OUT STD_LOGIC_VECTOR (16 DOWNTO 0)
	);
END component;

Component C1X3_Mem IS
	PORT
	(
		clock		: IN STD_LOGIC  := '1';
		wren		: IN STD_LOGIC ;
		rden		: IN STD_LOGIC  := '1';
		address		: IN STD_LOGIC_VECTOR (9 DOWNTO 0);
		data		: IN STD_LOGIC_VECTOR (16 DOWNTO 0);
		q		: OUT STD_LOGIC_VECTOR (16 DOWNTO 0)
	);
END component;

Component C2X1_mem IS
	PORT
	(
		clock		: IN STD_LOGIC  := '1';
		wren		: IN STD_LOGIC ;
		rden		: IN STD_LOGIC  := '1';
		address		: IN STD_LOGIC_VECTOR (9 DOWNTO 0);
		data		: IN STD_LOGIC_VECTOR (16 DOWNTO 0);
		q		: OUT STD_LOGIC_VECTOR (16 DOWNTO 0)
	);
END component;

Component C2X2_Mem IS
	PORT
	(
		clock		: IN STD_LOGIC  := '1';
		wren		: IN STD_LOGIC ;
		rden		: IN STD_LOGIC  := '1';
		address		: IN STD_LOGIC_VECTOR (9 DOWNTO 0);
		data		: IN STD_LOGIC_VECTOR (16 DOWNTO 0);
		q		: OUT STD_LOGIC_VECTOR (16 DOWNTO 0)
	);
END component;

Component C2X3_Mem IS
	PORT
	(
		clock		: IN STD_LOGIC  := '1';
		wren		: IN STD_LOGIC ;
		rden		: IN STD_LOGIC  := '1';
		address		: IN STD_LOGIC_VECTOR (9 DOWNTO 0);
		data		: IN STD_LOGIC_VECTOR (16 DOWNTO 0);
		q		: OUT STD_LOGIC_VECTOR (16 DOWNTO 0)
	);
END component;
-----------------------------------------------------------------

--------------------------------END of COMPONENTS DECLERATION-------------------------------

signal WE : std_logic_vector(1 downto 0);

-----MEMORY SIGNALS
signal C1X1out_sig: std_logic_vector(16 downto 0);
signal C1X2out_sig: std_logic_vector(16 downto 0);
signal C1X3out_sig: std_logic_vector(16 downto 0);
signal C2X1out_sig: std_logic_vector(16 downto 0);
signal C2X2out_sig: std_logic_vector(16 downto 0);
signal C2X3out_sig: std_logic_vector(16 downto 0);  -- Output signals to be used if needed

signal X1: std_logic_vector((W-1) downto 0);
signal X2: std_logic_vector((W-1) downto 0);
signal X3: std_logic_vector((W-1) downto 0);
signal Y : std_logic;
------C REGISTER SIGNALS
signal C1addr: std_logic_vector(9 downto 0);
signal C2addr: std_logic_vector(9 downto 0);
signal CRst: std_logic_vector(1 downto 0);
signal C1addr_s: std_logic_vector(9 downto 0) := (others=>'0');
signal C2addr_s: std_logic_vector(9 downto 0) := (others=>'0');


-------------------omnia-------------------------
signal addressIn_classes1 :std_logic_vector(9 downto 0);--address in direct to memory
signal addressIn_classes2 :std_logic_vector(9 downto 0);--address in direct to memory

signal addreIncreas_classes1 :std_logic_vector(9 downto 0); --address after increament
signal addreIncreas_classes2 :std_logic_vector(9 downto 0); --address after increament

signal addreMuxOut_classes1 :std_logic_vector(9 downto 0); --which address in to cache Avg CV or from zero
signal addreMuxOut_classes2 :std_logic_vector(9 downto 0); --which address in to cache Avg CV or from zero

signal cout1: std_logic;
signal cout2: std_logic;

------------------counters sig -----------------------
signal Count_ClassI_Sig :  unsigned (9 downto 0);
signal Count_ClassJ_sig :  unsigned (9 downto 0);
signal Count_1024_sig:unsigned(9 downto 0);  -------- count to enter 900 data entery 

begin

process(clk,WE, Count_reset) is
  begin
	if Count_reset ='1' then
	Count_ClassI_sig<=(others=>'0');
	Count_ClassJ_sig<=(others=>'0');
	Count_1024_sig<=(others=>'0');
	
	ELSIF(rising_edge(clk)) then 
	if ( WE(0) = '1') then
	   Count_ClassI_sig<=Count_ClassI_sig+1;
 	  Count_1024_sig <=Count_1024_sig+1;
	elsif(WE(1) = '1') then
		Count_ClassJ_sig<=Count_ClassJ_sig+1;
		Count_1024_sig<=Count_1024_sig+1;
   	 end if;
    end if;
  end process;
-----------------------------------------------------------------------------------------
C1X1: C1X1_Mem port map(clk,WE(0),Read_enable_C1,addreMuxOut_classes1,X1,C1X1out_sig); 
C1X2: C1X2_Mem port map(clk,WE(0),Read_enable_C1,addreMuxOut_classes1,X2,C1X2out_sig); 
C1X3: C1X3_Mem port map(clk,WE(0),Read_enable_C1,addreMuxOut_classes1,X3,C1X3out_sig); 
C2X1: C2X1_Mem port map(clk,WE(1),Read_enable_C2,addreMuxOut_classes2,X1,C2X1out_sig); 
C2X2: C2X2_Mem port map(clk,WE(1),Read_enable_C2,addreMuxOut_classes2,X2,C2X2out_sig); 
C2X3: C2X3_Mem port map(clk,WE(1),Read_enable_C2,addreMuxOut_classes2,X3,C2X3out_sig); 

C1reg: reg generic map(n=>10) port map(clk,CRst(0),WE(0),C1addr_s,C1addr);
C2reg: reg generic map(n=>10) port map(clk,CRst(1),WE(1),C2addr_s,C2addr);
-------------------------------------------------------------------------------------
Norm_Wkblock :NormCalculate  generic map (Feature_Width=>W,Ctild_Width=>Ctild_Width,Norm_Width=>Norm_Width,Cache_Width=>Cache_Width,n=>16) port map(clk,Reset_fifo_Norm_wkblock,WriteEnable_fifo_Norm_wkblock,ReadEnable_fifo_Norm_wkblock,
  FifoEmpty_fifo_Norm_wkblock,FifoFull_fifo_Norm_wkblock,reg_reset_WkBlock,reg_enable_WkBlock,Ctilde,C1X1out_sig,C1X2out_sig,C1X3out_sig,
     C2X1out_sig,C2X2out_sig,C2X3out_sig,Select_Norm_queueIn ,Cache_i_min,Cache_j_max,WkSelect,lamda,max_min_enable);



C1X1out<= C1X1out_sig;
C1X2out <=C1X2out_sig;
C1X3out<= C1X3out_sig;
C2X1out<= C2X1out_sig;
C2X2out<= C2X2out_sig;
C2X3out<=C2X3out_sig;


Count_ClassI<=Count_ClassI_Sig;
Count_ClassJ<=Count_ClassJ_sig;
Count_1024<=Count_1024_sig;


--Set the Write Enable for the two classes MEMORY
WE<="01" when Y='0' and On_sig='1' else    --------- i sig to start writing 
    "10" when Y='1' and On_sig='1' else
    "00";

incidacte_address_class<=Y;

 LABLE_Reg_addres   : reg generic map(n => 10) port map(clk,reg_reset_class1_Address,reg_enable_class1_Address,addreIncreas_classes1,addressIn_classes1);
 LABLE_AddreInc   :N_bitfulladder generic map(n => 10) port map(addressIn_classes1,"0000000001", addreIncreas_classes1, cout1);
 
LABLE_Reg_addres2   : reg generic map(n => 10) port map(clk,reg_reset_class2_Address,reg_enable_class2_Address,addreIncreas_classes2,addressIn_classes2);
 LABLE_AddreInc2   :N_bitfulladder generic map(n => 10) port map(addressIn_classes2,"0000000001", addreIncreas_classes2, cout2);

 LABLE_addressSel : mux2x1 generic map(n => 10) port map(Address_i_new,addressIn_classes1,addressSel_Class,addreMuxOut_classes1);
 LABLE_addressSe2 : mux2x1 generic map(n => 10) port map(Address_j_new,addressIn_classes2,addressSel_Class,addreMuxOut_classes2);



end architecture Classes_arch;