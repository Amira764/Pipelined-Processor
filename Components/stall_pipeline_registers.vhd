LIBRARY ieee;
USE ieee.std_logic_1164.all;

ENTITY stall_pipeline_registers IS
	generic (
		WIDTH : integer := 8
	);
PORT( Clk, rst, stall	: IN std_logic;
     flush : IN std_logic_vector(1 downto 0); 
	  d : IN std_logic_vector (WIDTH-1 downto 0);
	  q 		: OUT std_logic_vector (WIDTH-1 downto 0));
END stall_pipeline_registers;

ARCHITECTURE myarch1 OF stall_pipeline_registers IS 
BEGIN
	PROCESS (Clk,rst)
	BEGIN
		IF(Rst = '1')THEN
				q <= (others => '0');				
		elsIF falling_edge(Clk) and stall = '0' THEN
		      if(flush = "00") then
					q <= d;
				elsif (flush = "10") or (flush = "11") then
					q <= (others => '0');	
				end if;
		END IF;
	END PROCESS;
END myarch1;