LIBRARY ieee;
USE ieee.std_logic_1164.all;

ENTITY mux2_Generic IS
	generic (
		WIDTH : integer := 8
	);
	
	PORT( in0,in1: IN std_logic_vector (width-1 DOWNTO 0);
	sel : IN std_logic;
	out1: OUT std_logic_vector (width-1 DOWNTO 0));
END mux2_Generic;

ARCHITECTURE arch_Generic OF mux2_Generic IS

	BEGIN

		out1 <= in0 WHEN sel = '0'
		ELSE in1;

END arch_Generic;
