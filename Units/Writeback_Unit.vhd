LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

ENTITY Writeback_Unit IS
    PORT (
        -- Inputs
        alu_result     : IN  std_logic_vector(15 DOWNTO 0);    -- ALU result
        imm            : IN  std_logic_vector(15 DOWNTO 0);    -- Immediate value
        mem_data       : IN  std_logic_vector(15 DOWNTO 0);    -- Memory data
        input_port_data: IN  std_logic_vector(15 DOWNTO 0);    -- Input port data
		  output_port_in : IN  std_logic_vector(15 DOWNTO 0);    -- Output port data   (Data1)
		  control_signals_in : in std_logic_vector(23 downto 0);             -- Combined control signals input

        -- Outputs
        regwrite_data  : OUT std_logic_vector(15 DOWNTO 0);    -- Data to be written to the register
        output_port    : OUT std_logic_vector(15 DOWNTO 0)    -- Output port (conditionally updated)		 
    );
END Writeback_Unit;

ARCHITECTURE Behavioral OF Writeback_Unit IS

    -- Instantiate the 4-input mux to choose between the ALU result, imm, mem_data, or input port data
    COMPONENT mux4_Generic IS
        GENERIC (
            WIDTH : integer := 16
        );
        PORT (
            in0  : IN std_logic_vector(WIDTH-1 DOWNTO 0);
            in1  : IN std_logic_vector(WIDTH-1 DOWNTO 0);
            in2  : IN std_logic_vector(WIDTH-1 DOWNTO 0);
            in3  : IN std_logic_vector(WIDTH-1 DOWNTO 0);
            sel  : IN std_logic_vector(1 DOWNTO 0);
            out1 : OUT std_logic_vector(WIDTH-1 DOWNTO 0)
        );
    END COMPONENT;

    -- Internal signal for mux output
    SIGNAL mux_out : std_logic_vector(15 DOWNTO 0);

BEGIN

    -- Instantiate the 4-input mux to select the writeback data
    mux_inst : mux4_Generic
        GENERIC MAP (WIDTH => 16)
        PORT MAP (
            in0  => alu_result,            -- ALU result
            in1  => imm,                   -- Immediate value
            in2  => mem_data,              -- Data from memory
            in3  => input_port_data,       -- Input port data
            sel  => control_signals_in(18 downto 17),          -- Selection signal (2-bit)
            out1 => mux_out                -- Output of the mux
        );

    -- Output the selected writeback data
    regwrite_data <= mux_out;         -- Data to be written to the register

    -- Conditional assignment for output_port based on wen_out
    PROCESS(control_signals_in(20), output_port_in)
    BEGIN
        IF control_signals_in(20) = '1' THEN
            output_port <=  output_port_in;  -- Update output_port when wen_out is 1
		  ELSE
			output_port <= (others => '0');  -- Define what happens when wen_out is 0	
        END IF;
    END PROCESS;

END Behavioral;
