
----------------------------------------------------------------------------------

----------------------------------------------------------------------------------
-- Title      : Implementation of Digitial Down Converter Core
----------------------------------------------------------------------------------
-- Project    : RHINO SDR Processing Blocks
----------------------------------------------------------------------------------
--
--	Author     : Lekhobola Tsoeunyane
-- Company    : University Of Cape Town
-- Email		  : lekhobola@gmail.com
-- Date	     : 12:31:24 08/15/2014
----------------------------------------------------------------------------------
-- Revisions : 
----------------------------------------------------------------------------------
-- Features
-- 1) Digital Down-Shifting using Numerically-Controlled Oscillator core
-- 2) Decimation and Filtering using 2 CIC cores
-- 2) CIC compensation filter using FIR cire
--
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
----------------------------------------------------------------------------------
-- Library declarations
----------------------------------------------------------------------------------
Library IEEE;
Use IEEE.STD_LOGIC_1164.ALL;
Use IEEE.STD_LOGIC_SIGNED.all;
Use IEEE.MATH_REAL.ALL;

Library NCO_Lib;
Use NCO_Lib.ncocomponents.all;

Library DSP_PRIMITIVES_Lib;
Use DSP_PRIMITIVES_Lib.dspcomponents.all;

Library CIC_Lib;
Use CIC_Lib.ciccomponents.all;

Library FIR_Lib;
Use FIR_Lib.fir_pkg.all;
Use FIR_Lib.fircomponents.all;

entity ddc is
	generic(
		DIN_WIDTH 			 : natural := 16;
		DOUT_WIDTH 			 : natural := 16;
		-- NCO Configurations
		PHASE_WIDTH		    : natural := 32;
		PHASE_DITHER_WIDTH : natural := 22;
		-- CIC 1 configurations
		SELECT_CIC1  		  : std_logic := '1';
		NUMBER_OF_STAGES1	  : natural := 10;
		DIFFERENTIAL_DELAY1 : natural := 1;
		SAMPLE_RATE_CHANGE1 : natural := 128;
		-- Compensating FIR configuratons
		SELECT_CFIR		     : std_logic := '0';
		NUMBER_OF_TAPS   	  : natural	  := 21;  													
		FIR_LATENCY         : natural   := 0;  
      COEFF_WIDTH  	     : natural   := 16;
		COEFFS		        : coeff_type := (-78,-132,-217,-247,-57,516,1534,2880,4261,5301,5689,5301,4261,2880,1534,516,-57,-247,-217,-132,-78);	
      -- CIC 2 configurations
		SELECT_CIC2  		  : std_logic := '0';
		NUMBER_OF_STAGES2	  : natural := 1;
		DIFFERENTIAL_DELAY2 : natural := 1;
		SAMPLE_RATE_CHANGE2 : natural	:= 2	
	);
	port(
		CLK  : in  std_logic;
		RST  : in  std_logic;
		EN	  : in  std_logic;
		DIN  : in  std_logic_vector(DIN_WIDTH - 1 downto 0);
		FTW  : in  std_logic_vector(PHASE_WIDTH - 1 downto 0);
		VLD  : out std_logic;
		IOUT : out std_logic_vector(DOUT_WIDTH - 1 downto 0);
		QOUT : out std_logic_vector(DOUT_WIDTH - 1 downto 0)		
	);
end ddc;

architecture Behavioral of ddc is
		
	constant AMPL_WIDTH  : natural := 16;
	constant CIC_DOUT_WIDTH1 : natural := DIN_WIDTH + (NUMBER_OF_STAGES1 * integer(ceil(log2(real(DIFFERENTIAL_DELAY1 * SAMPLE_RATE_CHANGE1)))));
	constant FIR_WIDTH       : natural := natural(ceil(log2(real((2 ** (DOUT_WIDTH-1)) * (2 ** (COEFF_WIDTH-1)) * NUMBER_OF_TAPS)))) + 1;
	constant CIC_DOUT_WIDTH2 : natural := DOUT_WIDTH + (NUMBER_OF_STAGES2 * integer(ceil(log2(real(DIFFERENTIAL_DELAY2 * SAMPLE_RATE_CHANGE2)))));
	
	signal nco_iout      : std_logic_vector(AMPL_WIDTH - 1 downto 0) 		 := (others => '0');
	signal nco_qout      : std_logic_vector(AMPL_WIDTH - 1 downto 0) 		 := (others => '0');
	signal mixer_iout    : std_logic_vector(DIN_WIDTH  - 1 downto 0)  	 := (others => '0');
	signal mixer_qout    : std_logic_vector(DIN_WIDTH  - 1 downto 0)      := (others => '0');
	signal cic_iout1     : std_logic_vector(CIC_DOUT_WIDTH1 - 1 downto 0)  := (others => '0');
	signal cic_qout1     : std_logic_vector(CIC_DOUT_WIDTH1 - 1 downto 0)  := (others => '0');
	signal fir_iout      : std_logic_vector(FIR_WIDTH - 1 downto 0)  := (others => '0');
	signal fir_qout      : std_logic_vector(FIR_WIDTH - 1 downto 0)  := (others => '0');
	signal cic_iout2     : std_logic_vector(CIC_DOUT_WIDTH2 - 1 downto 0)  := (others => '0');
	signal cic_qout2     : std_logic_vector(CIC_DOUT_WIDTH2 - 1 downto 0)  := (others => '0');
	signal ivld1		   : std_logic;
	signal qvld1     	   : std_logic;
	signal ivld2		   : std_logic;
	signal qvld2     	   : std_logic;
	signal ivld3		   : std_logic;
	signal qvld3     	   : std_logic;
begin
	
	NCO_INST : NCO 
	GENERIC MAP(
		FTW_WIDTH   => PHASE_WIDTH,
		PHASE_WIDTH => PHASE_WIDTH,
		PHASE_DITHER_WIDTH => PHASE_DITHER_WIDTH
	)
	PORT MAP(
		CLK  => clk,
		RST  => rst,
		FTW  => FTW,
		IOUT => nco_iout,
		QOUT => nco_qout
	);
	
	PHASE_MIXER : mixer 
	generic map(
		DIN1_WIDTH => DIN_WIDTH,
		DIN2_WIDTH => AMPL_WIDTH,
		DOUT_WIDTH => DIN_WIDTH
	)
	port map(
		din1 => din,
		din2 => nco_iout,
		dout => mixer_iout
	);
	
	QUAD_MIXER : mixer 
	generic map(
		DIN1_WIDTH => DIN_WIDTH,
		DIN2_WIDTH => AMPL_WIDTH,
		DOUT_WIDTH => DIN_WIDTH
	)
	port map(
		din1 => din,
		din2 => nco_qout,
		dout => mixer_qout
	);
	
	USE_CIC1 : if SELECT_CIC1 = '1' generate	
	PHASE_DECIMATOR1: CIC
	GENERIC MAP(
		DIN_WIDTH	  		 => DIN_WIDTH,
		NUMBER_OF_STAGES	 => NUMBER_OF_STAGES1,
		DIFFERENTIAL_DELAY => DIFFERENTIAL_DELAY1,
		SAMPLE_RATE_CHANGE => SAMPLE_RATE_CHANGE1,
		FILTER_TYPE        => '0',
		CLKIN_PERIOD_NS    => 0.0
	)
	PORT MAP(
		CLK  => clk,
		RST  => rst,
		EN   => EN,
		DIN  => mixer_iout,
		VLD  => ivld1,
		DOUT => cic_iout1
	);
	
	QUAD_DECIMATOR1 : CIC 
	GENERIC MAP(
		DIN_WIDTH	  		 => DIN_WIDTH,
		NUMBER_OF_STAGES	 => NUMBER_OF_STAGES1,
		DIFFERENTIAL_DELAY => DIFFERENTIAL_DELAY1,
		SAMPLE_RATE_CHANGE => SAMPLE_RATE_CHANGE1,
		FILTER_TYPE        => '0',
		CLKIN_PERIOD_NS    => 0.0
	)
	PORT MAP(
		CLK  => clk,
		RST  => rst,
		EN   => EN,
		DIN  => mixer_qout,
		VLD  => qvld1,
		DOUT => cic_qout1
	);
	end generate USE_CIC1;	

	USE_CFIR : if SELECT_CFIR = '1' generate	
	PHASE_CFIR : fir_par
	generic map(
		DIN_WIDTH		  => DOUT_WIDTH,
		DOUT_WIDTH  	  => FIR_WIDTH,
		COEFF_WIDTH 	  => COEFF_WIDTH,
		LATENCY          => FIR_LATENCY,
		NUMBER_OF_TAPS	  => NUMBER_OF_TAPS,
		coeffs			  => COEFFS
	)
	port map(
		clk   => clk,
		rst   => rst,							  
		en    => ivld1,
		loadc => '0',
		vld   => ivld2,
		coeff => (others => '0'),
		din   => cic_iout1(CIC_DOUT_WIDTH1 - 1 downto CIC_DOUT_WIDTH1 - DOUT_WIDTH),
		dout  => fir_iout
	);
	
	QUAD_CFIR : fir_par
	generic map(
		DIN_WIDTH		  => DOUT_WIDTH,
		DOUT_WIDTH  	  => FIR_WIDTH,
		COEFF_WIDTH 	  => COEFF_WIDTH,
		LATENCY          => FIR_LATENCY,
		NUMBER_OF_TAPS	  => NUMBER_OF_TAPS,
		coeffs			  => COEFFS
	)
	port map(
		clk   => clk,
		rst   => rst,							  
		en    => qvld1,
		loadc => '0',
		vld   => qvld2,
		coeff => (others => '0'),
		din   => cic_qout1(CIC_DOUT_WIDTH1 - 1 downto CIC_DOUT_WIDTH1 - DOUT_WIDTH),
		dout  => fir_qout
	);
	end generate USE_CFIR;
	
	USE_CIC2 : if SELECT_CIC2 = '1' generate	
	PHASE_DECIMATOR2: CIC
	GENERIC MAP(
		DIN_WIDTH	  		 => DOUT_WIDTH,
		NUMBER_OF_STAGES	 => NUMBER_OF_STAGES2,
		DIFFERENTIAL_DELAY => DIFFERENTIAL_DELAY2,
		SAMPLE_RATE_CHANGE => SAMPLE_RATE_CHANGE2,
		FILTER_TYPE        => '0',
		CLKIN_PERIOD_NS    => 0.0
	)
	PORT MAP(
		CLK  => clk,
		RST  => rst,
		EN   => ivld2,
		DIN  => fir_iout(DOUT_WIDTH - 1 downto 0),
		VLD  => ivld3,
		DOUT => cic_iout2
	);
	
	QUAD_DECIMATOR2 : CIC 
	GENERIC MAP(
		DIN_WIDTH	  		 => DOUT_WIDTH,
		NUMBER_OF_STAGES	 => NUMBER_OF_STAGES2,
		DIFFERENTIAL_DELAY => DIFFERENTIAL_DELAY2,
		SAMPLE_RATE_CHANGE => SAMPLE_RATE_CHANGE2,
		FILTER_TYPE        => '0',
		CLKIN_PERIOD_NS    => 0.0
	)
	PORT MAP(
		CLK  => clk,
		RST  => rst,
		EN   => qvld2,
		DIN  => fir_qout(DOUT_WIDTH - 1 downto 0),
		VLD  => qvld3,
		DOUT => cic_qout2
	);
	end generate USE_CIC2;
	
	
	process(clk,rst) 
	begin
		if(rst = '1') then 
		elsif(rising_edge(clk)) then
			if(en = '1') then
				if(SELECT_CIC2 = '1') then		
					vld <= (ivld3 and qvld3);
					if(DOUT_WIDTH < CIC_DOUT_WIDTH2) then
						iout <= cic_iout2(CIC_DOUT_WIDTH2 - 1 downto  CIC_DOUT_WIDTH2 - DOUT_WIDTH);
						qout <= cic_qout2(CIC_DOUT_WIDTH2 - 1 downto  CIC_DOUT_WIDTH2 - DOUT_WIDTH);
					elsif(DOUT_WIDTH > CIC_DOUT_WIDTH2) then
						iout <= (DOUT_WIDTH - CIC_DOUT_WIDTH2 - 1 downto 0 => cic_iout2(CIC_DOUT_WIDTH2 - 1)) & cic_iout2(CIC_DOUT_WIDTH2 - 1 downto 0);
						qout <= (DOUT_WIDTH - CIC_DOUT_WIDTH2 - 1 downto 0 => cic_qout2(CIC_DOUT_WIDTH2 - 1)) & cic_qout2(CIC_DOUT_WIDTH2 - 1 downto 0);
					else
						iout <= cic_iout2;
						qout <= cic_qout2;
					end if;
				elsif(SELECT_CIC1 = '1' and SELECT_CFIR = '0') then
					vld <= (ivld1 and qvld1);
					if(DOUT_WIDTH < CIC_DOUT_WIDTH1) then
						iout <= cic_iout1(CIC_DOUT_WIDTH1 - 1 downto  CIC_DOUT_WIDTH1 - DOUT_WIDTH);
						qout <= cic_qout1(CIC_DOUT_WIDTH1 - 1 downto  CIC_DOUT_WIDTH1 - DOUT_WIDTH);
					elsif(DOUT_WIDTH > CIC_DOUT_WIDTH1) then
						iout <= (DOUT_WIDTH - CIC_DOUT_WIDTH1 - 1 downto 0 => cic_iout1(CIC_DOUT_WIDTH1 - 1)) & cic_iout1(CIC_DOUT_WIDTH1 - 1 downto 0);
						qout <= (DOUT_WIDTH - CIC_DOUT_WIDTH1 - 1 downto 0 => cic_qout1(CIC_DOUT_WIDTH1 - 1)) & cic_qout1(CIC_DOUT_WIDTH1 - 1 downto 0);
					else
						iout <= cic_iout1;
						qout <= cic_qout1;
					end if;
				elsif(SELECT_CFIR = '1') then	
					vld <= (ivld2 and qvld2);
					if(DOUT_WIDTH < FIR_WIDTH) then
						iout <= fir_iout(DOUT_WIDTH - 1 downto  0);
						qout <= fir_qout(DOUT_WIDTH - 1 downto  0);
					elsif(DOUT_WIDTH > FIR_WIDTH) then
						iout <= (DOUT_WIDTH - FIR_WIDTH - 1 downto 0 => fir_iout(FIR_WIDTH - 1)) & fir_iout(FIR_WIDTH - 1 downto 0);
						qout <= (DOUT_WIDTH - FIR_WIDTH - 1 downto 0 => fir_qout(FIR_WIDTH - 1)) & fir_qout(FIR_WIDTH - 1 downto 0);
					else
						iout <= fir_iout;
						qout <= fir_qout;
					end if;		
				else
					vld <= '1';
					if(DOUT_WIDTH < DIN_WIDTH) then
						iout <= mixer_iout(DOUT_WIDTH - 1 downto  DIN_WIDTH - DOUT_WIDTH);
						qout <= mixer_qout(DOUT_WIDTH - 1 downto  DIN_WIDTH - DOUT_WIDTH);
					elsif(DOUT_WIDTH > DIN_WIDTH) then
						iout <= (DOUT_WIDTH - DIN_WIDTH - 1 downto 0 => mixer_iout(DIN_WIDTH - 1)) & mixer_iout(DIN_WIDTH - 1 downto 0);
						qout <= (DOUT_WIDTH - DIN_WIDTH - 1 downto 0 => mixer_qout(DIN_WIDTH - 1)) & mixer_qout(DIN_WIDTH - 1 downto 0);
					else
						iout <= mixer_iout;
						qout <= mixer_qout;
					end if;				
				end if;
			end if;
		end if;
	end process;
	
	--vld <= (ivld2 and qvld2) when SELECT_CIC2 = '1' else
	--		 (ivld1 and qvld1);

   -----------------------------------------------------------------------------------
	-- Debugging Section
	-----------------------------------------------------------------------------------
	-- Mixer Output 
	--iout <=  mixer_iout(DIN_WIDTH - 1 downto 0);
	--qout <=  mixer_qout(DIN_WIDTH - 1 downto 0);
	
	-- NCO output
	--iout <= nco_iout(15 downto 0);
	--qout <= nco_qout(15 downto 0);
	
	-- CIC 1 output
	--iout <= cic_iout1(CIC_DOUT_WIDTH1 - 1 downto  CIC_DOUT_WIDTH1 - DOUT_WIDTH);
	--qout <= cic_qout1(CIC_DOUT_WIDTH1 - 1 downto  CIC_DOUT_WIDTH1 - DOUT_WIDTH);	
	
	-- CIC 2 output
	--iout <= fir_iout(DOUT_WIDTH - 1 downto  0);
	--qout <= fir_qout(DOUT_WIDTH - 1 downto  0);
	
	-- C-FIR 2 output
	--iout <= cic_iout2(CIC_DOUT_WIDTH2 - 1 downto  CIC_DOUT_WIDTH2 - DOUT_WIDTH);
	--qout <= cic_qout2(CIC_DOUT_WIDTH2 - 1 downto  CIC_DOUT_WIDTH2 - DOUT_WIDTH);
	
	------------------------------------------------------------------------------------
	-- Debugging Section
	------------------------------------------------------------------------------------
end Behavioral;

