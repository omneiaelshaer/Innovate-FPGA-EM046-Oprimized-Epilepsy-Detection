Library ieee;
Use ieee.std_logic_1164.all;
Use ieee.numeric_std.all;
Entity comparator is
Generic (n : integer := 16);
port(   In1 : IN std_logic_vector(n-1 downto 0);--top
	In2 : IN std_logic_vector (n-1 downto 0); --bot
        Y : out std_logic_vector(1 downto 0)
	
	
);
end entity comparator;
 
Architecture comparator_arch of comparator is

SIGNAL result: std_logic_vector(n-1 downto 0);
SIGNAl concatenated: std_logic_vector (n-1 downto 0);
Begin

result <=std_logic_vector(signed(In1)-signed(In2));
concatenated<=(others=>'0');

Y<= "10" when (In1(n-1)='1' or In1 =concatenated) else ---in1<=0 nafs el point
    "00" when (result(n-1)='1') else----in1<in2 point aal segment
    "01" ; --point gedida
   
-----when (result(15)='0')else ----in1>in2 point el gedida
---"11";
end comparator_arch ;
