----------------------------------------------------------------------------------
-- Engineer:       Matjaž Mav
-- 
-- Create Date:    02/04/2017 
-- Module Name:    prescaler - Behavioral 
-- Target Devices: 
-- Description: 
----------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity prescaler is
    generic (
        value : integer := 255
    );
    port (
        clk_i : in std_logic;
        reset_i : in std_logic;
        enable_o : out std_logic
    );
end prescaler;

architecture Behavioral of prescaler is
    signal count : integer range 0 to (value - 1) := 0;
begin

    process( clk_i )
    begin
        if rising_edge( clk_i ) then
            if reset_i = '1' then
				count <= 0;
			elsif count >= value then
				count <= 0;
				enable_o <= '1';
			else
				count <= count + 1;
				enable_o <= '0';
			end if;
        end if ;
    end process ;

end Behavioral;

