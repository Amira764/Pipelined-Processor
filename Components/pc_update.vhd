library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity pc_update is
    port (
        pc_out      : in std_logic_vector(15 downto 0);  -- Current PC value
        has_imm    : in std_logic;                     -- Immediate flag (selection signal)
        new_pc      : out std_logic_vector(15 downto 0) -- Updated PC value
    );
end pc_update;

architecture behavior of pc_update is
    -- Internal signals
    signal increment_value : std_logic_vector(15 downto 0); -- Value selected by the MUX
begin

    -- MUX: Select between +1 and +2 based on the immediate flag
    increment_value <= x"0001" when has_imm = '0' else x"0002";

    -- Adder: Add the selected increment value to pc_out
    process (pc_out, increment_value)
        variable pc_value : unsigned(15 downto 0);
        variable increment : unsigned(15 downto 0);
    begin
        pc_value := unsigned(pc_out);
        increment := unsigned(increment_value);
        new_pc <= std_logic_vector(pc_value + increment);
    end process;

end behavior;
