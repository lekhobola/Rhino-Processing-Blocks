--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   16:17:25 06/05/2014
-- Design Name:   
-- Module Name:   /home/lekhobola/projects/rhino/nco/wav_gen/wav_gen_tb.vhd
-- Project Name:  nco
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: wav_gen
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
use ieee.std_logic_arith.all;
 
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--USE ieee.numeric_std.ALL;
 
ENTITY wav_gen_tb IS
END wav_gen_tb;
 
ARCHITECTURE behavior OF wav_gen_tb IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT wav_gen
    GENERIC(
				AMPL_WIDTH  : natural;
				PHASE_WIDTH : natural
		);
		PORT(
				clk,rst : in std_logic;
				phase	  : in std_logic_vector (PHASE_WIDTH - 1 downto 0);
				iout    : out std_logic_vector(AMPL_WIDTH  - 1 downto 0);
				qout    : out std_logic_vector(AMPL_WIDTH  - 1 downto 0)
		);
    END COMPONENT;   

   --Inputs
   signal clk : std_logic := '0';
   signal rst : std_logic := '0';
   signal phase : std_logic_vector(9 downto 0)     := (others => '0');
	signal iout,qout : std_logic_vector(7 downto 0) := (others => '0');

   -- Clock period definitions
   constant clk_period : time := 10 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   WAVE_GENERATOR : wav_gen
	GENERIC MAP(
			AMPL_WIDTH  => 8,
			PHASE_WIDTH => 10
	)
	PORT MAP(
			clk   => CLK,
			rst   => RST,
			phase => phase,
			iout  => IOUT,
			qout  => QOUT
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
		wait for 5 ns;

      -- insert stimulus here 
		wait until falling_edge(clk);
		for i in 0 to 1023 loop
			phase <= conv_std_logic_vector(i,10);
			wait until falling_edge(clk);
		end loop;
      wait;
   end process;

END;
