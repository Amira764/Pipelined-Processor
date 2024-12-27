LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;

ENTITY Hazard_Detection_Unit IS
    PORT (
        -- Inputs
        d_ex_data1       			: IN std_logic_vector(2 downto 0); -- ID/EX.Rs	Address
        d_ex_data2       			: IN std_logic_vector(2 downto 0); -- ID/EX.Rt	Address	
        ex_mem_rd        			: IN std_logic_vector(2 downto 0); -- EX/MEM.Rd	Address
        ex_mem_reg_write 			: IN std_logic;                   -- EX/MEM.RegWrite
        mem_wb_rd        			: IN std_logic_vector(2 downto 0); -- MEM/WB.Rd	Address
        mem_wb_reg_write 			: IN std_logic;                   -- MEM/WB.RegWrite
		  mem_wb_mem_read          : IN std_logic; 

        -- Outputs
        forwardA         			: OUT std_logic_vector(1 downto 0);
        forwardB         			: OUT std_logic_vector(1 downto 0)
    );
END Hazard_Detection_Unit;

ARCHITECTURE Behavioral OF Hazard_Detection_Unit IS
BEGIN
    PROCESS(d_ex_data1, d_ex_data2, ex_mem_rd, ex_mem_reg_write, mem_wb_rd, mem_wb_reg_write)
    BEGIN
        -- Default values
        forwardA <= "00";
        forwardB <= "00";

        -- Check for EX/MEM hazards
        IF (ex_mem_reg_write = '1') THEN
            IF ex_mem_rd = d_ex_data1 THEN
                forwardA <= "01";
            END IF;
            IF ex_mem_rd = d_ex_data2 THEN
                forwardB <= "01";
            END IF;
        END IF;

        -- Check for MEM/WB hazards (only if no EX/MEM hazard)
        IF (mem_wb_reg_write = '1'  ) THEN
            IF (mem_wb_rd = d_ex_data1) AND 
               NOT ((ex_mem_reg_write = '1') AND (ex_mem_rd = d_ex_data1)) THEN
					 IF(mem_wb_mem_read = '1') THEN 
							forwardA <= "11";
					 ELSE
							forwardA <= "10";
					 END IF;
            END IF;
            IF (mem_wb_rd = d_ex_data2) AND 
               NOT ((ex_mem_reg_write = '1') AND (ex_mem_rd = d_ex_data2)) THEN
                IF(mem_wb_mem_read = '1') THEN 
							forwardB <= "11";
					 ELSE
							forwardB <= "10";
					 END IF;
            END IF;
        END IF;
    END PROCESS;
END Behavioral;
