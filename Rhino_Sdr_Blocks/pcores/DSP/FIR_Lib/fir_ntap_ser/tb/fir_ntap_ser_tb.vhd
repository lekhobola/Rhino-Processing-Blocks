--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   14:36:48 07/17/2014
-- Design Name:   
-- Module Name:   /home/lekhobola/Projects/serial_fir/serial_fir_tb.vhd
-- Project Name:  serial_fir
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: serial_fir
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

Library RHINO_FIR_CORE_Lib;
Use RHINO_FIR_CORE_Lib.fir_pkg.all;
--use work.fir_filter_pkg.all;
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--USE ieee.numeric_std.ALL;
 
ENTITY fir_ntap_ser_tb IS
END fir_ntap_ser_tb;
 
ARCHITECTURE behavior OF fir_ntap_ser_tb IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT fir_ntap_ser
	 generic(
		IN_WIDTH        	: natural;
		COEFFICIENT_WIDTH : natural;
		NUMBER_OF_TAPS    : natural;
		COEFFS		      : coeff_type(0 to 3)
	 );
    PORT(
         clk : in std_logic;
			rst : in std_logic;									  
			en  : in std_logic;
			vld : out std_logic;
			sample_rdy : in  std_logic;
         x : IN  std_logic_vector(7 downto 0);
         y : OUT  std_logic_vector(8 downto 0)
        );
    END COMPONENT;
    

   --Inputs
   signal rst : std_logic := '0';
   signal clk : std_logic := '0';
   signal vld,en,sample_rdy : std_logic := '0';
   signal x : std_logic_vector(7 downto 0) := (others => '0');

 	--Outputs
   signal y : std_logic_vector(8 downto 0);

   -- Clock period definitions
   constant clk_period : time := 10 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: fir_ntap_ser 
	GENERIC MAP(
		IN_WIDTH        	=> 8,
		COEFFICIENT_WIDTH => 9,
		NUMBER_OF_TAPS    => 4,
		COEFFS		      => (124,214,57,-33)
	)
	PORT MAP (
          clk => clk,
          rst => rst,
			 en  => en,
			 vld => vld,
			 sample_rdy => sample_rdy,
          x => x,
          y => y
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
		en <= '1';
      -- insert stimulus here 
		for i in 0 to 3 loop
			SAMPLE_RDY <= '1';
			x <= "01100100";
			wait for CLK_period;
			x <= "00000000";
			SAMPLE_RDY <= '0';
			wait for CLK_period * 5;
		end loop;
      wait;
   end process;

END;
