LIBRARY ieee;
USE ieee.std_logic_1164.all;

ENTITY mux2 IS
	PORT ( IN1,IN2,SEL:  IN std_logic;
		  OUT1        : OUT  std_logic);
END ENTITY mux2;

ARCHITECTURE  arch1 OF mux2 IS
BEGIN
  
   out1 <= (in1 and (not sel)) 
                     or 
                     (in2 and sel);

END arch1;
