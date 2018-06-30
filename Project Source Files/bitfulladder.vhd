library ieee;
use ieee.std_logic_1164.all;

entity bitfulladder is
port
(a,b,cin:in std_logic;
f,cout:out std_logic
);
end entity bitfulladder;

architecture archbitfulladder of bitfulladder is
begin
f<= (a xor b) xor cin;
cout<= (a and b) or (cin and (a xor b));
end architecture archbitfulladder;