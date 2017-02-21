
----------------------------------------------------------------------------
-- Title      : Interfacing RHINO with 4DSP-FMC150
----------------------------------------------------------------------------
-- Project    : RHINO SDR Processing Blocks
----------------------------------------------------------------------------
--
--	Author     : Lekhobola Tsoeunyane
-- Company    : University Of Cape Town
-- Email		  : lekhobola@gmail.com
----------------------------------------------------------------------------
-- Revisions : 
----------------------------------------------------------------------------
-- Features
-- 1) SPI configuration of ADS62P49, DAC3283, CDCE72010, ADS4249 and AMC7823
-- 2) LVDS interface to ADS62P49 and DAC3283
-- 2) ADS62P49 auto-calibration
-- 
-----------------------------------------------------------------------------
-- Library declarations
-----------------------------------------------------------------------------
library ieee;
  use ieee.std_logic_unsigned.all;
  use ieee.std_logic_misc.all;
  use ieee.std_logic_arith.all;
  use ieee.std_logic_1164.all;
library unisim;
  use unisim.vcomponents.all;

------------------------------------------------------------------------------
-- Entity declaration
------------------------------------------------------------------------------
entity fmc150_if is
port (

	--RHINO Resources
	sysrst	        : in  std_logic; 
	clk_100MHz       : in  std_logic;
	mmcm_locked      : in  std_logic;

	clk_61_44MHz     : in  std_logic;
	clk_122_88MHz    : in  std_logic;

	-------------- user design interface -----------------------
	-- ADC 
	adc_cha_dout     : out    std_logic_vector(13 downto 0);
	adc_chb_dout     : out    std_logic_vector(13 downto 0);


	calibration_ok   : out  std_logic;
	
	-------------- physical external interface -----------------

	--Clock/Data connection to ADC on FMC150 (ADS62P49)
	clk_ab_p         : in    std_logic;
	clk_ab_n         : in    std_logic;
	cha_p            : in    std_logic_vector(6 downto 0);
	cha_n            : in    std_logic_vector(6 downto 0);
	chb_p            : in    std_logic_vector(6 downto 0);
	chb_n            : in    std_logic_vector(6 downto 0);

	--Serial Peripheral Interface (SPI)
	spi_sclk         : out   std_logic; -- Shared SPI clock line
	spi_sdata        : out   std_logic; -- Shared SPI sata line

	-- ADC specific signals
	adc_n_en         : out   std_logic; -- SPI chip select
	adc_sdo          : in    std_logic; -- SPI data out
	adc_reset        : out   std_logic; -- SPI reset

	-- CDCE specific signals
	cdce_n_en        : out   std_logic; -- SPI chip select
	cdce_sdo         : in    std_logic; -- SPI data out
	cdce_n_reset     : out   std_logic;
	cdce_n_pd        : out   std_logic;
	ref_en           : out   std_logic;
	pll_status       : in    std_logic;

	-- Monitoring specific signals
	mon_n_en         : out   std_logic; -- SPI chip select
	mon_sdo          : in    std_logic; -- SPI data out
	mon_n_reset      : out   std_logic;
	mon_n_int        : in    std_logic;

		-- DAC specific signals
	dac_n_en         : out   std_logic; -- SPI chip select
	dac_sdo          : in    std_logic;
	
	--FMC Present status
	nfmc0_prsnt      : in    std_logic

	-- debug signals
);
end fmc150_if;

architecture rtl of fmc150_if is

	----------------------------------------------------------------------------------------------------
	-- Constant declaration
	----------------------------------------------------------------------------------------------------
	constant CLK_IDELAY : integer := 0; -- Initial number of delay taps on ADC clock input
	constant CHA_IDELAY : integer := 0; -- Initial number of delay taps on ADC data port A -- error-free capture range measured between 20 ... 30
	constant CHB_IDELAY : integer := 0; -- Initial number of delay taps on ADC data port B -- error-free capture range measured between 20 ... 30
	constant MAX_PATTERN_CNT : integer := 600;--16383; -- value of 15000 = approx 1 sec for ramp of length 2^14 samples @ 245.76 MSPS

	-- Define the phase increment word for the DDC and DUC blocks (aka NCO)
	-- dec2bin(round(Fc/Fs*2^28)), where Fc = -12 MHz, Fs = 61.44 MHz
	--constant FREQ_DEFAULT : std_logic_vector(27 downto 0) := x"CE00000";
	constant FREQ_DEFAULT : std_logic_vector(27 downto 0) := x"3200000";

	component mmcm_adac
	port
	 (-- Clock in ports
	  CLK_IN1           : in     std_logic;
	  -- Clock out ports
	  CLK_OUT1          : out    std_logic;
	  CLK_OUT2          : out    std_logic;
	  CLK_OUT3          : out    std_logic;
	  -- Status and control signals
	  RESET             : in     std_logic;
	  LOCKED            : out    std_logic
	 );
	end component;

	-- The following code must appear in the VHDL architecture header:
	------------- Begin Cut here for COMPONENT Declaration ------ COMP_TAG
	component MMCM
	port
	 (-- Clock in ports
	  CLK_IN1           : in     std_logic;
	  -- Clock out ports
	  CLK_OUT1          : out    std_logic;
	  CLK_OUT2          : out    std_logic;
	  CLK_OUT3          : out    std_logic;
	  -- Status and control signals
	  RESET             : in     std_logic;
	  LOCKED            : out    std_logic
	 );
	end component;

	component fmc150_spi_ctrl is
	port (
	  init_done			 : out std_logic;

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
	end component fmc150_spi_ctrl;


	component dac3283_serializer is
		port(
			--System Control Inputs
			RST_I          : in  STD_LOGIC;
			--Signal Channel Inputs
			DAC_CLK_O      : out STD_LOGIC;
			DAC_CLK_DIV4_O : out STD_LOGIC;
			DAC_READY      : out STD_LOGIC;
			CH_C_I         : in  STD_LOGIC_VECTOR(15 downto 0);
			CH_D_I         : in  STD_LOGIC_VECTOR(15 downto 0);
			-- DAC interface
			FMC150_CLK     : in  STD_LOGIC;
			DAC_DCLK_P     : out STD_LOGIC;
			DAC_DCLK_N     : out STD_LOGIC;
			DAC_DATA_P     : out STD_LOGIC_VECTOR(7 downto 0);
			DAC_DATA_N     : out STD_LOGIC_VECTOR(7 downto 0);
			FRAME_P        : out STD_LOGIC;
			FRAME_N        : out STD_LOGIC;
			-- Testing
			IO_TEST_EN     : in  STD_LOGIC
		);
	end component dac3283_serializer;

	component ADC_auto_calibration is
	  generic (
		  MAX_PATTERN_CNT : integer := 1000;   -- value of 15000 = approx 1 sec for ramp of length 2^14 samples @ 245.76 MSPS
		  INIT_IDELAY : integer                -- Initial number of delay taps on ADC data port
		);
	  Port ( 
		  reset                 : in  STD_LOGIC;
		  clk                   : in  STD_LOGIC;
		  ADC_calibration_start : in  STD_LOGIC;
		  ADC_data              : in  STD_LOGIC_VECTOR (13 downto 0);
		  re_mux_polarity       : out  STD_LOGIC;
		  trace_edge            : out  STD_LOGIC;
		  ADC_calibration_state : out  STD_LOGIC_VECTOR(2 downto 0);
		  iDelay_cnt            : out  STD_LOGIC_VECTOR (4 downto 0);
		  iDelay_inc_en		   : out  std_logic;
		  ADC_calibration_done  : out  BOOLEAN;
		  ADC_calibration_good  : out  STD_LOGIC);
	end component;
	
	----------------------------------------------------------------------------------------------------
	-- Debugging Components and Signals
	----------------------------------------------------------------------------------------------------
	component icon
	  PORT (
		 CONTROL0 : INOUT STD_LOGIC_VECTOR(35 DOWNTO 0);
		 CONTROL1 : INOUT STD_LOGIC_VECTOR(35 DOWNTO 0);
		 CONTROL2 : INOUT STD_LOGIC_VECTOR(35 DOWNTO 0));

	end component;

	component ila0
	  PORT (
		 CONTROL : INOUT STD_LOGIC_VECTOR(35 DOWNTO 0);
		 CLK : IN STD_LOGIC;
		 DATA : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
		 TRIG0 : IN STD_LOGIC_VECTOR(3 DOWNTO 0));

	end component;

	component ila1
	  PORT (
		 CONTROL : INOUT STD_LOGIC_VECTOR(35 DOWNTO 0);
		 CLK : IN STD_LOGIC;
		 DATA : IN STD_LOGIC_VECTOR(127 DOWNTO 0);
		 TRIG0 : IN STD_LOGIC_VECTOR(7 DOWNTO 0));

	end component;

	component vio
	  PORT (
		 CONTROL : INOUT STD_LOGIC_VECTOR(35 DOWNTO 0);
		 ASYNC_OUT : OUT STD_LOGIC_VECTOR(7 DOWNTO 0));

	end component;

	signal CONTROL0 : STD_LOGIC_VECTOR(35 DOWNTO 0);
	signal CONTROL1 : STD_LOGIC_VECTOR(35 DOWNTO 0);
	signal CONTROL2 : STD_LOGIC_VECTOR(35 DOWNTO 0);
	signal ila_data0 :  STD_LOGIC_VECTOR(15 DOWNTO 0);
	signal ila_data1 :  STD_LOGIC_VECTOR(127 DOWNTO 0);
	signal trig0 : STD_LOGIC_VECTOR(3 DOWNTO 0);
	signal trig1 : STD_LOGIC_VECTOR(7 DOWNTO 0);
	signal vio_data :  STD_LOGIC_VECTOR(7 DOWNTO 0);

	----------------------------------------------------------------------------------------------------
	-- End
	----------------------------------------------------------------------------------------------------

	----------------------------------------------------------------------------------------------------
	-- Signal declaration
	----------------------------------------------------------------------------------------------------
	--signal clk_100Mhz        : std_logic;
	--signal clk_200Mhz        : std_logic;
	--signal mmcm_locked       : std_logic;

	signal arst              : std_logic := '0';
	signal rst               : std_logic;
	signal rst_duc_ddc       : std_logic;

	signal clk_ab_l          : std_logic;
	signal clk_ab_dly        : std_logic;
	signal clk_ab_i          : std_logic;

	signal cha_ddr           : std_logic_vector(6 downto 0);  -- Double Data Rate
	signal cha_ddr_dly       : std_logic_vector(6 downto 0);  -- Double Data Rate, Delayed
	signal cha_sdr           : std_logic_vector(13 downto 0); -- Single Data Rate

	signal chb_ddr           : std_logic_vector(6 downto 0);  -- Double Data Rate
	signal chb_ddr_dly       : std_logic_vector(6 downto 0);  -- Double Data Rate, Delayed
	signal chb_sdr           : std_logic_vector(13 downto 0); -- Single Data Rate

	signal adc_dout_i        : std_logic_vector(13 downto 0); -- Single Data Rate, Extended to 16-bit
	signal adc_dout_q        : std_logic_vector(13 downto 0); -- Single Data Rate, Extended to 16-bit
	signal adc_vout          : std_logic;

	signal freq              : std_logic_vector(27 downto 0);
	signal cmplx_aresetn_duc : std_logic;
	signal dds_reset_duc     : std_logic;
	signal cmplx_aresetn_ddc : std_logic;
	signal dds_reset_ddc     : std_logic;

	signal signal_ce         : std_logic;
	signal signal_ce_prev    : std_logic;
	signal signal_vout       : std_logic;

	signal imp_dout_i        : std_logic_vector(15 downto 0);
	signal imp_dout_q        : std_logic_vector(15 downto 0);

	signal delay_update      : std_logic;
	signal clk_cntvaluein    : std_logic_vector(4 downto 0);
	signal cha_cntvaluein    : std_logic_vector(4 downto 0);
	signal chb_cntvaluein    : std_logic_vector(4 downto 0);

	signal clk_cntvalueout   : std_logic_vector(4 downto 0);
	type cha_cntvalueout_array is array(cha_p'length-1 downto 0) of std_logic_vector(4 downto 0);
	signal cha_cntvalueout   : cha_cntvalueout_array;
	type chb_cntvalueout_array is array(chb_p'length-1 downto 0) of std_logic_vector(4 downto 0);
	signal chb_cntvalueout   : chb_cntvalueout_array;

	signal rd_n_wr           : std_logic;
	signal addr              : std_logic_vector(15 downto 0);
	signal idata             : std_logic_vector(31 downto 0);
	signal odata             : std_logic_vector(31 downto 0);
	signal busy              : std_logic;
	signal cdce72010_valid   : std_logic;
	signal ads62p49_valid    : std_logic;
	signal dac3283_valid     : std_logic;
	signal amc7823_valid     : std_logic;

	--signal clk_66MHz         : std_logic;
	--signal clk_61_44MHz      : std_logic;
	signal clk_61_44MHz_n    : std_logic;
	--signal clk_122_88MHz     : std_logic;
	--signal clk_368_64MHz     : std_logic;
	--signal mmcm_adac_locked  : std_logic;


	signal dac_din_i         : std_logic_vector(15 downto 0);
	signal dac_din_q         : std_logic_vector(15 downto 0);

	signal frame             : std_logic;
	signal io_rst            : std_logic;

	signal dac_dclk_prebuf   : std_logic;
	signal dac_data_prebuf   : std_logic_vector(7 downto 0);
	signal dac_frame_prebuf  : std_logic;

	signal digital_mode      : std_logic;
	signal external_clock    : std_logic := '0';

	signal ADC_cha_calibration_start       : std_logic;
	signal ADC_chb_calibration_start       : std_logic;
	signal ADC_cha_calibration_done        : boolean;
	signal ADC_cha_calibration_done_r      : boolean;
	signal ADC_cha_calibration_done_rr     : boolean;
	signal ADC_chb_calibration_done        : boolean;
	signal ADC_chb_calibration_done_r      : boolean;
	signal ADC_chb_calibration_done_rr     : boolean;
	signal ADC_chb_calibration_test_pattern_mode_command_sent : boolean;
	signal ADC_cha_calibration_test_pattern_mode_command_sent : boolean;
	signal ADC_chb_normal_mode_command_sent : boolean;
	signal ADC_cha_normal_mode_command_sent : boolean;
	signal ADC_chb_trace_edge              : std_logic;
	signal ADC_cha_trace_edge              : std_logic;
	signal ADC_chb_calibration_state       : std_logic_vector(2 downto 0);
	signal ADC_cha_calibration_state       : std_logic_vector(2 downto 0);
	signal ADC_chb_calibration_good	      : std_logic;
	signal ADC_cha_calibration_good	      : std_logic;
	signal ADC_calibration_good	         : std_logic;
	signal ADC_chb_ready                   : boolean;
	signal ADC_cha_ready                   : boolean;
	signal ADC_ready                       : boolean;
	signal cha_cntvaluein_update    : std_logic_vector(4 downto 0);
	signal clk_cntvaluein_update    : std_logic_vector(4 downto 0);
	signal fmc150_spi_ctrl_done	: std_logic;
	signal fmc150_spi_ctrl_done_r	: std_logic;

	signal sysclk		: std_logic;

	signal busy_reg	: std_logic;
	signal cha_cntvaluein_update_61_44MHz    : std_logic_vector(4 downto 0);
	signal cha_cntvaluein_update_100MHz    : std_logic_vector(4 downto 0);
	signal chb_cntvaluein_update    : std_logic_vector(4 downto 0);
	signal chb_cntvaluein_update_vio    : std_logic_vector(4 downto 0);
	signal chb_cntvaluein_update_61_44MHz    : std_logic_vector(4 downto 0);
	signal chb_cntvaluein_update_100MHz    : std_logic_vector(4 downto 0);

	signal adc_dout_i_prev   : std_logic_vector(13 downto 0);
	signal adc_dout_61_44_MSPS_valid	 : std_logic;
	signal clk_61_44MHz_count 			 : std_logic;

	signal adc_cha_re_mux_polarity 	 : std_logic := '1';	-- initial state '1' is contrary to actual default behaviour in hardware, but desired for simulation to verify correctness of state machine
	signal adc_chb_re_mux_polarity 	 : std_logic := '1';	-- initial state '1' is contrary to actual default behaviour in hardware, but desired for simulation to verify correctness of state machine

	signal sclk					 : std_logic;
	signal sclk_n				 : std_logic;

	signal ce_a 				 : std_logic := '0';
	signal ce_b 				 : std_logic := '0';
	signal cha_inc_update		     : std_logic;
	signal cha_inc_update_100MHz    : std_logic; 
	signal cha_inc_update_61_44MHz  : std_logic;
	signal cha_incin					  : std_logic;
	signal chb_inc_update		     : std_logic;
	signal chb_inc_update_100MHz    : std_logic; 
	signal chb_inc_update_61_44MHz  : std_logic;
	signal chb_incin					  : std_logic;
	signal dac_ready					  : std_logic;

	signal txen    		 : std_logic := '0';
	signal dac_cnt        : std_logic_vector(13 downto 0) := (others => '0');
	--signal dac_sample_clk : std_logic;
	signal ftw				 : std_logic_vector(31 downto 0);

	----------------------------------------------------------------------------------------------------
	-- Begin
	----------------------------------------------------------------------------------------------------
begin

	clk_61_44MHz_n <= not clk_61_44MHz;
	
	----------------------------------------------------------------------------------------------------
	-- Channel A data from ADC
	----------------------------------------------------------------------------------------------------
	adc_data_a: for i in 0 to 6 generate

	  -- Differantial input buffer with termination (LVDS)
	  ibufds_inst : ibufds
	  generic map (
		 IOSTANDARD => "LVDS_25",
		 DIFF_TERM  => TRUE
	  )
	  port map (
		 i  => cha_p(i),
		 ib => cha_n(i),
		 o  => cha_ddr(i)
	  );

	-- Input delay
--	  iodelay_inst : iodelay2
--	  generic map (
--		 DATA_RATE          => "DDR",
--		 IDELAY_VALUE       => CHA_IDELAY,
--		 IDELAY_TYPE        => "VARIABLE_FROM_ZERO",
--		 COUNTER_WRAPAROUND => "STAY_AT_LIMIT",
--		 DELAY_SRC          => "IDATAIN",
--		 SERDES_MODE        => "NONE",
--		 SIM_TAPDELAY_VALUE => 75
--	  )
--	  port map (
--		 idatain    => cha_ddr(i),
--		 dataout    => cha_ddr_dly(i),
--		 t          => '1',

--		 odatain    => '0',

--		 ioclk0     => clk_61_44MHz,
--		 ioclk1     => clk_61_44MHz_n,
--		 clk        => clk_61_44MHz,
--		 cal        => '0',
--		 inc        => cha_incin,
--		 ce         => ce_a,
--		 busy       => open,
--		 rst        => sysrst
--	  );
	  
		 -- DDR to SDR
	  iddr_inst_cha : IDDR2
	  generic map (
	  --  DDR_CLK_EDGE => "SAME_EDGE_PIPELINED"
		DDR_ALIGNMENT => "NONE",
		INIT_Q0 =>	'0',
		INIT_Q1 =>	'0',
		SRTYPE => "SYNC")
	  port map (
		 q0 => cha_sdr(2*i),
		 q1 => cha_sdr(2*i+1),
		 c0 => clk_61_44MHz,
		 c1 => clk_61_44MHz_n,	
		 ce => '1',
		 d  => cha_ddr(i), --cha_ddr_dly(i), 		   
		 r  => sysrst,
		 s  => '0'
	  );

	end generate;

	----------------------------------------------------------------------------------------------------
	-- Channel B data from ADC
	----------------------------------------------------------------------------------------------------
	adc_data_b: for i in 0 to 6 generate

	  -- Differantial input buffer with termination (LVDS)
	  ibufds_inst : ibufds
	  generic map (
		 IOSTANDARD => "LVDS_25",
		 DIFF_TERM  => TRUE
	  )
	  port map (
		 i  => chb_p(i),
		 ib => chb_n(i),
		 o  => chb_ddr(i)
	  );


		-- Input delay
--	  iodelay_inst : iodelay2
--	  generic map (
--		 DATA_RATE          => "DDR",
--		 IDELAY_VALUE       => CHB_IDELAY,
--		 IDELAY_TYPE        => "VARIABLE_FROM_ZERO",
--		 COUNTER_WRAPAROUND => "STAY_AT_LIMIT",
--		 DELAY_SRC          => "IDATAIN",
--		 SERDES_MODE        => "NONE",
--		 SIM_TAPDELAY_VALUE => 75
--	  )
--	  port map (
--		 idatain    => chb_ddr(i),
--		 dataout    => chb_ddr_dly(i),
--		 t          => '1',

--		 odatain    => '0',

--		 ioclk0     => clk_61_44MHz,
--		 ioclk1     => clk_61_44MHz_n,
--		 clk        => clk_61_44MHz,
--		 cal        => '0',
--		 inc        => chb_incin,
--		 ce         => ce_b,
--		 busy       => open,
--		 rst        => sysrst
--	  );
	  
		  -- DDR to SDR
	  iddr_inst_chb : IDDR2
	  generic map (
	  --  DDR_CLK_EDGE => "SAME_EDGE_PIPELINED"
		DDR_ALIGNMENT => "NONE",
		INIT_Q0 =>	'0',
		INIT_Q1 =>	'0',
		SRTYPE => "SYNC")
	  port map (
		 q0 => chb_sdr(2*i),
		 q1 => chb_sdr(2*i+1),
		 c0 => clk_61_44MHz,
		 c1 => clk_61_44MHz_n,	
		 ce => '1',
		 d  => chb_ddr(i), -- chb_ddr_dly(i), 		   --chb_ddr_dly
		 r  => sysrst,
		 s  => '0'
	  );
	end generate;

	----------------------------------------------------------------------------------------------------
	-- Ouput 16-bit digital samples
	----------------------------------------------------------------------------------------------------
	process (clk_61_44MHz)
	begin
	  if (rising_edge(clk_61_44MHz)) then
		 adc_cha_dout <= cha_sdr;
		 adc_chb_dout <= chb_sdr;
	  end if;
	end process;

	----------------------------------------------------------------------------------------------------
	-- Configuring the FMC150 card
	----------------------------------------------------------------------------------------------------
	-- the fmc150_spi_ctrl component configures the devices on the FMC150 card through the Serial
	-- Peripheral Interfaces (SPI) and some additional direct control signals.
	----------------------------------------------------------------------------------------------------
	fmc150_spi_ctrl_inst : fmc150_spi_ctrl
	port map (
		init_done		 => fmc150_spi_ctrl_done,

		rd_n_wr         => rd_n_wr,
		addr            => addr,
		idata           => idata,
		odata           => odata,
		busy            => busy,

		cdce72010_valid => cdce72010_valid,
		ads62p49_valid  => ads62p49_valid,
		dac3283_valid   => dac3283_valid,
		amc7823_valid   => amc7823_valid,

		rst             => arst,
		clk             => clk_100MHz,
		external_clock  => external_clock,

		spi_sclk        => sclk,
		spi_sdata       => spi_sdata,

		adc_n_en        => adc_n_en,
		adc_sdo         => adc_sdo,
		adc_reset       => adc_reset,

		cdce_n_en       => cdce_n_en,
		cdce_sdo        => cdce_sdo,
		cdce_n_reset    => cdce_n_reset,
		cdce_n_pd       => cdce_n_pd,
		ref_en          => ref_en,
		pll_status      => pll_status,

		dac_n_en        => dac_n_en,
		dac_sdo         => dac_sdo,

		mon_n_en        => mon_n_en,
		mon_sdo         => mon_sdo,
		mon_n_reset     => mon_n_reset,
		mon_n_int       => mon_n_int,

		prsnt_m2c_l     => nfmc0_prsnt
	);
	
	calibration_ok <= cdce72010_valid and ads62p49_valid and dac3283_valid and amc7823_valid;
	
	-- ODDR2 is needed instead of the following
		-- and limiting in Spartan 6
		txclk_ODDR2_inst : ODDR2
		generic map (
			DDR_ALIGNMENT => "NONE",
			INIT => '0',
			SRTYPE => "SYNC")
		port map (
			Q => spi_sclk, -- 1-bit DDR output data
			C0 => sclk, -- clock is your signal from PLL
			C1 => sclk_n, -- n
			D0 => '1', -- 1-bit data input (associated with C0)
			D1 => '0', -- 1-bit data input (associated with C1)
			R => sysrst, -- 1-bit reset input
			S => '0' -- 1-bit set input
		);
		sclk_n <= not sclk;
		
		
	-------------------------------------------END------------------------------------------------------
	 
	----------------------------------------------------------------------------------------------------
	-- Debugging Section
	----------------------------------------------------------------------------------------------------
	--  ila_data0(0) <= fmc150_spi_ctrl_done;
	--  ila_data0(1) <= external_clock;
	--  ila_data0(2) <= busy;
	--  ila_data0(3) <= mmcm_adac_locked;
	--  ila_data0(4) <= mmcm_locked;
	--  ila_data0(5) <= pll_status;
	--  ila_data0(6) <= '1' when ADC_cha_ready = TRUE else '0';
	--  ila_data0(7) <= '1' when ADC_chb_ready = TRUE else '0';
	--  ila_data0(8) <= txen;
	  
	--  ila_data1(13 downto 0) <= adc_dout_i;
	--  ila_data1(27 downto 14)<= adc_dout_q;  
	--  ila_data1(41 downto 28) <= dac_cnt;
	--  ila_data1(44 downto 42) <= ADC_chb_calibration_state;
	--  ila_data1(49 downto 45) <= cha_cntvaluein;
	--  ila_data1(50) <= ADC_calibration_good;
	  
	  --trig0(0) <= busy;--cmd_state(3 downto 0);--busy;--init_done;
	--  trig1(2 downto 0) <= ADC_chb_calibration_state;
	  
	------ instantiate chipscope components -------
	--	icon_inst : icon
	--	  port map (
	--		 CONTROL0 => CONTROL0,
	--		 CONTROL1 => CONTROL1,
	--		 CONTROL2 => CONTROL2
	--		 );

	--	ila_data0_inst : ila0
	--	  port map (
	--		 CONTROL => CONTROL0,
	--		 CLK     => clk_100MHz,--clk_245_76MHz,
	--		 DATA    => ila_data0,
	--		 TRIG0   => TRIG0);
			
	--	ila_data1_inst : ila1
	--	  port map (
	--		 CONTROL => CONTROL2,
	--		 CLK => clk_61_44MHz,
	--		 DATA => ila_data1,
	--		 TRIG0 => TRIG1);
			 
	--	vio_inst : vio
	--  port map (
	--	 CONTROL => CONTROL1,
	--	 ASYNC_OUT => vio_data);
	----------------------------------------------------------------------------------------------------
	-- End 
	----------------------------------------------------------------------------------------------------
end rtl;
