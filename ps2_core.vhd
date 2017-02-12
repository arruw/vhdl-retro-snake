---------------------------------------------------------------------------------- 
-- Engineer:       Matjaz Mav
-- Create Date:    02/12/2017 
-- Module Name:    ps2_core - Behavioral 
-- Target Devices: 
-- Description: 
----------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity ps2_core is
    port (
        clk_i : in std_logic;
        reset_i : in std_logic;
        kbd_clk_i : in std_logic;
        kbd_data_i : in std_logic;
        kbd_scancode_o : out std_logic_vector (7 downto 0);
        kbd_scancode_ready_o : out std_logic
    );
end ps2_core;

architecture Behavioral of ps2_core is
    signal kbd_clk : std_logic;
    signal kbd_data : std_logic;
    signal kbd_scancode : std_logic_vector (7 downto 0);
    signal kbd_scancode_ready : std_logic;
    signal bit_number : integer range 0 to 10;
begin

    kbd_scancode_o <= kbd_scancode;
    kbd_scancode_ready_o <= kbd_scancode_ready;

    sync : process( clk_i )
    begin
        if rising_edge( clk_i ) then
            kbd_clk <= kbd_clk_i;
            kbd_data <= kbd_data_i;
        end if ;
    end process ; -- sync

    keyboard : process( kbd_clk )
    begin
        if falling_edge( kbd_clk ) then
            if reset_i = '1' then
                kbd_scancode <= (others => '0');
                kbd_scancode_ready <= '0';
                bit_number <= 0;
            elsif bit_number = 0 and kbd_data = '0' then                -- start bit
                kbd_scancode_ready <= '0';
                bit_number <= bit_number + 1;
            elsif 1 <= bit_number and bit_number <= 8 then              -- 8 data bits
                kbd_scancode <= kbd_data & kbd_scancode(7 downto 1);
                bit_number <= bit_number + 1;
            elsif bit_number = 9 then                                   -- parity bit
                bit_number <= bit_number + 1;
            elsif bit_number = 10 and kbd_data = '1' then               -- stop bit
                kbd_scancode_ready <= '1';
                bit_number <= 0;
            else
                kbd_scancode <= kbd_scancode;
                kbd_scancode_ready <= kbd_scancode_ready;
                bit_number <= bit_number;
            end if ;
        end if ;
    end process ; -- keyboard

end Behavioral;