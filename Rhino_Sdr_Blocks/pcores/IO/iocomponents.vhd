----------------------------------------------------------------------
----                                                              ----
---- Copyright (C) 2014 Lekhobola Tsoeunyane                             ----
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
use IEEE.STD_LOGIC_1164.all;

package iocomponents is

component fmc150_if is
	port (
	  --RHINO Resources
	  sysrst	          : in    std_logic; -- CPU RST button
	  clk_100MHz       : in    std_logic;
	  mmcm_locked      : in    std_logic;
	  
	  clk_61_44MHz     : in std_logic;
	  clk_122_88MHz    : in std_logic;
	  
	  -------------- user design interface -----------------------
	  -- ADC 
	  adc_cha_dout      : out std_logic_vector(13 downto 0);
	  adc_chb_dout      : out std_logic_vector(13 downto 0);
	  
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

	  -- DAC specific signals
	  dac_n_en         : out   std_logic; -- SPI chip select
	  dac_sdo          : in    std_logic; -- SPI data out

	  -- Monitoring specific signals
	  mon_n_en         : out   std_logic; -- SPI chip select
	  mon_sdo          : in    std_logic; -- SPI data out
	  mon_n_reset      : out   std_logic;
	  mon_n_int        : in    std_logic;

	  --FMC-0 Present status
	  nfmc0_prsnt      : in    std_logic
	);
	end component fmc150_if;
		 
	component UDP_1GbE is
	  generic(
			UDP_TX_DATA_BYTE_LENGTH : natural := 1;
			UDP_RX_DATA_BYTE_LENGTH : natural:= 1
		);
	  port(
			-- user logic interface
			own_ip_addr		   : in std_logic_vector (31 downto 0);
			own_mac_addr      : in std_logic_vector (47 downto 0);
			dst_ip_addr       : in std_logic_vector (31 downto 0);
			dst_mac_addr      : in std_logic_vector(47 downto 0);
			
			udp_src_port  		: in std_logic_vector (15 downto 0);
			udp_dst_port      : in std_logic_vector (15 downto 0);
			
			udp_tx_pkt_data	: in std_logic_vector (8 * UDP_TX_DATA_BYTE_LENGTH - 1 downto 0);
			udp_tx_pkt_vld    : in std_logic;
			udp_tx_rdy		   : out std_logic;
			
			udp_rx_pkt_data   : out std_logic_vector(8 * UDP_RX_DATA_BYTE_LENGTH - 1 downto 0);
			udp_rx_pkt_req    : in  std_logic;
			udp_rx_rdy		   : out std_logic;
			
			mac_init_done	   : out std_logic;
			
			-- MAC interface
			GIGE_COL			: in std_logic;
			GIGE_CRS			: in std_logic;
			GIGE_MDC			: out std_logic;
			GIGE_MDIO	   : inout std_logic;
			GIGE_TX_CLK	   : in std_logic;
			GIGE_nRESET	   : out std_logic;
			GIGE_RXD			: in std_logic_vector( 7 downto 0 );
			GIGE_RX_CLK		: in std_logic;
			GIGE_RX_DV		: in std_logic;
			GIGE_RX_ER		: in std_logic;
			GIGE_TXD			: out std_logic_vector( 7 downto 0 );
			GIGE_GTX_CLK 	: out std_logic;
			GIGE_TX_EN		: out std_logic;
			GIGE_TX_ER		: out std_logic;
			
			-- system control
			clk_125mhz     : in  std_logic;
			clk_100mhz     : in  std_logic;
			sys_rst_i      : in  std_logic;
			sysclk_locked  : in  std_logic
	  );
	end component UDP_1GbE;
end iocomponents;

package body iocomponents is

---- Example 1
--  function <function_name>  (signal <signal_name> : in <type_declaration>  ) return <type_declaration> is
--    variable <variable_name>     : <type_declaration>;
--  begin
--    <variable_name> := <signal_name> xor <signal_name>;
--    return <variable_name>; 
--  end <function_name>;

---- Example 2
--  function <function_name>  (signal <signal_name> : in <type_declaration>;
--                         signal <signal_name>   : in <type_declaration>  ) return <type_declaration> is
--  begin
--    if (<signal_name> = '1') then
--      return <signal_name>;
--    else
--      return 'Z';
--    end if;
--  end <function_name>;

---- Procedure Example
--  procedure <procedure_name>  (<type_declaration> <constant_name>  : in <type_declaration>) is
--    
--  begin
--    
--  end <procedure_name>;
 
end iocomponents;
