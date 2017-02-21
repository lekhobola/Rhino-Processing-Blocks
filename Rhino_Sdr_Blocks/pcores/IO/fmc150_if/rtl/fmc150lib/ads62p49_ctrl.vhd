-------------------------------------------------------------------------------------
-- FILE NAME : ads62p49_ctrl.vhd
--
-- AUTHOR    : Peter Kortekaas
--
-- COMPANY   : 4DSP
--
-- ITEM      : 1
--
-- UNITS     : Entity       - ads62p49_ctrl
--             architecture - ads62p49_ctrl_syn
--
-- LANGUAGE  : VHDL
--
-------------------------------------------------------------------------------------
--
-------------------------------------------------------------------------------------
-- DESCRIPTION
-- ===========
--
-- This file initialises the internal registers in the ADS62P49 from FPGA ROM
-- through SPI communication bus.
--
-------------------------------------------------------------------------------------
library ieee;
  use ieee.std_logic_1164.all;
  use ieee.std_logic_arith.all;
  use ieee.std_logic_misc.all;
  use ieee.std_logic_unsigned.all;

entity ads62p49_ctrl is
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
end ads62p49_ctrl;

architecture ads62p49_ctrl_syn of ads62p49_ctrl is

component fmc150_stellar_cmd is
generic
(
  START_ADDR           : std_logic_vector(27 downto 0) := x"0000000";
  STOP_ADDR            : std_logic_vector(27 downto 0) := x"00000FF"
);
port
(
  reset                : in  std_logic;
  -- Command Interface
  clk_cmd              : in  std_logic;                     --cmd_in and cmd_out are synchronous to this clock;
  out_cmd              : out std_logic_vector(63 downto 0);
  out_cmd_val          : out std_logic;
  in_cmd               : in  std_logic_vector(63 downto 0);
  in_cmd_val           : in  std_logic;
  -- Register interface
  clk_reg              : in  std_logic;                     --register interface is synchronous to this clock
  out_reg              : out std_logic_vector(31 downto 0); --caries the out register data
  out_reg_val          : out std_logic;                     --the out_reg has valid data  (pulse)
  out_reg_addr         : out std_logic_vector(27 downto 0); --out register address
  in_reg               : in  std_logic_vector(31 downto 0); --requested register data is placed on this bus
  in_reg_val           : in  std_logic;                     --pulse to indicate requested register is valid
  in_reg_req           : out std_logic;                     --pulse to request data
  in_reg_addr          : out std_logic_vector(27 downto 0);  --requested address
  --mailbox interface
  mbx_in_reg           : in  std_logic_vector(31 downto 0); --value of the mailbox to send
  mbx_in_val           : in  std_logic                      --pulse to indicate mailbox is valid
);
end component fmc150_stellar_cmd;

component  pulse2pulse
port (
  rst      : in  std_logic;
  in_clk   : in  std_logic;
  out_clk  : in  std_logic;
  pulsein  : in  std_logic;
  pulseout : out std_logic;
  inbusy   : out std_logic
);
end component;

component ads62p49_init_mem is
port (
  clka  : in  std_logic;
  addra : in  std_logic_vector(4 downto 0);
  douta : out std_logic_vector(15 downto 0)
);
end component;

constant ADDR_GLOBAL  : std_logic_vector(27 downto 0) := x"0000077";
constant ADDR_MAX_WR  : std_logic_vector(27 downto 0) := x"0000076";
constant ADDR_MAX_RD  : std_logic_vector(27 downto 0) := x"0000076";


type sh_states is (idle, instruct, data_io, data_valid);
signal sh_state       : sh_states;

signal serial_clk     : std_logic := '0';
signal sclk_ext       : std_logic := '0';

signal out_reg_val    : std_logic := '0';
signal out_reg_addr   : std_logic_vector(27 downto 0)  := (others => '0');
signal out_reg        : std_logic_vector(31 downto 0)  := (others => '0');

signal in_reg_req     : std_logic := '0';
signal in_reg_addr    : std_logic_vector(27 downto 0)  := (others => '0');
signal in_reg_val     : std_logic := '0';
signal in_reg         : std_logic_vector(31 downto 0)   := (others => '0');

signal done_sclk      : std_logic := '0';
signal init_done_sclk : std_logic := '0';
signal init_done_tmp  : std_logic := '0';
signal init_done_prev : std_logic := '0';

signal init           : std_logic := '0';
signal init_tmp       : std_logic := '0';
signal init_reg       : std_logic := '0';
signal reset          : std_logic := '0';

signal inst_val       : std_logic := '0';
signal inst_reg_val   : std_logic := '0';
signal inst_rw        : std_logic := '0';
signal inst_reg       : std_logic_vector(7 downto 0)  := (others => '0');
signal data_reg       : std_logic_vector(7 downto 0)  := (others => '0');

signal sh_counter     : integer;
signal shifting       : std_logic := '0';
signal read_n_write   : std_logic := '0';
signal ncs_int        : std_logic := '0';
signal busy           : std_logic := '0';
signal sdi            : std_logic := '0';

signal shift_reg      : std_logic_vector(15 downto 0)  := (others => '0');
signal init_address   : std_logic_vector(4 downto 0)  := (others => '0');
signal init_data      : std_logic_vector(15 downto 0) := (others => '0');

signal read_byte_val  : std_logic := '0';
signal data_read_val  : std_logic := '0';
signal data_read      : std_logic_vector(7 downto 0) := (others => '0');

begin

----------------------------------------------------------------------------------------------------
-- Generate serial clock (max 20MHz)
----------------------------------------------------------------------------------------------------

process (clk)
  -- Divide by 2^4 = 16, CLKmax = 16 x 20MHz = 320MHz
  variable clk_div : std_logic_vector(3 downto 0) := (others => '0');
begin
  if (rising_edge(clk)) then
    clk_div    := clk_div + '1';
    -- The slave samples the data on the rising edge of SCLK.
    -- therefore we make sure the external clock is slightly
    -- after the internal clock.
    serial_clk <= clk_div(clk_div'length-1);
    sclk_ext   <= serial_clk;
  end if;
end process;

----------------------------------------------------------------------------------------------------
-- Stellar Command Interface
----------------------------------------------------------------------------------------------------

fmc150_stellar_cmd_inst : fmc150_stellar_cmd
generic map
(
  START_ADDR   => START_ADDR,
  STOP_ADDR    => STOP_ADDR
)
port map
(
  reset        => rst,

  clk_cmd      => clk_cmd,
  in_cmd_val   => in_cmd_val,
  in_cmd       => in_cmd,
  out_cmd_val  => out_cmd_val,
  out_cmd      => out_cmd,

  clk_reg      => clk,
  out_reg_val  => out_reg_val,
  out_reg_addr => out_reg_addr,
  out_reg      => out_reg,

  in_reg_req   => in_reg_req,
  in_reg_addr  => in_reg_addr,
  in_reg_val   => in_reg_val,
  in_reg       => in_reg,

  mbx_in_val   => '0',
  mbx_in_reg   => (others => '0')
);

----------------------------------------------------------------------------------------------------
-- Shoot commands to the state machine
----------------------------------------------------------------------------------------------------

process (rst, clk)
begin
  if (rst = '1') then

    init_done      <= '0';
    init_done_tmp  <= '0';
    init_done_prev <= '0';
    init           <= '0';
    reset          <= '1';
    in_reg_val     <= '0';
    in_reg         <= (others => '0');
    inst_val       <= '0';
    inst_rw        <= '0';
    inst_reg       <= (others=> '0');
    data_reg       <= (others=> '0');

  elsif (rising_edge(clk)) then

    init_done      <= init_done_sclk;

    init_done_tmp  <= done_sclk;
    init_done_prev <= init_done_tmp;

    -- Release the init flag on rising edge init done
    if (init_done_tmp = '1' and init_done_prev = '0') then
      init <= '0';
    -- Enable the init flag when enable flag is high, but done flag is low
    elsif (init_ena = '1' and init_done_tmp = '0') then
      init <= '1';
    -- There is one additional status and control register available
    elsif (out_reg_val = '1' and out_reg_addr = ADDR_GLOBAL) then
      init <= out_reg(0);
    end if;

    --Write
    if (out_reg_val = '1' and out_reg_addr = ADDR_GLOBAL) then
      reset <= out_reg(1);
    else
      reset <= '0';
    end if;

    -- There is one additional status and control register available
    if (in_reg_req = '1' and in_reg_addr = ADDR_GLOBAL) then
      in_reg_val <= '1';
      in_reg     <= conv_std_logic_vector(0, 27) & '0' & busy & '0' & reset & init_done_prev;
    -- read from serial if when address is within device range
    elsif (in_reg_addr <= ADDR_MAX_RD) then
      in_reg_val <= data_read_val;
      in_reg     <= conv_std_logic_vector(0, 24) & data_read;
    else
      in_reg_val <= '0';
      in_reg     <= in_reg;
    end if;

    -- Write instruction, only when address is within device range
    if (out_reg_val = '1' and out_reg_addr <= ADDR_MAX_WR) then
      inst_val <= '1';
      inst_rw  <= '0'; -- write
      inst_reg <= out_reg_addr(7 downto 0);
      data_reg <= out_reg(7 downto 0);
    -- Read instruction, only when address is within device range
    elsif (in_reg_req = '1' and in_reg_addr <= ADDR_MAX_RD) then
      inst_val <= '1';
      inst_rw  <= '1'; -- read
      inst_reg <= in_reg_addr(7 downto 0);
      data_reg <= data_reg;
    -- No instruction
    else
      inst_val <= '0';
      inst_rw  <= inst_rw;
      inst_reg <= inst_reg;
      data_reg <= data_reg;
    end if;

  end if;
end process;

-- Intruction pulse
pulse2pulse_inst0 : pulse2pulse
port map
(
  rst      => rst,
  in_clk   => clk,
  out_clk  => serial_clk,
  pulsein  => inst_val,
  pulseout => inst_reg_val,
  inbusy   => open
);

----------------------------------------------------------------------------------------------------
-- Serial interface state-machine
----------------------------------------------------------------------------------------------------

process (rst, serial_clk)
begin
  if (rst = '1') then

    init_tmp     <= '0';
    init_reg     <= '0';
    sh_state     <= idle;
    sh_counter   <= 0;
    shifting     <= '0';
    read_n_write <= '0';
    ncs_int      <= '1';

  elsif (rising_edge(serial_clk)) then

    -- Double synchonise flag from other clock domain
    init_tmp <= init;
    init_reg <= init_tmp;

    -- Main state machine
    case sh_state is

      when idle =>
        sh_counter <= shift_reg'length-data_reg'length-1; --total length minus data bytes;
        -- Accept every instruction
        if (inst_reg_val = '1' or init_reg = '1') then
          shifting     <= '1';
          read_n_write <= inst_rw and not init_reg; -- force write during init
          ncs_int      <= '0';
          sh_state     <= instruct;
        else
          shifting     <= '0';
          ncs_int      <= '1';
        end if;

      when instruct =>
        if (sh_counter = 0) then
          sh_counter <= data_reg'length-1;
          sh_state   <= data_io;
        else
          sh_counter <= sh_counter - 1;
        end if;

      when data_io =>
        if (sh_counter = 0) then
          sh_counter <= shift_reg'length-data_reg'length-1; --total length minus data bytes;
          shifting   <= '0';
          ncs_int    <= '1';
          if (read_n_write = '1') then
            sh_state <= data_valid;
          else
            sh_state <= idle;
          end if;
        else
          sh_counter <= sh_counter - 1;
        end if;

      when data_valid =>
        sh_state <= idle;

      when others =>
        sh_state <= idle;

    end case;

  end if;
end process;

busy <= '0' when (sh_state = idle and init_reg = '0') else '1';

----------------------------------------------------------------------------------------------------
-- Instruction & data shift register
----------------------------------------------------------------------------------------------------

process (rst, serial_clk)
begin
  if (rst = '1') then

    shift_reg      <= (others => '0');
    init_address   <= (others => '0');
    done_sclk      <= '0';
    init_done_sclk <= '0';
    read_byte_val  <= '0';
    data_read      <= (others => '0');

  elsif (rising_edge(serial_clk)) then

    if (init_reg = '1' and shifting = '0') then
      shift_reg <= init_data;
      -- Stop when update instruction is reveived (= last instruction)
      if (init_data(15 downto 8) = ADDR_MAX_WR) then
        init_address <= (others => '0');
        done_sclk    <= '1';
      else
        init_address <= init_address + 1;
        done_sclk    <= '0';
      end if;
    elsif (inst_reg_val = '1' and init_reg = '0') then
      shift_reg <= inst_reg & data_reg;
    elsif (shifting = '1') then
      shift_reg <= shift_reg(shift_reg'length - 2 downto 0) & sdi;
    end if;

    if (done_sclk = '0') then
      init_done_sclk <= '0';
    elsif (sh_state = idle) then
      init_done_sclk <= '1';
    end if;

    -- Data read from device
    if (sh_state = data_valid) then
      read_byte_val <= '1';
      data_read     <= shift_reg(7 downto 0);
    else
      read_byte_val <= '0';
      data_read     <= data_read;
    end if;

  end if;
end process;

-- Transfer data valid pulse to other clock domain
pulse2pulse_inst1 : pulse2pulse
port map
(
  rst      => rst,
  in_clk   => serial_clk,
  out_clk  => clk,
  pulsein  => read_byte_val,
  pulseout => data_read_val,
  inbusy   => open
);

----------------------------------------------------------------------------------------------------
-- Initialization memory
----------------------------------------------------------------------------------------------------

ads62p49_init_mem_inst : ads62p49_init_mem
port map (
  clka  => serial_clk,
  addra => init_address,
  douta => init_data
);

----------------------------------------------------------------------------------------------------
-- Capture data in on rising edge SCLK
-- therefore freeze the signal on the falling edge of serial clock.
----------------------------------------------------------------------------------------------------
process (serial_clk)
begin
  if (falling_edge(serial_clk)) then
    sdi <= spi_sdi;
  end if;
end process;

----------------------------------------------------------------------------------------------------
-- Connect entity
----------------------------------------------------------------------------------------------------
in_cmd_busy <= busy; -- serial interface busy

spi_n_oe    <= '1' when (sh_state = data_io and read_n_write = '1') else ncs_int;
spi_n_cs    <= ncs_int;
spi_sclk    <= sclk_ext when ncs_int = '0' else '0';
spi_sdo     <= 'Z' when (sh_state = data_io and read_n_write = '1') else shift_reg(shift_reg'length - 1);

adc_reset   <= reset;

----------------------------------------------------------------------------------------------------
-- End
----------------------------------------------------------------------------------------------------

end ads62p49_ctrl_syn;
