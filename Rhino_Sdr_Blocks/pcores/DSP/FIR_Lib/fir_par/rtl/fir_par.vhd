
----------------------------------------------------------------------------------

----------------------------------------------------------------------------------
-- Title      : Implementation of FIR Core
----------------------------------------------------------------------------------
-- Project    : RHINO SDR Processing Blocks
----------------------------------------------------------------------------------
--
--	Author     : Lekhobola Tsoeunyane
-- Company    : University Of Cape Town
-- Email		  : lekhobola@gmail.com
-- Date	     : 15:39:58 10/24/2014 
----------------------------------------------------------------------------------
-- Revisions : 
----------------------------------------------------------------------------------
-- Features
-- It implements the follwing FIR structures :
-- 1) All coefficients transpose FIR
-- 2) Even symmetrical transpose FIR
-- 2) Odd symmetrical transpose FIR
-- 3) Moving Average FIR
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
Use IEEE.MATH_REAL.ALL;

Library FIR_Lib;
Use FIR_Lib.fir_pkg.all;

entity fir_par is
	generic(				  
		DIN_WIDTH 		  : natural := 16;  							
		DOUT_WIDTH       : natural := 32;
		COEFF_WIDTH 	  : natural := 16; 
		NUMBER_OF_TAPS   : natural := 95;  													
		LATENCY          : natural := 0;   
		COEFFS		     : coeff_type := (-1,1,2,-1,-4,0,7,3,-9,-9,9,17,-5,-25,-4,32,18,-34,-38,28,59,-10,-76,-19,83,56,-76,-96,49,130,-5,-148,-53,144,114,-113,-168,58,202,16,-207,-95,180,166,-122,-215,43,233,43,-215,-122,166,180,-95,-207,16,202,58,-168,-113,114,144,-53,-148,-5,130,49,-96,-76,56,83,-19,-76,-10,59,28,-38,-34,18,32,-4,-25,-5,17,9,-9,-9,3,7,0,-4,-1,2,1,-1)
	);
	port(
		clk   : in  std_logic;
		rst   : in  std_logic;									  
		en    : in  std_logic;
		loadc : in  std_logic;
		vld   : out std_logic;
		coeff : in  std_logic_vector(COEFF_WIDTH - 1 downto 0);  
		din   : in  std_logic_vector(DIN_WIDTH   - 1 downto 0);  
		dout  : out std_logic_vector(DOUT_WIDTH  - 1 downto 0)	  -- 
	);
end fir_par;

architecture Behavioral of fir_par is
	component fir_ntap_par
	generic(
		DIN_WIDTH  		 : natural; 
		DOUT_WIDTH		 : natural;
		COEFF_WIDTH		 : natural;
		NUMBER_OF_TAPS  : natural;  	
		COEFFS		    : coeff_type
	);
	port(
		clk  : in std_logic;
		rst  : in std_logic;									  
		en   : in std_logic;
		loadc: in std_logic;
		vld  : out std_logic;
		coeff: in  std_logic_vector(COEFF_WIDTH - 1 downto 0);
		din  : in  std_logic_vector(DIN_WIDTH - 1 downto 0);
		dout : out std_logic_vector(DOUT_WIDTH - 1 downto 0)	 
	);
	end component;

	component fir_ntap_esym_par
	generic(
		DIN_WIDTH	   : natural;
		DOUT_WIDTH	   : natural;
		COEFF_WIDTH 	: natural;
		NUMBER_OF_TAPS	: natural;
		COEFFS		   : coeff_type
	);
	port(
		clk : in std_logic;
		rst : in std_logic;									  
		en  : in std_logic;
		loadc: in std_logic;
		vld : out std_logic;
		coeff: in  std_logic_vector(COEFF_WIDTH - 1 downto 0);
		din 	 : in  std_logic_vector(DIN_WIDTH - 1 downto 0);
		dout	 : out std_logic_vector(DOUT_WIDTH - 1 downto 0)	  -- output data
	);	end component;

	component fir_ntap_osym_par
	generic(
		DIN_WIDTH  		: natural;  							-- input width of data and coefficients  	
		DOUT_WIDTH		: natural;
		COEFF_WIDTH    : natural;
		NUMBER_OF_TAPS : natural;  							-- filter length
		COEFFS		   : coeff_type
	);
	port(
		clk  : in  std_logic;
		rst  : in  std_logic;									  
		en   : in  std_logic;
		vld  : out std_logic;
		din  : IN  std_logic_vector(DIN_WIDTH  - 1 downto 0);
		dout : out std_logic_vector(DOUT_WIDTH - 1 downto 0)	  -- output data
	  );
	end component;
	 
	component fir_ntap_avg_par is
	generic(
		DIN_WIDTH	   : natural;
		DOUT_WIDTH     : natural;
		COEFF_WIDTH    : natural;
		NUMBER_OF_TAPS	: natural
	);
	port(
		clk : in std_logic;
		rst : in std_logic;									  
		en  : in std_logic;
		vld : out std_logic;
		din  : in  std_logic_vector(DIN_WIDTH  - 1 downto 0);
		dout : out std_logic_vector(DOUT_WIDTH - 1 downto 0)	  -- output data
	);
	end component fir_ntap_avg_par;
begin			 		 
				 
	GENERIC_FIR : if LATENCY = 0 GENERATE	
	fir_ntap_par_inst: fir_ntap_par 
	generic map(
		DIN_WIDTH      => DIN_WIDTH, 
		DOUT_WIDTH     => DOUT_WIDTH, 
		COEFF_WIDTH    => COEFF_WIDTH,
		NUMBER_OF_TAPS	=> NUMBER_OF_TAPS,
		COEFFS		   => COEFFS
	)
	port map (
		 clk   => clk,
		 rst   => rst,								  
		 en    => en,
		 loadc => loadc,
		 vld   => vld,
		 coeff => coeff,
		 din   => din,
		 dout  => dout
	  );
	end generate;

	EVEN_SYM_FIR : if LATENCY = 1 generate	
	fir_ntap_esym_par_inst: fir_ntap_esym_par 
	generic map(
		DIN_WIDTH      => DIN_WIDTH, 
		DOUT_WIDTH     => DOUT_WIDTH, 
		COEFF_WIDTH    => COEFF_WIDTH,
		NUMBER_OF_TAPS	=> NUMBER_OF_TAPS,
		COEFFS		   => COEFFS
	)
	port map (
		 clk   => clk,
		 rst   => rst,								  
		 en    => en,
		 loadc => loadc,
		 vld   => vld,
		 coeff => coeff,
		 din   => din,
		 dout  => dout
	  );
	end generate;

	MOVING_AVG_FIR : if LATENCY = 2 GENERATE	
	fir_ntap_osym_par_inst: fir_ntap_osym_par 
	generic map(
		DIN_WIDTH      => DIN_WIDTH,
		DOUT_WIDTH     => DOUT_WIDTH,		
		COEFF_WIDTH    => COEFF_WIDTH,
		NUMBER_OF_TAPS	=> NUMBER_OF_TAPS,
		COEFFS		   => COEFFS
	)
	port map (
		 clk  => clk,
		 rst  => rst,								  
		 en   => en,
		 vld  => vld,
		 din  => din,
		 dout => dout
	  );
	end generate;
	
	ODD_SYM_FIR : if LATENCY = 3 GENERATE	
	fir_ntap_osym_par_inst: fir_ntap_avg_par 
	generic map(
		DIN_WIDTH      => DIN_WIDTH, 
		DOUT_WIDTH     => DOUT_WIDTH,
		COEFF_WIDTH    => COEFF_WIDTH,
		NUMBER_OF_TAPS	=> NUMBER_OF_TAPS
	)
	port map (
		 clk  => clk,
		 rst  => rst,								  
		 en   => en,
		 vld  => vld,
		 din  => din,
		 dout => dout
	  );
	end generate;
end Behavioral;

