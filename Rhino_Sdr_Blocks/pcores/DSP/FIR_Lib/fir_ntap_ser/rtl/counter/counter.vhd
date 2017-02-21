
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity counter is
	generic(
		ADDR_WIDTH : natural
	);
	port(
		clk,rst,en : in std_logic;
		dout		  : out std_logic_vector(ADDR_WIDTH - 1 downto 0)
	);
end counter;

architecture Behavioral of counter is
	signal count : std_logic_vector(ADDR_WIDTH - 1 downto 0) := (others => '0');
begin
	process(clk,rst)		
	begin
		if(rst = '1') then
			count <= (others => '0');
		elsif(rising_edge(clk)) then
			if(en = '1') then
				count <= count + 1;
			end if;
		end if;
	end process;
	dout <= count;
end Behavioral;

