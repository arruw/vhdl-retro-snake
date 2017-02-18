----------------------------------------------------------------------------------
-- Engineer:       Matjaz Mav
-- Create Date:    02/18/2017 
-- Module Name:    screen - Behavioral 
-- Target Devices: 
-- Description: 
----------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
use work.common.all;

entity screen is
    port(
        clk_i : in std_logic;
        reset_i : in std_logic;
        read_data_screen_i : in std_logic_vector (0 to 79);
        read_address_screen_o : out integer range 0 to 29;
        h_sync_o : out std_logic;
        v_sync_o : out std_logic;
        color_o : out std_logic_vector (7 downto 0)
    );
end screen;

architecture Behavioral of screen is
    signal color : std_logic_vector (7 downto 0);
    signal column : integer range 0 to 639;
    signal row : integer range 0 to 479;

    component vga_core is
        port (
            clk_i : in std_logic;
            reset_i : in std_logic;
            color_i : in std_logic_vector (7 downto 0);
            h_sync_o : out std_logic;
            v_sync_o : out std_logic;
            color_o : out std_logic_vector (7 downto 0);
            column_o : out integer range 0 to 639;
            row_o : out integer range 0 to 479
        );
    end component;
begin

    read_address_screen_o <= row / 16;

    set_color : process( read_data_screen_i, column )
        variable block_type : std_logic_vector (0 to 1);
        variable column_index : integer range 0 to 79;
    begin
        column_index := (column / 16) * 2;
        block_type := read_data_screen_i(column_index to column_index + 1);

        case( block_type ) is
            when "00" => color <= "01001101";   -- grass    / green
            when "01" => color <= "01001001";   -- head     / dark gray
            when "10" => color <= "10010010";   -- tail    	/ lite gray
            when "11" => color <= "11011000";   -- food     / yellow
            when others => color <= "00000000";
        end case ;
    end process ; -- set_color

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

end Behavioral;

