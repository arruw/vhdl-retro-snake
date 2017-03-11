----------------------------------------------------------------------------------
-- Engineer:       Matjaz Mav
-- Create Date:    02/04/2017 
-- Module Name:    retro_snake - Behavioral 
-- Target Devices: 
-- Description: 
----------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;
use work.common.all;

entity retro_snake is
    port (
        clk_i : in std_logic;
        reset_i : in std_logic;
        -- PS2
        kbd_clk_i : in std_logic;
        kbd_data_i : in std_logic;
        -- VGA
        h_sync_o : out std_logic;
        v_sync_o : out std_logic;
        color_o : out std_logic_vector (7 downto 0);
        -- Seven Segment Display
        cathode_o : out std_logic_vector (6 downto 0);
        anode_o : out std_logic_vector(3 downto 0)
    );
end retro_snake;

architecture Behavioral of retro_snake is
    
    -- Canvas 
    signal write_enable_head : std_logic;
    signal write_address_head : integer range 0 to 29;
    signal write_data_head : std_logic_vector (0 to 79);

    signal read_address_screen : integer range 0 to 29;
    signal read_data_screen : std_logic_vector (0 to 79);

    signal read_address_head : integer range 0 to 29;
    signal read_data_head : std_logic_vector (0 to 79);

    -- Seven Segment Display
    signal score : std_logic_vector (15 downto 0);

    -- Direction
    signal direction : std_logic_vector (3 downto 0);

    component canvas is
        port (
            clk_i : in std_logic;
            reset_i : in std_logic;

            write_enable_head_i : in std_logic;
            write_data_head_i : in std_logic_vector (0 to 79);
            write_address_head_i : in integer range 0 to 29;

            read_address_screen_i : in integer range 0 to 29;
            read_data_screen_o : out std_logic_vector (0 to 79);

            read_address_head_i : in integer range 0 to 29;
            read_data_head_o : out std_logic_vector (0 to 79)
        );
    end component;

    component screen is
        port(
            clk_i : in std_logic;
            reset_i : in std_logic;
            read_data_screen_i : in std_logic_vector (0 to 79);
            read_address_screen_o : out integer range 0 to 29;
            h_sync_o : out std_logic;
            v_sync_o : out std_logic;
            color_o : out std_logic_vector (7 downto 0)
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

    c: canvas
    port map (
        clk_i => clk_i,
        reset_i => reset_i,

        write_enable_head_i => write_enable_head,
        write_data_head_i => write_data_head,
        write_address_head_i => write_address_head,

        read_address_screen_i => read_address_screen,
        read_data_screen_o => read_data_screen,

        read_address_head_i => read_address_head,
        read_data_head_o => read_data_head
    );

    scr: screen
    port map (
        clk_i => clk_i,
        reset_i => reset_i,
        read_data_screen_i => read_data_screen,
        read_address_screen_o => read_address_screen,
        h_sync_o => h_sync_o,
        v_sync_o => v_sync_o,
        color_o => color_o
    );

    ssd: ssd_core
    port map (
        clk_i => clk_i,
        reset_i => reset_i,
        number_i => score,
        cathode_o => cathode_o,
        anode_o => anode_o
    );

end Behavioral;