--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   22:34:03 07/16/2014
-- Design Name:   
-- Module Name:   /home/lekhobola/Projects/serial_fir/ipcore_dir/MAC/MAC_tb.vhd
-- Project Name:  serial_fir
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: MAC
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
 
ENTITY MAC_tb IS
END MAC_tb;
 
ARCHITECTURE behavior OF MAC_tb IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT MAC
	 generic(
		SAMPLE_WIDTH : natural;
		COEFF_WIDTH  : natural
	);
    PORT(
         clk : IN  std_logic;
         rst : IN  std_logic;
         clr : IN  std_logic;
         en : IN  std_logic;
         coeff : IN  std_logic_vector(3 downto 0);
         xn : IN  std_logic_vector(3 downto 0);
         yn : OUT  std_logic_vector(3 downto 0)
        );
    END COMPONENT;
    

   --Inputs
   signal clk : std_logic := '0';
   signal rst : std_logic := '0';
   signal clr : std_logic := '0';
   signal en : std_logic := '0';
   signal coeff : std_logic_vector(3 downto 0) := (others => '0');
   signal xn : std_logic_vector(3 downto 0) := (others => '0');

 	--Outputs
   signal yn : std_logic_vector(3 downto 0);

   -- Clock period definitions
   constant clk_period : time := 10 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: MAC 
	generic map(
		SAMPLE_WIDTH => 4,
		COEFF_WIDTH  => 4
	)
	PORT MAP (
          clk => clk,
          rst => rst,
          clr => clr,
          en => en,
          coeff => coeff,
          xn => xn,
          yn => yn
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
		coeff <= "0001";
		xn		<= "0010";
		wait for clk_period;
		en		<= '0';
		wait for clk_period;
		coeff <= "0011";
		xn		<= "0010";
		wait for clk_period;
		en		<= '1';
      wait;
   end process;

END;
