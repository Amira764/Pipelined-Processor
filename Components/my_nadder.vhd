LIBRARY ieee;
USE ieee.std_logic_1164.all;

ENTITY my_nadder IS
GENERIC (n : integer := 16);
PORT   (a, b : IN std_logic_vector(n-1 DOWNTO 0) ;
              cin   : IN std_logic;
              s      : OUT std_logic_vector(n-1 DOWNTO 0);
              cout : OUT std_logic);

END my_nadder;

ARCHITECTURE a_my_nadder OF my_nadder IS

         COMPONENT my_adder IS
                  PORT( a,b,cin : IN std_logic; s,cout : OUT std_logic);
          END COMPONENT;
         SIGNAL c : std_logic_vector(n DOWNTO 0);
			
BEGIN
c(0) <= cin;
loop1: FOR i IN 0 TO n-1 GENERATE
        fx: my_adder PORT MAP(a(i),b(i),c(i),s(i),c(i+1));
END GENERATE;
Cout <= c(n);
END a_my_nadder;

