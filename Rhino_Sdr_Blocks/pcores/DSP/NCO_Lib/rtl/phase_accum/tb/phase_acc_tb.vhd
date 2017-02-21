--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   17:13:53 06/05/2014
-- Design Name:   
-- Module Name:   /home/lekhobola/projects/rhino/nco/phase_accum/phase_acc_tb.vhd
-- Project Name:  nco
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: phase_acc
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
 
ENTITY phase_acc_tb IS
END phase_acc_tb;
 
ARCHITECTURE behavior OF phase_acc_tb IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
   COMPONENT phase_acc is
		generic(		
			FTW_WIDTH   : natural;
			PHASE_WIDTH : natural
		);
		port(
			clk   : in  std_logic;
			rst   : in  std_logic;
			ftw   : in  std_logic_vector(FTW_WIDTH   - 1 downto 0);
			phase : out std_logic_vector(PHASE_WIDTH - 1 downto 0)
		);
   END COMPONENT phase_acc;
    

   --Inputs
   signal clk : std_logic := '0';
   signal ftw   : std_logic_vector(7 downto 0) := (others => '0');
	signal phase : std_logic_vector(9 downto 0) := (others => '0');

   -- Clock period definitions
   constant clk_period : time := 10 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   phase_acc_inst : phase_acc 
		generic map(		
			FTW_WIDTH   => 8,
			PHASE_WIDTH => 10
		)
		port map(
			clk   => clk,
			rst   => '0',
			ftw   => ftw,
			phase => phase
		);

   -- Clock process definitions
   clk_process :process
   begin
		clk <= '0';
		wait for clk_period/2;
		clk <= '1';
		wait for clk_period/2;
   end process;
 
	
   -- Stimulus process
   stim_proc: process
   begin		
      -- hold reset state for 100 ns.
      wait for 100 ns;	

      wait for clk_period*10;

      -- insert stimulus here 
		ftw <= "00000001";
      wait;
   end process;

END;
