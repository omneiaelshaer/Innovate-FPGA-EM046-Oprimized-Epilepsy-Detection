library ieee;
use ieee.std_logic_1164.all;

entity bithalfadder is
port
(a,b:in std_logic;
f,cout:out std_logic
);
end entity bithalfadder;

architecture archbithalfadder of bithalfadder is
begin
f<= a xor b;
cout<= a and b;
end architecture archbithalfadder;