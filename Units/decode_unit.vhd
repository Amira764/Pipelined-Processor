LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;

ENTITY Decode_Unit IS
    PORT (
        -- Inputs
        clk                 : IN std_logic;                                  -- Clock signal
        rst                 : IN std_logic;                                  -- Reset signal
        mem_wb_write_en     : IN std_logic;                                  -- write enable		  
        input_port          : IN std_logic_vector(15 DOWNTO 0);              -- Input port data
		  rdst        			 : IN std_logic_vector(2 DOWNTO 0);               -- Destination register address
		  immediate    		 : IN std_logic_vector(15 DOWNTO 0);              -- Immediate value
		  rscr1        		 : IN std_logic_vector(2 DOWNTO 0);               -- Source register 1 address
		  rscr2        		 : IN std_logic_vector(2 DOWNTO 0);               -- Source register 2 address
		  opcode       		 : IN std_logic_vector(4 DOWNTO 0);               -- Opcode
		  reg_write_data      : IN std_logic_vector(15 DOWNTO 0);              -- Data Written Into the regsiter file
		  SP_in               : IN std_logic_vector(15 DOWNTO 0);
		  index               : IN std_logic;
		  stall               : IN std_logic;
		  rdst_pass				 : IN std_logic_vector(2 DOWNTO 0);

        -- Outputs
        data1           : OUT std_logic_vector(15 DOWNTO 0);             -- Data from source register 1
        data2           : OUT std_logic_vector(15 DOWNTO 0);             -- Data from source register 2
        rdst_out        : OUT std_logic_vector(2 DOWNTO 0);              -- Forwarded destination register address
		  rdata1_out		: OUT std_logic_vector(2 DOWNTO 0);
		  rdata2_out		: OUT std_logic_vector(2 DOWNTO 0);
		  control_signals : out std_logic_vector(23 downto 0);             -- Combined control signals output
		  flush1          : OUT std_logic
		  
--		  debug_reg_file : out reg_file_type       -- Debug port for register file
    );
END Decode_Unit;

ARCHITECTURE structural OF Decode_Unit IS
    -- Component Declaration for the Register File
    COMPONENT register_file
        GENERIC (
            NUM_REGISTERS : integer := 8;  -- Number of registers
            WIDTH         : integer := 16  -- Width of each register
        );
        PORT (
            Clk            : IN  std_logic;                              -- Clock signal
            Rst            : IN  std_logic;                              -- Reset signal
            write_enable   : IN  std_logic;                              -- Write enable signal
            write_addr     : IN  std_logic_vector(2 DOWNTO 0);           -- Address to write
            write_data     : IN  std_logic_vector(WIDTH-1 DOWNTO 0);     -- Data to write to the register
            read_addr1     : IN  std_logic_vector(2 DOWNTO 0);           -- Address to read (first register)
            read_addr2     : IN  std_logic_vector(2 DOWNTO 0);           -- Address to read (second register)
            read_data1     : OUT std_logic_vector(WIDTH-1 DOWNTO 0);     -- Data read from the first register
            read_data2     : OUT std_logic_vector(WIDTH-1 DOWNTO 0)      -- Data read from the second register
        );
    END COMPONENT;
	 
	 COMPONENT Control_Unit is
		 port (
			  rst             : in  std_logic;                        -- Reset signal
			  index           : in  std_logic; 
			  opcode          : in  std_logic_vector(4 downto 0);     -- 5-bit opcode input
			  control_signals : out std_logic_vector(23 downto 0)     -- Combined control signals output 
		 );
	 end COMPONENT;
	 
	 COMPONENT SP_Ex_Detector IS
    PORT (
        control_signals_in : IN std_logic_vector(23 DOWNTO 0);    -- Control Signals
        SP_in              : IN std_logic_vector(15 DOWNTO 0);   -- SP_out in design
        control_signals_out: OUT std_logic_vector(23 DOWNTO 0)   -- Control Signals
    );
	END COMPONENT;

    -- Internal Signals for Register File Connections
    SIGNAL read_data1_internal : std_logic_vector(15 DOWNTO 0);
    SIGNAL read_data2_internal : std_logic_vector(15 DOWNTO 0);
	 
	-- SP Detector Signals
	signal control_signals_in, control_signals_in2 : std_logic_vector(23 downto 0);

--	 TYPE reg_file_type IS ARRAY (0 TO 7) OF std_logic_vector(15 DOWNTO 0);


BEGIN


    Control_Unit_Inst: Control_Unit
        PORT MAP (rst, index, opcode, control_signals_in);
		  
	U_SP_Ex_Detector: SP_Ex_Detector
    PORT MAP (control_signals_in,SP_in, control_signals_in2);
		  
    -- Instantiate Register File
    register_file_inst : register_file
        GENERIC MAP (
            NUM_REGISTERS => 8,
            WIDTH => 16
        )
        PORT MAP (
            Clk          => clk,
            Rst          => rst,
            write_enable => mem_wb_write_en,    
            write_addr   => rdst,     
            write_data   => reg_write_data,     
            read_addr1   => rscr1,               -- Source register 1 address
            read_addr2   => rscr2,               -- Source register 2 address
            read_data1   => read_data1_internal, -- Data read from source register 1
            read_data2   => read_data2_internal  -- Data read from source register 2
        );
		  
--	-- Pass through or fetch values	
--	data1 <= SP_in when ((control_signals_in(5) = '1' or control_signals_in(6) = '1')and control_signals_in(1 downto 0) = "00") -- Push and Pop
--				else read_data1_internal;

		PROCESS(stall,read_data1_internal,read_data2_internal,rdst,control_signals_in2,rdst_pass,rscr1,rscr2)
		BEGIN
			  IF stall = '1' THEN
					-- When stall is active, output zeros
					data1           <= (others => '0');
					data2           <= (others => '0');
					rdata1_out      <= (others => '0');
					rdata2_out      <= (others => '0');
					rdst_out        <= (others => '0');
					control_signals <= (others => '0');
					flush1          <=  '0';
			  ELSE
					-- When stall is inactive, pass through or fetch values
					data1           <= read_data1_internal;
					data2           <= read_data2_internal;
					rdata1_out      <= rscr1;
					rdata2_out      <= rscr2;
					rdst_out        <= rdst_pass;
					control_signals <= control_signals_in2;
					if (control_signals_in2(3 downto 2) = "10") OR (control_signals_in2(1 downto 0) /= "00") then
						flush1 <= '1';
					else
					   flush1  <=  '0';
					end if;
			  END IF;
		END PROCESS;
			

END structural;
