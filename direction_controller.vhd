----------------------------------------------------------------------------------
-- Engineer:       Matjaz Mav
-- Create Date:    02/18/2017 
-- Module Name:    snake_controller - Behavioral 
-- Target Devices: 
-- Description: 
----------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
use work.common.all;

entity direction_controller is
    port(
        clk_i : in std_logic;
        reset_i : in std_logic;
        kbd_clk_i : in std_logic;
        kbd_data_i : in std_logic;
        direction_o : out std_logic_vector (3 downto 0)
    );
end direction_controller;

architecture Behavioral of direction_controller is
    signal direction : std_logic_vector (3 downto 0) := "0000";

    constant left_c : std_logic_vector (7 downto 0) := x"6b";
    constant up_c : std_logic_vector (7 downto 0) := x"75";
    constant right_c : std_logic_vector (7 downto 0) := x"74";
    constant down_c : std_logic_vector (7 downto 0) := x"72";

    -- PS2
    signal kbd_scancode : std_logic_vector (7 downto 0);
    signal kbd_scancode_ready : std_logic;
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
begin

    direction_o <= direction;

    set_direction : process( clk_i )
    begin
        if rising_edge( clk_i ) then
            if reset_i = '1' then
                direction <= "0000";
            elsif kbd_scancode_ready = '1' then
                case( kbd_scancode ) is
                    when left_c => direction <= "1000";
                    when up_c => direction <= "0100";
                    when right_c => direction <= "0010";
                    when down_c => direction <= "0001";
                    when others => direction <= direction;           
                end case ;
            else
                direction <= direction;
            end if ;
        end if ;
    end process ; -- set_direction

    ps2: ps2_core
    port map (
        clk_i => clk_i,
        reset_i => reset_i,
        kbd_clk_i => kbd_clk_i,
        kbd_data_i => kbd_data_i,
        kbd_scancode_o => kbd_scancode,
        kbd_scancode_ready_o => kbd_scancode_ready
    );

end Behavioral ;