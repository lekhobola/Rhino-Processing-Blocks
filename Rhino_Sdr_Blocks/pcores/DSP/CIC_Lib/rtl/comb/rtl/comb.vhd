----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    13:44:45 08/13/2014 
-- Design Name: 
-- Module Name:    comb - Behavioral 
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

entity comb is
	generic(
		DIN_WIDTH	  			 : natural;
		DIFFERENTIAL_DELAY : natural		
	);
	port(
		clk		: in  std_logic;
		rst  		: in  std_logic;
		en		   : in  std_logic;
		din 	   : in  std_logic_vector(DIN_WIDTH - 1 downto 0);
		dout 		: out std_logic_vector(DIN_WIDTH - 1 downto 0)
	);
end comb;

architecture Behavioral of comb is
   type del_type is array(0 to DIFFERENTIAL_DELAY - 1) of std_logic_vector(DIN_WIDTH - 1 downto 0);
	signal delay : del_type := (others => (others => '0'));
	signal dout_temp : std_logic_vector(DIN_WIDTH - 1 downto 0) := (others => '0');
begin
	process(clk,rst)
	begin
		if(rst = '1') then
			delay <= (others => (others => '0'));
		elsif(rising_edge(clk)) then
			if(en = '1') then
				delay(0) <= din;
				if(DIFFERENTIAL_DELAY > 1) then
					for i in DIFFERENTIAL_DELAY - 2 downto 0 loop
						delay(i+1) <= delay(i);
					end loop;
				end if;			
				dout_temp <= din - delay(DIFFERENTIAL_DELAY - 1);
			end if;
		end if;		
	end process;
   dout <= dout_temp;	
end Behavioral;

