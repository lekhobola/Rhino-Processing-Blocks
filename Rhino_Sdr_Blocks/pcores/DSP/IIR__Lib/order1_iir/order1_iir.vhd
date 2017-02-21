library ieee;
use IEEE.std_logic_1164.all;
use IEEE.STD_LOGIC_ARITH.all;
use IEEE.STD_LOGIC_SIGNED.all;

entity order1_iir is
	generic(
	   IN_WIDTH 	: natural;
		OUT_WIDTH   : natural;
		COEFF_WIDTH : natural;
		COEFF			: integer
	);
	port(
		clk,rst : in  std_logic;
		x 		  : in  std_logic_vector(IN_WIDTH - 1 downto 0);
		y 		  : out std_logic_vector(OUT_WIDTH - 1 downto 0)
	);
end order1_iir;

architecture behavioral of order1_iir is
	signal delay : std_logic_vector(OUT_WIDTH - 1 downto 0) := (others => '0');
begin
	process(clk,rst)
		variable prod : std_logic_vector(OUT_WIDTH + COEFF_WIDTH - 1 downto 0) := (others => '0');
	begin
		if(rst = '1') then
			delay <= (others => '0');
		elsif(clk ='1' and clk'event) then
			prod := conv_std_logic_vector(COEFF, COEFF_WIDTH) * delay;
			delay <= ((OUT_WIDTH - IN_WIDTH - 1 downto 0 => x(IN_WIDTH - 1)) & x) + prod(OUT_WIDTH + COEFF_WIDTH - 2  downto COEFF_WIDTH - 1);
		end if;
	end process;
	y <= delay;
end  behavioral;
