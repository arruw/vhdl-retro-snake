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
        clk_i, reset_i                                  : in std_logic;
        kbd_clk_i, kbd_data_i                           : in std_logic;

        read_data_snake_0_i, read_data_snake_1_i        : in std_logic_vector (0 to 79);
        read_address_snake_0_o, read_address_snake_1_o  : out integer range 0 to 29;

        write_enable_0_o,   write_enable_1_o            : out std_logic;
        write_data_0_o,     write_data_1_o              : out std_logic_vector (0 to 79);
        write_address_0_o,  write_address_1_o           : out integer range 0 to 29
    );
end snake;

architecture Behavioral of snake is
    type state_t is (IDLE, HEAD, OVER);
    signal state, next_state : state_t;

    signal score : integer range 0 to 99 := 0;
    signal move_index : integer range 0 to 99 := 0;
    signal is_eating : std_logic;

    signal clk_1Hz : std_logic;
    signal direction_queue : std_logic_vector (399 downto 0);
    signal curr_direction, prev_direction : std_logic (3 downto 0);

    signal head_address : block_address_t := (15, 40);
    signal next_address_block : std_logic_vector(1 downto 0);
    signal next_address, curr_address, prev_address : block_address_t;
  
    component prescaler is
        generic (
            value : integer := 255
        );
        port (
            clk_i : in std_logic;
            reset_i : in std_logic;
            enable_o : out std_logic
        );
    end component;

    component direction_queue_core is
        port(
            clk_i : in std_logic;
            reset_i : in std_logic;
            kbd_clk_i : in std_logic;
            kbd_data_i : in std_logic;
            push_enable_i : in std_logic;
            direction_queue_o : out std_logic_vector (399 downto 0)
        );
    end component;
begin

    set_next_and_prev_address : process( curr_address, move_index )
        variable curr_direction_index, prev_direction_index : integer range 0 to 399;
        variable curr_direction, prev_direction : std_logic_vector (3 downto 0);
    begin
        curr_direction_index := 399 - (move_index * 4);
        prev_direction_index := curr_direction_index - 4;
        curr_direction := direction_queue(curr_direction_index downto curr_direction_index - 3);
        prev_direction := direction_queue(prev_direction_index downto prev_direction_index - 3);

        next_address <= get_next_block_address(curr_address, curr_direction);
        prev_address <= get_prev_block_address(curr_address, prev_direction);
    end process ; -- set_next_and_prev_address

    read_address_snake_0_o <= next_address.address;
    next_address_block <= read_data_snake_0_i(next_address.offset to next_address + 1);

    sync_state : process( clk_i )
    begin
        if reset_i = '1' then
            state <= IDLE;
            score <= 0;
            move_index <= 0;
            head_address <= (15, 40);
        else
            state <= next_state;
        end if ;
    end process ; -- sync_state

    set_next_state : process( state )
    begin
        case( state ) is
            when IDLE   =>  
                if clk_1Hz = '1' then
                    if next_address_block = "00" then
                        next_state <= HEAD;
                    else
                        next_state <= OVER;
                    end if ;
                else                 
                    next_state <= IDLE;
                end if ;
            when HEAD   =>
            when OVER   => next_state <= OVER;
            when others => next_state <= IDLE;
        end case ;
    end process ; -- set_next_state

    p: prescaler
    generic map (
        value => 50000000 -- 1s
    )
    port map (
        clk_i => clk_i,
        reset_i => reset_i,
        enable_o => clk_1Hz
    );

    dq: direction_queue_core
    port map (
        clk_i => clk_i,
        reset_i => reset_i,
        kbd_clk_i => kbd_clk_i,
        kbd_data_i => kbd_data_i,
        push_enable_i => clk_1Hz,
        direction_queue_o => direction_queue
    );
end Behavioral;