--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   17:32:17 06/23/2014
-- Design Name:   
-- Module Name:   /home/lekhobola/projects/rhino/fft/ipcore_dir/shift_reg/shift_reg_tb.vhd
-- Project Name:  fft
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: shift_reg
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
 
ENTITY shift_reg_tb IS
END shift_reg_tb;
 
ARCHITECTURE behavior OF shift_reg_tb IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT shift_reg
	 GENERIC(
			shift_reg_data_w : natural;
			depth  : natural
	 );
    PORT(
         clk : IN  std_logic;
         rst : IN  std_logic;
         xr : IN  std_logic_vector(8 downto 0);
         xi : IN  std_logic_vector(8 downto 0);
         zr : OUT  std_logic_vector(8 downto 0);
         zi : OUT  std_logic_vector(8 downto 0)
        );
    END COMPONENT;
    

   --Inputs
   signal clk : std_logic := '0';
   signal rst : std_logic := '0';
   signal xr : std_logic_vector(8 downto 0) := (others => '0');
   signal xi : std_logic_vector(8 downto 0) := (others => '0');

 	--Outputs
   signal zr : std_logic_vector(8 downto 0);
   signal zi : std_logic_vector(8 downto 0);

   -- Clock period definitions
   constant clk_period : time := 10 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: shift_reg
	GENERIC MAP(
			shift_reg_data_w => 9,
			depth  => 1
	 )
	PORT MAP (
          clk => clk,
          rst => rst,
          xr => xr,
          xi => xi,
          zr => zr,
          zi => zi
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

     -- wait for clk_period*10;
      -- insert stimulus here 
		xr <= "000000001";
		xi <= "000000001";
		rst <= '0';
		wait for clk_period;
		xr <= "000000010";
		xi <= "000000010";
		wait for clk_period;
		xr <= "000000011";
		xi <= "000000011";
		wait for clk_period;
		xr <= "000000100";
		xi <= "000000100";
		wait for clk_period;
		xr <= "000000101";
		xi <= "000000101";
		wait for clk_period;
		xr <= "000000110";
		xi <= "000000110";
		wait for clk_period;
		xr <= "000000111";
		xi <= "000000111";
		wait for clk_period;
		xr <= "000001000";
		xi <= "000001000";
      wait;
   end process;
END;
