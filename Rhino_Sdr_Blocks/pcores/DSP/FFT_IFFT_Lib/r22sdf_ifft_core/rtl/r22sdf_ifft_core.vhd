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
--* pipelined FFT core with configurable Input bit widths where N is powers of 2. 
--* i.e. 8, 16, 32, 64, 128, 256, 512, 1024, 2048, 4096. The input samples are 
--* in  natural order and ouput samples are in bit reversed order.
--********************************************************************************
--* params:																	   
--*        N	   	 - Number of fft points, valid options are 8, 16, 32, 64, 
--*							128, 256, 512, 1024, 2048, 4096								       
--*        DIN_W      - Input data bit width, default option is 8
--*		  TFT_W		 - Twiddle factor bit width, default option is 16									   
--* ports:																		   
--* 			[in]  CLK - System clock - active on the rising edge					   
--* 			[in]  RST - Active high asynchronous reset line
--* 			[in]  XSr - Real-part input sample 
--*         [in]  XSi - Imaginary-part input sample
--*         [out] XKr - Real-part output sample
--*			[out] XKi - Imaginary-part output sample
--********************************************************************************
--* Notes: Only powers of 2 are valid for number of points option "N"    
--********************************************************************************
ENTITY r22sdf_ifft_core IS
	GENERIC(
		N		 : NATURAL := 8;
		DIN_W  : NATURAL := 11;
		TF_W   : NATURAL := 16
	);
	PORT(
		CLK,RST : IN STD_LOGIC;
		EN 	  : IN STD_LOGIC;
		XKr,XKi : IN STD_LOGIC_VECTOR(DIN_W - 1 downto 0);
		VLD	  : OUT STD_LOGIC;
		XSr,XSi : OUT STD_LOGIC_VECTOR(DIN_W - INTEGER(LOG2(real(N))) + 1 downto 0)
	);
END r22sdf_ifft_core;

architecture Behavioral of r22sdf_ifft_core is
	COMPONENT r22sdf_fft_core IS
		GENERIC(
			N		 : NATURAL := 8;
			DIN_W  : NATURAL := 11;
			TF_W   : NATURAL := 16
		);
		PORT(
			CLK,RST : IN  STD_LOGIC;
			EN 	  : IN STD_LOGIC;
			XSr,XSi : IN  STD_LOGIC_VECTOR (DIN_W - 1 downto 0);
			VLD	  : OUT STD_LOGIC;
			XKr,XKi : OUT STD_LOGIC_VECTOR(DIN_W + INTEGER(LOG2(real(N))) - 1 downto 0)
		);
	END COMPONENT r22sdf_fft_core;
	constant LOGN			: natural := INTEGER(LOG2(real(N)));
	constant DOUT_W      : natural := DIN_W - LOGN + 1;
	signal   DOUTr,DOUTi : STD_LOGIC_VECTOR(DIN_W + LOGN - 1 downto 0);	
	
begin
	XSr <= DOUTi(DOUT_W + LOGN  downto LOGN);
	XSi <= DOUTr(DOUT_W + LOGN  downto LOGN);
	
	r22sdf_fft_core_inst :r22sdf_fft_core
		GENERIC MAP(
			N		 => N,
			DIN_W  => DIN_W,
			TF_W   => TF_W
		)
		PORT MAP(
			CLK => CLK,
			RST => RST,
			EN  => EN,
			XSr => XKr,
			XSi => XKi,
			VLD => VLD,
			XKr => doutr,
			XKi => douti
		);
end Behavioral;

