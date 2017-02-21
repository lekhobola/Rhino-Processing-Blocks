library ieee;
use ieee.std_logic_1164.all;
USE IEEE.NUMERIC_STD.ALL;
use ieee.std_logic_unsigned.all;

entity phase_acc is
	generic(		
	   FTW_WIDTH   : natural;
		PHASE_WIDTH : natural
	);
	port(
		clk   : in  std_logic;
		rst   : in  std_logic;
		ftw   : in  std_logic_vector(FTW_WIDTH - 1 downto 0);
		phase : out std_logic_vector(PHASE_WIDTH - 1 downto 0)
	);
end phase_acc;

architecture behavioral of phase_acc is
	signal 	 delay   : std_logic_vector( PHASE_WIDTH - 1 downto 0) := (others => '0');
begin
	process(clk,rst)
		variable sum : std_logic_vector(PHASE_WIDTH - 1 downto 0) := (others => '0');
	begin
		if(rst = '1') then
			phase <= (others => '0');
			sum   := (others => '0');
		elsif(rising_edge(clk)) then
			sum   := delay + ftw;		
			delay <= sum;
		end if;
		phase <= sum;
	end process;
end  behavioral;