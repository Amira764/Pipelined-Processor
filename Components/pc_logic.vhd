LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

ENTITY pc_logic IS
    PORT (
        clk         : IN std_logic;                           -- Clock signal
        JMP_Cond    : IN std_logic;                           -- Jump condition
        CCR         : IN std_logic;                           -- Condition register

        Pc_Chng     : IN std_logic_vector(1 DOWNTO 0);        -- Input for 2-to-1 MUX
        Ex_Res      : IN std_logic_vector(1 DOWNTO 0);        -- 2-bit selector for 4-to-1 MUX

        New_PC      : IN std_logic_vector(15 DOWNTO 0);       -- New PC input
        reg         : IN std_logic_vector(15 DOWNTO 0);       -- Register value input
        DM_SP       : IN std_logic_vector(15 DOWNTO 0);       -- Data Memory [SP]

        IM_1        : IN std_logic_vector(15 DOWNTO 0);       -- Instruction Memory input1
        IM_2        : IN std_logic_vector(15 DOWNTO 0);       -- Instruction Memory input2
        IM_3        : IN std_logic_vector(15 DOWNTO 0);       -- Instruction Memory input3
        IM_4        : IN std_logic_vector(15 DOWNTO 0);       -- Instruction Memory input4

        mux_op      : OUT std_logic_vector(15 DOWNTO 0)       -- mux output entering pc register
    );
END pc_logic;

ARCHITECTURE behavior OF pc_logic IS

    -- Internal signals
    SIGNAL comp_op        : std_logic;                        -- Comparator result
    SIGNAL pc_chng_new    : std_logic_vector(1 DOWNTO 0);     -- 2x1 MUX output
    SIGNAL IM             : std_logic_vector(15 DOWNTO 0);    -- 4x1 MUX output

BEGIN

    -- Comparator Logic
    comp_op <= '1' WHEN JMP_Cond = CCR ELSE '0';

    -- First MUX: 2-to-1 MUX with 2-bit inputs
    pc_chng_new <= Pc_Chng WHEN comp_op = '0' ELSE "01";

    -- Second MUX: 4-to-1 MUX for Instruction Memory Selection
    PROCESS (Ex_Res, IM_1, IM_2, IM_3, IM_4)
    BEGIN
        CASE Ex_Res IS
            WHEN "00" => IM <= IM_3;
            WHEN "01" => IM <= IM_4;
            WHEN "10" => IM <= IM_1;
            WHEN OTHERS => IM <= IM_2;
        END CASE;
    END PROCESS;

    -- Third MUX: 4-to-1 MUX for PC Source Selection
    PROCESS (pc_chng_new, New_PC, reg, DM_SP, IM)
    BEGIN
        CASE pc_chng_new IS
            WHEN "00" => mux_op <= New_PC;
            WHEN "01" => mux_op <= reg;
            WHEN "10" => mux_op <= DM_SP;
            WHEN OTHERS => mux_op <= IM;
        END CASE;
    END PROCESS;

END behavior;
