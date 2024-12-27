LIBRARY ieee;
USE ieee.std_logic_1164.all;

ENTITY flush_pipeline_registers2 IS
	generic (
		WIDTH : integer := 8
	);
PORT( Clk, rst	: IN std_logic;
     flush : IN std_logic_vector(1 downto 0); 
	  d : IN std_logic_vector (WIDTH-1 downto 0);
	  q 		: OUT std_logic_vector (WIDTH-1 downto 0));
END flush_pipeline_registers2;

ARCHITECTURE myarch1 OF flush_pipeline_registers2 IS 
BEGIN
	PROCESS (Clk,rst)
	BEGIN
		IF(Rst = '1')THEN
				q <= (others => '0');
		elsIF falling_edge(Clk) THEN
            if(flush = "00") or (flush = "10") then
					q <= d;
				elsif (flush = "11") then
					q <= (others => '0');	
				end if;
		END IF;
	END PROCESS;
END myarch1;