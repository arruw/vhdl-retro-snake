--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   11:58:58 02/04/2017
-- Design Name:   
-- Module Name:   E:/matja/Projects/FRI_DN/vhdl-redtor-snake/prescaler_test.vhd
-- Project Name:  vhdl-redtor-snake
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: prescaler
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
 
ENTITY prescaler_test IS
END prescaler_test;
 
ARCHITECTURE behavior OF prescaler_test IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT prescaler
	 GENERIC (
			value : integer := 255
		  );
    PORT(
         clk_i : IN  std_logic;
         reset_i : IN  std_logic;
         enable_o : OUT  std_logic
        );
    END COMPONENT;
    

   --Inputs
   signal clk_i : std_logic := '0';
   signal reset_i : std_logic := '0';

 	--Outputs
   signal enable_o : std_logic;

   -- Clock period definitions
   constant clk_i_period : time := 10 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: prescaler 
		  GENERIC MAP (
			 value => 1
		  )
		  PORT MAP (
          clk_i => clk_i,
          reset_i => reset_i,
          enable_o => enable_o
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
		reset_i <= '1';
      wait for 100 ns;	
		reset_i <= '0';

      wait for clk_i_period*10;
      -- insert stimulus here 

      wait;
   end process;

END;
