--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   09:55:42 02/05/2017
-- Design Name:   
-- Module Name:   E:/matja/Projects/FRI_DN/vhdl-redtor-snake/canvas_test.vhd
-- Project Name:  vhdl-redtor-snake
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: canvas
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
 
ENTITY canvas_test IS
END canvas_test;
 
ARCHITECTURE behavior OF canvas_test IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
	COMPONENT canvas
		port (
			clk_i, write_enable_i : in std_logic;
			data_i : in std_logic_vector (1 downto 0);
			address_write_x_i, address_read_x_i : in integer range 0 to 19;
			address_write_y_i, address_read_y_i : in integer range 0 to 14;
			data_o : out std_logic_vector (1 downto 0)
		);
	END COMPONENT;
    

   --Inputs
   signal clk_i : std_logic := '0';
   signal write_enable_i : std_logic := '0';
   signal data_i : std_logic_vector(1 downto 0) := (others => '0');
   signal address_write_x_i, address_read_x_i : integer range 0 to 19 := 0;
   signal address_write_y_i, address_read_y_i : integer range 0 to 14 := 0;

 	--Outputs
   signal data_o : std_logic_vector(1 downto 0);

   -- Clock period definitions
   constant clk_i_period : time := 10 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: canvas PORT MAP (
          clk_i => clk_i,
          write_enable_i => write_enable_i,
          data_i => data_i,
          address_write_x_i => address_write_x_i,
          address_read_x_i => address_read_x_i,
          address_write_y_i => address_write_y_i,
          address_read_y_i => address_read_y_i,
          data_o => data_o
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
		
		wait for clk_i_period*10;
		
		address_read_x_i <= 9;
		address_read_y_i <= 7;
		
      wait;
   end process;

END;
