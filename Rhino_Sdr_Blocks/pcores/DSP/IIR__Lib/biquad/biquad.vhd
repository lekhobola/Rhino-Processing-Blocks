----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    17:04:29 11/05/2014 
-- Design Name: 
-- Module Name:    biquad - Behavioral 
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
library ieee;
use ieee.std_logic_1164.all;
use IEEE.STD_LOGIC_ARITH.all;
use IEEE.STD_LOGIC_SIGNED.all;

library RHINO_IIR_CORE_Lib;
use RHINO_IIR_CORE_Lib.iir_filter_pkg.all;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity biquad is
	generic(
		IN_WIDTH    		: natural;
	   COEFF_WIDTH       : natural;
		b						: biquad_type;
		a					   : biquad_type
	);
	port(
		clk,rst : in  std_logic;
		x 		  : in  std_logic_vector(IN_WIDTH - 1 downto 0);
		y 		  : out std_logic_vector(IN_WIDTH - 1 downto 0)
	);
end biquad;

architecture behavioural of biquad is	
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
			prodb0 := x * conv_std_logic_vector(b(0), COEFF_WIDTH);
			del_x1 <= x;
			prodb1 := del_x1 * conv_std_logic_vector(b(1), COEFF_WIDTH);
			del_x2 <= del_x1;
			prodb2 := del_x2 * conv_std_logic_vector(b(2), COEFF_WIDTH);			
			del_y2 <= del_y1;
			proda1 := del_y1 * conv_std_logic_vector(a(1), COEFF_WIDTH);
			proda2 := del_y2 * conv_std_logic_vector(a(2), COEFF_WIDTH);
			sum3   := (prodb2(IN_WIDTH + COEFF_WIDTH - 1) & prodb2) - (proda2(IN_WIDTH + COEFF_WIDTH - 1) & proda2);
			sum2   := sum3 - proda1;
			sum1   := (prodb1(IN_WIDTH + COEFF_WIDTH - 1) & prodb1) + sum2;
			sum0   := prodb0 + sum1;			
			del_y1 <= sum0(IN_WIDTH + COEFF_WIDTH - 2 downto COEFF_WIDTH);
		end if;		
	end process;
	y <= del_y1;
end behavioural;



