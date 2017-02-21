--
--	Package File Template
--
--	Purpose: This package defines supplemental types, subtypes, 
--		 constants, and functions 
--
--   To use any of the example code shown below, uncomment the lines and modify as necessary
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

Library IEEE;
Use IEEE.STD_LOGIC_1164.all;
Use IEEE.MATH_REAL.all;

package ciccomponents is
	component CIC is
	generic(
		DIN_WIDTH	  		 : natural;
		NUMBER_OF_STAGES	 : natural;
		DIFFERENTIAL_DELAY : natural;
		SAMPLE_RATE_CHANGE : natural;
		FILTER_TYPE        : std_logic;
      CLKIN_PERIOD_NS    : real		
	);
	port(
	   clk  : in  std_logic;
		rst  : in  std_logic;
		en   : in std_logic;
		din  : in  std_logic_vector(DIN_WIDTH - 1 downto 0);
		vld  : out std_logic;
		dout : out std_logic_vector(DIN_WIDTH + (NUMBER_OF_STAGES * integer(ceil(log2(real(DIFFERENTIAL_DELAY * SAMPLE_RATE_CHANGE))))) - 1 downto 0) -- out_width : N*log2(RM)+in_width
	);
	end component CIC;
end ciccomponents;

package body ciccomponents is
end ciccomponents;
