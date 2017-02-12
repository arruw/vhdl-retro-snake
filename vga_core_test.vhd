--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   12:09:05 02/04/2017
-- Design Name:   
-- Module Name:   E:/matja/Projects/FRI_DN/vhdl-redtor-snake/vga_core_test.vhd
-- Project Name:  vhdl-redtor-snake
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: vga_core
-- 
-- Dependencies:
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
--
-- Notes: 
-- This testbench has been automatically generated using types std_logic and
-- std_logic_vector for the ports of the unit under test.  Xilinx recommends
-- that these types always be used for the top-level I/O of a design in order
-- to guarantee that the testbench will bind correctly to the post-implementation 
-- simulation model.
--------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
 
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--USE ieee.numeric_std.ALL;
 
ENTITY vga_core_test IS
END vga_core_test;
 
ARCHITECTURE behavior OF vga_core_test IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
	COMPONENT vga_core
		 port (
			  clk_i, reset_i : in std_logic;
			  color_i : in std_logic_vector (7 downto 0);
			  h_sync_o, v_sync_o : out std_logic;
			  color_o : out std_logic_vector (7 downto 0);
			  column_o : out integer range 0 to 799;
			  row_o : out integer range 0 to 479
		 );
	END COMPONENT;
    

   --Inputs
   signal clk_i : std_logic := '0';
   signal reset_i : std_logic := '0';
   signal color_i : std_logic_vector(7 downto 0) := "11100011";

 	--Outputs
   signal h_sync_o : std_logic;
   signal v_sync_o : std_logic;
   signal color_o : std_logic_vector(7 downto 0);
   signal column_o : integer range 0 to 799;
   signal row_o : integer range 0 to 479;

   -- Clock period definitions
   constant clk_i_period : time := 10 ns;
	
	--Other
	signal address_read_x : integer range 0 to 19 := 0;
	signal address_read_y : integer range 0 to 14 := 0;
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: vga_core PORT MAP (
          clk_i => clk_i,
          reset_i => reset_i,
          color_i => color_i,
          h_sync_o => h_sync_o,
          v_sync_o => v_sync_o,
          color_o => color_o,
          column_o => column_o,
          row_o => row_o
        );
	
	 align_read_x : process( column_o )
    begin
        address_read_x <= column_o / 32;
    end process ; -- align_read_x

    align_read_y : process( row_o )
    begin
        address_read_y <= row_o / 32;
    end process ; -- align_read_y
	
   -- Clock process definitions
   clk_i_process :process
   begin
		clk_i <= '0';
		wait for clk_i_period/2;
		clk_i <= '1';
		wait for clk_i_period/2;
   end process;
 

   -- Stimulus process
   stim_proc: process
   begin		
      -- hold reset state for 100 ns.
		reset_i <= '1';
      wait for 100 ns;	
		reset_i <= '0';
		
      wait for clk_i_period*10;
      -- insert stimulus here 

      wait;
   end process;

END;
