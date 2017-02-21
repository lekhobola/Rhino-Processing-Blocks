--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   12:30:33 07/15/2014
-- Design Name:   
-- Module Name:   /home/lekhobola/Projects/serial_fir/ipcore_dir/sample_ram/shift_reg/shift_reg_tb.vhd
-- Project Name:  serial_fir
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
    PORT(
         clk : IN  std_logic;
         rst : IN  std_logic;
         we : IN  std_logic;
         addr : IN  std_logic_vector(1 downto 0);
         din : IN  std_logic_vector(8 downto 0);
         dout : OUT  std_logic_vector(8 downto 0)
        );
    END COMPONENT;
    

   --Inputs
   signal clk : std_logic := '0';
   signal rst : std_logic := '0';
   signal we : std_logic := '0';
   signal addr : std_logic_vector(1 downto 0) := (others => '0');
   signal din : std_logic_vector(8 downto 0) := (others => '0');

 	--Outputs
   signal dout : std_logic_vector(8 downto 0);

   -- Clock period definitions
   constant clk_period : time := 10 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: shift_reg PORT MAP (
          clk => clk,
          rst => rst,
          we => we,
          addr => addr,
          din => din,
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
		din  <= "001100100";
		addr <= "00";
		we   <= '1';
		wait for clk_period;
		din  <= "000000000";
		addr <= "00";
		we   <= '0';
		wait for clk_period;
		addr <= "01";
		wait for clk_period;
		addr <= "10";
		wait for clk_period;
		addr <= "11";
      wait;
   end process;

END;
