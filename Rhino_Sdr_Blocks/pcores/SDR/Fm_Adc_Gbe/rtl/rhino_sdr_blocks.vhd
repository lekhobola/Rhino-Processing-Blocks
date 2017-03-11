----------------------------------------------------------------------------------

----------------------------------------------------------------------------------
-- Title  	  : The top module for all DSP and peripheral cores
----------------------------------------------------------------------------------
-- Project    : RHINO SDR Processing Blocks
----------------------------------------------------------------------------------
--
--	Author     : Lekhobola Tsoeunyane
-- Company    : University Of Cape Town
-- Email		  : lekhobola@gmail.com
-- Date	     : 12:29:21 06/26/2015  
----------------------------------------------------------------------------------
-- Revisions : 15-02-2017
----------------------------------------------------------------------------------
-- Features
-- 1) Digitize 89.0 MHz FM channel (using bandpass sampling at 7.68 Msps of ADC)
-- 2) Send the ADC samples to a PC via Gbe
--
----------------------------------------------------------------------------------
-- Target Devices: RHINO (SPARTAN 6)
----------------------------------------------------------------------------------
-- Library declarations
----------------------------------------------------------------------------------
----------------------------------------------------------------------
-- Description: 
----------------------------------------------------------------------
----                                                              ----
---- Copyright (C) 2015 Lekhobola Tsoeunyane                             ----
----     lekhobola (at) gmail.com                             ----
----                                                              ----
---- This source file may be used and distributed without         ----
---- restriction provided that this copyright statement is not    ----
---- removed from the file and that any derivative work contains  ----
---- the original copyright notice and the associated disclaimer. ----
----                                                              ----
---- This source file is free software; you can redistribute it   ----
---- and/or modify it under the terms of the GNU Lesser General   ----
---- Public License as published by the Free Software Foundation; ----
---- either version 2.1 of the License, or (at your option) any   ----
---- later version.                                               ----
----                                                              ----
---- This source is distributed in the hope that it will be       ----
---- useful, but WITHOUT ANY WARRANTY; without even the implied   ----
---- warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR      ----
---- PURPOSE.  See the GNU Lesser General Public License for more ----
---- details.                                                     ----
----                                                              ----
---- You should have received a copy of the GNU Lesser General    ----
---- Public License along with this source; if not, download it   ----
---- from http://www.opencores.org/lgpl.shtml                     ----
----                                                              ----
----------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
Use IEEE.std_logic_unsigned.all;

Library IO_Lib;
Use IO_Lib.iocomponents.all;

Library DDC_Lib;
Use DDC_Lib.ddccomponents.all;

Library FFT_IFFT_Lib;
Use FFT_IFFT_Lib.fftcomponents.all;

entity rhino_sdr_blocks is
	port (
	
		-------------------------------------------------------
		--------------- RHINO Resources -----------------------
		-------------------------------------------------------
		sys_clk_p          : in  	std_logic;
		sys_clk_n          : in  	std_logic;
		sys_rst_i          : in  	std_logic;
		
		-------------------------------------------------------
		------------------ Status LEDs ------------------------
		-------------------------------------------------------
		fmc150_pll_ok      : out 	std_logic;
		fmc150_calib_ok    : out   std_logic;
		gbe_init_ok        : out   std_logic;
		
		-------------------------------------------------------
		-------------- FMC150 interface -----------------------
		-------------------------------------------------------
		--Clock/Data connection to ADC on FMC150 (ADS62P49)
		clk_ab_p           : in    std_logic;
		clk_ab_n           : in    std_logic;
		cha_p              : in    std_logic_vector(6 downto 0);
		cha_n              : in    std_logic_vector(6 downto 0);
		chb_p              : in    std_logic_vector(6 downto 0);
		chb_n              : in    std_logic_vector(6 downto 0);

		--Serial Peripheral Interface (SPI)
		spi_sclk           : out   std_logic; -- Shared SPI clock line
		spi_sdata          : out   std_logic; -- Shared SPI sata line

		-- ADC specific signals
		adc_n_en           : out   std_logic; -- SPI chip select
		adc_sdo            : in    std_logic; -- SPI data out
		adc_reset          : out   std_logic; -- SPI reset

		-- CDCE specific signals
		cdce_n_en          : out   std_logic; -- SPI chip select
		cdce_sdo           : in    std_logic; -- SPI data out
		cdce_n_reset       : out   std_logic;
		cdce_n_pd          : out   std_logic;
		ref_en             : out   std_logic;
		pll_status         : in    std_logic;

		-- DAC specific signals
		dac_n_en           : out   std_logic; -- SPI chip select
		dac_sdo            : in    std_logic; -- SPI data out

		-- Monitoring specific signals
		mon_n_en           : out   std_logic; -- SPI chip select
		mon_sdo            : in    std_logic; -- SPI data out
		mon_n_reset        : out   std_logic;
		mon_n_int          : in    std_logic;

		--FMC Present status
		nfmc0_prsnt        : in    std_logic;
		
		-------------------------------------------------------
		------------------- 1Gbps MAC interface ---------------
		-------------------------------------------------------
		GIGE_COL			    : in std_logic;
		GIGE_CRS			    : in std_logic;
		GIGE_MDC			    : out std_logic;
		GIGE_MDIO	       : inout std_logic;
		GIGE_TX_CLK	       : in std_logic;
		GIGE_nRESET	       : out std_logic;
		GIGE_RXD			    : in std_logic_vector( 7 downto 0 );
		GIGE_RX_CLK		    : in std_logic;
		GIGE_RX_DV		    : in std_logic;
		GIGE_RX_ER	       : in std_logic;
		GIGE_TXD			    : out std_logic_vector( 7 downto 0 );
		GIGE_GTX_CLK 	    : out std_logic;
		GIGE_TX_EN		    : out std_logic;
		GIGE_TX_ER		    : out std_logic
	);
end rhino_sdr_blocks;

architecture Behavioral of rhino_sdr_blocks is

	---------------------------------------------------------------------------
	--	Component declaration section 
	---------------------------------------------------------------------------
	
	component clk_manager is
	port(
		--External Control
		SYS_CLK_P_i  : in  std_logic;
		SYS_CLK_N_i  : in  std_logic;
		SYS_RST_i    : in  std_logic;
		
		clk_ab_p		 : in std_logic;
		clk_ab_n   	 : in std_logic;
		
		-- Clock out ports
		clk_125mhz    : out std_logic;
		clk_122_88mhz : out std_logic;
		clk_62_5mhz    : out std_logic;
		clk_61_44mhz  : out std_logic;		
		clk_25mhz     : out std_logic;
		
		-- Status and control signals
		RESET         : out std_logic;
		sysclk_locked : out std_logic;
		adcclk_locked : out std_logic
	);
   end component clk_manager;	

	component dsp_gbe_intercon
	 generic(
		MEM_DATA_BYTES : natural;		
		MEM_DEPTH 		: natural
	);
	port(
		rst   		 : in   std_logic;
		clk   		 : in   std_logic;
		en    	    : in   std_logic;
		rd_en 		 : in   std_logic;
		vld   		 : out  std_logic;
		new_pkt_rcvd : in   std_logic;
		din   		 : in   std_logic_vector(8 * MEM_DATA_BYTES - 1 downto 0);
		dout  		 : out  std_logic_vector(8 * MEM_DATA_BYTES * MEM_DEPTH - 1 downto 0);
		count        : out std_logic_vector(6 downto 0)
	  );
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
		 DATA : IN STD_LOGIC_VECTOR(69 DOWNTO 0);
		 TRIG0 : IN STD_LOGIC_VECTOR(3 DOWNTO 0));

	end component;

	component ila1
	  PORT (
		 CONTROL : INOUT STD_LOGIC_VECTOR(35 DOWNTO 0);
		 CLK : IN STD_LOGIC;
		 DATA : IN STD_LOGIC_VECTOR(47 DOWNTO 0);
		 TRIG0 : IN STD_LOGIC_VECTOR(7 DOWNTO 0));

	end component;

	component vio
	  PORT (
		 CONTROL : INOUT STD_LOGIC_VECTOR(35 DOWNTO 0);
		 ASYNC_OUT : OUT STD_LOGIC_VECTOR(31 DOWNTO 0));

	end component;
	
	
	signal CONTROL0 : STD_LOGIC_VECTOR(35 DOWNTO 0);
	signal CONTROL1 : STD_LOGIC_VECTOR(35 DOWNTO 0);
	signal CONTROL2 : STD_LOGIC_VECTOR(35 DOWNTO 0);
	signal ila_data0 :  STD_LOGIC_VECTOR(69 DOWNTO 0);
	signal ila_data1 :  STD_LOGIC_VECTOR(47 DOWNTO 0);
	signal trig0 : STD_LOGIC_VECTOR(3 DOWNTO 0);
	signal trig1 : STD_LOGIC_VECTOR(7 DOWNTO 0);
	signal vio_data :  STD_LOGIC_VECTOR(31 DOWNTO 0);

	----------------------------------------------------------------------------------------------------
	-- End
	----------------------------------------------------------------------------------------------------
	
	---------------------------------------------------------------------------
	--	Signal declaration section 
	---------------------------------------------------------------------------
	attribute S: string;
	attribute keep : string;
	
	------------------------- FMC150 signals ----------------------------------	
	attribute S of GIGE_RXD   : signal is "TRUE"; 
	attribute S of GIGE_RX_DV : signal is "TRUE";
	attribute S of GIGE_RX_ER : signal is "TRUE";	
	
	constant UDP_TX_DATA_BYTE_LENGTH : integer := 256;
	constant UDP_RX_DATA_BYTE_LENGTH : integer := 3;
	constant UDP_TX_DATA_WIDTH       : integer := UDP_TX_DATA_BYTE_LENGTH * 8; 
	constant INTERCON_BYTES          : integer := 2;
	constant INTERCON_DEPTH          : integer := UDP_TX_DATA_BYTE_LENGTH / INTERCON_BYTES;
	
	signal adc_cha_dout      : std_logic_vector(13 downto 0);
	signal adc_chb_dout      : std_logic_vector(13 downto 0);

   signal dac_chc_din      : std_logic_vector(15 downto 0);
	signal dac_chd_din      : std_logic_vector(15 downto 0);
	
	signal clk_62_5mhz			: std_logic;
	signal mmcm_locked      : std_logic;
	signal dac_fpga_clk     : std_logic;
	
	------------------------- MAC signals -------------------------------------
	signal udp_tx_pkt_data  : std_logic_vector (8 * UDP_TX_DATA_BYTE_LENGTH - 1 downto 0);
	signal udp_tx_pkt_vld   : std_logic;
	signal udp_tx_pkt_sent  : std_logic;
	signal udp_tx_pkt_vld_r : std_logic;
	signal udp_tx_rdy		   : std_logic;
			
	signal udp_rx_pkt_data  : std_logic_vector(8 * UDP_RX_DATA_BYTE_LENGTH - 1 downto 0);
	signal udp_rx_pkt_data_r: std_logic_vector(8 * UDP_RX_DATA_BYTE_LENGTH - 1 downto 0);
	signal udp_rx_pkt_req   : std_logic;
   signal udp_rx_rdy		   : std_logic;
	signal udp_rx_rdy_r     : std_logic;
	
	signal dst_mac_addr     : std_logic_vector(47 downto 0);
	signal tx_state			: std_logic_vector(2 downto 0) := "000";
	signal rx_state			: std_logic_vector(2 downto 0) := "000";
	
	signal adc_pkt_vld	   : std_logic;
	signal adc_pkt_data     : std_logic_vector (8 * UDP_TX_DATA_BYTE_LENGTH - 1 downto 0);
	signal adc_pkt_rd_en    : std_logic;
	signal tx_delay_cnt		: integer := 0;
	
	signal mac_init_done    : std_logic;
	signal calibration_ok_r : std_logic;
	signal new_pkt_rcvd     : std_logic;
	
	signal clk_61_44MHz     :  std_logic;
	signal clk_122_88MHz    :  std_logic;
	signal clk_ab_l 		   : std_logic;

	signal clk_368_64MHz    : std_logic;
	signal clk_25MHz        : std_logic;

	signal clk_125mhz       : std_logic;
	signal adcclk_locked    : std_logic;
	signal sysclk_locked    : std_logic;
	signal sysrst 		      : std_logic;
	
	-------------- Down-sampler -------------------------------------------
	signal ds_vld  : std_logic;
	signal ds_dout : std_logic_vector(15 downto 0);
	
	
	-------------- FFT Core ----------------------------------------------
	signal fft_rst  : std_logic;
	signal fft_vld  : std_logic;
	signal fft_done : std_logic;
	signal XKr 		 : std_logic_vector(31 downto 0);
	signal XKi      : std_logic_vector(31 downto 0);
	
	signal XKr_r 		 : std_logic_vector(27 downto 0);
	signal XKi_r       : std_logic_vector(27 downto 0);
	
	-------------- Interconnect -------------------------------------------
	signal bridge_rst : std_logic;
	signal bridge_en  : std_logic;
	signal tag			: std_logic_vector(8 downto 0) := (others =>'0');
	signal counter_samples : std_logic_vector( 6 downto 0);
	
	
	-------------- Test Vector in ROM--------------------------------------
	signal rom_addr  : std_logic_vector(5 downto 0);
	signal rom_doutr : std_logic_vector(15 downto 0);
	signal rom_douti : std_logic_vector(15 downto 0);
	signal trigger   : std_logic;
	
	------------------------- DAC -----------------------------------------
	signal FTW : std_logic_vector(31 downto 0);
	
	------------------------ DDC ------------------------------------------
	signal DDC_FTW  :  std_logic_vector(31 downto 0) := (others=>'0');
	signal IOUT 	 : std_logic_vector (15 downto 0);
	signal QOUT		 : std_logic_vector (15 downto 0);
	signal ddc_vld  : std_logic;
	type fm_type is array(0 to  8191) of std_logic_vector(15 downto 0);	
	signal fm_counter : integer range 0 to 8191 := 0;
	signal fm_data : std_logic_vector(15 downto 0);
	signal fm_addr : std_logic_vector(12 downto 0);
begin

	-------------------------- Status LEDs---------------------------------
	fmc150_pll_ok    <= pll_status;
   fmc150_calib_ok  <= calibration_ok_r;
	gbe_init_ok      <= mac_init_done;
	  
	---------------------------------------------------------------------------
	--	FMC150 ADC/DAC interface 
	---------------------------------------------------------------------------
	fmc150_if_inst : fmc150_if 
	port map(

	  --RHINO Resources
	  sysrst	          => sysrst,
	  clk_100MHz       => clk_62_5mhz,
	  mmcm_locked      => sysclk_locked,
	  
	  clk_61_44MHz     => clk_61_44MHz,
	  clk_122_88MHz    => clk_122_88MHz,
	  
	  -------------- user design interface -----------------------
	  -- ADC 
	  adc_cha_dout     => adc_cha_dout,
	  adc_chb_dout     => adc_chb_dout,
	  
	  calibration_ok	 => calibration_ok_r,
	  
	  -------------- physical external interface -----------------
	  
	  --Clock/Data connection to ADC on FMC150 (ADS62P49)
	  clk_ab_p         => clk_ab_p,
	  clk_ab_n         => clk_ab_n,
	  cha_p            => cha_p,
	  cha_n            => cha_n,
	  chb_p            => chb_p,
	  chb_n            => chb_n,

	  --Serial Peripheral Interface (SPI)
	  spi_sclk         => spi_sclk,
	  spi_sdata        => spi_sdata,

	  -- ADC specific signals
	  adc_n_en         => adc_n_en,
	  adc_sdo          => adc_sdo,
	  adc_reset        => adc_reset,

	  -- CDCE specific signals
	  cdce_n_en        => cdce_n_en,
	  cdce_sdo         => cdce_sdo,
	  cdce_n_reset     => cdce_n_reset,
	  cdce_n_pd        => cdce_n_pd,
	  ref_en           => ref_en,
	  pll_status       => pll_status,

	  -- DAC specific signals
	  dac_n_en         => dac_n_en,
	  dac_sdo          => dac_sdo,

	  -- Monitoring specific signals
	  mon_n_en         => mon_n_en,
	  mon_sdo          => mon_sdo,
	  mon_n_reset      => mon_n_reset,
	  mon_n_int        => mon_n_int,

	  --FMC-0 Present status
	  nfmc0_prsnt      => nfmc0_prsnt
	);

	---------------------------------------------------------------------------
	--	1Gbe Ethernet interface 
	---------------------------------------------------------------------------
	UDP_1GbE_inst : UDP_1GbE 	  
	generic map(
			UDP_TX_DATA_BYTE_LENGTH => UDP_TX_DATA_BYTE_LENGTH,
			UDP_RX_DATA_BYTE_LENGTH => UDP_RX_DATA_BYTE_LENGTH
	 )
	port map(
			-- user logic interface
			own_ip_addr		   => x"c0a80003",
			own_mac_addr      => x"0024ba7d1d70",
			dst_ip_addr       => x"c0a80001",
			dst_mac_addr      => x"e03f49aedbb2",
			
			udp_src_port  		=> x"26CA", --9930
			udp_dst_port      => x"26D4", --9940
			
			udp_tx_pkt_data	=> udp_tx_pkt_data,
			udp_tx_pkt_vld    => udp_tx_pkt_vld,
			udp_tx_rdy		   => udp_tx_rdy,
			
			udp_rx_pkt_data   => udp_rx_pkt_data,
			udp_rx_pkt_req    => udp_rx_pkt_req,
			udp_rx_rdy		   => udp_rx_rdy,
			
			mac_init_done	   => mac_init_done,	
			
			-- MAC interface
			GIGE_COL			=> GIGE_COL,
			GIGE_CRS			=> GIGE_CRS,
			GIGE_MDC			=> GIGE_MDC,
			GIGE_MDIO	   => GIGE_MDIO,
			GIGE_TX_CLK	   => GIGE_TX_CLK,
			GIGE_nRESET	   => GIGE_nRESET,
			GIGE_RXD			=> GIGE_RXD,
			GIGE_RX_CLK		=> GIGE_RX_CLK,
			GIGE_RX_DV		=> GIGE_RX_DV,
			GIGE_RX_ER		=> GIGE_RX_ER,
			GIGE_TXD			=> GIGE_TXD,
			GIGE_GTX_CLK 	=> GIGE_GTX_CLK,
			GIGE_TX_EN		=> GIGE_TX_EN,
			GIGE_TX_ER		=> GIGE_TX_ER,
			
			-- system control
			clk_125mhz     => clk_125mhz,
			clk_100mhz     => clk_62_5mhz,
			sys_rst_i      => sysrst,
			sysclk_locked  => sysclk_locked
	  );

		clk_manager_inst : clk_manager
		port map(
			--External Control
			SYS_CLK_P_i  => sys_clk_p,
			SYS_CLK_N_i  => sys_clk_n,
			SYS_RST_i    => SYS_RST_i,
			
			clk_ab_p		 => clk_ab_p,
			clk_ab_n   	 => clk_ab_n,

			-- Clock out ports
			clk_125mhz    => clk_125mhz,
			clk_122_88mhz => clk_122_88mhz,
			clk_62_5mhz   => clk_62_5mhz,
			clk_61_44mhz  => clk_61_44mhz,		
			clk_25mhz     => clk_25mhz,			
			-- Status and control signals
			RESET         => sysrst,
			sysclk_locked => sysclk_locked,
			adcclk_locked => adcclk_locked
		);
		
		dsp_gbe_intercon_inst : dsp_gbe_intercon
		generic map(
			MEM_DATA_BYTES => INTERCON_BYTES,		
			MEM_DEPTH 		=> INTERCON_DEPTH
		)
		port map(
			rst  			 => sysrst,
			clk  			 => clk_61_44mhz,
			en   			 => '1', 
			rd_en			 => adc_pkt_rd_en,
			vld  			 => adc_pkt_vld,
			new_pkt_rcvd => new_pkt_rcvd,
			din  			 => (15 downto 14 => adc_cha_dout(13)) & adc_cha_dout,
			dout 			 => adc_pkt_data,
			count        => counter_samples
		);
			
		tx_proc : process(sysrst,clk_61_44MHz)
		begin
			if(sysrst = '1') then
			elsif(rising_edge(clk_61_44MHz)) then
				case tx_state is
					when "000" =>
						udp_tx_pkt_vld_r <= '0';
						adc_pkt_rd_en    <= '0';
						if(adc_pkt_vld = '1') then
							tx_state <= "001";															
						end if;
					when "001" =>
						if(udp_tx_rdy = '1') then				
							udp_tx_pkt_vld_r <= '1';
							adc_pkt_rd_en    <= '1';
							udp_tx_pkt_data  <= adc_pkt_data;
							tx_state         <= "010";			
						end if;
					when "010" =>						
						adc_pkt_rd_en    <= '1';
						udp_tx_pkt_vld_r <= '1';
						if(udp_tx_rdy = '0' and adc_pkt_vld = '0') then
							udp_tx_pkt_vld_r <= '0';
							tx_state         <= "000";
						end if;
					when others =>
						null;
				end case;
			end if;
		end process;		
		
		udp_tx_pkt_vld <= udp_tx_pkt_vld_r; 
				
		----------------------------------------------------------------------------------------------------
	   -- Debugging Section
	   ----------------------------------------------------------------------------------------------------
	   ila_data0(0) <= udp_tx_rdy;
		ila_data0(1) <= adc_pkt_vld;
		ila_data0(2) <= adc_pkt_rd_en;
		ila_data0(3) <= new_pkt_rcvd;
		ila_data0(4) <= pll_status;
		ila_data0(5) <= udp_tx_pkt_vld_r;
		ila_data0(6) <= mac_init_done;
		ila_data0(12 downto 7) <= rom_addr;
		
		ila_data0(15 downto 13) <= tx_state;
		
		ila_data0(31 downto 16) <= fm_data;
   	ila_data0(57 downto 51) <= counter_samples;
		--ila_data0(66   downto 51) <= rom_doutr;
		ila_data0(67) <= bridge_en;
		
		TRIG0(0) <= adc_pkt_vld;
		
	   ila_data1(13 downto 0) <= adc_cha_dout;
	   ila_data1(27 downto 14)<= adc_chb_dout;  
		ila_data1(28) <= pll_status;
		
		
		------ instantiate chipscope components -------
		icon_inst : icon
		  port map (
			 CONTROL0 => CONTROL0,
			 CONTROL1 => CONTROL1,
			 CONTROL2 => CONTROL2
			 );

		ila_data0_inst : ila0
		port map (
			 CONTROL => CONTROL0,
			 CLK     => clk_62_5mhz,
			 DATA    => ila_data0,
			 TRIG0   => TRIG0);
			
		ila_data1_inst : ila1
		  port map (
			 CONTROL => CONTROL2,
			 CLK => clk_61_44MHz,
			 DATA => ila_data1,
			 TRIG0 => TRIG1);
			 
		vio_inst : vio
	   port map (
		 CONTROL => CONTROL1,
		 ASYNC_OUT => vio_data);
	----------------------------------------------------------------------------------------------------
	-- End 
	----------------------------------------------------------------------------------------------------
end Behavioral;

