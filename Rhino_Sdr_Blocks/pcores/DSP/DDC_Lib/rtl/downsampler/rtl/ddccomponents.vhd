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

library IEEE;
use IEEE.STD_LOGIC_1164.all;

Library FIR_Lib;
Use FIR_Lib.fir_pkg.all;

package ddccomponents is

	component downsampler is
		generic(
			DIN_WIDTH 			  : natural;
			DOUT_WIDTH 			  : natural;
			-- CIC 1 configurations
			NUMBER_OF_STAGES	  : natural;
			DIFFERENTIAL_DELAY  : natural;
			SAMPLE_RATE_CHANGE  : natural;
			-- Compensating FIR configuratons
			NUMBER_OF_TAPS   	  : natural;  													
			FIR_LATENCY         : natural;  
			COEFF_WIDTH  	     : natural;
			COEFFS		        : coeff_type
		);
		port(
			CLK  : in  std_logic;
			RST  : in  std_logic;
			EN	  : in  std_logic;
			DIN  : in  std_logic_vector(DIN_WIDTH - 1 downto 0);
			VLD  : out std_logic;
			DOUT : out std_logic_vector(DOUT_WIDTH - 1 downto 0)
		);
	end component downsampler;

	component ddc is
	generic(
		DIN_WIDTH 			 : natural;
		DOUT_WIDTH 			 : natural;
		-- NCO Configurations
		PHASE_WIDTH		    : natural;
		PHASE_DITHER_WIDTH : natural;
		-- CIC 1 configurations
		SELECT_CIC1  		  : std_logic;
		NUMBER_OF_STAGES1	  : natural;
		DIFFERENTIAL_DELAY1 : natural;
		SAMPLE_RATE_CHANGE1 : natural;
		-- Compensating FIR configuratons
		SELECT_CFIR		     : std_logic;
		NUMBER_OF_TAPS   	  : natural;  													
		FIR_LATENCY         : natural;  
      COEFF_WIDTH  	     : natural;
		COEFFS		        : coeff_type;	
      -- CIC 2 configurations
		SELECT_CIC2  		  : std_logic;
		NUMBER_OF_STAGES2	  : natural;
		DIFFERENTIAL_DELAY2 : natural;
		SAMPLE_RATE_CHANGE2 : natural		
	);
	port(
		CLK  : in  std_logic;
		RST  : in  std_logic;
		EN	  : in  std_logic;
		DIN  : in  std_logic_vector(DIN_WIDTH - 1 downto 0);
		FTW  : in  std_logic_vector(PHASE_WIDTH - 1 downto 0);
		VLD  : out std_logic;
		IOUT : out std_logic_vector(DOUT_WIDTH - 1 downto 0);
		QOUT : out std_logic_vector(DOUT_WIDTH - 1 downto 0)		
	);
	end component ddc;
end ddccomponents;

package body ddccomponents is

---- Example 1
--  function <function_name>  (signal <signal_name> : in <type_declaration>  ) return <type_declaration> is
--    variable <variable_name>     : <type_declaration>;
--  begin
--    <variable_name> := <signal_name> xor <signal_name>;
--    return <variable_name>; 
--  end <function_name>;

---- Example 2
--  function <function_name>  (signal <signal_name> : in <type_declaration>;
--                         signal <signal_name>   : in <type_declaration>  ) return <type_declaration> is
--  begin
--    if (<signal_name> = '1') then
--      return <signal_name>;
--    else
--      return 'Z';
--    end if;
--  end <function_name>;

---- Procedure Example
--  procedure <procedure_name>  (<type_declaration> <constant_name>  : in <type_declaration>) is
--    
--  begin
--    
--  end <procedure_name>;
 
end ddccomponents;
