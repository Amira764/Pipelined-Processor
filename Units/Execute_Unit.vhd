LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;

ENTITY Execute_Unit IS
    PORT (
        -- Inputs
        clk          : IN std_logic;                                  -- Clock signal
        rst          : IN std_logic;                                  -- Reset signal
        data1        : IN std_logic_vector(15 DOWNTO 0);              -- Data from source register 1
        data2        : IN std_logic_vector(15 DOWNTO 0);              -- Data from source register 2
        imm          : IN std_logic_vector(15 DOWNTO 0);              -- Immediate value
		  control_signals_in : IN std_logic_vector(23 downto 0);             -- Combined control signals output
		  control_signals_in2 : IN std_logic_vector(23 downto 0);
		  CCR_in 		: in std_logic_vector(2 downto 0);
		  forwardA		: in std_logic_vector(1 downto 0);
		  forwardB		: in std_logic_vector(1 downto 0);
		  ALU_FWD		: in std_logic_vector(15 downto 0);
		  Mem_FWD		: in std_logic_vector(15 downto 0);
		  ALUResult_MEM_FWD  : in std_logic_vector(15 downto 0);
		  input_port         : in std_logic_vector(15 downto 0);
		  write_input        : in std_logic_vector(1 downto 0); 
		  Mem_wb_imm         : in std_logic_vector(15 downto 0);
		  Ex_Mem_imm         : in std_logic_vector(15 downto 0);
        -- Outputs
        alu_result   : OUT std_logic_vector(15 DOWNTO 0);             -- ALU result
        control_signals_out : out std_logic_vector(23 downto 0);             -- Combined control signals output
		  CCR : out std_logic_vector(2 downto 0);
		  EM_R : OUT std_logic_vector(15 DOWNTO 0); 
		  flush2          : OUT std_logic
    );
END Execute_Unit;

ARCHITECTURE Behavioral OF Execute_Unit IS
    -- Component Declaration for ALU
    COMPONENT ALU
        GENERIC (
            WIDTH : integer := 16
        );
        PORT (
            S : IN std_logic_vector(2 DOWNTO 0);
            In1, In2 : IN std_logic_vector(WIDTH-1 DOWNTO 0);
            Cin : IN std_logic;
            F : OUT std_logic_vector(WIDTH-1 DOWNTO 0);
--            Cout : OUT std_logic;
				 CCR : out std_logic_vector(2 downto 0)
        );
    END COMPONENT;
	 
		component mux4_Generic IS
			generic (
				WIDTH : integer := 8
			);
			
			PORT( in0,in1,in2,in3: IN std_logic_vector (width-1 DOWNTO 0);
			sel : IN std_logic_vector (1 DOWNTO 0);
			out1: OUT std_logic_vector (width-1 DOWNTO 0));
		END component;


    -- Internal signals
    SIGNAL alu_cout : std_logic;
    SIGNAL mux_out1, mux_out2: std_logic_vector(15 DOWNTO 0);
	 SIGNAL alu_result_sig : std_logic_vector(15 DOWNTO 0);  -- ALU result signal
	 SIGNAL ccr_sig, alu_ccr : std_logic_vector(2 DOWNTO 0);         -- CCR signal
	 
	 signal sel_mux4_inst2: std_logic_vector(1 downto 0);
	 signal mux_data1,mux_data2,mux_data3 : std_logic_vector(15 DOWNTO 0); 
	 signal control_signals_changed : std_logic_vector(23 downto 0);
	 signal is_std : std_logic_vector(2 downto 0);
	 signal is_LDD : std_logic_vector(2 downto 0);
	 

BEGIN
			

			control_signals_changed(23 downto 4) <= control_signals_in(23 downto 4);
			
			is_std <= control_signals_in(5) & control_signals_in(6) & control_signals_in(22); --001 if std
			is_LDD <= control_signals_in(18 downto 16); --101 if LDD
			
		  mux_data1 <= data2 WHEN (is_std = "001") ELSE data1;	
		  mux_data3 <= ALU_FWD when (write_input /= "11") else input_port;
		 --  because of std: not(sp_plus or sp_minus) and mem_write 
		  
    -- Instantiate mux4_Generic for selecting data1
    mux4_inst1 : mux4_Generic
        GENERIC MAP (
            WIDTH => 16  -- Set the width of the mux
        )
        PORT MAP (
            in0 => mux_data1,        	-- First input: data1_input
            in1 => mux_data3,    -- Second input: Zeroes
            in2 => ALUResult_MEM_FWD,    			-- Third input: alu
            in3 => Mem_FWD,    			-- Fourth input: memory
            sel => forwardA,           -- Mux select signal  
            out1 => mux_out1           -- Mux output  (Input1 of ALU)
        );
		  
		mux_data2 <= data2 WHEN (control_signals_in(16) = '0' ) ELSE imm;
		
    -- Instantiate mux4_Generic for selecting data2
    mux4_inst2 : mux4_Generic
        GENERIC MAP (
            WIDTH => 16  -- Set the width of the mux
        )
        PORT MAP (
            in0 => mux_data2,      		   -- First input: data2_input
            in1 => mux_data3,    	 			-- Second input: imm
            in2 => ALUResult_MEM_FWD,    			-- Third input: alu
            in3 => Mem_FWD,    			-- Fourth input: memory
            sel => forwardB,     -- Mux select signal  
            out1 => mux_out2           -- Mux output  (Input1 of ALU)
        );
		  
		   -- ALU instantiation
    ALU_inst : ALU
        GENERIC MAP (
            WIDTH => 16
        )
        PORT MAP (
            S => control_signals_in(15 downto 13),              -- ALU operation
            In1 => mux_out1,             -- ALU input 1
            In2 => mux_out2,           -- ALU input 2 (selected by mux)
            Cin => '0',               -- Carry-in set to 0 for this design
            F => alu_result_sig,          -- ALU result
--            Cout => alu_cout,          -- ALU carry-out (not used in this implementation)
				 CCR => alu_ccr
        );
		  
		  
	PROCESS (alu_result_sig, alu_cout, control_signals_in, CCR_in, control_signals_in2)
	BEGIN  
		ccr_sig <= CCR_in;
				 -- Default assignment: carry over existing CCR values

				 -- CCR[2] = Carry Flag (if alu_cout = '1')
				 IF ( control_signals_in(9) = '1') THEN
					  ccr_sig(2) <= alu_ccr(2);
				 END IF;

				 -- CCR[0] = Zero Flag (if alu_result = 0)
				 IF ( control_signals_in(7) = '1') THEN
					  ccr_sig(0) <= alu_ccr(0);
				 END IF;

				 -- CCR[1] = Negative Flag (if alu_result is negative)
				 IF (control_signals_in(8) = '1') THEN
					  ccr_sig(1) <= alu_ccr(1);
				 END IF;

				 -- Check Jump Condition Flags and reset corresponding CCR bits
				 IF (CCR_in(0) = '1' AND control_signals_in(11 DOWNTO 10) = "01") THEN  -- JZ
					  ccr_sig(0) <= '0';
					  control_signals_changed(1 DOWNTO 0) <= "01";
				 ELSIF (CCR_in(1) = '1' AND control_signals_in(11 DOWNTO 10) = "10") THEN -- JN
					  ccr_sig(1) <= '0';
					  control_signals_changed(1 DOWNTO 0) <= "01";
				 ELSIF (CCR_in(2) = '1' AND control_signals_in(11 DOWNTO 10) = "11") THEN -- JC
					  ccr_sig(2) <= '0';
					  control_signals_changed(1 DOWNTO 0) <= "01";
				 ELSE
					  control_signals_changed(1 DOWNTO 0) <= control_signals_in(1 DOWNTO 0);
				 END IF;
				 
				 IF (to_integer(unsigned(alu_result_sig)) > 4095) and ((is_std = "001") or (is_LDD = "101")) then --invalid memory address exception
					 control_signals_changed(3 downto 2) <= "11"; 
					 control_signals_changed(1 downto 0) <= "11";
				 ELSE
					 control_signals_changed(3 downto 2) <= control_signals_in(3 downto 2);		
				 END IF;
				 
				 IF (control_signals_in(1 downto 0) = "01") AND (control_signals_in(11 downto 10) /= "00") THEN  -- Case JMP condt
						flush2 <= '1';
				 ELSIF control_signals_in(3 downto 2) = "11" THEN   -- Case Load Exception
						flush2 <= '1';
				 else
						flush2 <= '0';
				 end if;
		 
	END PROCESS;

	-- Outputs
	control_signals_out <= control_signals_changed;
	alu_result <= alu_result_sig;
	CCR <= ccr_sig;
	
	EM_R <= Mem_wb_imm WHEN forwardA = "10" else 
	        Ex_Mem_imm when forwardA = "01" else data1 ;



END Behavioral;
