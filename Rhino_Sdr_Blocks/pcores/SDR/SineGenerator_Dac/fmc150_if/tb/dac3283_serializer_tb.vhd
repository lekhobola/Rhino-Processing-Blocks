--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   21:37:34 05/27/2015
-- Design Name:   
-- Module Name:   /home/lekhobola/Downloads/dugong-master/rhino_top/dac3283_serializer_tb1.vhd
-- Project Name:  rhino_top
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: dac3283_serializer
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
 
ENTITY dac3283_serializer_tb IS
END dac3283_serializer_tb;
 
ARCHITECTURE behavior OF dac3283_serializer_tb IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT dac3283_serializer
    PORT(
         RST_I : IN  std_logic;
         DAC_CLK_O : OUT  std_logic;
         DAC_CLK_DIV4_O : OUT  std_logic;
         DAC_READY : OUT  std_logic;
         CH_C_I : IN  std_logic_vector(15 downto 0);
         CH_D_I : IN  std_logic_vector(15 downto 0);
         FMC150_CLK : IN  std_logic;
         DAC_DCLK_P : OUT  std_logic;
         DAC_DCLK_N : OUT  std_logic;
         DAC_DATA_P : OUT  std_logic_vector(7 downto 0);
         DAC_DATA_N : OUT  std_logic_vector(7 downto 0);
         FRAME_P : OUT  std_logic;
         FRAME_N : OUT  std_logic;
         IO_TEST_EN : IN  std_logic
        );
    END COMPONENT;
    

   --Inputs
   signal RST_I : std_logic := '0';
   signal CH_C_I : std_logic_vector(15 downto 0) := (others => '0');
   signal CH_D_I : std_logic_vector(15 downto 0) := (others => '0');
   signal FMC150_CLK : std_logic := '0';
   signal IO_TEST_EN : std_logic := '0';

 	--Outputs
   signal DAC_CLK_O : std_logic;
   signal DAC_CLK_DIV4_O : std_logic;
   signal DAC_READY : std_logic;
   signal DAC_DCLK_P : std_logic;
   signal DAC_DCLK_N : std_logic;
   signal DAC_DATA_P : std_logic_vector(7 downto 0);
   signal DAC_DATA_N : std_logic_vector(7 downto 0);
   signal FRAME_P : std_logic;
   signal FRAME_N : std_logic;

   -- Clock period definitions
   constant FMC150_CLK_period : time := 4.069 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: dac3283_serializer PORT MAP (
          RST_I => RST_I,
          DAC_CLK_O => DAC_CLK_O,
          DAC_CLK_DIV4_O => DAC_CLK_DIV4_O,
          DAC_READY => DAC_READY,
          CH_C_I => CH_C_I,
          CH_D_I => CH_D_I,
          FMC150_CLK => FMC150_CLK,
          DAC_DCLK_P => DAC_DCLK_P,
          DAC_DCLK_N => DAC_DCLK_N,
          DAC_DATA_P => DAC_DATA_P,
          DAC_DATA_N => DAC_DATA_N,
          FRAME_P => FRAME_P,
          FRAME_N => FRAME_N,
          IO_TEST_EN => IO_TEST_EN
        );

   -- Clock process definitions
   FMC150_CLK_process :process
   begin
		FMC150_CLK <= '0';
		wait for FMC150_CLK_period/2;
		FMC150_CLK <= '1';
		wait for FMC150_CLK_period/2;
   end process;
 

   -- Stimulus process
   stim_proc: process
   begin		
      -- hold reset state for 100 ns.
      wait for 100 ns;	

      wait for FMC150_CLK_period*10;
		IO_TEST_EN <= '0';
		CH_C_I <= x"FF00";
		CH_D_I <= x"F00F";
      -- insert stimulus here 
		
		wait until rising_edge(FRAME_P);
		CH_C_I <= x"AA00";
		CH_D_I <= x"A00A";
		
		wait until rising_edge(FRAME_P);
		CH_C_I <= x"FF00";
		CH_D_I <= x"F00F";
      wait;
   end process;

END;
