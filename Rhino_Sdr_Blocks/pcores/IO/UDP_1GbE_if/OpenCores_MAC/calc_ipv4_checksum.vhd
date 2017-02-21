-------------------------------------------------------------------------------
-- Title      : calc of the ipv4 checksum
-- Project    : 
-------------------------------------------------------------------------------
-- File       : calc_ipv4_checksum.vhd
-- Author     : Steffen Mauch
-- Company    : TU Ilmenau
-- Created    : 2013-02-03
-- Last update: 2013-04-19
-- Platform   : ISE 13.4
-- Standard   : VHDL'93
----------------------------------------------------------------------
-- Description: 
----------------------------------------------------------------------
----                                                              ----
---- Copyright (C) 2013 Steffen Mauch                             ----
----     steffen.mauch (at) gmail.com                             ----
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
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
library UNISIM;
use UNISIM.VComponents.all;

entity calc_ipv4_checksum is
    Port ( clk : in  STD_LOGIC;
           data : in  STD_LOGIC_VECTOR (159 downto 0);
			  ready : out STD_LOGIC;
           checksum : out  STD_LOGIC_VECTOR (15 downto 0);
           reset : in  STD_LOGIC);
end calc_ipv4_checksum;

architecture Behavioral of calc_ipv4_checksum is
	type array_int is array(0 to 9) of integer range 0 to 2**16-1;
	signal tmpData : array_int;
 
begin
	t1 : process( data )
	begin
		for i in 0 to 9 loop
			if( i=6 ) then
				-- ignore checksum field!
				tmpData(6) <= 0;
			else
				tmpData(i) <= to_integer( unsigned(data( i*16+15 downto i*16)) ); 
			end if;
		end loop;
	end process;

	calc_checksum_process : process(clk,reset)
		variable tempCheckSum : integer range 0 to 2**26-1;
	begin
		if( reset='1' ) then
			ready <= '0';
			checksum <= (others => '0');
		elsif( rising_edge(clk) ) then
			tempCheckSum := 0;
			for n in 0 to 9 loop
				tempCheckSum := tempCheckSum + tmpData(n);
			end loop;
			-- division is not a problem because power of 2!
			checksum <= not std_logic_vector(to_unsigned( (tempCheckSum mod 2**16) + (tempCheckSum / 2**16) ,16 ));
			ready <= '1';
		end if;
	end process;

end Behavioral;

