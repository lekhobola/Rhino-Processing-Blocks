--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   18:10:22 11/22/2016
-- Design Name:   
-- Module Name:   /home/lekhobola/Documents/dev/research/xilinx/RhinoBTC/pcores/UDP_1GbE/tb/cal_ipv4_checksum_tb.vhd
-- Project Name:  RhinoBTC
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: calc_ipv4_checksum
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
 
ENTITY cal_ipv4_checksum_tb IS
END cal_ipv4_checksum_tb;
 
ARCHITECTURE behavior OF cal_ipv4_checksum_tb IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT calc_ipv4_checksum
    PORT(
         clk : IN  std_logic;
         data : IN  std_logic_vector(159 downto 0);
         ready : OUT  std_logic;
         checksum : OUT  std_logic_vector(15 downto 0);
         reset : IN  std_logic
        );
    END COMPONENT;
    

   --Inputs
   signal clk : std_logic := '0';
   signal data : std_logic_vector(159 downto 0) := (others => '0');
   signal reset : std_logic := '0';

 	--Outputs
   signal ready : std_logic;
   signal checksum : std_logic_vector(15 downto 0);

   -- Clock period definitions
   constant clk_period : time := 10 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: calc_ipv4_checksum PORT MAP (
          clk => clk,
          data => data,
          ready => ready,
          checksum => checksum,
          reset => reset
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
		wait until rising_edge(clk);
			 --dst-ip(16)[15:0] | src-ip(16)[15:0] | dsp-ip(16)[31:16] | checksum(16) | src-port(16) | Flags (3) | Frag Offset (13)  | TTL (8)    | Protocol (8) | IP-Header-Length (16) | Identification | Version (4) | Header Length (4) | Diff Services (8)
		data <=  x"0001" &          x"0003" &		   x"c0a8" &			 x"0000" &       x"26CA" &    "010" &     "0000000000000" &   "01000000" &  "00010001" &       x"0022" &              x"0000" &         "0100" &       "0101" &	        "00000000";
      -- insert stimulus here 

      wait;
   end process;

END;
