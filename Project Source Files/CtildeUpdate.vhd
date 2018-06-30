LIBRARY IEEE;
USE IEEE.std_logic_1164.all;
USE IEEE.numeric_std.all;

ENTITY CtildeUpdate IS 
Generic (Ctild_Width : integer := 10;   
         n : integer := 16;
	Cache_Width : integer := 23);   --Size of  Ctilde_Update_Output in bits
		PORT (
                      CacheDataOut: in std_logic_vector(Cache_Width-1 downto 0);
                      Lamda   : in std_logic_vector(n-1 downto 0);
		      Ctilde  : in std_logic_vector(Ctild_Width-1 downto 0);
                      sub_add_Select: IN std_logic; -- It is 1 when there is Seizure (performs addition) and 0 when there is no seizure (performs subtraction) 
         	      Ctilde_Update_Output : OUT std_logic_vector(Cache_Width-1 downto 0)--check if we need overflow
);    
END ENTITY CtildeUpdate;


ARCHITECTURE Arch_CtildeUpdate OF CtildeUpdate IS

signal Multi_By_Ctilde: std_logic_vector(18 downto 0); 
signal Sig_Ctilde_Update_Output : std_logic_vector(Cache_Width downto 0); 

BEGIN
  
Multi_By_Ctilde <= std_logic_vector( unsigned(Lamda(8 downto 0)) *unsigned(Ctilde));--19 bit (11,8)

Sig_Ctilde_Update_Output<=std_logic_vector(signed (CacheDataOut(CacheDataOut'High)&CacheDataOut)-signed (Multi_By_Ctilde&"0000")) when sub_add_Select='1' else
		      std_logic_vector(signed (CacheDataOut(CacheDataOut'High)&CacheDataOut)+signed (Multi_By_Ctilde&"0000"));  ----- add from cache1 ,sub from cache2

Ctilde_Update_Output<=Sig_Ctilde_Update_Output(Cache_Width-1 downto 0);

END Arch_CtildeUpdate;
