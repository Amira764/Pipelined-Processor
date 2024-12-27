LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY pc_register IS
    PORT (
        clk     : IN std_logic;                               -- Clock signal
        rst     : IN std_logic;                               -- Reset signal 
		  stall   : in std_logic;
		  freeze  : IN std_logic;
        mux_op  : IN std_logic_vector(15 DOWNTO 0);           -- Input signal for PC
		  IM_0    : IN std_logic_vector(15 DOWNTO 0); 
        pc_out  : OUT std_logic_vector(15 DOWNTO 0)           -- Output PC value 
    );
END pc_register;

ARCHITECTURE behavior OF pc_register IS

    SIGNAL pc : std_logic_vector(15 DOWNTO 0) := (OTHERS => '0'); -- Internal PC signal
	 
BEGIN
    PROCESS (clk, rst)
    BEGIN
        IF rst = '1' THEN
            pc <= IM_0; -- Reset PC to zero
        ELSIF rising_edge(clk) and freeze ='0' and stall = '0' THEN
               pc <= mux_op;      
            END IF;
    END PROCESS;

    -- Output the current value of PC
    pc_out <= pc;

END behavior;
