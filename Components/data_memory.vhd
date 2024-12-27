library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity data_memory is 
	generic( 
			address_bits : integer := 12; 
			word_width : integer := 16 ); 
	port( 
			clk 		: in std_logic; 
			rst		: in std_logic; 
			we 		: in std_logic; 
--			mem_read : in std_logic;
			address_bus_read 	: in std_logic_vector(address_bits-1 downto 0);
			address_bus_write : in std_logic_vector(address_bits-1 downto 0);
			write_in	        	: in std_logic_vector(word_width-1 downto 0); 
			port_read	 	   : out std_logic_vector(word_width-1 downto 0)
		);
end data_memory; 

architecture behavioral of data_memory is 
	type ram_type is array((2**address_bits)-1 downto 0) of std_logic_vector(word_width-1 downto 0); 
	signal memory : ram_type := (OTHERS => (OTHERS => '0')); -- Initialize memory to 0;
	begin 

		process(clk, rst) 
		begin 
			if(rst = '1') then
				for loc in 0 to (2**address_bits) - 1 loop
				
					memory(loc) <= (others => '0');
					memory(1) <= "0000000000000101"; 
--					memory(6) <= "0000000000000000"; 
--					memory(7) <= "0000000000000101"; 
					
				end loop;
			elsif clk'event and clk = '1' then 
				if we='1' then 
					memory(to_integer(unsigned(address_bus_write))) <= write_in; 
				end if; 
			end if;
		end process; 

		port_read <= memory(to_integer(unsigned(address_bus_read)));
		
--		port_read <= memory(to_integer(unsigned(address_bus_read))) when mem_read = '1' else (others => '0');
		
end architecture;

