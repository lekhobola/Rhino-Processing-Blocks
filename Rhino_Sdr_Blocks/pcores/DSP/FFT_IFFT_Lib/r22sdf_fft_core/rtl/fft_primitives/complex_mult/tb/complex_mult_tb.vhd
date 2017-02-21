--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   20:15:19 06/23/2014
-- Design Name:   
-- Module Name:   /home/lekhobola/Projects/fft/ipcore_dir/complex_mult/complex_mult_tb.vhd
-- Project Name:  fft
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: complex_mult
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
 
ENTITY complex_mult_tb IS
END complex_mult_tb;
 
ARCHITECTURE behavior OF complex_mult_tb IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT complex_mult
    PORT(
         ar : IN  std_logic_vector(8 downto 0);
         ai : IN  std_logic_vector(8 downto 0);
         br : IN  std_logic_vector(8 downto 0);
         bi : IN  std_logic_vector(8 downto 0);
         cr : OUT  std_logic_vector(17 downto 0);
         ci : OUT  std_logic_vector(17 downto 0)
        );
    END COMPONENT;
    

   --Inputs
   signal ar : std_logic_vector(8 downto 0) := (others => '0');
   signal ai : std_logic_vector(8 downto 0) := (others => '0');
   signal br : std_logic_vector(8 downto 0) := (others => '0');
   signal bi : std_logic_vector(8 downto 0) := (others => '0');

 	--Outputs
   signal cr : std_logic_vector(17 downto 0);
   signal ci : std_logic_vector(17 downto 0);
   -- No clocks detected in port list. Replace <clock> below with 
   -- appropriate port name 
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: complex_mult PORT MAP (
          ar => ar,
          ai => ai,
          br => br,
          bi => bi,
          cr => cr,
          ci => ci
        );

   -- Stimulus process
   stim_proc: process
   begin		
      -- hold reset state for 100 ns.
      wait for 500 ns;	

      -- insert stimulus here 
		wait for 40ns;
		ar <= "000000001"; -- 1
		ai <= "000000010"; -- j2
		br <= "000000011"; -- 3
		bi <= "000000101"; -- j5
      wait;
   end process;

END;
