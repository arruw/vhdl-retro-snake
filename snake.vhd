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
        kbd_clk_i : in std_logic;
        kbd_data_i : in std_logic;

        read_data_head_i : in std_logic_vector (0 to 79);
        read_address_head_o : out integer range 0 to 29;

        read_data_next_head_i : in std_logic_vector (0 to 79);
        read_address_next_head_o : out integer range 0 to 29;

        read_data_tail_i : in std_logic_vector (0 to 79);
        read_address_tail_o : out integer range 0 to 29;

        write_enable_o : out std_logic;
        write_data_o : out std_logic_vector (0 to 79);
        write_address_o : out integer range 0 to 29
    );
end snake;

architecture Behavioral of snake is
    type state_t is (
        MOVE_HEAD, MOVE_HEAD_WRITE_WAIT,
        MOVE_NECK, MOVE_NECK_WRITE_WAIT,
        MOVE_TAIL, MOVE_TAIL_WRITE_WAIT
    );
    signal state : state_t := MOVE_HEAD;

    signal clk_1Hz : std_logic;
	signal direction_queue : std_logic_vector (399 downto 0);
	signal length : integer := 3;

    signal head_direction : std_logic_vector (3 downto 0);
    signal tail_direction : std_logic_vector (3 downto 0);

    signal head_address : block_address_t := (15, 40);
    signal head_data : std_logic_vector (0 to 79);
    
    signal next_tail_address : block_address_t;
    signal tail_address : block_address_t := (15, 44);
    signal tail_data : std_logic_vector (0 to 79);

    signal next_head_address : block_address_t;
    signal next_head_data : std_logic_vector (0 to 79);
    signal next_head_address_block : std_logic_vector(1 downto 0);
  
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

    head_direction <= direction_queue(399 downto 396);
    tail_direction <= direction_queue((399 - length * 4) downto (396 - length * 4));

    next_head_address <= get_next_block_address(head_address, head_direction);
    next_tail_address <= get_next_block_address(tail_address, tail_direction);
    
    read_address_next_head_o <= next_head_address.address;
    next_head_address_block <= read_data_next_head_i(next_head_address.offset to next_head_address.offset + 1);
    set_next_head_data : process( read_data_next_head_i, next_head_address.offset )
    begin
        next_head_data <= read_data_next_head_i;  
        next_head_data(next_head_address.offset to next_head_address.offset + 1) <= "01";
    end process ; -- set_next_head_data

    read_address_head_o <= head_address.address;
    set_head_data : process( read_data_head_i, head_address.offset )
    begin
        head_data <= read_data_head_i;  
        head_data(head_address.offset to head_address.offset + 1) <= "10";
    end process ; -- set_head_data

    read_address_tail_o <= tail_address.address;
    set_tail_data : process( read_data_tail_i, tail_address.offset )
    begin
        tail_data <= read_data_tail_i;  
        tail_data(tail_address.offset to tail_address.offset + 1) <= "11";
    end process ; -- set_tail_data

    process( clk_i )
    begin
        if rising_edge( clk_i ) then
            if state = MOVE_HEAD and clk_1Hz = '1' and head_direction /= "0000" then
                -- move head to next position
                write_address_o <= next_head_address.address;
                write_data_o <= next_head_data;
                write_enable_o <= '1';
                state <= MOVE_HEAD_WRITE_WAIT;

            elsif state = MOVE_HEAD_WRITE_WAIT then
                write_enable_o <= '0';
                state <= MOVE_NECK;

            elsif state = MOVE_NECK then
                -- move neck to prev head position
                write_address_o <= head_address.address;
                write_data_o <= head_data;
                write_enable_o <= '1';
                -- move head pointer
                head_address <= next_head_address;
                state <= MOVE_NECK_WRITE_WAIT;

            elsif state = MOVE_NECK_WRITE_WAIT then
                write_enable_o <= '0';
                state <= MOVE_TAIL;

            elsif state = MOVE_TAIL then
                -- clear tail
                write_address_o <= tail_address.address;
                write_data_o <= tail_data;
                write_enable_o <= '1';
                -- move tail pointer
                tail_address <= next_tail_address;
                state <= MOVE_TAIL_WRITE_WAIT;

            elsif state = MOVE_TAIL_WRITE_WAIT then
                write_enable_o <= '0';
                state <= MOVE_HEAD;
            
            else
                write_enable_o <= '0';
                state <= state;
            end if;
        end if ;
    end process ;

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