library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity instruction_memory is
    port(
        clk          : in std_logic;                             -- Clock signal
        rst          : in std_logic;                             -- Reset signal
        pc_out       : in std_logic_vector(15 downto 0);         -- 16-bit Program Counter (lower 12 bits used)
        pc_im        : in std_logic_vector(15 downto 0);         -- Takes address for instruction_pc
        instruction  : out std_logic_vector(15 downto 0);        -- 16-bit instruction output
        immediate    : out std_logic_vector(15 downto 0);        -- 16-bit immediate value output
        instruction_pc : out std_logic_vector(15 downto 0);      -- 16-bit instruction fetched from pc_im
		intruction_zero : out std_logic_vector(15 downto 0); 
        instruction_3 : out std_logic_vector(15 downto 0);
        has_imm      : out std_logic                             -- Indicates if there is an immediate value
    );
end instruction_memory;

architecture behavioral of instruction_memory is
    -- 4K x 16-bit memory array
    type ram_type is array(0 to 4095) of std_logic_vector(15 downto 0);
    signal memory : ram_type := (others => (others => '0'));  -- Initialize all locations to zeros

    signal address : integer range 0 to 4095;  -- Internal signal for address conversion (pc_out)
    signal address_pc_im : integer range 0 to 4095; -- Internal signal for address conversion (pc_im)

begin
    -- Address Conversion
    address <= to_integer(unsigned(pc_out(11 downto 0)));      -- Address based on `pc_out`
    address_pc_im <= to_integer(unsigned(pc_im(11 downto 0))); -- Address based on `pc_im`

--		--IN R0
--		--LDM R1, 10
--		--ADD R2, R1, R0
--		--STD R2, 5(R0)
--		--LDD R3, 5(R0)
--		--OUT R3
--		--CALL R3
--
----	 	memory(0) <= "0000000000000101";  -- START POINT
----		
----		memory(1) <= "0000000000000000";  -- NOP
----		memory(2) <= "0000000000000000";  -- NOP 
----		memory(3) <= "0000000000000000";  -- NOP
----		memory(4) <= "0000000000000000";  -- NOP 
----		
----		memory(5) <= "0011000000000000";  -- IN R0
----		memory(6) <= "1001000000000110";  -- NOP
----		memory(7) <= "0000000000001010";  -- NOP
----		memory(8) <= "0100100100001000";  -- NOP
----		memory(9) <= "1010001000000010";  -- NOP 
----		memory(10) <= "0000000000000101"; -- JC
----		
----		memory(11) <= "1001100000001110"; -- NOP
----		memory(12) <= "0000000000000101"; -- NOP
----		memory(13) <= "0010101100000000"; -- NOP
----		
----		memory(14) <= "1110001100000000"; -- NOP 
--		-----------------------------------------
--		
--		
--		memory(0) <= "0000000000000101";  -- START POINT
--		
--		memory(1) <= "0000000000001011";  -- empty stack
--		memory(2) <= "0000000000010100";  -- invalid address 20
--		
--		memory(3) <= "0000000000000000";  -- NOP
--		memory(4) <= "0000000000000000";  -- NOP 
--		
----		memory(5) <= "1010001000100010";  -- STD put 3 in mkan ghalat 3yzah mayktbsh fl memory brdo
----		memory(6) <= "0000000000000000";  -- 0
--		
--		memory(5) <= "0011000000000000";  -- ldd
--		memory(6) <= "0010000000000100";  -- offset
--		
----		memory(5) <= "0000000000000000";  -- PUSH
----		memory(6) <= "0000000000000000";  -- NOP 
--		
--		memory(7) <= "0100100000100000";  -- add
--		memory(8) <= "0100111100100000";  -- NOP
--		memory(9) <= "0100111100100000";  -- POP
--		memory(10) <="0001000000000000";  -- NOP
--		
--		memory(11) <= "1101000100000000"; -- SUB (empty stack)
--		memory(12) <= "0100100000100000"; -- ADD (invalid address) 1101 f R4		
--		memory(13) <= "0100100000100000";  -- POP
--		memory(14) <= "0000000000000000";  -- NOP
--		memory(15) <= "0000000000000000";  -- POP
--		memory(16) <= "0000000000000000";  -- NOP
--		memory(17) <= "0000000000000000"; -- SUB (empty stack)
--		memory(18) <= "0000000000000000"; -- ADD (invalid address) 1101 f R4	
--		memory(19) <= "0000000000000000";  -- POP
--		memory(20) <= "0100111010110000";  -- ADD (invalid address) 1101 f R4	

		
		

    -- Read Memory
    process(address, address_pc_im)
    begin
        -- Fetch the current instruction based on pc_out
        instruction <= memory(address);

        -- Determine if the instruction has an immediate value
        has_imm <= memory(address)(1);  -- Second least significant bit of instruction

        -- Fetch the immediate value only if has_imm = 1
        if memory(address)(1) = '1' then
            immediate <= memory(address + 1);
        else
            immediate <= (others => '0');  -- Set immediate to all zeros
        end if;

        -- Fetch the instruction based on pc_im for instruction_pc output
        instruction_pc <= memory(address_pc_im);
    end process;
	 
	 intruction_zero <= memory(0);
     instruction_3   <= memory(3);

end behavioral;
