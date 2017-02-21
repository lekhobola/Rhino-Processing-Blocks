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

package fftcomponents is

	COMPONENT r22sdf_fft_ifft_core IS
		GENERIC(
			N		      : NATURAL := 8;
			DIN_WIDTH   : NATURAL := 11;
			DOUT_WIDTH  : NATURAL := 11;
			TF_W        : NATURAL := 16;
			MODE        : STD_LOGIC
		);
		PORT(
			CLK,RST  : IN  STD_LOGIC;
			EN 	   : IN  STD_LOGIC;
			XSr,XSi  : IN  STD_LOGIC_VECTOR(DIN_WIDTH - 1 downto 0);
			VLD	   : OUT STD_LOGIC;
			DONE	   : OUT STD_LOGIC;
			XKr,XKi  : OUT STD_LOGIC_VECTOR(DOUT_WIDTH - 1 downto 0)
		);
	END COMPONENT r22sdf_fft_ifft_core;
	
end  fftcomponents;

package body fftcomponents is 
end fftcomponents;
