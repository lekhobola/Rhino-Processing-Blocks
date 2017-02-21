--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   16:35:46 08/03/2014
-- Design Name:   
-- Module Name:   /home/lekhobola/Projects/serial_fir/ipcore_dir/rounder/rounder_tb.vhd
-- Project Name:  serial_fir
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: rounder
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
 
ENTITY rounder_tb IS
END rounder_tb;
 
ARCHITECTURE behavior OF rounder_tb IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT rounder
	 generic(
		IN_WIDTH  : natural := 23;
		OUT_WIDTH : natural := 12
	 );
    PORT(
         din : IN  std_logic_vector(IN_WIDTH - 1 downto 0);
         dout : OUT  std_logic_vector(OUT_WIDTH - 1 downto 0)
        );
    END COMPONENT;
    

   --Inputs
   signal din : std_logic_vector(22 downto 0) := (others => '0');

 	--Outputs
   signal dout : std_logic_vector(11 downto 0);
   -- No clocks detected in port list. Replace <clock> below with 
   -- appropriate port name 
 
   constant clock_period : time := 10 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: rounder 
	 generic map(
		IN_WIDTH  => 23,
		OUT_WIDTH => 12
	 )
	PORT MAP (
          din => din,
          dout => dout
        );

   -- Stimulus process
   stim_proc: process
   begin		
      -- hold reset state for 100 ns.
      wait for 100 ns;	

      wait for clock_period*10;

      -- insert stimulus here 
		din <= "00100011010001010011111";
		wait for clock_period;
		din <= "01001101100111111110111";
		wait for clock_period;
		din <= "00100110110010011100110";
		wait for clock_period;
		din <= "01000001101110011101011";
		wait for clock_period;
		din <= "10101100101001011000111";
      wait;
   end process;

END;
