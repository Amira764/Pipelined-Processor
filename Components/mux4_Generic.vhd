LIBRARY ieee;
USE ieee.std_logic_1164.all;

ENTITY mux4_Generic IS
	generic (
		WIDTH : integer := 8
	);
	
	PORT( in0,in1,in2,in3: IN std_logic_vector (width-1 DOWNTO 0);
	sel : IN std_logic_vector (1 DOWNTO 0);
	out1: OUT std_logic_vector (width-1 DOWNTO 0));
END mux4_Generic;

ARCHITECTURE arch_Generic OF mux4_Generic IS

	BEGIN

		out1 <= in0 WHEN sel(1) = '0' AND sel(0) ='0'
		ELSE in1 WHEN sel(1) = '0' AND sel(0) ='1'
		ELSE in2 WHEN sel(1) = '1' AND sel(0) ='0'
		ELSE in3;

END arch_Generic;
