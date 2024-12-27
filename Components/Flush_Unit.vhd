LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;

ENTITY Flush_Unit IS
    PORT (
        -- Inputs
        clk                  : IN std_logic;                     -- Clock signal
        rst                  : IN std_logic;                     -- Reset signal
        d_ex_control_signal  : IN std_logic_vector(23 downto 0); -- Control signals from D/EX stage
        ex_mem_control_signal : IN std_logic_vector(23 downto 0); -- Control signals from EX/MEM stage
        
        -- Outputs
        flush_signal         : OUT std_logic_vector(1 downto 0)  -- Flush signal
    );
END Flush_Unit;

ARCHITECTURE Behavioral OF Flush_Unit IS
BEGIN
    -- Determine flush_signal based on conditions
    PROCESS(clk, rst, d_ex_control_signal, ex_mem_control_signal)
    BEGIN
        IF rst = '1' THEN
            flush_signal <= "00"; -- Reset flush_signal
        ELSE
            -- Check EX/MEM conditions first
            IF (ex_mem_control_signal(1 downto 0) = "01") AND (ex_mem_control_signal(11 downto 10) /= "00") THEN  -- Case JMP condt
						flush_signal <= "11";
				ELSIF ex_mem_control_signal(3 downto 2) = "11" THEN   -- Case Load Exception
						flush_signal <= "11";
				ELSIF (d_ex_control_signal(3 downto 2) = "10") OR (d_ex_control_signal(1 downto 0) /= "00") THEN  -- Case Stack Exception OR (JMP/ CALL/ RET/ INT/ RTI)
						flush_signal <= "10";
				ELSE 
						flush_signal <= "00";
				END IF;
		  END IF;
    END PROCESS;

END Behavioral;

