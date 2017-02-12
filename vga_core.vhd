----------------------------------------------------------------------------------
-- Engineer:       Matjaz Mav
-- Create Date:    02/04/2017 
-- Module Name:    vga_core - Behavioral 
-- Target Devices: 
-- Description: 
----------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity vga_core is
    port (
        clk_i, reset_i : in std_logic;
        color_i : in std_logic_vector (7 downto 0);
        h_sync_o, v_sync_o : out std_logic;
        color_o : out std_logic_vector (7 downto 0);
        column_o : out integer range 0 to 639;
        row_o : out integer range 0 to 479
    );
end vga_core;

architecture Behavioral of vga_core is
    constant h_display_time : integer := 640;
    constant h_front_porch : integer := 48;
    constant h_back_porch : integer := 16;
    constant h_sync_pulse : integer := 96;
    constant h_scan_time : integer := 800;

    constant v_display_time : integer := 480;
    constant v_front_porch : integer := 10;
    constant v_back_porch : integer := 29;
    constant v_sync_pulse : integer := 2;
    constant v_scan_time : integer := 521;

    signal h_count : integer range 0 to 799 := 0;
    signal v_count : integer range 0 to 520 := 0;
    signal h_vidon, v_vidon, vidon, clk_25MHz : std_logic := '0';

    signal column : integer range 0 to 639 := 0;
    signal row : integer range 0 to 479 := 0;

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
begin

    vidon <= h_vidon and v_vidon;
    column_o <= column;
    row_o <= row;
	
    p: prescaler
    generic map (
        value => 1
    )
    port map (
        clk_i => clk_i,
        reset_i => reset_i,
        enable_o => clk_25MHz
    );

    count_h : process( clk_25MHz )
    begin
        if rising_edge( clk_25MHz ) then
            if reset_i = '1' or h_count >= h_scan_time - 1 then
                h_count <= 0;
            else
                h_count <= h_count + 1; 
            end if ;
        end if ;
    end process ; -- count_h

    count_v : process( clk_25MHz )
    begin
        if rising_edge( clk_25MHz ) then
            if reset_i = '1' then
                v_count <= 0;
            elsif h_count >= h_scan_time - 1 then
                if v_count >= v_scan_time - 1 then
                    v_count <= 0;
                else
                    v_count <= v_count + 1; 
                end if ;
            else
                v_count <= v_count;
            end if ;
        end if ;
    end process ; -- count_v

    vidon_h : process( h_count )
    begin
        if h_count < h_display_time then
            h_vidon <= '1';
            column <= h_count;
        else
            h_vidon <= '0';
            column <= column;
        end if ;
    end process ; -- vidon_h

    vidon_v : process( v_count )
    begin
        if v_count < v_display_time then
            v_vidon <= '1';
            row <= v_count;
        else
            v_vidon <= '0';
            row <= row;
        end if ;
    end process ; -- vidon_v

    sync_h : process( h_count )
    begin
        if h_count >= h_display_time + h_back_porch and h_count < h_display_time + h_back_porch + h_sync_pulse then
            h_sync_o <= '0';
        else
            h_sync_o <= '1';
        end if ;
    end process ; -- sync_h

    sync_v : process( v_count )
    begin
        if v_count >= v_display_time + v_back_porch and v_count < v_display_time + v_back_porch + v_sync_pulse then
            v_sync_o <= '0';
        else
            v_sync_o <= '1';
        end if ;
    end process ; -- sync_v
    
    color : process( vidon, color_i )
    begin
        if vidon = '1' then
            color_o <= color_i;
        else
            color_o <= (others => '0');
        end if ;
    end process ; -- color

end Behavioral;