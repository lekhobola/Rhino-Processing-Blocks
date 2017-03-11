--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   16:36:57 06/27/2015
-- Design Name:   
-- Module Name:   /home/lekhobola/Documents/xilinx/Rhino_Sdr_Blocks/pcores/SDR/rtl/adc_eth_bridge/tb/adc_eth_bridge_tb.vhd
-- Project Name:  Rhino_Sdr_Blocks
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: adc_eth_bridge
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
 
ENTITY dsp_gbe_intercon_tb IS
END dsp_gbe_intercon_tb;
 
ARCHITECTURE behavior OF dsp_gbe_intercon_tb IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT dsp_gbe_intercon
	 generic(
		MEM_DATA_BYTES : natural;		
		MEM_DEPTH 		: natural
	);
    PORT(
         rst  : IN   std_logic;
         clk  : IN   std_logic;
			en   : in   std_logic;
			rd_en : in  std_logic;
         vld  : OUT  std_logic;
			new_pkt_rcvd : out std_logic;
         din  : IN   std_logic_vector(8 * MEM_DATA_BYTES - 1 downto 0);
         dout : OUT  std_logic_vector(8 * MEM_DATA_BYTES * MEM_DEPTH - 1 downto 0)
			--count : out std_logic_vector(7 downto 0)
        );
    END COMPONENT;
    

	--constants
	constant MEM_DATA_BYTES : natural := 1;
	constant MEM_DEPTH      : natural := 4;
   --Inputs
   signal rst : std_logic := '0';
   signal clk : std_logic := '0';
	signal en  : std_logic;
	signal rd_en : std_logic;
   signal din : std_logic_vector(8 * MEM_DATA_BYTES -1 downto 0) := (others => '0');

 	--Outputs
   signal vld : std_logic;
	signal new_pkt_rcvd : std_logic;
   signal dout : std_logic_vector(8 * MEM_DATA_BYTES * MEM_DEPTH - 1 downto 0);
	signal count :  std_logic_vector(1 downto 0);

   -- Clock period definitions
   constant clk_period : time := 10 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: dsp_gbe_intercon 
			generic map(
				MEM_DATA_BYTES => MEM_DATA_BYTES,		
				MEM_DEPTH 		=> MEM_DEPTH
			)
			PORT MAP (
          rst => rst,
          clk => clk,
			 en  => en,
			 rd_en => rd_en,
          vld => vld,
			 new_pkt_rcvd => new_pkt_rcvd,
          din => din,
          dout => dout
			-- count => count
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
		wait until rising_edge(clk);
		en  <= '1';
		din <= x"01";
		wait until rising_edge(clk);
		din <= x"02";
		wait until rising_edge(clk);
		din <= x"03";
		wait until rising_edge(clk);		
		din <= x"04";
		wait until rising_edge(clk);	
		din <= x"05";
		wait until rising_edge(clk);
		din <= x"06";
		wait until rising_edge(clk);
		din <= x"07";
		wait until rising_edge(clk);
		din <= x"08";
		wait until rising_edge(clk);
		din <= x"09";
		wait until rising_edge(clk);		
		din <= x"0A";
		wait until rising_edge(clk);	
		din <= x"0B";
		wait until rising_edge(clk);
		din <= x"0C";
		wait until rising_edge(clk);
		din <= x"0D";
		wait until rising_edge(clk);		
		din <= x"0E";
		wait until rising_edge(clk);	
		din <= x"0F";
		wait until rising_edge(clk);		
		din <= x"10";
		wait until rising_edge(clk);	
		din <= x"11";
		wait until rising_edge(clk);
		din <= x"12";
		wait until rising_edge(clk);
		din <= x"13";
		wait until rising_edge(clk);		
		din <= x"14";
		wait until rising_edge(clk);	
		din <= x"15";
		wait until rising_edge(clk);	
		din <= x"16";
		wait until rising_edge(clk);	
		din <= x"17";
		wait until rising_edge(clk);
		din <= x"18";
		wait until rising_edge(clk);
		din <= x"19";
		wait until rising_edge(clk);		
		din <= x"1A";
		wait until rising_edge(clk);	
		din <= x"1B";
		wait until rising_edge(clk);
		din <= x"1C";
		wait until rising_edge(clk);
		din <= x"1D";
		wait until rising_edge(clk);		
		din <= x"1E";
		wait until rising_edge(clk);	
		din <= x"1F";
		wait until rising_edge(clk);	
		din <= x"00";
      wait;
   end process;

END;
