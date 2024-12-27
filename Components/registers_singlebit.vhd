LIBRARY ieee;
USE ieee.std_logic_1164.all;

ENTITY registers_singlebit IS
PORT( Clk, rst 	: IN std_logic;
	  d : IN std_logic;
			q 		: OUT std_logic);
END registers_singlebit;

ARCHITECTURE myarch1 OF registers_singlebit IS 
BEGIN
	PROCESS (Clk,rst)
	BEGIN
		IF(Rst = '1') THEN
				q <=  '0';
		else
				IF falling_edge(Clk) THEN
						q <= d;
				END IF;	
		END IF;
	END PROCESS;
END myarch1;