--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   13:42:25 06/12/2014
-- Design Name:   
-- Module Name:   /home/lekhobola/projects/rhino/rn_fir/odd_sym_fir/odd_sym_fir_tb.vhd
-- Project Name:  rn_fir
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: odd_sym_fir
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
USE IEEE.STD_LOGIC_UNSIGNED.ALL;
use work.fir_filter_pkg.all;
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--USE ieee.numeric_std.ALL;
 
ENTITY fir_ntap_avg_par_tb IS
END fir_ntap_avg_par_tb;
 
ARCHITECTURE behavior OF fir_ntap_avg_par_tb IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
	component fir_ntap_avg_par is
	generic(
		DIN_WIDTH	   : natural;
		DOUT_WIDTH     : natural;
		COEFF_WIDTH    : natural;
		NUMBER_OF_TAPS	: natural
	);
	port(
		clk : in std_logic;
		rst : in std_logic;									  
		en  : in std_logic;
		vld : out std_logic;
		din  : in  std_logic_vector(DIN_WIDTH  - 1 downto 0);
		dout : out std_logic_vector(DOUT_WIDTH - 1 downto 0)	  -- output data
	);
	end component fir_ntap_avg_par;
    

   --Inputs
   signal clk : std_logic := '0';
   signal rst,en,vld : std_logic := '0';
   signal din : std_logic_vector(7 downto 0) := (others => '0');

 	--Outputs
   signal  dout : std_logic_vector(11 downto 0);

   -- Clock period definitions
   constant clk_period : time := 10 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: fir_ntap_avg_par 
		GENERIC MAP(
			DIN_WIDTH   => 8,  							-- input width of data and coefficients  	
			DOUT_WIDTH  => 12,
			COEFF_WIDTH => 8,
			NUMBER_OF_TAPS => 16
	   )
		PORT MAP (
          clk => clk,
          rst => rst,
			 en  => en,
			 vld => vld,
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
		wait until falling_edge(clk);
		rst <= '0';
		en  <= '1';
		din <= x"78";
		wait until falling_edge(clk);
		din <= x"64";
		wait until falling_edge(clk);
		din <= x"50";
		wait until falling_edge(clk);
		din <= x"3C";
		wait until falling_edge(clk);
		din <= x"28";
		wait until falling_edge(clk);
		din <= x"14";
		wait until falling_edge(clk);
		din <= x"5A";
		wait until falling_edge(clk);
		din <= x"46";
		wait until falling_edge(clk);
		din <= x"78";
		wait until falling_edge(clk);
		din <= x"64";
		wait until falling_edge(clk);
		din <= x"50";
		wait until falling_edge(clk);
		din <= x"3C";
		wait until falling_edge(clk);
		din <= x"28";
		wait until falling_edge(clk);
		din <= x"14";
		wait until falling_edge(clk);
		din <= x"5A";
		wait until falling_edge(clk);
		din <= x"46";
		wait until falling_edge(clk);
		din <= "00000000"; 
      wait;
   end process;
END;
