LIBRARY ieee;
USE ieee.std_logic_1164.all;

ENTITY registers IS
	generic (
		WIDTH : integer := 8
	);
PORT( Clk, rst	: IN std_logic;
	  d : IN std_logic_vector (WIDTH-1 downto 0);
	  q 		: OUT std_logic_vector (WIDTH-1 downto 0));
END registers;

ARCHITECTURE myarch1 OF registers IS 
BEGIN
	PROCESS (Clk,rst)
	BEGIN
		IF(Rst = '1') THEN
				q <= (others => '0');
		else
				IF rising_edge(Clk) THEN
						q <= d;
				END IF;	
		END IF;
	END PROCESS;
END myarch1;