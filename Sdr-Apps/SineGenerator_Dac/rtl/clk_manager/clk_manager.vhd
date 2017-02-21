library ieee;
use ieee.std_logic_1164.all;

library unisim;
use unisim.vcomponents.all;

entity clk_manager is
	port(
		--External Control
		SYS_CLK_P_i  : in  std_logic;
		SYS_CLK_N_i  : in  std_logic;
		SYS_RST_i    : in  std_logic;
		
		-- Clock out ports
		clk_62_5mhz    : out std_logic;
		
		-- Status and control signals
		RESET         : out std_logic;
		sysclk_locked : out std_logic
	);
end entity clk_manager;

architecture RTL of clk_manager is
		
	--external buffering
	signal sys_clk_i_b : std_logic;
	signal clk_ab_l : std_logic;
	signal locked : std_logic;
  -- Output clock buffering / unused connectors
  signal clkfbout         : std_logic;
  signal clkfbout_buf     : std_logic;
  signal clkout0          : std_logic;
  signal clkout1_unused   : std_logic;
  signal clkout2_unused   : std_logic;
  signal clkout3_unused   : std_logic;
  signal clkout4_unused   : std_logic;
  signal clkout5_unused   : std_logic;
  
begin

	-- External buffering
	-- Input buffering
	--------------------------------------
	clkin1_buf : IBUFGDS
	generic map(
		DIFF_TERM  => FALSE,
		IOSTANDARD => "LVPECL_33"
	)
	port map(
		O  => sys_clk_i_b,
		I  => SYS_CLK_P_i,
		IB => SYS_CLK_N_i
	);

  -- Clocking primitive
  --------------------------------------
  -- Instantiation of the PLL primitive
  --    * Unused inputs are tied off
  --    * Unused outputs are labeled unused

  pll_base_inst : PLL_BASE
  generic map
   (BANDWIDTH            => "OPTIMIZED",
    COMPENSATION         => "INTERNAL",
    DIVCLK_DIVIDE        => 1,
    CLKFBOUT_MULT        => 5,
    CLKFBOUT_PHASE       => 0.000,
    CLKOUT0_DIVIDE       => 8,
    CLKOUT0_PHASE        => 0.000,
    CLKOUT0_DUTY_CYCLE   => 0.500,
    CLKIN_PERIOD         => 10.000,
    REF_JITTER           => 0.010)
  port map
    -- Output clocks
   (CLKFBOUT            => clkfbout_buf,
    CLKOUT0             => clkout0,
    CLKOUT1             => clkout1_unused,
    CLKOUT2             => clkout2_unused,
    CLKOUT3             => clkout3_unused,
    CLKOUT4             => clkout4_unused,
    CLKOUT5             => clkout5_unused,
    -- Status and control signals
    LOCKED              => locked,
    RST                 => '0',
    -- Input clock control
    CLKFBIN             => clkfbout_buf,
    CLKIN               => sys_clk_i_b);
	
	clkout1_buf : BUFG
	port map
	(O   => clk_62_5mhz,
	 I   => clkout0);
	 
	sysclk_locked <= locked;
	RESET <= not locked;
end architecture RTL;
