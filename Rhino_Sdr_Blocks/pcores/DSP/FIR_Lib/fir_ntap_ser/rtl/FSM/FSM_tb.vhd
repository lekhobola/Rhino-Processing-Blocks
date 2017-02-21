--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   02:23:40 07/15/2014
-- Design Name:   
-- Module Name:   /home/lekhobola/Projects/serial_fir/ipcore_dir/FSM/FSM_tb.vhd
-- Project Name:  serial_fir
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: FSM
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
 
ENTITY FSM_tb IS
END FSM_tb;
 
ARCHITECTURE behavior OF FSM_tb IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT FSM
    PORT(
         CLK : IN  std_logic;
         RST : IN  std_logic;
         SAMPLE_RDY : IN  std_logic;
         COEFF_CNT_ZERO : IN  std_logic;
         EN_SAMPLE_CNT : OUT  std_logic;
         EN_COEFF_CNT : OUT  std_logic;
         WE_RAM : OUT  std_logic;
         CLR_ACC : OUT  std_logic;
         EN_MAC_REG : OUT  std_logic
        );
    END COMPONENT;
    

   --Inputs
   signal CLK : std_logic := '0';
   signal RST : std_logic := '0';
   signal SAMPLE_RDY : std_logic := '0';
   signal COEFF_CNT_ZERO : std_logic := '0';

 	--Outputs
   signal EN_SAMPLE_CNT : std_logic;
   signal EN_COEFF_CNT : std_logic;
   signal WE_RAM : std_logic;
   signal CLR_ACC : std_logic;
   signal EN_MAC_REG : std_logic;

   -- Clock period definitions
   constant CLK_period : time := 10 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: FSM PORT MAP (
          CLK => CLK,
          RST => RST,
          SAMPLE_RDY => SAMPLE_RDY,
          COEFF_CNT_ZERO => COEFF_CNT_ZERO,
          EN_SAMPLE_CNT => EN_SAMPLE_CNT,
          EN_COEFF_CNT => EN_COEFF_CNT,
          WE_RAM => WE_RAM,
          CLR_ACC => CLR_ACC,
          EN_MAC_REG => EN_MAC_REG
        );

   -- Clock process definitions
   CLK_process :process
   begin
		CLK <= '0';
		wait for CLK_period/2;
		CLK <= '1';
		wait for CLK_period/2;
   end process;
 

   -- Stimulus process
   stim_proc: process
   begin		
      -- hold reset state for 100 ns.
      wait for 100 ns;	

      wait for CLK_period*10;

      -- insert stimulus here 
		SAMPLE_RDY <= '1';
		wait for CLK_period;
		SAMPLE_RDY <= '0';
		wait for CLK_period*8;
		COEFF_CNT_ZERO <= '1';
		wait for CLK_period;
		COEFF_CNT_ZERO <= '0';
      wait;
   end process;

END;
