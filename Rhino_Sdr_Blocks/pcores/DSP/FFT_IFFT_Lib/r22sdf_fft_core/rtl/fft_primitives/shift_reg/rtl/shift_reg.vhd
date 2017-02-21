library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_SIGNED.ALL;

entity shift_reg is
	generic(
			shift_reg_data_w : natural;
			depth  : natural
	);
	port(
			clk,rst,en : in  std_logic;			
		   xr      	  : in  std_logic_vector(shift_reg_data_w - 1 downto 0);
			xi         : in  std_logic_vector(shift_reg_data_w - 1 downto 0);
			zr         : out std_logic_vector(shift_reg_data_w - 1 downto 0);
			zi         : out std_logic_vector(shift_reg_data_w - 1 downto 0)
	);
end shift_reg;
	
architecture Behavioral of shift_reg is
	type reg_type is array (0 to depth - 1) of std_logic_vector(shift_reg_data_w - 1 downto 0);	
	signal reg_r : reg_type := ((others=> (others=>'0')));
	signal reg_i : reg_type := ((others=> (others=>'0')));
begin		
	process(clk,rst)		
	begin
		if(rst = '1') then
			reg_r <= ((others=> (others=>'0')));
			reg_i <= ((others=> (others=>'0')));
		elsif(rising_edge(clk)) then		
			if(en = '1') then
				reg_r(0) <= xr;
				reg_i(0) <= xi;
				if(depth > 1) then
					for i in depth - 2 downto 0 loop
						reg_r(i + 1) <= reg_r(i);
						reg_i(i + 1) <= reg_i(i);
					end loop;	
				end if;
			end if;
		end if;
	end process;
	
	zr <= reg_r(depth - 1);
	zi <= reg_i(depth - 1);
end Behavioral;

