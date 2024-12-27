LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all; 

ENTITY ALU IS
    generic (
        WIDTH : integer := 16
    );

    port (
        S : in std_logic_vector(2 downto 0);
        In1, In2 : in std_logic_vector(WIDTH-1 downto 0);
        Cin : in std_logic;
        F : out std_logic_vector(WIDTH-1 downto 0);
--        Cout : out std_logic
		  CCR : out std_logic_vector(2 downto 0)
    );

END ALU;

architecture arch5 of ALU is

    signal x1, x2,x3 : std_logic_vector(WIDTH-1 DOWNTO 0);
    signal y1, y2,y3 : std_logic;
	 signal temp : std_logic_vector(16 DOWNTO 0);
    signal sub_result : unsigned(WIDTH-1 DOWNTO 0);

begin


	temp<= std_logic_vector(unsigned("0"&In1) + unsigned(In2)) when S="000" else
    std_logic_vector(unsigned("0"&In1) - unsigned(In2)) when S="001" else
    std_logic_vector(unsigned("0"&In1) + 1) when S="100" else
	 not ("0"&In1) when S = "010" else
	 ("0"&In1) and ("0"&In2)when S = "011" else
	 ("0"&In1) when S = "101" else (others => '0');

--    -- Addition
--    x1 <= std_logic_vector(unsigned(In1) + unsigned(In2)); 
--    y1 <= '1' when unsigned(In1) + unsigned(In2) >= 2**WIDTH else '0';
--
--    -- Subtraction using standard arithmetic
--    sub_result <= unsigned(In1) - unsigned(In2); 
--    x2 <= std_logic_vector(sub_result);
--    y2 <= '1' when sub_result < 0 else '0';
--	 
--	 -- increment
--	 x3 <= std_logic_vector(unsigned(In1) + 1); 
--    y3 <= '1' when (unsigned(In1) + 1) >= 2**WIDTH else '0';

    -- Logic for F output
    F <= temp (15 downto 0);
			

--    -- Logic for Cout output
--    CCR(2) <= temp(16)  when S = "000"
--            else temp(16)  when S = "001"
--            else temp(16)  when S = "100"
--				else '1' when S = "110"           -- For SETC
--				else '0';
				
				
	CCR(0)<='1' when temp(15 downto 0)="0000000000000000" else '0';
    CCR(1)<=temp(15);
    CCR(2)<=temp(16) when S /= "110" else '1' ;

END arch5;
