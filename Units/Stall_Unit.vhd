LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY Stall_Unit IS
    PORT (
        -- Inputs
        FD_data1     : IN std_logic_vector(2 downto 0);  -- Rs from IF/ID pipeline register
        FD_data2     : IN std_logic_vector(2 downto 0);  -- Rt from IF/ID pipeline register
        D_EX_Rd      : IN std_logic_vector(2 downto 0);  -- Rd from ID/EX pipeline register
        D_EX_MemRead : IN std_logic;                     -- MemRead from ID/EX pipeline register
		  stall_in     : IN std_logic;                       -- Stall signal (1 if hazard detected)
        
        -- Outputs
        stall        : OUT std_logic                        -- Stall signal (1 if hazard detected)
    );
END Stall_Unit;

ARCHITECTURE Behavioral OF Stall_Unit IS
BEGIN
    PROCESS (FD_data1, FD_data2, D_EX_Rd, D_EX_MemRead, stall_in)
    BEGIN
        -- Default: No stall
        stall <= '0';
		  if (stall_in = '1') then
				stall <= '0';
		  else
			  -- Check for Load-Use Hazard
			  IF (D_EX_MemRead = '1') THEN
					IF (FD_data1 = D_EX_Rd) OR (FD_data2 = D_EX_Rd) THEN
						 stall <= '1';  -- Hazard detected, trigger stall
					END IF;
			  END IF;
		  END IF;	

    END PROCESS;

END Behavioral;
