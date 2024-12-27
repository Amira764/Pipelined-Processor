library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity processor is
    Port (
	     clk        : in  STD_LOGIC;
        rst        : in  STD_LOGIC;
        input_port : in  STD_LOGIC_VECTOR (15 downto 0);
        output_port : out  STD_LOGIC_VECTOR (15 downto 0)
    );
end processor;

architecture Behavioral of processor is

--	 TYPE reg_file_type IS ARRAY (0 TO 7) OF std_logic_vector(15 DOWNTO 0);

	component fetch_unit is
		 port (
			  rst         : in std_logic;                             -- Reset signal
			  clk         : in std_logic;                             -- Clock signal
			  stall       : in std_logic;
			  control_signals_in: in std_logic_vector(23 downto 0);         -- Data Memory [SP]
			  control_signals_in2: in std_logic_vector(23 downto 0);   -- Control Signals from execute
			  freeze_flag : in std_logic; 
			  New_PC      : in std_logic_vector(15 downto 0);         -- New PC input
			  reg         : in std_logic_vector(15 downto 0);         -- Register value input
			  DM_SP       : in std_logic_vector(15 downto 0);         -- Data Memory [SP]
			  instruction : out std_logic_vector(15 downto 0);        -- 16-bit instruction output
			  immediate   : out std_logic_vector(15 downto 0);        -- Immediate value output
			  pc_new      : out std_logic_vector(15 downto 0);         -- Updated PC output
			  flush_signal : out std_logic_vector(1 downto 0)
		 );
	end component;

	component Decode_Unit IS
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
			  rdata1_out		: OUT std_logic_vector(2 DOWNTO 0);
			  rdata2_out		: OUT std_logic_vector(2 DOWNTO 0);
			  rdst_out        : OUT std_logic_vector(2 DOWNTO 0);              -- Forwarded destination register address
			  control_signals : out std_logic_vector(23 downto 0);              -- Combined control signals output 
			  flush1          : OUT std_logic
--			  debug_reg_file : out reg_file_type       -- Debug port for register file
		 );
	END component;

	component Execute_Unit IS
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
	END component;

	component Memory_Unit IS
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
	END component;

	component Writeback_Unit IS
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
	END component;
	
	component Hazard_Detection_Unit IS
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
	END component;
	
	component Stall_Unit IS
    PORT (
        -- Inputs
        FD_data1     : IN std_logic_vector(2 downto 0);  -- Rs from IF/ID pipeline register
        FD_data2     : IN std_logic_vector(2 downto 0);  -- Rt from IF/ID pipeline register
        D_EX_Rd      : IN std_logic_vector(2 downto 0);  -- Rd from ID/EX pipeline register
        D_EX_MemRead : IN std_logic;                     -- MemRead from ID/EX pipeline register
		  stall_in     : IN std_logic;
        
        -- Outputs
        stall        : OUT std_logic                        -- Stall signal (1 if hazard detected)
    );
	END component;
	
	component Flush_Unit IS
    PORT (
        -- Inputs
        clk                  : IN std_logic;                     -- Clock signal
        rst                  : IN std_logic;                     -- Reset signal
        d_ex_control_signal  : IN std_logic_vector(23 downto 0); -- Control signals from D/EX stage
        ex_mem_control_signal : IN std_logic_vector(23 downto 0); -- Control signals from EX/MEM stage
        
        -- Outputs
        flush_signal         : OUT std_logic_vector(1 downto 0)  -- Flush signal
    );
	END component;
	
	
	component instruction_memory is
    port(
        clk          : in std_logic;                             -- Clock signal
        rst          : in std_logic;                             -- Reset signal
        pc_out       : in std_logic_vector(15 downto 0);         -- 16-bit Program Counter (lower 12 bits used)
        instruction  : out std_logic_vector(15 downto 0);        -- 16-bit instruction output
        immediate    : out std_logic_vector(15 downto 0);        -- 16-bit immediate value output
        has_imm      : out std_logic                             -- Indicates if there is an immediate value
    );
	end component;
	
	
	 component registers is
	  GENERIC ( WIDTH : integer := 8);
	  port(
			Clk    : in  std_logic;
			rst    : in  std_logic;
			d      : in  std_logic_vector(WIDTH-1 downto 0);
			q      : out std_logic_vector(WIDTH-1 downto 0)
	  );
	end component;
	
	
	component SP_register IS
		generic (
			WIDTH : integer := 8
		);
	PORT( Clk, rst	: IN std_logic;
		  d : IN std_logic_vector (WIDTH-1 downto 0);
		  q 		: OUT std_logic_vector (WIDTH-1 downto 0));
	END component;
	
	component pipeline_registers IS
	generic (
		WIDTH : integer := 8
	);
	PORT( Clk, rst	: IN std_logic;
		  d : IN std_logic_vector (WIDTH-1 downto 0);
		  q 		: OUT std_logic_vector (WIDTH-1 downto 0));
	END component;
	
	component flush_pipeline_registers IS
		generic (
			WIDTH : integer := 8
		);
	PORT( Clk, rst	: IN std_logic;
		  flush : IN std_logic_vector(1 downto 0); 
		  d : IN std_logic_vector (WIDTH-1 downto 0);
		  q 		: OUT std_logic_vector (WIDTH-1 downto 0));
	END component;
	
	component flush_pipeline_registers2 IS
		generic (
			WIDTH : integer := 8
		);
	PORT( Clk, rst	: IN std_logic;
		  flush : IN std_logic_vector(1 downto 0); 
		  d : IN std_logic_vector (WIDTH-1 downto 0);
		  q 		: OUT std_logic_vector (WIDTH-1 downto 0));
	END component;
	
	component registers_singlebit IS
	PORT( Clk, rst 	: IN std_logic;
		  d : IN std_logic;
				q 		: OUT std_logic);
	END component;
	
	component stall_pipeline_registers IS
	generic (
		WIDTH : integer := 8
	);
	PORT( Clk, rst, stall     : IN std_logic;
		  flush : IN std_logic_vector(1 downto 0); 
		  d : IN std_logic_vector (WIDTH-1 downto 0);
		  q 		: OUT std_logic_vector (WIDTH-1 downto 0));
	END component;


	 -- Signals to connect the components
    signal new_pc       : std_logic_vector(15 downto 0);
    signal instruction  : std_logic_vector(15 downto 0);
    signal immediate    : std_logic_vector(15 downto 0);
    signal data1        : std_logic_vector(15 downto 0);
    signal data2        : std_logic_vector(15 downto 0);
    signal input_port_out  : std_logic_vector(15 downto 0);
    signal rdst_out, rdata1_out, rdata2_out     : std_logic_vector(2 downto 0);
    signal imm_out      : std_logic_vector(15 downto 0);
    signal control_signals : std_logic_vector(23 downto 0); --decode changes it
	 signal control_signals2 : std_logic_vector(23 downto 0); --execute changes it
    signal alu_result   : std_logic_vector(15 downto 0);
    signal read_data    : std_logic_vector(15 downto 0);
    signal mem_data     : std_logic_vector(15 downto 0);
    signal regwrite_data : std_logic_vector(15 downto 0);
    signal mem_wb_write_en : std_logic;
	 
	 -- Control Register Signals
	 signal ccr_reg_out_execute 	  : std_logic_vector(2 downto 0); --input
	 signal ccr_reg_out : std_logic_vector(2 downto 0); --output
	 signal ccr_reg_in  : std_logic_vector(2 downto 0);
	 
	 -- Output/Peripheral Handling Signals
	 signal internal_output_port, WB_output_port : std_logic_vector(15 downto 0); --to not affect the actual output port until writeback
	 
	 -- Special Purpose Registers
	 signal SP, SP_out : std_logic_vector(15 downto 0); -- Stack Pointer
	 signal EPC, EPC_out : std_logic_vector(15 downto 0); -- Exception Program Counter
	 
	 -- Fetch Decode Signals
	 signal FD_PC, FD_input, FD_imm, FD_Instr  : std_logic_vector(15 downto 0); 
	 
	 -- Decode Execute Signals
	 signal DE_PC, DE_input, DE_imm, DE_R1, DE_R2 : std_logic_vector(15 downto 0); 
	 signal DE_Rdst, DE_Rdata1_address, DE_Rdata2_address : std_logic_vector(2 downto 0); 
	 signal DE_Ctrl : std_logic_vector(23 downto 0); 
	 
	 -- Execute Memory Signals
	 signal EM_PC, EM_input, EM_imm, EM_R1, EM_ALU_Res : std_logic_vector(15 downto 0); 
	 signal EM_Rdst : std_logic_vector(2 downto 0); 
	 signal EM_Ctrl : std_logic_vector(23 downto 0);
	 signal EM_CCR  : std_logic_vector (2 downto 0);
	 
	 -- Memory WriteBack Signals
	 signal MW_Read_Data, MW_input, MW_imm, MW_ALU_Res, MW_output,output,EM_R,reg_in : std_logic_vector(15 downto 0); 
	 signal MW_Rdst : std_logic_vector(2 downto 0); 
	 signal MW_Ctrl : std_logic_vector(23 downto 0);
	 signal MW_CCR,CCR_temp  : std_logic_vector(2 downto 0); 
--	 signal debug_reg_file : reg_file_type; -- Internal signal for debugging

	 signal forwardA, forwardB : std_logic_vector(1 downto 0); 
	 signal stall, flush1, flush2 :	std_logic;
	 signal stall_in :	std_logic;
	 signal flush, flush_in,flush_out1,flush_out2    : std_logic_vector(1 downto 0); 
	 

begin

		flush_out2 <= "00";
		flush_in <= "00";

		-- Fetch Decode Pipeline Registers
		 PC_F_D:           stall_pipeline_registers generic map (16) port map(clk,rst,stall,flush_out2, new_pc,FD_PC);
		 Input_Port_F_D:   stall_pipeline_registers generic map (16) port map(clk,rst,stall,flush_out2,input_port,FD_input);
		 Imm_F_D:          stall_pipeline_registers generic map (16) port map(clk,rst,stall,flush_out2,immediate,FD_imm);
		 Current_Instr_FD: stall_pipeline_registers generic map (16) port map(clk,rst,stall,flush_out2,instruction,FD_Instr);
		 
		 -- Decode Execute Pipeline Registers
		 PC_D_E:          flush_pipeline_registers generic map (16) port map(clk,rst,flush,FD_PC,DE_PC);
		 Input_Port_D_E:  flush_pipeline_registers generic map (16) port map(clk,rst,flush,FD_input,DE_input);
		 Imm_D_E:         flush_pipeline_registers generic map (16) port map(clk,rst,flush,FD_imm,DE_imm);
		 Rsrc1_D_E:       flush_pipeline_registers generic map (16) port map(clk,rst,flush,data1,DE_R1);
		 Rsrc2_D_E:       flush_pipeline_registers generic map (16) port map(clk,rst,flush,data2,DE_R2);
		 Rdst_D_E:        flush_pipeline_registers generic map (3) port map(clk,rst,flush,rdst_out,DE_Rdst);
		 Rdata1_add_D_E:  flush_pipeline_registers generic map (3) port map(clk,rst,flush,rdata1_out,DE_Rdata1_address);
		 Rdata2_add_D_E:  flush_pipeline_registers generic map (3) port map(clk,rst,flush,rdata2_out,DE_Rdata2_address);
		 Control_D_E:     flush_pipeline_registers generic map (24) port map(clk,rst,flush,control_signals,DE_Ctrl);
		 
		 -- Execute Memory Pipeline Registers
		 PC_E_M:          flush_pipeline_registers2 generic map (16) port map(clk,rst,flush,DE_PC,EM_PC);
		 Input_Port_E_M:  flush_pipeline_registers2 generic map (16) port map(clk,rst,flush,DE_input,EM_input);
		 Imm_E_M:         flush_pipeline_registers2 generic map (16) port map(clk,rst,flush,DE_imm,EM_imm);
		 Rsrc1_E_M:       flush_pipeline_registers2 generic map (16) port map(clk,rst,flush,EM_R,EM_R1);
		 Rdst_E_M:        flush_pipeline_registers2 generic map (3) port map(clk,rst,flush,DE_Rdst,EM_Rdst);
		 Alu_res_E_M:     flush_pipeline_registers2 generic map (16) port map(clk,rst,flush,alu_result,EM_ALU_Res);
		 Control_E_M:     flush_pipeline_registers2 generic map (24) port map(clk,rst,flush,control_signals2,EM_Ctrl);
		 CCR_E_M:         flush_pipeline_registers2 generic map (3) port map(clk,rst,flush,ccr_reg_out_execute,EM_CCR);
		 
		 -- Memory WriteBack Pipeline Registers
		 Read_Data_M_W:   pipeline_registers generic map (16) port map(clk,rst,read_data,MW_Read_Data);
		 Input_Port_M_W:  pipeline_registers generic map (16) port map(clk,rst,EM_input,MW_input);
		 Imm_M_W:         pipeline_registers generic map (16) port map(clk,rst,EM_imm,MW_imm);
		 Output_Port_M_W: pipeline_registers generic map (16) port map(clk,rst,output,MW_output);
		 Rdst_M_W:        pipeline_registers generic map (3) port map(clk,rst,EM_Rdst,MW_Rdst);
		 Alu_res_M_W:     pipeline_registers generic map (16) port map(clk,rst,EM_ALU_Res,MW_ALU_Res);
		 Control_M_W:     pipeline_registers generic map (24) port map(clk,rst,EM_Ctrl,MW_Ctrl);
		 CCR_M_W:         pipeline_registers generic map (3) port map(clk,rst,CCR_temp,MW_CCR);
		 
		 stall_register:     registers_singlebit port map(clk,rst,stall,stall_in);
--		 flush_register :    pipeline_registers GENERIC MAP (2) port map (clk, rst, flush_in, flush_out2);
--		 flush_register2 :    registers GENERIC MAP (2) port map (clk, rst, flush_in, flush_out1);

		 -- Instantiate CCR (Condition Code Register)
		 CCR_reg_inst : registers GENERIC MAP (WIDTH => 3) port map (clk, rst, MW_CCR, ccr_reg_out);

		 -- Instantiate SP register
		 SP_reg_inst : SP_register GENERIC MAP (WIDTH => 16) port map (clk, rst, SP, SP_out);

		 -- Instantiate EPC register
		 EPC_reg_inst : registers GENERIC MAP (WIDTH => 16) port map (clk, rst, EPC, EPC_out);

    -- Instantiate the Fetch Unit
	Fetch_Unit_Inst : fetch_unit
		 port map (
			  rst                => rst,                 -- Reset signal
			  clk                => clk,                 -- Clock signal
			  stall              => stall,
			  control_signals_in => EM_Ctrl,             -- Control Signals
			  control_signals_in2=> DE_Ctrl,
			  freeze_flag 			=> control_signals(4),  -- freeze from decode
			  New_PC             => new_pc,              -- New PC input
			  reg                => reg_in,               -- Register value input
			  DM_SP              => MW_Read_Data,        -- Data Memory [SP]
			  instruction        => instruction,         -- 16-bit instruction output
			  immediate          => immediate,           -- Immediate value output
			  pc_new             => new_pc,               -- Updated PC output
			  flush_signal       => flush
		 );

	
    -- Instantiate the Decode Unit
    decode_unit_inst : component Decode_Unit
        port map (
            clk                 => clk,
            rst                 => rst,
            mem_wb_write_en     => MW_Ctrl(19),
            input_port          => FD_input,
            rdst                => MW_Rdst,           				    -- Dist bits
            immediate           => FD_imm,                 			    -- output of fetch
            rscr1               => FD_Instr(10 downto 8),  				 -- Placeholder for actual source register 1
            rscr2               => FD_Instr(7 downto 5),  				 -- Placeholder for actual source register 2
            opcode              => FD_Instr(15 downto 11),            -- Placeholder for opcode
				reg_write_data      => regwrite_data,       					 -- Data Written Into the regsiter file
            SP_in               => SP_out, 									 --from SP_Reg 
				index               => FD_Instr(0),
				stall               => stall,
				rdst_pass			  => FD_Instr(4 downto 2),
				data1               => data1,
            data2               => data2,
				rdata1_out          => rdata1_out,
				rdata2_out          => rdata2_out,
            rdst_out            => rdst_out,
            control_signals     => control_signals,
				flush1              => flush1				
--				debug_reg_file      => debug_reg_file     -- Debug port for register file
        );

    -- Instantiate the Execute Unit
	execute_unit_inst : component Execute_Unit
		 port map (
			  clk                  => clk,                   -- Clock signal
			  rst                  => rst,                   -- Reset signal
			  data1                => DE_R1,                 -- Data from source register 1 (or immediate, based on decode)
			  data2                => DE_R2,                 -- Data from source register 2
			  imm                  => DE_imm,                -- Immediate value (decoded from instruction)
			  control_signals_in   => DE_Ctrl,               -- Combined control signals (from Decode stage) 
			  control_signals_in2  => EM_Ctrl,
			  CCR_in 		        => EM_CCR,
			  forwardA				  => forwardA,
			  forwardB		        => forwardB,
			  ALU_FWD		        => EM_ALU_Res,
			  Mem_FWD		        => MW_Read_Data,
			  ALUResult_MEM_FWD    => MW_ALU_Res,
			  input_port           => EM_input,
		     write_input          => EM_Ctrl(18 downto 17),
			  Mem_wb_imm           => MW_imm,
			  Ex_Mem_imm           => EM_imm,
			  alu_result           => alu_result,            -- ALU result
			  control_signals_out  => control_signals2,       -- Forwarded control signals
			  CCR                  => ccr_reg_out_execute,      -- Condition Code Register (to be updated with status)
			  EM_R                 => EM_R,
			  flush2               => flush2
		 );

		 
    -- Instantiate the Memory Unit
	memory_unit_inst : component Memory_Unit		 
		 PORT MAP (
			  -- Inputs
			  clk                 => clk,                                 -- Clock signal
			  rst                 => rst,                                   -- Reset signal
			  new_pc              => EM_PC,                -- New Program Counter
			  alu_result          => EM_ALU_Res,              -- ALU result                               
			  control_signals_in  => EM_Ctrl,               -- Combined control signals output
			  SP_data        		 => SP_out,              -- SP Data
			  Rsrc1          		 => EM_R1,             -- Rsrc1
			  CCR_in         		 => EM_CCR,
			  EM_R1               => EM_R1,
			  forwardA            => forwardA,
			  
			
			  -- Outputs
			  read_data      		 => read_data,             -- Read data from memory
			  SP_out         		 => SP,
			  CCR_out        		 => CCR_temp,
			  output_port         => output
		 );
		 
    -- Instantiate the Writeback Unit
    writeback_unit_inst : component Writeback_Unit
        port map (
            alu_result         => MW_ALU_Res,
            imm                => MW_imm,
            mem_data           => MW_Read_Data,
            input_port_data    => MW_input,
            output_port_in     => output,
				output_port        => WB_output_port,
            control_signals_in => MW_Ctrl,
            regwrite_data      => regwrite_data
        );
		  
	hazard_detection_unit_inst :  component Hazard_Detection_Unit
		port map(
        -- Inputs
        d_ex_data1       		 => DE_Rdata1_address,
        d_ex_data2       		 => DE_Rdata2_address,
        ex_mem_rd        		 => EM_Rdst,
        ex_mem_reg_write 		 => EM_Ctrl(19),
        mem_wb_rd        		 => MW_Rdst,
        mem_wb_reg_write 		 => MW_Ctrl(19),
		  mem_wb_mem_read        => MW_Ctrl(23),
        -- Outputs
        forwardA         		 => forwardA,
        forwardB         		 => forwardB
    );
	 
	 stall_unit_inst : component Stall_Unit
    PORT map(
        -- Inputs
        FD_data1     			=> FD_Instr(10 downto 8),  -- Rs from IF/ID pipeline register
        FD_data2              => FD_Instr(7 downto 5),  -- Rt from IF/ID pipeline register
        D_EX_Rd               => DE_Rdst,  -- Rd from ID/EX pipeline register
        D_EX_MemRead          => DE_Ctrl(23),                    -- MemRead from ID/EX pipeline register
		  stall_in              => stall_in,
        
        -- Outputs
        stall                 => stall                        -- Stall signal (1 if hazard detected)
    );
	 
	 process(control_signals2, control_signals) --to check if exception happened from control signals out of decode and execute
		 begin
				if control_signals2(3 downto 2) = "10" or control_signals2(3 downto 2) = "11" then --in decode
					EPC <= DE_PC;
				elsif control_signals(3 downto 2) = "10" or control_signals(3 downto 2) = "11" then --in execute
					EPC <= FD_PC;
				end if;
		 end process;
		 
	process(EM_R,EM_R1,forwardA)
		begin
		if (forwardA = "01") then
				reg_in <= EM_R;
		else 
			reg_in <=EM_R1;
		end if;
	end process;
	 
--	 flush_unit_inst : component Flush_Unit 
--    PORT map(
--        -- Inputs
--        clk                   => clk,                    -- Clock signal
--        rst                   => rst,                    -- Reset signal
--        d_ex_control_signal   => DE_Ctrl,                -- Control signals from D/EX stage
--        ex_mem_control_signal => EM_Ctrl,                -- Control signals from EX/MEM stage
--        
--        -- Outputs
--        flush_signal          => flush                   -- Flush signal
--    );
--	 
--	     process(flush1,flush2)
--				begin
--					if(flush2 = '1') then
--						flush_in <= "11";
--					elsif (flush1 = '1') then
--					   flush_in <= "10";
--					else
--						flush_in <= "00";
--					end if;
--		  end process;
--		  
--		  process(flush_out1,flush_out2)
--				begin
--					if(flush_out1 = "11") or (flush_out2 = "11")   then
--						flush <= "11";
--					elsif (flush_out1 = "10") or (flush_out2 = "10") then
--					   flush <= "10";
--					else
--						flush <= "00";
--					end if;
--		  end process;
		  
		  Output_port_register: registers generic map (16) port map(clk,rst,WB_output_port,output_port);

    -- Output port update process
--    process (Clk, Rst)
--    begin
--        if (Rst = '1') then
--            output_port <= (others => '0'); -- Reset output port to 0
--			end if;
--    end process;

end Behavioral;