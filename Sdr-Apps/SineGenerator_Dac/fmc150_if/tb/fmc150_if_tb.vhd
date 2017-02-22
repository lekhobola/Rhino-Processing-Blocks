-------------------------------------------------------------------------------------
-- FILE NAME : ml605_fmc150_tb.vhd
--
-- AUTHOR    : Peter Kortekaas
--
-- COMPANY   : 4DSP
--
-- ITEM      : 1
--
-- UNITS     : Entity       - ml605_fmc150_tb
--             architecture - ml605_fmc150_tb_beh
--
-- LANGUAGE  : VHDL
--
-------------------------------------------------------------------------------------
-- Library declarations
library ieee;
  use ieee.std_logic_unsigned.all;
  use ieee.std_logic_misc.all;
  use ieee.std_logic_arith.all;
  use ieee.std_logic_1164.all;
library unisim;
  use unisim.vcomponents.all;
library work;

entity rhino_fmc150_tb is
end rhino_fmc150_tb;

architecture testbench of rhino_fmc150_tb is

----------------------------------------------------------------------------------------------------
-- Constant declaration
----------------------------------------------------------------------------------------------------
constant SYSCLK_PERIOD : time := 5.000 ns; -- Period of the system clock on the ML605 (Freq=200MHz)
constant DACCLK_PERIOD : time := 4.069 ns; -- Period of the DAC clock on the FMC150 (Freq=245.76MHz)
constant ADCCLK_PERIOD : time := 16.276 ns; -- Period of the ADC clock on the FMC150 (Freq=61.44MHz)

constant SW_OFF : std_logic := '0';
constant SW_ON  : std_logic := '1';

----------------------------------------------------------------------------------------------------
-- Component declaration
----------------------------------------------------------------------------------------------------
component rhino_fmc150 is
port (

  --ML605 Resources
  cpu_reset        : in    std_logic;
  sysclk_p         : in    std_logic;
  sysclk_n         : in    std_logic;
  gpio_led         : out   std_logic_vector(7 downto 0);
  gpio_dip_sw      : in    std_logic_vector(7 downto 0);
  gpio_led_c       : out   std_logic;
  gpio_led_e       : out   std_logic;
  gpio_led_n       : out   std_logic;
  gpio_led_s       : out   std_logic;
  gpio_led_w       : out   std_logic;
  gpio_sw_c        : in    std_logic;
  gpio_sw_e        : in    std_logic;
  gpio_sw_n        : in    std_logic;
  gpio_sw_s        : in    std_logic;
  gpio_sw_w        : in    std_logic;

  --Clock/Data connection to ADC on FMC150
  clk_ab_p         : in    std_logic;
  clk_ab_n         : in    std_logic;
  cha_p            : in    std_logic_vector(6 downto 0);
  cha_n            : in    std_logic_vector(6 downto 0);
  chb_p            : in    std_logic_vector(6 downto 0);
  chb_n            : in    std_logic_vector(6 downto 0);

  --Clock/Data connection to DAC on FMC150
  dac_dclk_p       : out   std_logic;
  dac_dclk_n       : out   std_logic;
  dac_data_p       : out   std_logic_vector(7 downto 0);
  dac_data_n       : out   std_logic_vector(7 downto 0);
  dac_frame_p      : out   std_logic;
  dac_frame_n      : out   std_logic;
  txenable         : out   std_logic;

  --Clock/Trigger connection to FMC150
  clk_to_fpga_p    : in    std_logic;
  clk_to_fpga_n    : in    std_logic;
  ext_trigger_p    : in    std_logic;
  ext_trigger_n    : in    std_logic;

  --Serial Peripheral Interface (SPI)
  spi_sclk         : out   std_logic;
  spi_sdata        : out   std_logic;
  adc_n_en         : out   std_logic;
  adc_sdo          : in    std_logic;
  adc_reset        : out   std_logic;

  cdce_n_en        : out   std_logic;
  cdce_sdo         : in    std_logic;
  cdce_n_reset     : out   std_logic;
  cdce_n_pd        : out   std_logic;
  ref_en           : out   std_logic;
  pll_status       : in    std_logic;

  dac_n_en         : out   std_logic;
  dac_sdo          : in    std_logic;

  mon_n_en         : out   std_logic;
  mon_sdo          : in    std_logic;
  mon_n_reset      : out   std_logic;
  mon_n_int        : in    std_logic;

  --FMC Present status
  prsnt_m2c_l      : in    std_logic

);
end component rhino_fmc150;

----------------------------------------------------------------------------------------------------
-- Signal declaration
----------------------------------------------------------------------------------------------------
signal cpu_reset     : std_logic := '1';
signal sysclk_p      : std_logic := '0';
signal sysclk_n      : std_logic := '1';

signal clk_to_fpga_p : std_logic := '0';
signal clk_to_fpga_n : std_logic := '1';

signal clk_ab_p      : std_logic := '0';
signal clk_ab_n      : std_logic := '1';
signal cha_p         : std_logic_vector(6 downto 0) := (others => '0');
signal cha_n         : std_logic_vector(6 downto 0) := (others => '1');
signal chb_p         : std_logic_vector(6 downto 0) := (others => '0');
signal chb_n         : std_logic_vector(6 downto 0) := (others => '1');

signal gpio_dip_sw   : std_logic_vector(7 downto 0);
signal gpio_sw_c     : std_logic := '0';


signal spi_sclk      : std_logic;
signal spi_sdata     : std_logic;
----------------------------------------------------------------------------------------------------
-- Begin
----------------------------------------------------------------------------------------------------
begin

----------------------------------------------------------------------------------------------------
-- Mode of operation is set through DIP Switches
-- Enable digital mode
----------------------------------------------------------------------------------------------------
gpio_dip_sw(0) <= SW_ON;
gpio_dip_sw(1) <= SW_OFF;
gpio_dip_sw(2) <= SW_OFF;
gpio_dip_sw(3) <= SW_OFF;
gpio_dip_sw(4) <= SW_OFF;
gpio_dip_sw(5) <= SW_OFF;
gpio_dip_sw(6) <= SW_OFF;
gpio_dip_sw(7) <= SW_OFF;

----------------------------------------------------------------------------------------------------
-- Trigger impulse response
----------------------------------------------------------------------------------------------------

process
begin

  gpio_sw_c <= '0';
  wait for 90 us;

  gpio_sw_c <= '1';
  wait for 1 us;

  gpio_sw_c <= '0';
  wait;

end process;

----------------------------------------------------------------------------------------------------
-- Generate reset and clock signals
----------------------------------------------------------------------------------------------------
cpu_reset <= '0' after 10 ns;

sysclk_p <= not sysclk_p after SYSCLK_PERIOD / 2;
sysclk_n <= not sysclk_n after SYSCLK_PERIOD / 2;

clk_to_fpga_p <= not clk_to_fpga_p after DACCLK_PERIOD / 2;
clk_to_fpga_n <= not clk_to_fpga_n after DACCLK_PERIOD / 2;

clk_ab_p <= not clk_ab_p after ADCCLK_PERIOD / 2;
clk_ab_n <= not clk_ab_n after ADCCLK_PERIOD / 2;

----------------------------------------------------------------------------------------------------
-- Generate ADC data
----------------------------------------------------------------------------------------------------
process(clk_ab_p)
  variable ramp : std_logic_vector(13 downto 0) := (others => '0');
begin
  if (rising_edge(clk_ab_p) or rising_edge(clk_ab_n)) then
    -- Increment ramp value
    if (rising_edge(clk_ab_p)) then
      ramp := ramp + 1;
    end if;
    -- Output even bits
    if (rising_edge(clk_ab_p)) then
      cha_p <= ramp(12) & ramp(10) & ramp(08) & ramp(06) & ramp(04) & ramp(02) & ramp(00);
      cha_n <= not (ramp(12) & ramp(10) & ramp(08) & ramp(06) & ramp(04) & ramp(02) & ramp(00));
      chb_p <= ramp(12) & ramp(10) & ramp(08) & ramp(06) & ramp(04) & ramp(02) & ramp(00);
      chb_n <= not (ramp(12) & ramp(10) & ramp(08) & ramp(06) & ramp(04) & ramp(02) & ramp(00));
    -- Output uneven bits
    elsif (rising_edge(clk_ab_n)) then
      cha_p <= ramp(13) & ramp(11) & ramp(09) & ramp(07) & ramp(05) & ramp(03) & ramp(01);
      cha_n <= not (ramp(13) & ramp(11) & ramp(09) & ramp(07) & ramp(05) & ramp(03) & ramp(01));
      chb_p <= ramp(13) & ramp(11) & ramp(09) & ramp(07) & ramp(05) & ramp(03) & ramp(01);
      chb_n <= not (ramp(13) & ramp(11) & ramp(09) & ramp(07) & ramp(05) & ramp(03) & ramp(01));
    end if;
  end if;
end process;

----------------------------------------------------------------------------------------------------
-- Unit under test: FPGA on ML605
----------------------------------------------------------------------------------------------------
uut: rhino_fmc150
port map (
  cpu_reset        => cpu_reset,
  sysclk_p         => sysclk_p,
  sysclk_n         => sysclk_n,
  gpio_led         => open,
  gpio_dip_sw      => gpio_dip_sw,
  gpio_led_c       => open,
  gpio_led_e       => open,
  gpio_led_n       => open,
  gpio_led_s       => open,
  gpio_led_w       => open,
  gpio_sw_c        => gpio_sw_c,
  gpio_sw_e        => '0',
  gpio_sw_n        => '0',
  gpio_sw_s        => '0',
  gpio_sw_w        => '0',
  clk_ab_p         => clk_ab_p,
  clk_ab_n         => clk_ab_n,
  cha_p            => cha_p,
  cha_n            => cha_n,
  chb_p            => chb_p,
  chb_n            => chb_n,
  dac_dclk_p       => open,
  dac_dclk_n       => open,
  dac_data_p       => open,
  dac_data_n       => open,
  dac_frame_p      => open,
  dac_frame_n      => open,
  txenable         => open,
  clk_to_fpga_p    => clk_to_fpga_p,
  clk_to_fpga_n    => clk_to_fpga_n,
  ext_trigger_p    => '0',
  ext_trigger_n    => '1',
  spi_sclk         => spi_sclk,
  spi_sdata        => spi_sdata,
  adc_n_en         => open,
  adc_sdo          => 'Z',
  adc_reset        => open,
  cdce_n_en        => open,
  cdce_sdo         => 'Z',
  cdce_n_reset     => open,
  cdce_n_pd        => open,
  ref_en           => open,
  pll_status       => '1',
  dac_n_en         => open,
  dac_sdo          => 'Z',
  mon_n_en         => open,
  mon_sdo          => 'Z',
  mon_n_reset      => open,
  mon_n_int        => '1',
  prsnt_m2c_l      => '0'
);

----------------------------------------------------------------------------------------------------
-- End
----------------------------------------------------------------------------------------------------
end testbench;
