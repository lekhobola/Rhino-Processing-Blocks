----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    17:11:50 07/12/2014 
-- Design Name: 
-- Module Name:    MAC - Behavioral 
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
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_SIGNED.ALL;

library RHINO_DSP_PRIMITIVES_Lib;
use RHINO_DSP_PRIMITIVES_Lib.rounder;

entity MAC is
	generic(
		SAMPLE_WIDTH : natural;
		COEFF_WIDTH  : natural
	);
	port(
		clk,rst,clr,en : in std_logic;
		coeff				: in std_logic_vector(COEFF_WIDTH - 1 downto 0);
		x   				: in std_logic_vector(SAMPLE_WIDTH - 1 downto 0);
		y					: out std_logic_vector(SAMPLE_WIDTH downto 0)		
	);
end MAC;

architecture Behavioral of MAC is	
	COMPONENT rounder IS
		GENERIC(
			DIN_WIDTH  : natural;
			DOUT_WIDTH : natural
		);
		PORT(
			din  : in  std_logic_vector(DIN_WIDTH - 1 downto 0);
			dout : out std_logic_vector(DOUT_WIDTH - 1 downto 0)
		);
	END COMPONENT rounder;
		
	signal accum : std_logic_vector(COEFF_WIDTH + SAMPLE_WIDTH downto 0) := (others => '0');
	signal yreg : std_logic_vector(COEFF_WIDTH + SAMPLE_WIDTH downto 0) := (others => '0');
begin
		
	process(clk,rst)
		variable sum     : std_logic_vector(COEFF_WIDTH + SAMPLE_WIDTH downto 0) := (others => '0');
		variable product : std_logic_vector(COEFF_WIDTH + SAMPLE_WIDTH - 1 downto 0) := (others => '0');
	begin				
		if(rst = '1') then
			accum <= (others => '0');
		elsif(rising_edge(clk)) then
			product  := x * coeff;
			sum      := product + accum;	
			if(clr = '1') then
				accum <= (others => '0');
			elsif(en = '1') then
				yreg <= accum;				
			else
				accum <= sum;
			end if;
		end if;			
	end process;
	
--	rounder_inst : rounder
--	GENERIC MAP(
--		DIN_WIDTH  => COEFF_WIDTH + SAMPLE_WIDTH,
--		DOUT_WIDTH => SAMPLE_WIDTH + 1
--	)
--	PORT MAP(
--		din  => yreg(COEFF_WIDTH + SAMPLE_WIDTH - 1 downto 0), 
--		dout => y
--	);
  y <= yreg(COEFF_WIDTH + SAMPLE_WIDTH - 1 downto  SAMPLE_WIDTH );
end Behavioral;

