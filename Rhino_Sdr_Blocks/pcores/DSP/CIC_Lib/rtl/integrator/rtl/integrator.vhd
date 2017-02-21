----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    12:44:41 08/13/2014 
-- Design Name: 
-- Module Name:    integrator - Behavioral 
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
use IEEE.STD_LOGIC_SIGNED.ALL;
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity integrator is
	generic(
		DIN_WIDTH  : natural;
		DOUT_WIDTH : natural
	);
	port(
		clk  : in  std_logic;
		rst  : in  std_logic;
		en	  : in  std_logic;
		din  : in  std_logic_vector(DIN_WIDTH  - 1 downto 0);
		dout : out std_logic_vector(DOUT_WIDTH - 1 downto 0)
	);
end integrator;

architecture Behavioral of integrator is
	signal delay : std_logic_vector(DOUT_WIDTH - 1 downto 0) := (others => '0');
begin
	process(clk,rst) 
	begin
		if(rst = '1') then
			delay <= (others => '0');
		elsif(rising_edge(clk)) then
			if(en = '1') then
				delay <= din + delay;
			end if;
		end if;			
	end process;
	dout <= delay;
end Behavioral;

