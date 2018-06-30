Library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

Entity CVmonitor is
Generic (Addr_Width :integer:=10);
port( 
	clk: 		in std_logic;
	reset:		in std_logic;
	flag_newpoint:	in std_logic;   -- a new point has came
	i: 		in std_logic_vector( 9 downto 0);
	j: 		in std_logic_vector( 9 downto 0);
	CV_counter:	in unsigned(9 downto 0);

     requested_address: out std_logic_vector (9 downto 0); --from CV monitor to i and j CV memory
	Repeated: 	out std_logic;
	i_rep_Reg: out std_logic_vector( 9 downto 0);
	j_rep_Reg: out std_logic_vector( 9 downto 0)
		
);
end entity CVmonitor;

architecture arch_CVmonitor of CVmonitor is

--------------------COMPONENTS INST:-------------------
TYPE state IS (idle, last_ij_read ,ij_read, compare);
SIGNAL current_state : state;
SIGNAL ijConcatenated: std_logic_vector((2*10)-1 downto 0);
SIGNAL ijConcatenated_const: std_logic_vector((2*10)-1 downto 0);
SIGNAL sig_CVcounter: unsigned (9 downto 0);  --Intiallized with the input CVcounter
SIGNAL subtracted: signed(19 downto 0);
SIGNAL i_Reg: std_logic_vector( 9 downto 0):="0000000010";
SIGNAL j_Reg: std_logic_vector( 9 downto 0):="0000000011";
SIGNAL flag_newpoint_reg: std_logic;
Begin

subtracted<=signed(ijConcatenated_const)-signed(ijConcatenated);

i_rep_Reg<=i_Reg;
j_rep_Reg<=j_Reg;




main_proc: process(clk) is
begin
if(reset='1') then
--Signals Intializations goes here: 
current_state<=idle;
--i_Reg<=(others=>'0');
--j_Reg<=(others=>'0');
requested_address<=(others=>'0');
Repeated<='0';


elsif(rising_edge(clk)) then

	case current_state IS
		WHEN idle=>
			if(flag_newpoint_reg='1' and sig_CVcounter>0) then  --A new point arrived AND there already exist a point
				current_state<=last_ij_read;
				requested_address<=std_logic_vector(sig_CVcounter);
				sig_CVcounter<=sig_CVcounter-1;	
				flag_newpoint_reg<='0';
			else		
				flag_newpoint_reg<=flag_newpoint;	
				sig_CVcounter<=CV_counter;
				ijConcatenated<= (others=>'0');
				ijConcatenated_const<= (others=>'0');
				
			end if;
			
			--ij_const_enable<='1';
			

		WHEN last_ij_read=>

			ijConcatenated_const<= i & j;
			current_state<=ij_read;

			requested_address<=std_logic_vector(sig_CVcounter);
			sig_CVcounter<=sig_CVcounter-1;

		WHEN ij_read=>

			ijConcatenated<= i & j;
			current_state<=compare;
			if(signed(sig_CVcounter)<0) then
				requested_address<=(others=>'0');
			else
				requested_address<=std_logic_vector(sig_CVcounter);
			end if;
			sig_CVcounter<=sig_CVcounter-1;
	
		WHEN compare=>
			if(subtracted = 0 ) then
				Repeated<='1';
				current_state<=idle;
				i_Reg<= ijConcatenated_const(19 downto 10); --- to write the last point 
				j_Reg<= ijConcatenated_const(9 downto 0);
			elsif(signed(sig_CVcounter)+2 = 0) then 
				current_state<=idle;
			else
				current_state<=ij_read;
			end if;


		WHEN others=>
			current_state<=idle;
			
	end case;

end if;

end process;
end architecture arch_CVmonitor;
