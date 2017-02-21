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
 
ENTITY mixer_tb IS
END mixer_tb;
 
ARCHITECTURE behavior OF mixer_tb IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
	component mixer is
	generic(
		DIN1_WIDTH : natural;
		DIN2_WIDTH : natural;
		DOUT_WIDTH : natural
	);
	port(
		din1 : in std_logic_vector (DIN1_WIDTH  - 1 downto 0);
		din2 : in std_logic_vector (DIN2_WIDTH  - 1 downto 0);
		dout : out std_logic_vector(DOUT_WIDTH - 1 downto 0)
	);
	end component mixer;
    

   --Inputs
   signal clk : std_logic := '0';
	signal rst : std_logic := '0';
   signal din1 : std_logic_vector(7 downto 0) := (others => '0');
	signal din2 : std_logic_vector(7 downto 0) := (others => '0');
	signal dout : std_logic_vector(7 downto 0) := (others => '0');

   -- Clock period definitions
   constant clk_period : time := 10 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   mixer_inst : mixer 
	generic map(
		DIN1_WIDTH => 8,
		DIN2_WIDTH => 8,
		DOUT_WIDTH => 8
	)
	port map(
		din1 => din1,
		din2 => din2,
		dout => dout
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
		din1 <= x"0A";
		din2 <= x"40";
      wait;
   end process;

END;
