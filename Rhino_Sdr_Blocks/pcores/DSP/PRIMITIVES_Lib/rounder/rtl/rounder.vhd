----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    16:16:07 08/03/2014 
-- Design Name: 
-- Module Name:    rounder - Behavioral 
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
USE IEEE.NUMERIC_STD.ALL;
USE IEEE.STD_LOGIC_SIGNED.ALL;
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity rounder is
	generic(
		DIN_WIDTH  : natural := 4;
		DOUT_WIDTH : natural := 2
	);
	port(
		din  : in  std_logic_vector(DIN_WIDTH  - 1 downto 0);
		dout : out std_logic_vector(DOUT_WIDTH - 1 downto 0)
	);
end rounder;

architecture Behavioral of rounder is	
	constant rad_pos : integer := DIN_WIDTH - DOUT_WIDTH; 
	signal rounded_reg : std_logic_vector(DOUT_WIDTH - 1 downto 0);
begin
	process(din)
		variable rounded_temp : std_logic_vector(DOUT_WIDTH downto 0);
	begin
		if(rad_pos > 0) then 
			if(conv_integer(din(DIN_WIDTH - 1 downto rad_pos)) = (2 ** (DOUT_WIDTH)) - 1) then
				rounded_temp := din(DIN_WIDTH - 1) & din(DIN_WIDTH - 1 downto rad_pos);
			else
				if(rad_pos = 1) then
					rounded_temp := din(DIN_WIDTH - 1) & din(DIN_WIDTH - 1 downto rad_pos) + ((DIN_WIDTH - 1 downto rad_pos  => '0') & din(0));
				else
					if(to_integer(signed(din)) < 0 and conv_integer(din(rad_pos - 1 downto 0)) = 0) then
						rounded_temp :=  din(DIN_WIDTH - 1) & din(DIN_WIDTH - 1 downto rad_pos);
					else
						rounded_temp := din(DIN_WIDTH - 1) & din(DIN_WIDTH - 1 downto rad_pos) + ((DIN_WIDTH - 1 downto rad_pos  => '0') & din(rad_pos-1));
					end if;
				end if;
			end if;
			rounded_reg <= rounded_temp(DOUT_WIDTH - 1 downto 0);
		else
			rounded_reg <= rounded_temp(DIN_WIDTH - 1 downto rad_pos);
		end if;		
	end process;
	dout <= rounded_reg;
end Behavioral;

