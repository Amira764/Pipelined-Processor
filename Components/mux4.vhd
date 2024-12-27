LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

ENTITY mux4 IS
PORT( 
    in0, in1, in2, in3 : IN std_logic;
    sel : IN std_logic_vector(1 DOWNTO 0);
    out1 : OUT std_logic
);
END mux4;

ARCHITECTURE arch1 OF mux4 IS
BEGIN
   out1 <= in0 WHEN sel(0) = '0' AND sel(1) = '0' 
           ELSE in1 WHEN sel(0) = '0' AND sel(1) = '1' 
           ELSE in2 WHEN sel(0) = '1' AND sel(1) = '0' 
           ELSE in3;
END arch1;
