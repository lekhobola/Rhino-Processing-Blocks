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

package ncocomponents is
	component NCO is
	generic(
		FTW_WIDTH   : natural;
		PHASE_WIDTH : natural;
		PHASE_DITHER_WIDTH : natural
	);
	port(
		CLK  : in  std_logic;
		RST  : in  std_logic;
		FTW  : in  std_logic_vector(FTW_WIDTH - 1 downto 0);
		IOUT : out std_logic_vector(15 downto 0);
		QOUT : out std_logic_vector(15 downto 0)
	);
	end component NCO;
end ncocomponents;
package body ncocomponents is
end ncocomponents;
