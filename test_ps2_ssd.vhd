----------------------------------------------------------------------------------
-- Engineer:       Matjaz Mav
-- Create Date:    02/12/2017 
-- Module Name:    test_ps2_ssd - Behavioral 
-- Target Devices:  
-- Description: 
----------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity test_ps2_ssd is
    port (
        clk_i : in std_logic;
        reset_i : in std_logic;
        kbd_clk_i : in std_logic;
        kbd_data_i : in std_logic;
        cathode_o : out std_logic_vector (6 downto 0);
        anode_o : out std_logic_vector(3 downto 0)
    );
end test_ps2_ssd;

architecture Behavioral of test_ps2_ssd is
    signal kbd_scancode : std_logic_vector (7 downto 0);
    signal kbd_scancode_ready : std_logic;
    signal number : std_logic_vector (15 downto 0);

    component ps2_core is
        port (
            clk_i : in std_logic;
            reset_i : in std_logic;
            kbd_clk_i : in std_logic;
            kbd_data_i : in std_logic;
            kbd_scancode_o : out std_logic_vector (7 downto 0);
            kbd_scancode_ready_o : out std_logic
        );
    end component;

    component ssd_core is
        port(
            clk_i : in std_logic;
            reset_i : in std_logic;
            number_i : in std_logic_vector (15 downto 0);
            cathode_o : out std_logic_vector (6 downto 0);
            anode_o : out std_logic_vector(3 downto 0)
        );
    end component;
begin

    ps2: ps2_core
    port map (
        clk_i => clk_i,
        reset_i => reset_i,
        kbd_clk_i => kbd_clk_i,
        kbd_data_i => kbd_data_i,
        kbd_scancode_o => kbd_scancode,
        kbd_scancode_ready_o => kbd_scancode_ready
    );

    ssd: ssd_core
    port map (
        clk_i => clk_i,
        reset_i => reset_i,
        number_i => number,
        cathode_o => cathode_o,
        anode_o => anode_o
    );

    set_number : process( kbd_scancode_ready )
    begin
        if rising_edge( kbd_scancode_ready ) then
            number <= "00000000" & kbd_scancode;
        end if ;
    end process ; -- set_number

    -- number <= "00000000" & kbd_scancode;

end Behavioral;

