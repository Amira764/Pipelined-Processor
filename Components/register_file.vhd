LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;

ENTITY register_file IS
    GENERIC (
        NUM_REGISTERS : integer := 8;  -- Number of registers
        WIDTH         : integer := 16  -- Width of each register
    );
    PORT (
        Clk            : IN  std_logic;                                       -- Clock signal
        Rst            : IN  std_logic;                                       -- Reset signal
        write_enable   : IN  std_logic;                                       -- Write enable signal
        write_addr     : IN  std_logic_vector(2 DOWNTO 0);                    -- Address to write
        write_data     : IN  std_logic_vector(WIDTH-1 DOWNTO 0);              -- Data to write to the register
        read_addr1     : IN  std_logic_vector(2 DOWNTO 0);                    -- Address to read (first register)
        read_addr2     : IN  std_logic_vector(2 DOWNTO 0);                    -- Address to read (second register)
        read_data1     : OUT std_logic_vector(WIDTH-1 DOWNTO 0);              -- Data read from the first register
        read_data2     : OUT std_logic_vector(WIDTH-1 DOWNTO 0)               -- Data read from the second register
    );
END register_file;

ARCHITECTURE Behavioral OF register_file IS
--    TYPE register_array IS ARRAY (0 TO NUM_REGISTERS-1) OF std_logic_vector(WIDTH-1 DOWNTO 0);
	 TYPE register_array IS ARRAY (0 TO NUM_REGISTERS-1) OF std_logic_vector(WIDTH-1 DOWNTO 0);
	 SIGNAL registers : register_array := (OTHERS => (OTHERS => '0')); -- Initialize registers to 0

BEGIN
    -- Write operation
    PROCESS (Clk, Rst,registers)
    BEGIN
        IF (Rst = '1') THEN
            --registers <= (OTHERS => (OTHERS => '0')); -- Reset all registers to 0
				 registers <= (
                "0000000000001010",   -- Register 0 (Dummy data)
                "0000000000000101",   -- Register 1 (Dummy data)
					 
                "0000000000000011",   -- Register 2 (Dummy data)
                "0000000000010100",   -- Register 3 (Dummy data)
                "0000000000000101",   -- Register 4 (Dummy data)
                "0000000000000110",   -- Register 5 (Dummy data)
                "0000000000000111",   -- Register 6 (Dummy data)
                "0000000000001111"    -- Register 7 (Dummy data)
            );
        ELSIF rising_edge(Clk) THEN
            IF write_enable = '1' THEN
                -- Write to the selected register
                registers(to_integer(unsigned(write_addr))) <= write_data;
            END IF;
		 END IF;
            -- Read operations
				 read_data1 <= registers(to_integer(unsigned(read_addr1))); -- Read data from the first register
				 read_data2 <= registers(to_integer(unsigned(read_addr2))); -- Read data from the second register
    END PROCESS;

END Behavioral;
