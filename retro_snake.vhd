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
    type direction_t is ( none, left, up, right, down );
    type state_t is ( idle, head, tail );

    constant left_c : std_logic_vector (7 downto 0) := x"6b";
    constant up_c : std_logic_vector (7 downto 0) := x"75";
    constant right_c : std_logic_vector (7 downto 0) := x"74";
    constant down_c : std_logic_vector (7 downto 0) := x"72";

    signal state : state_t := idle;
    signal next_state : state_t;
    signal direction : direction_t := none;

    signal head_address_curr : integer range 0 to 29 := 15;
    signal head_offset_curr  : integer range 0 to 79 := 20;

    signal head_address_prev : integer range 0 to 29;
    signal head_offset_prev  : integer range 0 to 79;

    signal tail_address : integer range 0 to 29;
    signal tail_offset  : integer range 0 to 79;

    signal food_address : integer range 0 to 29;
    signal food_offset  : integer range 0 to 79;

    -- VGA
    signal color : std_logic_vector (7 downto 0);
    signal column : integer range 0 to 639;
    signal row : integer range 0 to 479;

    -- Canvas 
    signal write_enable : std_logic;
    signal write_address : integer range 0 to 29;
    signal write_data : std_logic_vector (0 to 79);
    signal read_address0 : integer range 0 to 29;
    signal read_data0 : std_logic_vector (0 to 79);
    signal read_address1 : integer range 0 to 29;
    signal read_data1 : std_logic_vector (0 to 79);

    -- PS2
    signal kbd_scancode : std_logic_vector (7 downto 0);
    signal kbd_scancode_ready : std_logic;
    
    -- Seven Segment Display
    signal score : std_logic_vector (15 downto 0);

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
            read_address0_i : in integer range 0 to 29;
            read_address1_i : in integer range 0 to 29;
            read_data0_o : out std_logic_vector (0 to 79);
            read_data1_o : out std_logic_vector (0 to 79)
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

    sync_state : process( clk_i )
    begin
        if rising_edge( clk_i ) then
            if reset_i = '1' then
                state <= idle;
            else
                state <= next_state;
            end if ;
        end if ;
    end process ; -- sync_state

    next_state : process( state )
    begin
        case ( state ) is
            when idle => next_state <= head;
            when head => next_state <= tail;
            when tail => next_state <= idle;
            when others => next_state <= idle;
        end case ;
    end process ; -- next_state

    exec_state : process( state )
    begin
        case( state ) is
            when idle =>
                write_enable <= '0';
            when head =>
                head_address_prev <= head_address_curr;
                head_offset_prev <= head_offset_curr;
                head_address_curr <= 
                head_offset_curr <=

                write_address <= head_address_curr;
                write_data <= 
                write_enable <= '1';
            when tail => 
                
                write_enable <= '1';
            when others =>
                write_enable <= '0';
        end case ;
    end process ; -- exec_state

    set_color : process( read_data0, column )
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

    set_direction : process( kbd_scancode_ready )
    begin
        if rising_edge( kbd_scancode_ready ) then
            case( kbd_scancode ) is
                when left_c => direction <= left_c;
                when up_c => direction <= up_c;
                when right_c => direction <= right_c;
                when down_c => direction <= down_c;
                when others => direction <= direction;
            end case ;
        end if ;
    end process ; -- set_direction

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
        read_address0_i => read_address0,
        read_address1_i => read_address1,
        read_data0_o => read_data0
        read_data1_o => read_data1
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
        number_i => score,
        cathode_o => cathode_o,
        anode_o => anode_o
    );

end Behavioral;