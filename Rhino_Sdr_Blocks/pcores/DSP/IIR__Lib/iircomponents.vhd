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

Library RHINO_IIR_CORE_Lib;
Use RHINO_IIR_CORE_Lib.iir_filter_pkg.all;

package iircomponents is
	component order1_iir is
	generic(
		IN_WIDTH 	: natural;  
		OUT_WIDTH   : natural;
		COEFF_WIDTH : natural;
		COEFF			: integer
	);
	port(
		clk,rst : in  std_logic;
		x 		  : in  std_logic_vector(IN_WIDTH - 1 downto 0);
		y 		  : out std_logic_vector(OUT_WIDTH - 1 downto 0)
	);
	end component order1_iir;
end iircomponents;

package body iircomponents is
end iircomponents;
