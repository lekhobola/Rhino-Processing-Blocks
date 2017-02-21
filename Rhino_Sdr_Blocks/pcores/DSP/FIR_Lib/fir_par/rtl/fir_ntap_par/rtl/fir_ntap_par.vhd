----------------------------------------------------------------------------------
-- Company: 		 UNIVERSITY OF CAPE TOWN
-- Engineer: 		 Lekhobola Joachim Tsoeunyane
-- 
-- Create Date:    11:57:47 05/06/2014 
-- Design Name: 
-- Module Name:    rhino_fir - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: 
--
-- Dependencies: 
--
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: 
--
----------------------------------------------------------------------------------
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
Use IEEE.STD_LOGIC_ARITH.all;
Use IEEE.STD_LOGIC_SIGNED.all;

Library FIR_Lib;
Use FIR_Lib.fir_pkg.all;
--Use work.fir_pkg.all;

entity fir_ntap_par is
	generic(
			DIN_WIDTH  		   : natural;  							-- input width of data and coefficients  	
			DOUT_WIDTH			: natural; 
			COEFF_WIDTH 		: natural;
			NUMBER_OF_TAPS 	: natural;  							-- filter length
			COEFFS		      : coeff_type
	);
	port(
			clk  : in std_logic;
			rst  : in std_logic;									  
			en   : in std_logic;
			loadc: in std_logic;
			vld  : out std_logic;
			coeff: in  std_logic_vector(COEFF_WIDTH - 1 downto 0);
			din  : in  std_logic_vector(DIN_WIDTH  - 1 downto 0);  -- input data
			dout : out std_logic_vector(DOUT_WIDTH - 1 downto 0)	  -- output data
	);
end fir_ntap_par;

architecture Behavioral of fir_ntap_par is 			
	
	constant MULTIPLIER_WIDTH : natural := DIN_WIDTH + COEFF_WIDTH;
	constant ADDER_WIDTH 	  : natural := DOUT_WIDTH + COEFF_WIDTH + 1;
	
	type state_type is (Idle,LoadCoeff,Proc);
	type mult_type  is array (0 to NUMBER_OF_TAPS - 1) of std_logic_vector (MULTIPLIER_WIDTH - 1 downto 0);
	type adder_type is array (0 to NUMBER_OF_TAPS - 1) of std_logic_vector (ADDER_WIDTH - 1 downto 0);

	signal coeff_regs : coeff_type(0 to NUMBER_OF_TAPS - 1) := coeffs;
	signal prods  : mult_type  := (others => (others => '0'));  -- multiplier array
	signal adders : adder_type := (others => (others => '0')); -- adder array
	signal yout   : std_logic_vector (ADDER_WIDTH - 1 downto 0) := (others => '0'); -- output register
	signal enProc : std_logic  := '0';
	signal vld_r  : std_logic  := '0';
	signal state  : state_type := Idle;
	signal ldcnt  : integer range 0 to NUMBER_OF_TAPS - 1 := 0;
	signal cnt	  : integer range 0 to 2 := 0;
begin
	
	process(clk,en)
	begin		
		if(en = '0') then
			cnt <= 0;
			ldcnt <= 0;
			state <= Idle;
		elsif(rising_edge(clk)) then
			if(en = '1') then
				case state is
					when Idle =>
						if(loadc = '1') then
							enProc <= '0';
							state <= LoadCoeff;
						else
							enProc <= '1';
							state  <= Proc;
						end if;
					when LoadCoeff =>
						if(ldcnt < NUMBER_OF_TAPS) then
							coeff_regs(ldcnt) <= conv_integer(coeff);	
							ldcnt <= ldcnt + 1;
							state <= LoadCoeff;
						else					
							enProc <= '1';
							state <= Proc;
						end if;
					when Proc =>
						if(cnt < 2) then
							vld_r <= '0';
							cnt <= cnt + 1;
						else
							vld_r <= '1';
						end if;
						state <= Proc;
				end case;
			end if;
		end if;
	end process;
	
	process (clk,rst)
	begin
		if(rst = '1') then
			for i in NUMBER_OF_TAPS - 1 downto 0 loop
				prods (i) <= (others => '0');
				adders(i) <= (others => '0');
			end  loop;	
		elsif (rising_edge(clk)) then -- Multiply-Adder pipeline		
			vld <= '0';
			if(en = '1') then
				if(enProc = '1') then					
					vld <= '1';					
					for i in NUMBER_OF_TAPS - 1 downto 0 loop	
						-- filter multiplier
						prods(i) <= conv_std_logic_vector(coeff_regs(i), COEFF_WIDTH) * din; 
					end  loop;		
					-- compute transposed fir filter			
					for j in NUMBER_OF_TAPS - 2 downto 0 loop	
						-- sum of products
						adders(j) <=  (prods(j)(MULTIPLIER_WIDTH - 1) & prods(j)) + adders(j + 1); 
					end loop;						
					-- first tap [no sum]
					adders(NUMBER_OF_TAPS - 1) <= (ADDER_WIDTH - 1 downto MULTIPLIER_WIDTH => prods(NUMBER_OF_TAPS - 1)(MULTIPLIER_WIDTH - 1)) & prods(NUMBER_OF_TAPS - 1); 
					yout <= adders(0);
				end if;	
			end if;
		end if;
	end process;
	dout <= yout(ADDER_WIDTH - 3 downto COEFF_WIDTH - 1); 
end Behavioral;
