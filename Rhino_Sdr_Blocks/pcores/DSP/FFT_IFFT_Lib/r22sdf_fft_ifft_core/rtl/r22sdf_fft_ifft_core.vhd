--********************************************************************************
--* Company:        University of Cape Town									   
--* Engineer:       Lekhobola Joachim Tsoeunyane, lekhobola@gmail.com		       
--********************************************************************************
--* Create Date:    08-August-2014 00:25:09  				 										   
--* Design Name:    Pipelined R2^2 DIF-SDF FFT								       
--* Module Name:    rhino_r22sdf_fft_core.vhd										   
--* Project Name:   RHINO SDR Processing Blocks								   
--* Target Devices: Xilinx - SPARTAN-6											   
--********************************************************************************
--* Dependencies: fft8.vhd,fft16.vhd,fft32.vhd,fft64.vhd,fft128.vhd,fft256.vhd
--*					fft512.vhd,fft1024.vhdfft2048.vhd,fft4096.vhd
--********************************************************************************
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.MATH_REAL.ALL;

--********************************************************************************
--* This module implements a complex N-point Radix 2^2 single-path delay feedback   
--* pipelined FFT or IFFT core with configurable Input bit widths where N is powers of 2. 
--* i.e. 8, 16, 32, 64, 128, 256, 512, 1024, 2048, 4096. The input samples are 
--* in  natural order and ouput samples are in bit reversed order.
--********************************************************************************
--* params:																	   
--*        N	   	 - Number of fft points, valid options are 8, 16, 32, 64, 
--*							128, 256, 512, 1024, 2048, 4096								       
--*        DIN_W      - Input data bit width, default option is 8
--*		  TFT_W		 - Twiddle factor bit width, default option is 16	
--*		  MODE		 - 0=Enable FFT, 1=Enable IFFT								   
--* ports:																		   
--* 			[in]  CLK - System clock - active on the rising edge					   
--* 			[in]  RST - Active high asynchronous reset line
--* 			[in]  EN  - System Clock Enable
--* 			[in]  XSr - Real-part input sample 
--*         [in]  XSi - Imaginary-part input sample
--*         [out] XKr - Real-part output sample
--*			[out] XKi - Imaginary-part output sample
--********************************************************************************
--* Notes: Only powers of 2 are valid for number of points option "N"    
--********************************************************************************
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
ENTITY r22sdf_fft_ifft_core IS
	GENERIC(
		N		      : NATURAL := 8;
		DIN_WIDTH   : NATURAL := 11;
		DOUT_WIDTH  : NATURAL := 11;
		TF_W        : NATURAL := 16;
		MODE        : STD_LOGIC := '0'
	);
	PORT(
		CLK,RST  : IN  STD_LOGIC;
		EN 	   : IN  STD_LOGIC;
		XSr,XSi  : IN  STD_LOGIC_VECTOR(DIN_WIDTH - 1 downto 0);
		VLD	   : OUT STD_LOGIC;
		DONE	   : OUT STD_LOGIC;
		XKr,XKi  : OUT STD_LOGIC_VECTOR(DOUT_WIDTH - 1 downto 0)
	);
END r22sdf_fft_ifft_core;

architecture Behavioral of r22sdf_fft_ifft_core is
	COMPONENT r22sdf_fft_core IS
	GENERIC(
		N		 : NATURAL;
		DIN_W  : NATURAL;
		TF_W   : NATURAL 
	);
	PORT(
		CLK	  : IN STD_LOGIC;
		RST	  : IN STD_LOGIC;
		EN 	  : IN  STD_LOGIC;
		XSr,XSi : IN STD_LOGIC_VECTOR(DIN_W - 1 downto 0);
		VLD	  : OUT STD_LOGIC;
		DONE	  : OUT STD_LOGIC;
		XKr,XKi : OUT STD_LOGIC_VECTOR(DIN_W + INTEGER(LOG2(real(N))) - 1 downto 0)
	);
	END COMPONENT r22sdf_fft_core;
	
	COMPONENT r22sdf_ifft_core IS
		GENERIC(
			N		 : NATURAL := 8;
			DIN_W  : NATURAL := 11;
			TF_W   : NATURAL := 16
		);
		PORT(
			CLK,RST : IN  STD_LOGIC;
			EN 	  : IN STD_LOGIC;
			XKr,XKi : IN  STD_LOGIC_VECTOR (DIN_W - 1 downto 0);
			VLD	  : OUT STD_LOGIC;
			XSr,XSi : OUT STD_LOGIC_VECTOR(DIN_W - INTEGER(LOG2(real(N))) + 1 downto 0)
		);
	END COMPONENT r22sdf_ifft_core;

	constant FFT_DOUT_WIDTH  : natural  := DIN_WIDTH + INTEGER(LOG2(real(N)));
	constant IFFT_DOUT_WIDTH : natural  := DIN_WIDTH - INTEGER(LOG2(real(N))) + 2;
	signal doutr,douti   : std_logic_vector(FFT_DOUT_WIDTH - 1  downto 0);
	signal doutr1,douti1 : std_logic_vector(IFFT_DOUT_WIDTH - 1 downto 0);
begin

	gen_fft : if mode = '0' GENERATE
	BEGIN
	r22sdf_fft_core_inst :r22sdf_fft_core
		GENERIC MAP(
			N		 => N,
			DIN_W  => DIN_WIDTH,
			TF_W   => TF_W
		)
		PORT MAP(
			CLK => CLK,
			RST => RST,
			EN  => EN,
			XSr => XSr,
			XSi => XSi,
			VLD => vld,
			DONE => DONE,
			XKr => doutr,
			XKi => douti
		);
		XKr <= doutr(FFT_DOUT_WIDTH - 1 downto FFT_DOUT_WIDTH - DOUT_WIDTH);
		XKi <= douti(FFT_DOUT_WIDTH - 1 downto FFT_DOUT_WIDTH - DOUT_WIDTH);
	 end GENERATE;
	 
	gen_ifft : if mode = '1' GENERATE
	BEGIN
	  r22sdf_ifft_core_inst :r22sdf_ifft_core
		GENERIC MAP(
			N		 => N,
			DIN_W  => DIN_WIDTH,
			TF_W   => TF_W
		)
		PORT MAP(
			CLK => CLK,
			RST => RST,
			EN  => EN,		
			XKr => XSr,
			XKi => XSi,
			VLD => VLD,
			XSr => doutr1,
			XSi => douti1
		);
		XKr <= doutr1(IFFT_DOUT_WIDTH - 1 downto IFFT_DOUT_WIDTH - DOUT_WIDTH);
		XKi <= douti1(IFFT_DOUT_WIDTH - 1 downto IFFT_DOUT_WIDTH - DOUT_WIDTH);
	 end GENERATE;	
end Behavioral;

