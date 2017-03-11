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

        write_enable_head_o : out std_logic;
        write_data_head_o : out std_logic_vector (0 to 79);
        write_address_head_o : out integer range 0 to 29
    );
end snake;

architecture Behavioral of snake is
    -- type state_t is (IDLE, READ_HEAD, MOVE_HEAD);
    -- signal state, next_state : state_t;

    signal clk_1Hz : std_logic;
	signal direction_queue : std_logic_vector (399 downto 0);
	 
    signal head_direction : std_logic_vector (3 downto 0);
    signal head_address : block_address_t := (15, 40);
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
    next_head_address <= get_next_block_address(head_address, head_direction);
    read_address_head_o <= next_head_address.address;
    identifier : process( read_data_head_i, next_head_address.offset )
    begin
        next_head_address_block <= read_data_head_i(next_head_address.offset to next_head_address.offset + 1);
        next_head_data <= read_data_head_i;  
        next_head_data(next_head_address.offset to next_head_address.offset + 1) <= "01";
    end process ; -- identifier

    move_head : process( clk_i )
        -- variable next_data_head : std_logic_vector (0 to 79) := read_data_head_i;
    begin
        if rising_edge( clk_i ) then
            if clk_1Hz = '1' and head_direction /= "0000" then
                --- next_data_head(next_head_address.offset to next_head_address.offset + 1) := "01";
                write_address_head_o <= next_head_address.address;
                -- write_data_head_o <= next_data_head;
                write_data_head_o <= next_head_data;
                write_enable_head_o <= '1';
                head_address <= next_head_address;
            else
                write_enable_head_o <= '0';
            end if ;
        end if ;
    end process ; -- move_head

    -- sync_state : process( clk_i )
    -- begin
    --     if rising_edge( clk_i ) then
    --         if reset_i = '1' then
    --             state <= IDLE;
    --             head_address <= (15, 40);
    --         else
    --             state <= next_state;
    --         end if ;
    --     end if ;
    -- end process ; -- sync_state

    -- set_next_state : process( state, clk_1Hz )
    -- begin
    --     case( state ) is
    --         when IDLE =>  
    --             if clk_1Hz = '1' then
    --                 next_state <= READ_HEAD;
    --             else                 
    --                 next_state <= IDLE;
    --             end if ;
    --         when READ_HEAD => next_state <= MOVE_HEAD;
    --         when MOVE_HEAD => next_state <= IDLE;
    --         when others => next_state <= IDLE;
    --     end case ;
    -- end process ; -- set_next_state

    -- state_logic : process( state )
    -- begin
    --     case( state ) is
    --         when READ_HEAD =>
    --             read_address_head_o
    --         when MOVE_HEAD => next_state <= IDLE;
    --         when others => next_state <= IDLE;
    --     end case ;
    -- end process ; -- state_logic

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