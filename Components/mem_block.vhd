library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity mem_block is 
	generic( 
		address_bits : integer := 3; 
		word_width : integer := 8 ); 
	port( 
		clk 		: in std_logic; 
		rst		: in std_logic; 
		we 		: in std_logic; 
		address_bus_read0 	: in std_logic_vector(address_bits-1 downto 0);
		address_bus_read1 	: in std_logic_vector(address_bits-1 downto 0);
		address_bus_write 	: in std_logic_vector(address_bits-1 downto 0);
		write_in	 	: in std_logic_vector(word_width-1 downto 0); 
		port0	 	: out std_logic_vector(word_width-1 downto 0); 
		port1 	: out std_logic_vector(word_width-1 downto 0)
	);	
end mem_block; 

architecture behavioral of mem_block is 
	type ram_type is array((2**address_bits)-1 downto 0) of std_logic_vector(word_width-1 downto 0); 
	signal memory : ram_type;
	begin 
		process(clk, rst) 
		begin 
			if(rst = '1') then
				for loc in 0 to (2**address_bits) - 1 loop
					memory(loc) <= (others => '0');
				end loop;
			elsif clk'event and clk = '1' then 
				if we='1' then 
					memory(to_integer(unsigned(address_bus_write))) <= write_in; 
				end if; 
			end if;
		end process; 

		port0	<= memory(to_integer(unsigned(address_bus_read0)));
		port1	<= memory(to_integer(unsigned(address_bus_read1)));
end architecture;

