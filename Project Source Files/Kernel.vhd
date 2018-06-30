LIBRARY IEEE;
USE IEEE.std_logic_1164.all;
USE IEEE.numeric_std.all;

ENTITY Kernel IS 

		PORT (
				           diff  : in  std_logic_vector(18 downto 0); -- (4,12)  
			              Output  : out std_logic_vector(15 downto 0)  -- (4,12)
                     );

END ENTITY Kernel;

ARCHITECTURE Arch_Kernel OF Kernel IS

component exp_lut is
port(
  i_x            : in  std_logic_vector( 15 downto 0);  --(4,12)
  o_exp          : out std_logic_vector( 15 downto 0)); --(4,12)
end component exp_lut;

 
signal X_Minus_Y_Squared           : signed(37 downto 0); --(8,24)
signal output_sig		  : std_logic_vector(15 downto 0);
signal Negative_X_Minus_Y_Squared: signed(37 downto 0);
signal conc_for_Neg:std_logic_vector( 15 downto 0);
begin

X_Minus_Y_Squared   <= signed(diff) *  signed(diff);
Negative_X_Minus_Y_Squared <= to_signed(0,34) - signed(X_Minus_Y_Squared );
Output<= output_sig; -- (4,12)
conc_for_Neg<=std_logic_vector(Negative_X_Minus_Y_Squared(Negative_X_Minus_Y_Squared'HIGH)&Negative_X_Minus_Y_Squared(27 downto 13));
Exp: exp_lut port map ( conc_for_Neg , output_sig );     
END Arch_Kernel;