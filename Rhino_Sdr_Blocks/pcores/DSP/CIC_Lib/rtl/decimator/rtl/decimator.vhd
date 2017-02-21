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
Use IEEE.STD_LOGIC_1164.ALL;
Use IEEE.MATH_REAL.ALL;

Library UNISIM;
Use UNISIM.VComponents.all;

entity decimator is
	generic(
		DIN_WIDTH	  			 : natural;
		NUMBER_OF_STAGES	 : natural;
		DIFFERENTIAL_DELAY : natural;
		SAMPLE_RATE_CHANGE : natural;
		CLKIN_PERIOD_NS	 : real
	);
	port(
	   CLK  : in  std_logic;
		RST  : in  std_logic;
		EN   : in std_logic;
		DIN  : in  std_logic_vector(DIN_WIDTH - 1 downto 0);
		VLD  : out std_logic;
		DOUT : out std_logic_vector(DIN_WIDTH + (NUMBER_OF_STAGES * integer(ceil(log2(real(DIFFERENTIAL_DELAY * SAMPLE_RATE_CHANGE))))) - 1 downto 0) -- dout_width : N*log2(RM)+DIN_WIDTH
	);
end decimator;

architecture Behavioral of decimator is
	COMPONENT integrator IS
		GENERIC(
			DIN_WIDTH  : natural;
			DOUT_WIDTH : natural
		);
		PORT(
			clk,rst,en : in std_logic;
			din  		  : in std_logic_vector(DIN_WIDTH - 1 downto 0);
			dout 		  : out std_logic_vector(DOUT_WIDTH -1  downto 0)
		);
	END COMPONENT integrator;
	
	COMPONENT comb IS
		GENERIC(
			DIN_WIDTH	  			 : natural;
			DIFFERENTIAL_DELAY : natural		
		);
		PORT(
			clk      : in  std_logic;
			rst  		: in  std_logic;
			en		   : in  std_logic;
			din  		: in  std_logic_vector(DIN_WIDTH - 1 downto 0);
			dout 		: out std_logic_vector(DIN_WIDTH - 1 downto 0)
		);
	END COMPONENT comb;
	
	constant dout_width     		: natural := DIN_WIDTH + (NUMBER_OF_STAGES * integer(ceil(log2(real(DIFFERENTIAL_DELAY * SAMPLE_RATE_CHANGE)))));
	
	type integ_type is array(0 to NUMBER_OF_STAGES - 1) of std_logic_vector(dout_width - 1 downto 0);
	type comb_type  is array(0 to NUMBER_OF_STAGES - 1) of std_logic_vector(dout_width - 1 downto 0);
	
	signal integ_wire : integ_type := (others => (others => '0'));
	signal comb_wire  : comb_type  := (others => (others => '0'));
	signal clkcnt	   : integer range 0 to SAMPLE_RATE_CHANGE/2;	
	signal vld_r	   : std_logic := '0';
begin

	vld <= vld_r;
	
	process(clk)
	begin
		if(rising_edge(clk)) then
			vld_r <= '0';
			if(en = '1') then
				if(clkcnt = SAMPLE_RATE_CHANGE - 1) then
					vld_r <= '1';
					clkcnt <= 0;
				else					
					clkcnt <= clkcnt + 1;
				end if;
			end if;
		end if;
	end process;
	
	IntegratorGen : for i in 0 to NUMBER_OF_STAGES - 1 generate
	begin
		FirstIntegrator : if i = 0 generate
		FirstIntegrator_inst : integrator 
		generic map(
			DIN_WIDTH  => DIN_WIDTH,
			DOUT_WIDTH => dout_width
		)
		port map(
			clk  => clk,
			rst  => rst,
			en   => en,
			din  => DIN,
			dout => integ_wire(0)
		);
		end generate;
		
		MiddleIntegrator : if i > 0 generate
		MiddleIntegrator_inst : integrator 
		generic map(
			DIN_WIDTH  => dout_width,
			DOUT_WIDTH => dout_width
		)
		port map(
			clk  => clk,
			rst  => rst,
			en   => en,
			din  => integ_wire(i - 1),
			dout => integ_wire(i)
		);
		end generate;
	end generate IntegratorGen;	
	
	CombGen : for i in 0 to NUMBER_OF_STAGES - 1 generate
	begin
		FirstComb : if i = 0 generate
		FirstComb_inst : comb 
		generic map(
			DIN_WIDTH	  			 => dout_width,
			DIFFERENTIAL_DELAY => DIFFERENTIAL_DELAY
		)
		port map(
			clk  => clk,
			rst  => rst,			
			en	  => vld_r,
			din  => integ_wire(NUMBER_OF_STAGES - 1),
			dout => comb_wire(0)
		);
		end generate;
		
		MiddleComb : if i > 0 generate
		MiddleComb_inst : comb 
		generic map(
			DIN_WIDTH	  			 => dout_width,
			DIFFERENTIAL_DELAY => DIFFERENTIAL_DELAY
		)
		port map(
			clk  => clk,
			rst  => rst,
			en	  => vld_r,
			din  => comb_wire(i - 1),
			dout => comb_wire(i)
		);
		end generate;
	end generate CombGen;

	DOUT <= comb_wire(NUMBER_OF_STAGES - 1);
end Behavioral;



