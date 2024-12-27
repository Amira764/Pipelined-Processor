library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity tb_pc_update is
end tb_pc_update;

architecture behavior of tb_pc_update is
    -- Component Declaration
    component pc_update
        port (
            pc_out      : in std_logic_vector(15 downto 0);
            imm_flag    : in std_logic;
            new_pc      : out std_logic_vector(15 downto 0)
        );
    end component;

    -- Signals
    signal pc_out      : std_logic_vector(15 downto 0) := (others => '0');
    signal imm_flag    : std_logic := '0';
    signal new_pc      : std_logic_vector(15 downto 0);

begin
    -- Instantiate DUT
    dut: pc_update
        port map (
            pc_out      => pc_out,
            imm_flag    => imm_flag,
            new_pc      => new_pc
        );

    -- Stimulus Process
    stim_proc: process
    begin
        -- Test Case 1: imm_flag = 0, increment by +1
        pc_out <= x"0000";
        imm_flag <= '0';
        wait for 10 ns;

        -- Test Case 2: imm_flag = 1, increment by +2
        pc_out <= x"0000";
        imm_flag <= '1';
        wait for 10 ns;

        -- Test Case 3: imm_flag = 0, increment from non-zero PC
        pc_out <= x"0005";
        imm_flag <= '0';
        wait for 10 ns;

        -- Test Case 4: imm_flag = 1, increment from non-zero PC
        pc_out <= x"0005";
        imm_flag <= '1';
        wait for 10 ns;

        -- Finish simulation
        wait;
    end process;

end behavior;
