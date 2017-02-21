--
--	Package File Template
--
--	Purpose: This package defines supplemental types, subtypes, 
--		 constants, and functions 
--
--   To use any of the example code shown below, uncomment the lines and modify as necessary
--

library IEEE;
use IEEE.STD_LOGIC_1164.all;
USE IEEE.MATH_REAL.ALL;

package r22sdf_fft_ifft_pkg is	

   function bitReversedIndex(index : in integer;bitwidth : in integer) return integer;
end r22sdf_fft_ifft_pkg;

package body r22sdf_fft_pkg is

-- Define fft functions
function bitReversedIndex(index : in integer;bitwidth : in integer) return integer is
		variable oldIndex : std_logic_vector(bitwidth - 1 downto 0) := std_logic_vector(to_unsigned(index, bitwidth));
		variable newIndex : std_logic_vector(bitwidth - 1 downto 0) := (others => '0');
		begin
			for i in 0 to bitwidth-1 loop
				newIndex(i) := oldIndex(bitwidth - i - 1);
			end loop;
		return to_integer(unsigned(newIndex));
	end function;
end r22sdf_fft_pkg;
