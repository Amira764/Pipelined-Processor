LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL; -- Use only numeric_std for arithmetic operations

ENTITY SP_Ex_Detector IS
    PORT (
        control_signals_in : IN std_logic_vector(23 DOWNTO 0);    -- Control Signals
        SP_in              : IN std_logic_vector(15 DOWNTO 0);   -- SP_out in design
        control_signals_out: OUT std_logic_vector(23 DOWNTO 0)   -- Control Signals
    );
END SP_Ex_Detector;

ARCHITECTURE behavior OF SP_Ex_Detector IS

    signal new_sp_plus : std_logic;

BEGIN

		 process (control_signals_in, SP_in)
			  variable sp_temp : unsigned(15 downto 0); -- Temporary variable for SP calculations
		 begin
			  -- Convert SP_in to an unsigned type for arithmetic operations
			  sp_temp := unsigned(SP_in);		  

			  -- Comparator, AND, MUX logic
			  if sp_temp = to_unsigned(4095, 16) and control_signals_in(6) = '1' then  -- 2^12-1 exception
					new_sp_plus <= '0';
					control_signals_out <= "000000000000000000001000"; 
--					control_signals_out <= control_signals_in(21 downto 18) & '0' &control_Signals_in(16 downto 7) & '0' & control_Signals_in(5 downto 4) & "10" & control_signals_in(1 downto 0); --edit ex_Res
			  else
					new_sp_plus <= control_signals_in(6);
					control_signals_out <= control_signals_in;
			  end if;

			  -- Check SP_plus (bit 6) and SP_minus (bit 5) and perform the respective operations
--			  if new_sp_plus = '1' then
--					sp_temp := sp_temp + 1; -- Increment SP
--			  elsif control_signals_in(5) = '1' then --sp_minus
--					sp_temp := sp_temp - 1; -- Decrement SP
--			  else
--					sp_temp := sp_temp;
--			  end if;

        -- Convert back to std_logic_vector and assign to SP_out
--        SP_out <= std_logic_vector(sp_temp);

    end process;

END behavior;
