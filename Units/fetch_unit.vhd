library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity fetch_unit is
    port (
        rst         : in std_logic;                             -- Reset signal
        clk         : in std_logic;                             -- Clock signal
		  stall       : in std_logic;
		  control_signals_in : in std_logic_vector(23 downto 0);   -- Control Signals from execute
		  control_signals_in2: in std_logic_vector(23 downto 0);   -- Control Signals from execute
		  freeze_flag : in std_logic;                             -- from decode

        New_PC      : in std_logic_vector(15 downto 0);         -- New PC input
        reg         : in std_logic_vector(15 downto 0);         -- Register value input
        DM_SP       : in std_logic_vector(15 downto 0);         -- Data Memory [SP]
		  
        instruction : out std_logic_vector(15 downto 0);        -- 16-bit instruction output
        immediate   : out std_logic_vector(15 downto 0);        -- Immediate value output
        pc_new      : out std_logic_vector(15 downto 0);         -- Updated PC output
		  flush_signal : out std_logic_vector(1 downto 0)
    );
end fetch_unit;

architecture structural of fetch_unit is

    -- Internal PC Signals
    signal pc_logic_out, pc_reg_out, pc_im,incremented_pc : std_logic_vector(15 downto 0);      -- Output from pc_logic, pc_register, signal for IM[i]
	 
    signal has_imm        : std_logic;                          -- Immediate flag from instruction_memory
    signal instruction_mem_out : std_logic_vector(15 downto 0);  -- Output from instruction memory
    signal immediate_mem_out   : std_logic_vector(15 downto 0);  -- Immediate value from instruction memory

    -- Internal signals for MUX and logic
    signal comp_op        : std_logic;                        -- Comparator result
    signal pc_chng_new    : std_logic_vector(1 downto 0);     -- 2x1 MUX output
    signal IM             : std_logic_vector(15 downto 0);    -- 4x1 MUX output
	signal IM_0            : std_logic_vector(15 downto 0);    -- 4x1 MUX output
	signal IM_3            : std_logic_vector(15 downto 0);
    signal increment_value : std_logic_vector(15 downto 0);   -- Value selected by the MUX
	signal pc_chng         : std_logic_vector(1 downto 0);

    -- Instantiating the instruction memory component
	component instruction_memory is
		 port(
			  clk          : in std_logic;                             -- Clock signal
			  rst          : in std_logic;                             -- Reset signal
			  pc_out       : in std_logic_vector(15 downto 0);         -- 16-bit Program Counter (lower 12 bits used)
			  pc_im        : in std_logic_vector(15 downto 0);         -- Takes address for instruction_pc
			  instruction  : out std_logic_vector(15 downto 0);        -- 16-bit instruction output
			  immediate    : out std_logic_vector(15 downto 0);        -- 16-bit immediate value output
			  instruction_pc : out std_logic_vector(15 downto 0);      -- 16-bit instruction fetched from pc_im
			  intruction_zero : out std_logic_vector(15 downto 0); 
			  instruction_3   : out std_logic_vector(15 downto 0); 
			  has_imm      : out std_logic                             -- Indicates if there is an immediate value
		 );
	end component;
	 
	 -- Instantiating the registers component for the PC register
	component pc_register IS

		 PORT (
			  clk     : IN std_logic;                               -- Clock signal
			  rst     : IN std_logic;                               -- Reset signal
			  stall   : in std_logic;
			  freeze  : IN std_logic;
			  mux_op  : IN std_logic_vector(15 DOWNTO 0);           -- Input signal for PC
			  IM_0    : IN std_logic_vector(15 DOWNTO 0); 
			  pc_out  : OUT std_logic_vector(15 DOWNTO 0)           -- Output PC value
		 );
		 
	END component;

begin

	-- Instantiate instruction_memory
	Instruction_Memory_Inst : instruction_memory
		 port map (
			  clk            => clk,               -- Clock signal
			  rst            => rst,               -- Reset signal
			  pc_out         => pc_reg_out,        -- PC output connected to the main PC register output
			  pc_im          => pc_im,             -- PC immediate address signal (for fetching specific instructions)
			  instruction    => instruction_mem_out, -- Instruction fetched from memory
			  immediate      => immediate_mem_out,   -- Immediate value fetched from memory
			  instruction_pc => IM,                  -- Instruction fetched at address `pc_im`
			  intruction_zero => IM_0, 
			  instruction_3   => IM_3,
			  has_imm        => has_imm              -- Immediate flag indicating the presence of an immediate value
		 );

    -- Instruction Memory Logic (Fetch the instruction and immediate value)
    process (rst,instruction_mem_out,immediate_mem_out)
    begin
        if rst = '1' then
            instruction <= (others => '0');
            immediate <= (others => '0');
        else
            -- Update instruction and immediate values
            instruction <= instruction_mem_out;
            immediate <= immediate_mem_out;
        end if;
    end process;
	 
	 pc_chng_new <= control_signals_in2(1 downto 0) when control_signals_in(11 downto 10) = "00" else control_signals_in(1 downto 0);
	 flush_signal <= "00" when pc_chng_new = "00" else
	                 "10" when control_signals_in(11 downto 10) = "00" else
						  "11";
						  
--		 pc_chng_new <= control_signals_in(1 downto 0);
    -- Second MUX: 4-to-1 MUX for Instruction Memory Selection
	process (control_signals_in(3 downto 2), instruction_mem_out)
	begin
		 -- Select the correct value for pc_reg_out based on Ex_Res
		 case control_signals_in(3 downto 2) is --ExRes set to get IM[i]
			  when "00" => 
					pc_im <= IM_3;  -- Assuming this value should be in hexadecimal format
			  when "01" => 
					pc_im <= std_logic_vector(unsigned(IM_3)+1);
			  when "10" => 
					pc_im <= x"0001";
			  when others => 
					pc_im <= x"0002";
		 end case;

	end process;


    -- Third MUX: 4-to-1 MUX for PC Source Selection
    process (pc_chng_new, incremented_pc, reg, DM_SP, IM)
    begin
        case pc_chng_new is
            when "00" => pc_logic_out <= incremented_pc;
            when "01" => pc_logic_out <= reg;
            when "10" => pc_logic_out <= DM_SP;
            when others => pc_logic_out <= IM;
        end case;
    end process;
	 
	 
	 -- Instantiate the PC register (16 bits)
    PC : pc_register port map (clk, rst, stall, freeze_flag, pc_logic_out, IM_0 , pc_reg_out);
	 
    -- PC Update: Updates the PC with +1 or +2 based on has_imm flag
    increment_value <= x"0001" when has_imm = '0' else x"0002";

	-- PC Update: Updates the PC with +1 or +2 based on has_imm flag
	process (rst, increment_value, pc_reg_out, control_signals_in)
		 variable pc_value : unsigned(15 downto 0);
		 variable increment : unsigned(15 downto 0);
	begin
		 if rst = '1' then
			  -- When reset is active, take the value of IM_0
			  pc_new <= pc_reg_out;
			  incremented_pc <= (others => '0');
		 elsif freeze_flag = '1' then
			  -- When freeze is active, hold the current value of PC
			  pc_new <= pc_reg_out;
			  incremented_pc <= pc_reg_out;
		 else
			  -- Otherwise, update pc_new based on pc_value + increment
			  pc_value := unsigned(pc_reg_out);
			  increment := unsigned(increment_value);
			  incremented_pc <=  std_logic_vector(pc_value + increment);
			  pc_new <= std_logic_vector(pc_value + increment);
				
			  
		 end if;
	end process;

end structural;
