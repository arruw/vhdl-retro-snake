----------------------------------------------------------------------------------
-- Engineer:       Matjaz Mav
-- Create Date:    02/18/2017 
-- Module Name:    snake - Behavioral 
-- Target Devices:  
-- Description: 
----------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
use work.common.all;

entity snake is
    port(
        clk_i : in std_logic;
        reset_i : in std_logic;

        read_data_head_i : in std_logic_vector (0 to 79);
        read_address_head_o : out integer range 0 to 29;

        read_data_tail_i : in std_logic_vector (0 to 79);
        read_address_tail_o : out integer range 0 to 29;

        read_data_food_i : in std_logic_vector (0 to 79);
        read_address_food_o : out integer range 0 to 29
    );
end snake;

architecture Behavioral of snake is

begin


end Behavioral;