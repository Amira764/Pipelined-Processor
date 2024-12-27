LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY tb_pc_register IS
END tb_pc_register;

ARCHITECTURE behavior OF tb_pc_register IS
    -- Component Declaration
    COMPONENT pc_register
        PORT (
            clk     : IN std_logic;
            reset   : IN std_logic;
            freeze  : IN std_logic;
            mux_op  : IN std_logic_vector(15 DOWNTO 0);
            pc_out  : OUT std_logic_vector(15 DOWNTO 0)
        );
    END COMPONENT;

    -- Signals
    SIGNAL clk    : std_logic := '0';
    SIGNAL reset  : std_logic := '0';
    SIGNAL freeze : std_logic := '0';
    SIGNAL mux_op : std_logic_vector(15 DOWNTO 0) := (OTHERS => '0');
    SIGNAL pc_out : std_logic_vector(15 DOWNTO 0);

    -- Clock period
    CONSTANT clk_period : time := 10 ns;

BEGIN
    -- Instantiate the PC Register
    DUT: pc_register
        PORT MAP (
            clk     => clk,
            reset   => reset,
            freeze  => freeze,
            mux_op  => mux_op,
            pc_out  => pc_out
        );

    -- Clock Generation
    clk_process: PROCESS
    BEGIN
        WHILE TRUE LOOP
            clk <= '0';
            WAIT FOR clk_period / 2;
            clk <= '1';
            WAIT FOR clk_period / 2;
        END LOOP;
    END PROCESS;

    -- Stimulus Process
    stim_proc: PROCESS
    BEGIN
        -- Test 1: Reset PC
        reset <= '1';
        WAIT FOR clk_period;
        reset <= '0';
        WAIT FOR clk_period;

        -- Test 2: Normal PC update
        mux_op <= "0000000000000010"; -- Set mux_op to 2
        WAIT FOR clk_period;

        -- Test 3: Freeze PC (Hold value)
        freeze <= '1';
        mux_op <= "0000000000000100"; -- Change mux_op to 4 (should not update)
        WAIT FOR clk_period;

        -- Test 4: Unfreeze and update PC
        freeze <= '0';
        WAIT FOR clk_period;

        -- Test Complete
        WAIT;
    END PROCESS;
END behavior;
