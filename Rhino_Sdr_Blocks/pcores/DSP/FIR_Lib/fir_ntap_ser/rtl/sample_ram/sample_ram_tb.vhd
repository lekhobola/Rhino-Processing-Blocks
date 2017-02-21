--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   13:45:09 07/15/2014
-- Design Name:   
-- Module Name:   /home/lekhobola/Projects/serial_fir/ipcore_dir/sample_ram/sample_ram_tb.vhd
-- Project Name:  serial_fir
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: sample_ram
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
 
ENTITY sample_ram_tb IS
END sample_ram_tb;
 
ARCHITECTURE behavior OF sample_ram_tb IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
	 constant ADDR_WIDTH : natural := 2;
	 constant IN_WIDTH   : natural := 9;
	 
    COMPONENT counter 
		GENERIC(
			ADDR_WIDTH : natural
		);
		PORT(
			clk,rst,en : in  std_logic;
			dout		  : out std_logic_vector(ADDR_WIDTH - 1 downto 0)
		);
   END COMPONENT;
	
	COMPONENT shift_reg 
		GENERIC(
				IN_WIDTH   : natural;
				ADDR_WIDTH : natural
		);
		PORT(
				clk,rst,we : in  std_logic;			
				addr	  	  : in  std_logic_vector(ADDR_WIDTH - 1 downto 0);
				din     	  : in  std_logic_vector(IN_WIDTH - 1 downto 0);
				dout       : out std_logic_vector(IN_WIDTH - 1 downto 0)
		);
	END COMPONENT;	
	signal addr :  std_logic_vector(ADDR_WIDTH - 1 downto 0) := (others => '0');
    

   --Inputs
   signal clk : std_logic := '0';
   signal rst : std_logic := '0';
   signal en : std_logic := '0';
   signal we : std_logic := '0';
   signal din : std_logic_vector(8 downto 0) := (others => '0');

 	--Outputs
   signal dout : std_logic_vector(8 downto 0);

   -- Clock period definitions
   constant clk_period : time := 40 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   counter_inst : counter 
	GENERIC MAP(
		ADDR_WIDTH => ADDR_WIDTH
	)
	PORT MAP(
		clk  => clk,
		rst  => rst,
		en   => en,
		dout => addr
	);
	
	shift_reg_inst : shift_reg 
	GENERIC MAP(
			IN_WIDTH   => IN_WIDTH,
			ADDR_WIDTH => ADDR_WIDTH
	)
	PORT MAP(
			clk  => clk,
			rst  => rst,
			we   => we,
			addr => addr,
			din  => din,
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
		din  <= "001100100";
		wait until rising_edge(clk);
		we   <= '1';
		wait for clk_period;
	--	en <= '1';
		we   <= '0';
		din  <= "000000000";
		en <= '1';

      wait;
   end process;

END;
