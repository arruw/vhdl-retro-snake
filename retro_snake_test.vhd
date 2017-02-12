--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   14:52:18 02/11/2017
-- Design Name:   
-- Module Name:   E:/matja/Projects/FRI_DN/vhdl-redtor-snake/retro_snake_test.vhd
-- Project Name:  vhdl-redtor-snake
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: retro_snake
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
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
 
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--USE ieee.numeric_std.ALL;
 
ENTITY retro_snake_test IS
END retro_snake_test;
 
ARCHITECTURE behavior OF retro_snake_test IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT retro_snake
    PORT(
         clk_i : IN  std_logic;
         reset_i : IN  std_logic;
         h_sync_o : OUT  std_logic;
         v_sync_o : OUT  std_logic;
         color_o : OUT  std_logic_vector(7 downto 0);
         column_o : OUT  integer range 0 to 639;
         row_o : OUT  integer range 0 to 479
        );
    END COMPONENT;
    

   --Inputs
   signal clk_i : std_logic := '0';
   signal reset_i : std_logic := '0';

 	--Outputs
   signal h_sync_o : std_logic;
   signal v_sync_o : std_logic;
   signal color_o : std_logic_vector(7 downto 0);
   signal column_o : integer range 0 to 639;
   signal row_o : integer range 0 to 479;

   -- Clock period definitions
   constant clk_i_period : time := 10 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: retro_snake PORT MAP (
          clk_i => clk_i,
          reset_i => reset_i,
          h_sync_o => h_sync_o,
          v_sync_o => v_sync_o,
          color_o => color_o,
          column_o => column_o,
          row_o => row_o
        );

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
      wait for 100 ns;	

		reset_i <= '1';
      wait for clk_i_period*10;
		reset_i <= '0';
		
      -- insert stimulus here 

      wait;
   end process;

END;
