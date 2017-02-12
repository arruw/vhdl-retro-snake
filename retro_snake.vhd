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
        clk_i, reset_i : in std_logic;
        h_sync_o, v_sync_o : out std_logic;
        color_o : out std_logic_vector (7 downto 0)
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
begin

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

    read_address <= row / 16;

    set_color : process( read_data, column )
        variable block_type : std_logic_vector (0 to 1);
        variable column_index : integer range 0 to 79;
    begin
        column_index := (column / 16) * 2;
        block_type := read_data(column_index to column_index + 1);

        case( block_type ) is
            when "00" => color <= "10010010";   -- grass    / green
            when "01" => color <= "11111111";   -- food     / orange
            when "10" => color <= "00000000";   -- snake    / gray 01001001
            when "11" => color <= "01010101";   -- wall     / dark gray
            when others => color <= "11100000";
        end case ;
    end process ; -- set_color

    -- color <= "01001101";

end Behavioral;