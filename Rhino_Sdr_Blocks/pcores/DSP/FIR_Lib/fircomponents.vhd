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

Library FIR_Lib;
Use FIR_Lib.fir_pkg.all;

package fircomponents is
	component fir_par is
	generic(				  
		DIN_WIDTH 		  : natural;  							
		DOUT_WIDTH       : natural;
		COEFF_WIDTH 	  : natural;
		NUMBER_OF_TAPS   : natural;  													
		LATENCY	        : natural;   
		COEFFS		     : coeff_type
	);
	port(
		clk  : in  std_logic;
		rst  : in  std_logic;									  
		en   : in  std_logic;
		loadc: in  std_logic;
		vld  : out std_logic;
		coeff: in  std_logic_vector(COEFF_WIDTH - 1 downto 0);
		din  : in  std_logic_vector(DIN_WIDTH   - 1 downto 0);  
		dout : out std_logic_vector(DOUT_WIDTH  - 1 downto 0)	  -- 
	);
	end component fir_par;
end fircomponents;

package body fircomponents is
end fircomponents;
