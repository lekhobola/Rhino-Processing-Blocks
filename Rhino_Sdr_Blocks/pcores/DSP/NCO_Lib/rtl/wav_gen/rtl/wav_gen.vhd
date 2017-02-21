----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    11:18:11 06/05/2014 
-- Design Name: 
-- Module Name:    wav_gen - Behavioral 
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
use ieee.STD_LOGIC_signed.all;
use IEEE.STD_LOGIC_arith.ALL;
--library RHNO_NCO_CORE_Lib;
use work.wav_rom_pkg.all;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity wav_gen is
	port(
			clk,rst : in std_logic;
			phase	  : in std_logic_vector (9 downto 0);
			iout    : out std_logic_vector(15 downto 0);
			qout    : out std_logic_vector(15 downto 0)
	);
end wav_gen;

architecture Behavioral of wav_gen is
	constant PHASE_WIDTH : natural := 10;
begin
	process(clk,rst)
	begin
		if(rst = '1') then
			iout <= (others => '0');
			qout <= (others => '0');
		elsif(rising_edge(clk)) then
			case (phase(PHASE_WIDTH - 1 downto PHASE_WIDTH - 2)) is
				when "00"   => iout <=  cos_rom(conv_integer(unsigned(phase(PHASE_WIDTH - 3 downto 0))));
									qout <=  sin_rom(conv_integer(unsigned(phase(PHASE_WIDTH - 3 downto 0))));
				when "01"   => iout <=  -cos_rom((2 **(PHASE_WIDTH - 2) - 1) - conv_integer(unsigned(phase(PHASE_WIDTH - 3 downto 0))));
									qout <=  sin_rom((2 **(PHASE_WIDTH - 2) - 1) - conv_integer(unsigned(phase(PHASE_WIDTH - 3 downto 0))));
			   when "10"   => iout <=  -cos_rom(conv_integer(unsigned(phase(PHASE_WIDTH - 3 downto 0))));
								   qout <= -sin_rom(conv_integer(unsigned(phase(PHASE_WIDTH - 3 downto 0))));
				when "11" 	=> iout <= cos_rom((2 **(PHASE_WIDTH - 2) - 1) - conv_integer(unsigned((phase(PHASE_WIDTH - 3 downto 0)))));
								   qout <= -sin_rom((2 **(PHASE_WIDTH - 2) - 1) - conv_integer(unsigned(phase(PHASE_WIDTH - 3 downto 0))));
				when others => iout <= (others => '0');
									qout <= (others => '0');
			end case;
		end if;
	end process;
end Behavioral;

