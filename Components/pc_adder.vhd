LIBRARY ieee;
USE ieee.std_logic_1164.all;

ENTITY pc_adder IS
	generic (
		WIDTH : integer := 8
	);
PORT( Clk, rst,enable 	: IN std_logic;
		q 		: OUT std_logic_vector (WIDTH-1 downto 0));
END pc_adder;

ARCHITECTURE myarch1 OF pc_adder IS 

component my_nadder IS
GENERIC (n : integer := 4);
PORT   (a, b : IN std_logic_vector(n-1 DOWNTO 0) ;
              cin   : IN std_logic;
              s      : OUT std_logic_vector(n-1 DOWNTO 0);
              cout : OUT std_logic);

END component;

signal d,increment: std_logic_vector(7 downto 0):= (others => '0');
signal cout: std_logic;
BEGIN
	u1: my_nadder generic map (8) port map(d,(others => '0'),'1',increment,cout);
	PROCESS (Clk,rst)
	BEGIN
		IF(Rst = '1') THEN
				d <= (others => '0');
		elsIF rising_edge(Clk) THEN
				if(enable = '1') then
						d <= increment;
				end if;	
		END IF;
	END PROCESS;
	q <= d;
END myarch1;