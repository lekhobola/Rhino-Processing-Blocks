library ieee;
use ieee.std_logic_1164.all;
use IEEE.STD_LOGIC_ARITH.all;
use IEEE.STD_LOGIC_SIGNED.all;

library IIR_Lib;
use IIR_Lib.iir_pkg.all;

entity order2_iir is
	generic(
		IN_WIDTH    		: natural;
	   COEFF_WIDTH   : natural;
		b						: sos_type;
		a					   : sos_type;
		INDEX					: natural
	);
	port(
		clk,rst : in  std_logic;
		x 		  : in  std_logic_vector(IN_WIDTH - 1 downto 0);
		y 		  : out std_logic_vector(IN_WIDTH - 1 downto 0)
	);
end order2_iir;
	
architecture behavioural of order2_iir is	
	signal del_x1	  : std_logic_vector(IN_WIDTH - 1 downto 0)	      := (others => '0');
	signal del_x2	  : std_logic_vector(IN_WIDTH - 1 downto 0)	      := (others => '0');
	signal del_y1	  : std_logic_vector(IN_WIDTH - 1 downto 0)	      := (others => '0');
	signal del_y2	  : std_logic_vector(IN_WIDTH - 1 downto 0)	      := (others => '0');
begin
	
	process(clk,rst)
		variable sum0   : std_logic_vector(IN_WIDTH + COEFF_WIDTH  downto 0)	   := (others => '0');
		variable sum1   : std_logic_vector(IN_WIDTH + COEFF_WIDTH  downto 0)	   := (others => '0');	
		variable sum3   : std_logic_vector(IN_WIDTH + COEFF_WIDTH  downto 0)    := (others => '0');
		variable prodb0 : std_logic_vector(IN_WIDTH + COEFF_WIDTH - 1 downto 0) := (others => '0'); 
		variable prodb1 : std_logic_vector(IN_WIDTH + COEFF_WIDTH - 1 downto 0) := (others => '0'); 
		variable prodb2 : std_logic_vector(IN_WIDTH + COEFF_WIDTH - 1 downto 0) := (others => '0'); 
		variable proda1 : std_logic_vector(IN_WIDTH + COEFF_WIDTH - 1 downto 0) := (others => '0'); 
		variable proda2 : std_logic_vector(IN_WIDTH + COEFF_WIDTH - 1 downto 0) := (others => '0'); 
		variable sum2   : std_logic_vector(IN_WIDTH + COEFF_WIDTH downto 0)     := (others => '0');
	begin
		if(rst = '1') then
			del_x1   <= (others => '0'); 
			del_x2   <= (others => '0');
			del_y1   <= (others => '0'); 
			del_y2   <= (others => '0'); 	
		elsif(clk = '1' and clk'event) then
			prodb0 := x * conv_std_logic_vector(b(INDEX)(0), COEFF_WIDTH);
			del_x1 <= x;
			prodb1 := del_x1 * conv_std_logic_vector(b(INDEX)(1), COEFF_WIDTH);
			del_x2 <= del_x1;
			prodb2 := del_x2 * conv_std_logic_vector(b(INDEX)(2), COEFF_WIDTH);			
			del_y2 <= del_y1;
			proda1 := del_y1 * conv_std_logic_vector(a(INDEX)(1), COEFF_WIDTH);
			proda2 := del_y2 * conv_std_logic_vector(a(INDEX)(2), COEFF_WIDTH);
			sum3   := (prodb2(IN_WIDTH + COEFF_WIDTH - 1) & prodb2) - (proda2(IN_WIDTH + COEFF_WIDTH - 1) & proda2);
			sum2   := sum3 - proda1;
			sum1   := (prodb1(IN_WIDTH + COEFF_WIDTH - 1) & prodb1) + sum2;
			sum0   := prodb0 + sum1;			
			del_y1 <= sum0(IN_WIDTH + COEFF_WIDTH - 2  downto COEFF_WIDTH - 1);
		end if;		
		y <= del_y1;
	end process;
end behavioural;