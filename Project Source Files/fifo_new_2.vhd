Library ieee;
Use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

Entity fifo2 is
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
END fifo2;-- entity declarations ends

Architecture A_fifo of fifo2 is

component data_Memory_fifo2 is
generic (n: integer := 16);
port ( clk : in std_logic;
write_enable : in std_logic;
read_enable : in std_logic;
address : in std_logic_vector(1 downto 0);
datain : in std_logic_vector(n-1 downto 0);
dataout : out std_logic_vector(n-1 downto 0)

);
end component;

Signal ReadPointer  : std_logic_vector(1 downto 0);
Signal WritePointer : std_logic_vector(1 downto 0);
Signal ByteCounter  : std_logic_vector(1 downto 0);

Signal WriteEnable_s : std_logic;
Signal ReadEnable_s : std_logic;
Signal Addr_s        : std_logic_vector(1 downto 0);
Signal FifoFull_s    : std_logic;
Signal FifoEmpty_s   : std_logic;


Begin
    FifoRam :  data_Memory_fifo2
		generic map (n=>m)
		Port map (
 			   clk =>  Clk,
                           write_enable=>  WriteEnable_s,
			   read_enable =>ReadEnable_s,
			   address =>Addr_s,
                           datain =>DataIn,
                           dataout=>DataOut
			   
			 );

	ReadWriteFifoOut   : Process(Clk,Reset)
	Begin
		IF ( Reset = '1') then
			ReadPointer  <= "00";
			WritePointer <= "00";
			ByteCounter  <= "00";
                      
		ELSIF(rising_edge(Clk)) then    -- try rising edge 
			IF ( WriteEnable = '1' and FifoFull_s='0' and ReadEnable = '0') then
				WritePointer <= std_logic_vector(unsigned(WritePointer)+1);
				ByteCounter  <= std_logic_vector(unsigned(ByteCounter) +1);
				
			END IF;
			IF ( ReadEnable = '1' and FifoEmpty_s ='0' and WriteEnable = '0') then
				ReadPointer  <= std_logic_vector(unsigned(ReadPointer)+1);
				ByteCounter  <= std_logic_vector(unsigned(ByteCounter)-1);
				
			END IF;
				if (WritePointer="10"and FifoFull_s='1') then
					WritePointer <="00";
				end if;
				if (ReadPointer="10"and FifoEmpty_s ='1') then
					ReadPointer <="00";
				end if;
				
		END IF;
			--if (ReadEnable = '1' and ByteCounter ="10") then   --- goz2 el kan msh shghal , by-read mara zeyada we howa empty bas etzbatet and ask about it 
			---	ByteCounter <= "01";
				--end if; 
	END process;-- ReadWriteFifo Process ends
-----------------------------------------------------------
--  Combinatorial Logic
-----------------------------------------------------------
	FifoEmpty_s <= '1' when ( ByteCounter = "00") else
                       '0';
	FifoFull_s  <= ByteCounter(1);  --10

	FifoFull  <= FifoFull_s;
	FifoEmpty <= FifoEmpty_s;

	WriteEnable_s <= '1' when ( WriteEnable = '1' and FifoFull_s = '0') else
		       '0';
	ReadEnable_s <= '1' when( ReadEnable='1' and FifoEmpty_s='0') else
			'0';
	Addr_s <= WritePointer when ( WriteEnable = '1') else
		  ReadPointer when (ReadEnable='1');
------------------------------------------------------------
END A_fifo;--Architecture Ends

