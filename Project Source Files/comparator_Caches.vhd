
Library ieee;
Use ieee.std_logic_1164.all;
Use ieee.numeric_std.all;
Entity Comparator_Caches is
Generic (n : integer := 16);
port(   In1 : IN std_logic_vector(n-1 downto 0);--top
	In2 : IN std_logic_vector (n-1 downto 0); --bot
        Y : out std_logic_vector(1 downto 0)
	
	
);
end entity Comparator_Caches;
 
Architecture Comparator_Caches_arch of Comparator_Caches is

SIGNAL result: std_logic_vector(n downto 0);
SIGNAl concatenated: std_logic_vector (n-1 downto 0);
Begin

result <=std_logic_vector(signed(In1(In1'High)&In1)-signed(In2(In2'High)&In2));
concatenated<=(others=>'0');

Y<= "01" when (result(n)='0')or result=concatenated  else ---in2<=in1 
    "00" when (result(n)='1') else----in1<in2 point aal segment
    "10" ; 
   
-----when (result(15)='0')else ----in1>in2 point el gedida
---"11";
end Comparator_Caches_arch;