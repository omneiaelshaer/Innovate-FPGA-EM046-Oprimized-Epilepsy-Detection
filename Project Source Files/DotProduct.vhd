LIBRARY IEEE;
USE IEEE.std_logic_1164.all;
USE IEEE.numeric_std.all;

ENTITY DotProduct IS 
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

END ENTITY DotProduct;

ARCHITECTURE Arch_DotProduct OF DotProduct IS


signal Feature1_Multiply: std_logic_vector((2*Feature_Width)+1 downto 0); --34 bits 
signal Feature2_Multiply: std_logic_vector((2*Feature_Width)+1 downto 0);
signal Feature3_Multiply: std_logic_vector((2*Feature_Width)+1 downto 0);

BEGIN

Feature1_Multiply <= std_logic_vector( signed(Input1(Input1'HIGH)&Input1) * signed(Input2(Input2'HIGH)&Input2));
Feature2_Multiply <= std_logic_vector( signed(Input3(Input3'HIGH)&Input3) * signed(Input4(Input4'HIGH)&Input4));
Feature3_Multiply <= std_logic_vector( signed(Input5(Input5'HIGH)&Input5) * signed(Input6(Input6'HIGH)&Input6));

Result <= std_logic_vector( signed(Feature1_Multiply) + signed(Feature2_Multiply) + signed (Feature3_Multiply) ); --(10,24) with overflow included
     
END Arch_DotProduct;