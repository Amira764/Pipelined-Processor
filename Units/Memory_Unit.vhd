LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY Memory_Unit IS
    PORT (
        -- Inputs
        clk            : IN  std_logic;                                  -- Clock signal
        rst            : IN  std_logic;                                  -- Reset signal
        new_pc         : IN  std_logic_vector(15 DOWNTO 0);              -- New Program Counter
        alu_result     : IN  std_logic_vector(15 DOWNTO 0);              -- ALU result                               
		  control_signals_in : in std_logic_vector(23 downto 0);           -- Combined control signals output
		  SP_data        : IN  std_logic_vector(15 DOWNTO 0);              -- SP Data
		  Rsrc1          : IN  std_logic_vector(15 DOWNTO 0);              -- Rsrc1
		  CCR_in         : IN std_logic_vector(2 downto 0);
		  EM_R1          : IN  std_logic_vector(15 DOWNTO 0);
		  forwardA       : IN std_logic_vector(1 downto 0);
		  
		
        -- Outputs
        read_data      : OUT std_logic_vector(15 DOWNTO 0);              -- Read data from memory
		  SP_out         : OUT std_logic_vector(15 DOWNTO 0);
		  CCR_out        : OUT std_logic_vector(2 downto 0);
		  output_port    : OUT std_logic_vector(15 DOWNTO 0)
    );
END Memory_Unit;

ARCHITECTURE Behavioral OF Memory_Unit IS

    -- Memory component instantiation
    COMPONENT data_memory IS
        GENERIC (
            address_bits : integer := 12;
            word_width   : integer := 16
        );
        PORT (
            clk            : IN  std_logic;
            rst            : IN  std_logic;
            we             : IN  std_logic;
            address_bus_read  : IN  std_logic_vector(address_bits-1 DOWNTO 0);
            address_bus_write : IN  std_logic_vector(address_bits-1 DOWNTO 0);
            write_in       : IN  std_logic_vector(word_width-1 DOWNTO 0);
--				mem_read       : in std_logic;
            port_read      : OUT std_logic_vector(word_width-1 DOWNTO 0)
        );
    END COMPONENT;

    -- Mux to select between ALU result and new PC
    COMPONENT mux2_Generic IS
        GENERIC (
            WIDTH : integer := 16
        );
        PORT (
            in0  : IN std_logic_vector(WIDTH-1 DOWNTO 0);
            in1  : IN std_logic_vector(WIDTH-1 DOWNTO 0);
            sel  : IN std_logic;
            out1 : OUT std_logic_vector(WIDTH-1 DOWNTO 0)
        );
    END COMPONENT;

    -- Internal signals
    SIGNAL mux_out : std_logic_vector(15 DOWNTO 0);  -- Mux output for selecting data to write to memory
	 signal mem_read_address: std_logic_vector(11 DOWNTO 0);
	 signal mem_write_address : std_logic_vector(11 DOWNTO 0);
	 signal mem_read_data : std_logic_vector(15 DOWNTO 0);
	 signal int_pc_ccr : std_logic_vector(15 DOWNTO 0);
	 signal write_en : std_logic; --to_stop writing in case of exception

BEGIN
	
	 int_pc_ccr <= CCR_in & '0' & new_pc(11 downto 0);
    -- Instantiate the mux2 to choose between ALU result and new PC
    mux_inst : mux2_Generic
        GENERIC MAP (WIDTH => 16)
        PORT MAP (
            in0  => Rsrc1, -- Data1 (Rsrc1)
            in1  => int_pc_ccr, --dayman bn7ott el flags bs msh dymn hn.restore them         
            sel  => control_signals_in(21), -- Control signal to choose Rsrc1 or new PC
            out1 => mux_out
        );
		  
		  
	-- Update mem_read_address based on conditions
    PROCESS (control_signals_in, SP_data, alu_result)
    BEGIN
			-- PC_CHng and MEM_Read or SP plus or SP minus
        IF ((control_signals_in(1 DOWNTO 0) = "10") or control_signals_in(6) = '1' or control_signals_in(5) = '1')THEN 
            mem_read_address <= SP_data(11 downto 0);   -- Use SP_data i) the condition is met
				mem_write_address <= SP_data(11 downto 0);
				-- Check SP_plus (bit 6) and SP_minus (bit 5) and perform the respective operations
				  if control_signals_in(6) = '1' then
						SP_out <= std_logic_vector(unsigned(SP_data)+1); -- Increment SP
				  elsif control_signals_in(5) = '1' then --sp_minus
						SP_out <= std_logic_vector(unsigned(SP_data)-1); -- Decrement SP
				  else
						SP_out <= SP_data;
				  end if;
        ELSE 
            mem_read_address <= alu_result(11 DOWNTO 0);  -- Default to ALU result address
				mem_write_address <= alu_result(11 DOWNTO 0);
				SP_out <= SP_data;
        END IF;
    END PROCESS;

	 
	  -- 0 when ex_res detects invalid address or the default input otherwise
	  write_en <= '0' when control_signals_in(3 downto 2) = "11" else control_signals_in(22);

	  
    -- Instantiate the data memory
    data_mem_inst : data_memory
        GENERIC MAP (
            address_bits => 12,
            word_width   => 16
        )
        PORT MAP (
            clk               => clk,
            rst               => rst,
            we                => write_en, --hane7tag nemna3 da lw fi exception
            address_bus_read  => mem_read_address,
            address_bus_write => mem_write_address,
--				address_bus_write => alu_result (11 downto 0),
            write_in          => mux_out,   -- Data from mux to write into memory
--				mem_read          => control_signals_in(20);
            port_read         => mem_read_data  -- Data read from memory
        );
		  
	 PROCESS (mem_read_data, CCR_in)
      BEGIN
			read_data <= mem_read_data;
		   IF control_signals_in(15 downto 13) = "111" THEN  --Flags Restored RTI 
				CCR_out <= mem_read_data(15 downto 13);
			ELSE
				CCR_out <= CCR_in;
		   END IF;
	 END PROCESS;
	 process(forwardA,alu_result,EM_R1,mem_read_data)
		begin
			 IF forwardA = "00" THEN
				  output_port <= EM_R1;
			 ELSIF forwardA = "01" THEN
				  output_port <= EM_R1;
			 ELSIF forwardA = "11" THEN
				  output_port <= mem_read_data;
			 ELSE
				  output_port <= (others => '0'); -- Default case (optional, for completeness)
			 END IF;
	 end process;
						 

END Behavioral;
