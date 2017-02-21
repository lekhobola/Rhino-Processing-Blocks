----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    17:22:47 07/14/2014 
-- Design Name: 
-- Module Name:    coeff_rom - Behavioral 
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

Library RHINO_FIR_CORE_Lib;
Use RHINO_FIR_CORE_Lib.fir_pkg.all;
--use work.fir_filter_pkg.all;
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity coeff_rom is
	generic(
	   ROM_COEFF_WIDTH : natural;
		ROM_ADDR_WIDTH  : natural;
		COEFFS		    : coeff_type
	);
	port(
		clk,rst,en : in  std_logic;
		cnt_zero   : out std_logic;
		dout		  : out std_logic_vector(ROM_COEFF_WIDTH - 1 downto 0)
	);
end coeff_rom;

architecture Behavioral of coeff_rom is	
	COMPONENT counter 
		GENERIC(
			ADDR_WIDTH : natural
		);
		PORT(
			clk,rst,en : in  std_logic;
			dout		  : out std_logic_vector(ADDR_WIDTH - 1 downto 0)
		);
   END COMPONENT;
	
	COMPONENT rom 
		GENERIC(
			ADDR_WIDTH  : natural;
			COEFF_WIDTH : natural;
			COEFFS		: coeff_type(0 to (2 ** ROM_ADDR_WIDTH) - 1)
		);
		 PORT(
			  addr  : in  std_logic_vector (ADDR_WIDTH - 1 downto 0);
			  dout  : out std_logic_vector (COEFF_WIDTH - 1 downto 0)
		);
	END COMPONENT;
   signal addr : std_logic_vector(ROM_ADDR_WIDTH - 1 downto 0);
	signal flag : std_logic := '0';
begin

   flag <= addr(ROM_ADDR_WIDTH - 1);
	last_count : process(flag)
	begin	
		if(falling_edge(flag)) then
			cnt_zero <= '1';
			cnt_zero <= '0' AFTER 1 ns;
		end if;
	end process;
	
	counter_inst : counter 
	GENERIC MAP(
		ADDR_WIDTH => ROM_ADDR_WIDTH
	)
	PORT MAP(
		clk  => clk,
		rst  => rst,
		en   => en,
		dout => addr
	);
	
	rom_inst : rom 
	GENERIC MAP(
		ADDR_WIDTH  => ROM_ADDR_WIDTH,
		COEFF_WIDTH => ROM_COEFF_WIDTH,
		COEFFS 		=> COEFFS
	)
	PORT MAP(
		  addr => addr,
		  dout => dout
	);
end Behavioral;

