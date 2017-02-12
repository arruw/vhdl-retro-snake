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

entity retro_snake is
    port (
        clk_i : in std_logic;
        reset_i : in std_logic;
        -- VGA
        h_sync_o : out std_logic;
        v_sync_o : out std_logic;
        color_o : out std_logic_vector (7 downto 0);
        -- PS2
        kbd_clk_i : in std_logic;
        kbd_data_i : in std_logic;
        -- Seven Segment Display
        cathode_o : out std_logic_vector (6 downto 0);
        anode_o : out std_logic_vector(3 downto 0)
    );
end retro_snake;

architecture Behavioral of retro_snake is
    -- VGA
    signal color : std_logic_vector (7 downto 0);
    signal column : integer range 0 to 639;
    signal row : integer range 0 to 479;

    -- Canvas 
    signal read_address, write_address : integer range 0 to 29;
    signal read_data, write_data : std_logic_vector (0 to 79);
    signal write_enable : std_logic;

    -- PS2
    signal kbd_scancode : std_logic_vector (7 downto 0);
    signal kbd_scancode_ready : std_logic;
    
    -- Seven Segment Display
    signal number : std_logic_vector (15 downto 0);

    component vga_core is
        port (
            clk_i, reset_i : in std_logic;
            color_i : in std_logic_vector (7 downto 0);
            h_sync_o, v_sync_o : out std_logic;
            color_o : out std_logic_vector (7 downto 0);
            column_o : out integer range 0 to 639;
            row_o : out integer range 0 to 479
        );
    end component;

    component canvas is
        port (
            clk_i : in std_logic;
            write_enable_i : in std_logic;
            write_data_i : in std_logic_vector (0 to 79);
            write_address_i : in integer range 0 to 29;
            read_address_i : in integer range 0 to 29;
            read_data_o : out std_logic_vector (0 to 79)
        );
    end component;

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

    read_address <= row / 16;

    set_color : process( read_data, column )
        variable block_type : std_logic_vector (0 to 1);
        variable column_index : integer range 0 to 79;
    begin
        column_index := (column / 16) * 2;
        block_type := read_data(column_index to column_index + 1);

        case( block_type ) is
            when "00" => color <= "01001101";   -- grass    / green
            when "01" => color <= "01001001";   -- head     / dark gray
            when "10" => color <= "10010010";   -- tail    	/ lite gray
            when "11" => color <= "11011000";   -- food     / yellow
            when others => color <= "11100000";
        end case ;
    end process ; -- set_color

    set_number : process( kbd_scancode_ready )
    begin
        if rising_edge( kbd_scancode_ready ) then
            number <= "00000000" & kbd_scancode;
        end if ;
    end process ; -- set_number

    vga: vga_core
    port map (
        clk_i => clk_i,
        reset_i => reset_i,
        color_i => color,
        h_sync_o => h_sync_o,
        v_sync_o => v_sync_o,
        color_o => color_o,
        column_o => column,
        row_o => row
    );

    c: canvas
    port map (
        clk_i => clk_i,
        write_enable_i => write_enable,
        write_data_i => write_data,
        write_address_i => write_address,
        read_address_i => read_address,
        read_data_o => read_data
    );

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

end Behavioral;