--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   10:27:42 06/27/2015
-- Design Name:   
-- Module Name:   /home/lekhobola/Documents/xilinx/Rhino_Sdr_Blocks/pcores/IOs/UDP_1GbE_if/rtl/clk_manager/clk_manager_tb.vhd
-- Project Name:  Rhino_Sdr_Blocks
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: clk_manager
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
 
ENTITY clk_manager_tb IS
END clk_manager_tb;
 
ARCHITECTURE behavior OF clk_manager_tb IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT clk_manager
    PORT(
         SYS_CLK_P_i : IN  std_logic;
         SYS_CLK_N_i : IN  std_logic;
         SYS_RST_i : IN  std_logic;
         clk_ab_p : IN  std_logic;
         clk_ab_n : IN  std_logic;
         clk_125mhz : OUT  std_logic;
         clk_122_88mhz : OUT  std_logic;
         clk_100mhz : OUT  std_logic;
         clk_61_44mhz : OUT  std_logic;
         clk_25mhz : OUT  std_logic;
         RESET : OUT  std_logic;
         sysclk_locked : OUT  std_logic;
         adcclk_locked : OUT  std_logic
        );
    END COMPONENT;
    

   --Inputs
   signal SYS_CLK_P_i : std_logic := '0';
   signal SYS_CLK_N_i : std_logic := '0';
   signal SYS_RST_i : std_logic := '0';
   signal clk_ab_p : std_logic := '0';
   signal clk_ab_n : std_logic := '0';

 	--Outputs
   signal clk_125mhz : std_logic;
   signal clk_122_88mhz : std_logic;
   signal clk_100mhz : std_logic;
   signal clk_61_44mhz : std_logic;
   signal clk_25mhz : std_logic;
   signal RESET : std_logic;
   signal sysclk_locked : std_logic;
   signal adcclk_locked : std_logic;

   -- Clock period definitions
   constant clk_ab_period : time := 16.27604167 ns;
   constant SYS_CLK_period : time := 10 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: clk_manager PORT MAP (
          SYS_CLK_P_i => SYS_CLK_P_i,
          SYS_CLK_N_i => SYS_CLK_N_i,
          SYS_RST_i => SYS_RST_i,
          clk_ab_p => clk_ab_p,
          clk_ab_n => clk_ab_n,
          clk_125mhz => clk_125mhz,
          clk_122_88mhz => clk_122_88mhz,
          clk_100mhz => clk_100mhz,
          clk_61_44mhz => clk_61_44mhz,
          clk_25mhz => clk_25mhz,
          RESET => RESET,
          sysclk_locked => sysclk_locked,
          adcclk_locked => adcclk_locked
        );

   -- Clock process definitions
   clk_ab_p_process :process
   begin
		clk_ab_p <= '0';
		clk_ab_n <= '1';
		wait for clk_ab_period/2;
		clk_ab_p <= '1';
		clk_ab_n <= '0';
		wait for clk_ab_period/2;
   end process; 
	
	SYS_CLK_process :process
   begin
		SYS_CLK_P_i <= '0';
		SYS_CLK_N_i <= '1';
		wait for SYS_CLK_period/2;
		SYS_CLK_P_i <= '1';
		SYS_CLK_N_i <= '0';
		wait for SYS_CLK_period/2;
   end process; 

   -- Stimulus process
   stim_proc: process
   begin		
      -- hold reset state for 100 ns.
      wait for 100 ns;	

      wait for clk_ab_period*10;

      -- insert stimulus here 

      wait;
   end process;

END;
