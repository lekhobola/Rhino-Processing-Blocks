-------------------------------------------------------------------------------------
-- FILE NAME : fmc150_spi_ctrl.vhd
--
-- AUTHOR    : Peter Kortekaas
--
-- COMPANY   : 4DSP
--
-- ITEM      : 1
--
-- UNITS     : Entity       - fmc150_spi_ctrl
--             architecture - fmc150_spi_ctrl_syn
--
-- LANGUAGE  : VHDL
--
-------------------------------------------------------------------------------------
--
-------------------------------------------------------------------------------------
-- DESCRIPTION
-- ===========
--
-- This file initialises the internal registers of devices on the FMC150 from
-- FPGA ROM through SPI communication busses.
--
-------------------------------------------------------------------------------------

library ieee;
  use ieee.std_logic_unsigned.all;
  use ieee.std_logic_misc.all;
  use ieee.std_logic_arith.all;
  use ieee.std_logic_1164.all;
library unisim;
  use unisim.vcomponents.all;
library work;

entity fmc150_spi_ctrl is
port (

  init_done			 : out std_logic;
  -- VIO command interface
  rd_n_wr          : in    std_logic;
  addr             : in    std_logic_vector(15 downto 0);
  idata            : in    std_logic_vector(31 downto 0);
  odata            : out   std_logic_vector(31 downto 0);
  busy             : out   std_logic;

  cdce72010_valid  : in    std_logic;
  ads62p49_valid   : in    std_logic;
  dac3283_valid    : in    std_logic;
  amc7823_valid    : in    std_logic;

  rst              : in    std_logic;
  clk              : in    std_logic;
  external_clock   : in    std_logic;

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

  prsnt_m2c_l      : in    std_logic

);
end fmc150_spi_ctrl;

architecture fmc150_spi_ctrl_syn of fmc150_spi_ctrl is

----------------------------------------------------------------------------------------------------
-- Constant declaration
----------------------------------------------------------------------------------------------------


----------------------------------------------------------------------------------------------------
--Component declaration
----------------------------------------------------------------------------------------------------
component cdce72010_ctrl is
generic (
  START_ADDR      : std_logic_vector(27 downto 0) := x"0000000";
  STOP_ADDR       : std_logic_vector(27 downto 0) := x"00000FF"
);
port (
  rst             : in  std_logic;
  clk             : in  std_logic;
  -- Sequence interface
  init_ena        : in  std_logic;
  init_done       : out std_logic;
  -- Command Interface
  clk_cmd         : in  std_logic;
  in_cmd_val      : in  std_logic;
  in_cmd          : in  std_logic_vector(63 downto 0);
  out_cmd_val     : out std_logic;
  out_cmd         : out std_logic_vector(63 downto 0);
  in_cmd_busy     : out std_logic;
  -- Direct control
  external_clock  : in  std_logic;
  cdce_n_reset    : out std_logic;
  cdce_n_pd       : out std_logic;
  ref_en          : out std_logic;
  pll_status      : in  std_logic;
  -- SPI control
  spi_n_oe        : out std_logic;
  spi_n_cs        : out std_logic;
  spi_sclk        : out std_logic;
  spi_sdo         : out std_logic;
  spi_sdi         : in  std_logic
);
end component;

component ads62p49_ctrl is
generic (
  START_ADDR      : std_logic_vector(27 downto 0) := x"0000000";
  STOP_ADDR       : std_logic_vector(27 downto 0) := x"00000FF"
);
port (
  rst             : in  std_logic;
  clk             : in  std_logic;
  -- Sequence interface
  init_ena        : in  std_logic;
  init_done       : out std_logic;
  -- Command Interface
  clk_cmd         : in  std_logic;
  in_cmd_val      : in  std_logic;
  in_cmd          : in  std_logic_vector(63 downto 0);
  out_cmd_val     : out std_logic;
  out_cmd         : out std_logic_vector(63 downto 0);
  in_cmd_busy     : out std_logic;
  -- Direct control
  adc_reset       : out std_logic;
  -- SPI control
  spi_n_oe        : out std_logic;
  spi_n_cs        : out std_logic;
  spi_sclk        : out std_logic;
  spi_sdo         : out std_logic;
  spi_sdi         : in  std_logic
);
end component;

component dac3283_ctrl is
generic (
  START_ADDR      : std_logic_vector(27 downto 0) := x"0000000";
  STOP_ADDR       : std_logic_vector(27 downto 0) := x"00000FF"
);
port (
  rst             : in  std_logic;
  clk             : in  std_logic;
  -- Sequence interface
  init_ena        : in  std_logic;
  init_done       : out std_logic;
  -- Command Interface
  clk_cmd         : in  std_logic;
  in_cmd_val      : in  std_logic;
  in_cmd          : in  std_logic_vector(63 downto 0);
  out_cmd_val     : out std_logic;
  out_cmd         : out std_logic_vector(63 downto 0);
  in_cmd_busy     : out std_logic;
  -- SPI control
  spi_n_oe        : out std_logic;
  spi_n_cs        : out std_logic;
  spi_sclk        : out std_logic;
  spi_sdo         : out std_logic;
  spi_sdi         : in  std_logic
);
end component;

component amc7823_ctrl is
generic (
  START_ADDR      : std_logic_vector(27 downto 0) := x"0000000";
  STOP_ADDR       : std_logic_vector(27 downto 0) := x"00000FF"
);
port (
  rst             : in  std_logic;
  clk             : in  std_logic;
  -- Sequence interface
  init_ena        : in  std_logic;
  init_done       : out std_logic;
  -- Command Interface
  clk_cmd         : in  std_logic;
  in_cmd_val      : in  std_logic;
  in_cmd          : in  std_logic_vector(63 downto 0);
  out_cmd_val     : out std_logic;
  out_cmd         : out std_logic_vector(63 downto 0);
  in_cmd_busy     : out std_logic;
  -- Direct control
  mon_n_reset     : out std_logic;
  mon_n_int       : in  std_logic;
  -- SPI control
  spi_n_oe        : out std_logic;
  spi_n_cs        : out std_logic;
  spi_sclk        : out std_logic;
  spi_sdo         : out std_logic;
  spi_sdi         : in  std_logic
);
end component;

----------------------------------------------------------------------------------------------------
--Signal declaration
----------------------------------------------------------------------------------------------------
signal in_cmd                : std_logic_vector(63 downto 0) := (others => '0');

signal cdce72010_valid_prev  : std_logic := '0';
signal cdce72010_in_cmd_val  : std_logic := '0';
signal cdce72010_out_cmd_val : std_logic := '0';
signal cdce72010_out_cmd     : std_logic_vector(63 downto 0) := (others => '0');
signal cdce72010_in_cmd_busy : std_logic := '0';

signal ads62p49_valid_prev   : std_logic := '0';
signal ads62p49_in_cmd_val   : std_logic := '0';
signal ads62p49_out_cmd_val  : std_logic := '0';
signal ads62p49_out_cmd      : std_logic_vector(63 downto 0) := (others => '0');
signal ads62p49_in_cmd_busy  : std_logic := '0';

signal dac3283_valid_prev    : std_logic := '0';
signal dac3283_in_cmd_val    : std_logic := '0';
signal dac3283_out_cmd_val   : std_logic := '0';
signal dac3283_out_cmd       : std_logic_vector(63 downto 0) := (others => '0');
signal dac3283_in_cmd_busy   : std_logic := '0';

signal amc7823_valid_prev    : std_logic := '0';
signal amc7823_in_cmd_val    : std_logic := '0';
signal amc7823_out_cmd_val   : std_logic := '0';
signal amc7823_out_cmd       : std_logic_vector(63 downto 0) := (others => '0');
signal amc7823_in_cmd_busy   : std_logic := '0';

signal init_ena_cdce72010    : std_logic := '0';
signal init_done_cdce72010   : std_logic := '0';
signal init_ena_ads62p49     : std_logic := '0';
signal init_done_ads62p49    : std_logic := '0';
signal init_ena_dac3283      : std_logic := '0';
signal init_done_dac3283     : std_logic := '0';
signal init_ena_amc7823      : std_logic := '0';
signal init_done_amc7823     : std_logic := '0';

signal             spi_n_oe0 : std_logic_vector(3 downto 0) := (others => '0');
signal             spi_n_cs0 : std_logic_vector(3 downto 0) := (others => '0');
signal             spi_sclk0 : std_logic_vector(3 downto 0) := (others => '0');
signal              spi_sdo0 : std_logic_vector(3 downto 0) := (others => '0');
signal              spi_sdi0 : std_logic_vector(3 downto 0) := (others => '0');

begin

----------------------------------------------------------------------------------------------------
-- Input control
----------------------------------------------------------------------------------------------------
process(clk)
begin
  if (rising_edge(clk)) then

    cdce72010_valid_prev <= cdce72010_valid;
    ads62p49_valid_prev  <= ads62p49_valid;
    dac3283_valid_prev   <= dac3283_valid;
    amc7823_valid_prev   <= amc7823_valid;

    cdce72010_in_cmd_val <= cdce72010_valid xor cdce72010_valid_prev;
    ads62p49_in_cmd_val  <= ads62p49_valid  xor ads62p49_valid_prev;
    dac3283_in_cmd_val   <= dac3283_valid   xor dac3283_valid_prev;
    amc7823_in_cmd_val   <= amc7823_valid   xor amc7823_valid_prev;

    if (rd_n_wr = '0') then
      in_cmd(63 downto 60) <= x"1"; -- write command
    else
      in_cmd(63 downto 60) <= x"2"; -- read command
    end if;
    in_cmd(59 downto 32) <= x"000" & addr; -- address
    in_cmd(31 downto 00) <= idata; -- data

  end if;
end process;

----------------------------------------------------------------------------------------------------
-- Output control
----------------------------------------------------------------------------------------------------
process(clk)
begin
  if (rising_edge(clk)) then

    busy <= cdce72010_in_cmd_busy or
      ads62p49_in_cmd_busy or
      dac3283_in_cmd_busy or
      amc7823_in_cmd_busy;

    if (cdce72010_out_cmd_val = '1') then
      odata <= cdce72010_out_cmd(31 downto 0);
    elsif (ads62p49_out_cmd_val = '1') then
      odata <= ads62p49_out_cmd(31 downto 0);
    elsif (dac3283_out_cmd_val = '1') then
      odata <= dac3283_out_cmd(31 downto 0);
    elsif (amc7823_out_cmd_val = '1') then
      odata <= amc7823_out_cmd(31 downto 0);
    end if;

  end if;
end process;
----------------------------------------------------------------------------------------------------
-- SPI Interface controlling the clock IC
----------------------------------------------------------------------------------------------------
cdce72010_ctrl_inst : cdce72010_ctrl
generic map (
  START_ADDR      => x"0000000",
  STOP_ADDR       => x"FFFFFFF"
)
port map (
  rst             => rst,
  clk             => clk,

  init_ena        => init_ena_cdce72010,
  init_done       => init_done_cdce72010,

  clk_cmd         => clk,
  in_cmd_val      => cdce72010_in_cmd_val,
  in_cmd          => in_cmd,
  out_cmd_val     => cdce72010_out_cmd_val,
  out_cmd         => cdce72010_out_cmd,
  in_cmd_busy     => cdce72010_in_cmd_busy,

  external_clock  => external_clock,
  cdce_n_reset    => cdce_n_reset,
  cdce_n_pd       => cdce_n_pd,
  ref_en          => ref_en,
  pll_status      => pll_status,

  spi_n_oe        => spi_n_oe0(0),
  spi_n_cs        => spi_n_cs0(0),
  spi_sclk        => spi_sclk0(0),
  spi_sdo         => spi_sdo0(0),
  spi_sdi         => spi_sdi0(0)
);

----------------------------------------------------------------------------------------------------
-- SPI interface controlling ADC chip
----------------------------------------------------------------------------------------------------
ads62p49_ctrl_inst : ads62p49_ctrl
generic map (
  START_ADDR      => x"0000000",
  STOP_ADDR       => x"FFFFFFF"
)
port map (
  rst             => rst,
  clk             => clk,

  init_ena        => init_ena_ads62p49,
  init_done       => init_done_ads62p49,

  clk_cmd         => clk,
  in_cmd_val      => ads62p49_in_cmd_val,
  in_cmd          => in_cmd,
  out_cmd_val     => ads62p49_out_cmd_val,
  out_cmd         => ads62p49_out_cmd,
  in_cmd_busy     => ads62p49_in_cmd_busy,

  adc_reset       => adc_reset,

  spi_n_oe        => spi_n_oe0(1),
  spi_n_cs        => spi_n_cs0(1),
  spi_sclk        => spi_sclk0(1),
  spi_sdo         => spi_sdo0(1),
  spi_sdi         => spi_sdi0(1)
);

----------------------------------------------------------------------------------------------------
-- SPI interface controlling DAC chip
----------------------------------------------------------------------------------------------------
dac3283_ctrl_inst : dac3283_ctrl
generic map (
  START_ADDR      => x"0000000",
  STOP_ADDR       => x"FFFFFFF"
)
port map (
  rst             => rst,
  clk             => clk,

  init_ena        => init_ena_dac3283,
  init_done       => init_done_dac3283,

  clk_cmd         => clk,
  in_cmd_val      => dac3283_in_cmd_val,
  in_cmd          => in_cmd,
  out_cmd_val     => dac3283_out_cmd_val,
  out_cmd         => dac3283_out_cmd,
  in_cmd_busy     => dac3283_in_cmd_busy,

  spi_n_oe        => spi_n_oe0(2),
  spi_n_cs        => spi_n_cs0(2),
  spi_sclk        => spi_sclk0(2),
  spi_sdo         => spi_sdo0(2),
  spi_sdi         => spi_sdi0(2)
);

----------------------------------------------------------------------------------------------------
-- SPI interface controlling Monitoring chip
----------------------------------------------------------------------------------------------------
amc7823_ctrl_inst : amc7823_ctrl
generic map (
  START_ADDR      => x"0000000",
  STOP_ADDR       => x"FFFFFFF"
)
port map (
  rst             => rst,
  clk             => clk,

  init_ena        => init_ena_amc7823,
  init_done       => init_done_amc7823,

  clk_cmd         => clk,
  in_cmd_val      => amc7823_in_cmd_val,
  in_cmd          => in_cmd,
  out_cmd_val     => amc7823_out_cmd_val,
  out_cmd         => amc7823_out_cmd,
  in_cmd_busy     => amc7823_in_cmd_busy,

  mon_n_reset     => mon_n_reset,
  mon_n_int       => mon_n_int,

  spi_n_oe        => spi_n_oe0(3),
  spi_n_cs        => spi_n_cs0(3),
  spi_sclk        => spi_sclk0(3),
  spi_sdo         => spi_sdo0(3),
  spi_sdi         => spi_sdi0(3)
);

----------------------------------------------------------------------------------------------------
-- SPI PHY, shared SPI bus
----------------------------------------------------------------------------------------------------
spi_sclk <= spi_sclk0(0) when spi_n_cs0(0) = '0' else
            spi_sclk0(1) when spi_n_cs0(1) = '0' else
            spi_sclk0(2) when spi_n_cs0(2) = '0' else
            spi_sclk0(3) when spi_n_cs0(3) = '0' else '0';

spi_sdata <= spi_sdo0(0) when spi_n_oe0(0) = '0' else
             spi_sdo0(1) when spi_n_oe0(1) = '0' else
             spi_sdo0(2) when spi_n_oe0(2) = '0' else
             spi_sdo0(3) when spi_n_oe0(3) = '0' else '0';

cdce_n_en <= spi_n_cs0(0);
adc_n_en  <= spi_n_cs0(1);
dac_n_en  <= spi_n_cs0(2);
mon_n_en  <= spi_n_cs0(3);

spi_sdi0(0) <= cdce_sdo;
spi_sdi0(1) <= adc_sdo;
spi_sdi0(2) <= dac_sdo;
spi_sdi0(3) <= mon_sdo;

----------------------------------------------------------------------------------------------------
-- Sequence SPI initialization
----------------------------------------------------------------------------------------------------
init_ena_cdce72010 <= '1';
init_ena_ads62p49  <= init_done_cdce72010;
init_ena_dac3283   <= init_done_ads62p49;
init_ena_amc7823   <= init_done_dac3283;
init_done <= init_done_amc7823;
----------------------------------------------------------------------------------------------------
-- End
----------------------------------------------------------------------------------------------------
end fmc150_spi_ctrl_syn;
