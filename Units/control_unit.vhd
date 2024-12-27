library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity Control_Unit is
    port (
        rst             : in  std_logic;                        -- Reset signal
		  index           : in  std_logic;
        opcode          : in  std_logic_vector(4 downto 0);     -- 5-bit opcode input
		  control_signals : out std_logic_vector(23 downto 0)     -- Combined control signals output 
    );
end Control_Unit;

architecture behavioral of Control_Unit is

begin
    -- Process for controlling outputs based on opcode and reset
    process (rst, opcode)
    begin
		if rst = '1' then
			 -- Reset all 2-bit outputs to "00"
			control_signals <= "000000000000000000000000";

        else
            -- values based on opcode
			case opcode is
				 -- NOP (00000)
				 when "00000" =>          
					control_signals <= "000000000000000000000000";

				 -- HLT (00001)
				 when "00001" => 
					control_signals <= "000000000000000000010000";

				 -- SETC (00010)
				 when "00010" =>
					control_signals <= "000000001100001000000000";

				 -- NOT (00011)
				 when "00011" =>
					control_signals <= "000010000100000110000000";

				 -- INC (00100)
				 when "00100" =>
					control_signals <= "000010001000001110000000";

				 -- OUT (00101)
				 when "00101" =>
					control_signals <= "000100000000000000000000";
					
				 -- IN (00110)
				 when "00110" =>
					control_signals <= "000011100000000000000000";

				 -- MOV (01000)
				 when "01000" =>
					control_signals <= "000010001010000000000000";

				 -- ADD (01001)
				 when "01001" =>
					control_signals <= "000010000000001110000000";

				 -- SUB (01010)
				 when "01010" =>
					control_signals <= "000010000010001110000000";
				 
				 -- AND (01011)
				 when "01011" =>
					control_signals <= "000010000110000110000000";

				 -- IADD (01100)
				 when "01100" =>
					control_signals <= "000010010000001110000000";

				 -- PUSH (10000)
				 when "10000" =>
					control_signals <= "010000000000000000100000";

				 -- POP (10001)
				 when "10001" =>
					control_signals <= "100011000000000001000000";

				 -- LDM (10010)
				 when "10010" =>
					control_signals <= "000010100000000000000000";

				 -- LDD (10011)
				 when "10011" =>
					control_signals <= "100011010000000000000000";

				 -- STD (10100)
				 when "10100" =>
					control_signals <= "010000010000000000000000";

				 -- JZ (11000)
				 when "11000" =>
					control_signals <= "000000000000010010000000";

				 -- JN (11001)
				 when "11001" =>
					control_signals <= "000000000000100100000000";

				 -- JC (11010)
				 when "11010" =>
					control_signals <= "000000000000111000000000";

				 -- JMP (11011)
				 when "11011" =>
					control_signals <= "000000000001000000000001";

				 -- CALL (11100)
				 when "11100" =>
					control_signals <= "011000000000000000100001";

				 -- RET (11101)
				 when "11101" =>
					control_signals <= "100000000000000001000010";

				 -- INT (11110)
				 when "11110" =>
					control_signals <= "011000000000000000100" & index & "11";

				 -- RTI (11111)
				 when "11111" =>
					control_signals <= "100000001110001111000010";
					  
				 -- Others: Default case
				 when others =>
					control_signals <= "000000000000000000000000";
			end case;
        end if;
    end process;


			-- bit 21: Mem_Read
		  -- bit 20: Mem_Write
		  -- bit 19: Mem_Write_Sel
		  -- bit 18: WEN_out
		  -- bit 17: Reg_Write
		  -- bit 16: Reg_Write_Sel (1)
		  -- bit 15: Reg_Write_Sel (0)
		  -- bit 14: ALU_Src
		  -- bit 13: ALU_Sel (2)
		  -- bit 12: ALU_Sel (1)
		  -- bit 11: ALU_Sel (0)
		  -- bit 10: JMP
		  -- bit  9: JMP_Cond (1)
		  -- bit  8: JMP_Cond (0)
		  -- bit  7: Flag_Write
		  -- bit  6: SP_plus
		  -- bit  5: SP_minus
		  -- bit  4: Freeze
		  -- bit  3: Ex_Res (1)
		  -- bit  2: Ex_Res (0)
		  -- bit  1: PC_Chng (1)
		  -- bit  0: PC_Chng (0)

end behavioral;