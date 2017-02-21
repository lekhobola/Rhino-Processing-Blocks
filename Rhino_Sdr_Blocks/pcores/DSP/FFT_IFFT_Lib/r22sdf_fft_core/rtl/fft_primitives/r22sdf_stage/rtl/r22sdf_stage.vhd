--********************************************************************************
--* Company:        University of Cape Town									   
--* Engineer:       Lekhobola Joachim Tsoeunyane, lekhobola@gmail.com		       
--********************************************************************************
--* Create Date:    30-June-2014 12:44:49  				 										   
--* Design Name:    Pipelined R2^2 DIF-SDF FFT								       
--* Module Name:    r22sdf_stage.vhd										   
--* Project Name:   RHINO SDR Processing Blocks								   
--* Target Devices: Xilinx - SPARTAN-6											   
--********************************************************************************
--* Dependencies: BF2I.vhd,BF2II.vhd,shift_reg.vhd,complex_mult.vhd
--********************************************************************************
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

library DSP_PRIMITIVES_Lib;
use DSP_PRIMITIVES_Lib.dspcomponents.all;
--********************************************************************************
--* This module implements a complex Radix 2^2 single-path delay feedback   
--* FFT butterfly stage. It is made up of two butterflies namely BF2I and BF2II    
--* and they both compute a 4-point DFT of the R2^2-SDF FFT. BF2I computes a 
--* 2-point DFT and BF2II computes multiplication by -j followed by 2-point DFT.
--* The shift register a linked to the each butterflies to achieve and pipelined
--* structure of R2^2-SDF FFT. The two butterflies are followed by a complex 
--* multiplier which computes a product of BF2II ouput and ROM twidde factor
--* which is the last operation of the stage.
--********************************************************************************
--* params:																	   
--*        data_w - Input data bit width								       
--*        tf_w   - Twiddle factor bit width
--*		  del1_w	- Shift Register Depth of B2I									   
--*		  del2_w	- Shift Register Depth of B2II
--* ports:																		   
--* 			[in]  clk   - System clock - active on the rising edge					   
--* 			[in]  rst   - Active high asynchronous reset line
--*         [in]  s1    - Controls BF2I
--*         [in]  s2    - Controls BF2II
--* 			[in]  tfr   - Real-part twiddle factor 
--*         [in]  tfi   - Imaginary-part twiddle factor
--*         [in]  dinr  - Real-part input sample
--*			[in]  dini  - Imaginary-part input sample
--*         [out] doutr - Real output sample
--*			[out] douti - Imaginary output sample
--********************************************************************************
--* Notes: none
--********************************************************************************
entity r22sdf_stage is
	generic(
		data_w : natural;
		tf_w   : natural;
		del1_w : natural;
		del2_w : natural
	);
	port(
		clk,rst,en,s1,s2 : in std_logic;
		tfr,tfi	  		  : in std_logic_vector(tf_w - 1 downto 0);
		dinr,dini     	  : in std_logic_vector(data_w - 1 downto 0);
		doutr,douti   	  : out std_logic_vector(data_w + 1 downto 0)
	);
end r22sdf_stage;

architecture Behavioral of r22sdf_stage is
	COMPONENT BF2I
	   GENERIC(
			BF2I_data_w  : natural
		);
		PORT(
			s			    : in std_logic;
			xpr			 : in std_logic_vector  (BF2I_data_w  - 1 downto 0);
			xpi			 : in std_logic_vector  (BF2I_data_w  - 1 downto 0);
			xfr 			 : in std_logic_vector  (BF2I_data_w  downto 0);
			xfi 			 : in std_logic_vector  (BF2I_data_w  downto 0);
			znr          : out std_logic_vector (BF2I_data_w  downto 0);
			zni          : out std_logic_vector (BF2I_data_w  downto 0);
			zfr          : out std_logic_vector (BF2I_data_w  downto 0);
			zfi          : out std_logic_vector (BF2I_data_w  downto 0)
		);
	END COMPONENT;
	
	COMPONENT BF2II
		GENERIC(
			BF2II_data_w : natural
		);
		port(
			s			    : in std_logic;
			t			    : in std_logic;
			xpr			 : in std_logic_vector  (BF2II_data_w - 1 downto 0);
			xpi			 : in std_logic_vector  (BF2II_data_w - 1 downto 0);
			xfr 			 : in std_logic_vector  (BF2II_data_w downto 0);
			xfi 			 : in std_logic_vector  (BF2II_data_w downto 0);
			znr          : out std_logic_vector (BF2II_data_w downto 0);
			zni          : out std_logic_vector (BF2II_data_w downto 0);
			zfr          : out std_logic_vector (BF2II_data_w downto 0);
			zfi          : out std_logic_vector (BF2II_data_w downto 0)
		);
	END COMPONENT;
	
	COMPONENT shift_reg
		GENERIC(
			shift_reg_data_w : natural;
			depth  			  : natural
		);
		PORT(
			clk : IN  std_logic;
			rst : IN  std_logic;
			en  : in  std_logic;
			xr  : IN  std_logic_vector(shift_reg_data_w - 1 downto 0);
			xi  : IN  std_logic_vector(shift_reg_data_w - 1 downto 0);
			zr  : OUT std_logic_vector(shift_reg_data_w - 1 downto 0);
			zi  : OUT std_logic_vector(shift_reg_data_w - 1 downto 0)
		);
    END COMPONENT;

	COMPONENT complex_mult
		 GENERIC(
			dataa_w : natural;
			datab_w : natural
		 );
		 PORT(
				ar : in  std_logic_vector(dataa_w - 1 downto 0);
				ai : in  std_logic_vector(dataa_w - 1 downto 0);
				br : in  std_logic_vector(datab_w - 1 downto 0);
				bi : in  std_logic_vector(datab_w - 1 downto 0);
				cr : out std_logic_vector(dataa_w + datab_w - 1 downto 0);
				ci : out std_logic_vector(dataa_w + datab_w - 1 downto 0)
		  );
	 END COMPONENT;
	 
	COMPONENT rounder IS
		GENERIC(
			DIN_WIDTH  : natural;
			DOUT_WIDTH : natural
		);
		PORT(
			din  : in  std_logic_vector(DIN_WIDTH - 1 downto 0);
			dout : out std_logic_vector(DOUT_WIDTH - 1 downto 0)
		);
	END COMPONENT rounder;
	
	 signal BF2I_zfr   : std_logic_vector(data_w downto 0) := (others => '0');
	 signal BF2I_zfi   : std_logic_vector(data_w downto 0) := (others => '0');
	 signal BF2I_znr   : std_logic_vector(data_w downto 0) := (others => '0');
	 signal BF2I_zni   : std_logic_vector(data_w downto 0) := (others => '0');
	 
	 signal BF2I_ram_xfr : std_logic_vector(data_w downto 0) := (others => '0');
	 signal BF2I_ram_xfi : std_logic_vector(data_w downto 0) := (others => '0');
	 
	 signal BF2II_zfr   : std_logic_vector(data_w + 1 downto 0) := (others => '0');
	 signal BF2II_zfi   : std_logic_vector(data_w + 1 downto 0) := (others => '0');
	 signal BF2II_znr   : std_logic_vector(data_w + 1 downto 0) := (others => '0');
	 signal BF2II_zni   : std_logic_vector(data_w + 1 downto 0) := (others => '0');
	 
	 signal BF2II_ram_xfr : std_logic_vector(data_w + 1 downto 0) := (others => '0');
	 signal BF2II_ram_xfi : std_logic_vector(data_w + 1 downto 0) := (others => '0');	 
	
	 signal cm_xr  : std_logic_vector(data_w + tf_w + 1 downto 0) := (others => '0');
	 signal cm_xi  : std_logic_vector(data_w + tf_w + 1 downto 0) := (others => '0');
	 
begin	
   -- BF2I instantiation
	BF2I_inst : BF2I
	GENERIC MAP(
			BF2I_data_w => data_w
	)
	PORT MAP(
		s			    => s1,
		xpr			 => dinr,
		xpi			 => dini,
		xfr 			 => BF2I_ram_xfr,
		xfi 			 => BF2I_ram_xfi,
		znr          => BF2I_znr,
		zni          => BF2I_zni,
		zfr          => BF2I_zfr,
		zfi          => BF2I_zfi
	);
	
	-- BF2I Shift Register instantiation
	BF2I_RAM_inst : shift_reg
	GENERIC MAP(
		shift_reg_data_w => data_w + 1,
		depth  			  => del1_w
	)
	PORT MAP(
		clk => clk,
		rst => rst,
		en  => en,
		xr  => BF2I_zfr,
		xi  => BF2I_zfi,
		zr  => BF2I_ram_xfr,
		zi  => BF2I_ram_xfi
	);	 
	
	-- BF2II instantiation
	BF2II_inst : BF2II
	GENERIC MAP(
			BF2II_data_w => data_w + 1
	)
	PORT MAP(
		s   			 => s2,
		t   			 => s1,
		xpr			 => BF2I_znr,
		xpi			 => BF2I_zni,
		xfr 			 => BF2II_ram_xfr,
		xfi 			 => BF2II_ram_xfi,
		znr          => BF2II_znr,
		zni          => BF2II_zni,
		zfr          => BF2II_zfr,
		zfi          => BF2II_zfi
	);
	
	-- BF2II Shift Register instantiation
	BF2II_RAM_inst : shift_reg
	GENERIC MAP(
		shift_reg_data_w => data_w + 2,
		depth  			  => del2_w
	)
	PORT MAP(
		clk => clk,
		rst => rst,
		en  => en,
		xr  => BF2II_zfr,
		xi  => BF2II_zfi,
		zr  => BF2II_ram_xfr,
		zi  => BF2II_ram_xfi
	);
	
	-- Complex Multipler instantiation
	CM_inst : complex_mult
	GENERIC MAP(
		dataa_w => data_w + 2,
		datab_w => tf_w
	)
	PORT MAP(
		ar => BF2II_znr,
		ai => BF2II_zni,
		br => tfr,
		bi => tfi,
		cr => cm_xr,
		ci => cm_xi
	);
	
	rounder_inst0 : rounder
	GENERIC MAP(
		DIN_WIDTH  => data_w + tf_w,
		DOUT_WIDTH => data_w + 2
	)
	PORT MAP(
		din  => cm_xr(data_w + tf_w - 1 downto 0), 
		dout => doutr
	);
	
	rounder_inst1 : rounder
	GENERIC MAP(
		DIN_WIDTH  => data_w + tf_w,
		DOUT_WIDTH => data_w + 2
	)
	PORT MAP(
		din  => cm_xi(data_w + tf_w - 1 downto 0), 
		dout => douti
	);
	--doutr <= cm_xr(data_w + tf_w - 1 downto tf_w - 2);
	--douti <= cm_xi(data_w + tf_w - 1 downto tf_w - 2);
end Behavioral;

