library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity shift_reg is
	generic(
			IN_WIDTH   : natural := 9;
			ADDR_WIDTH : natural := 2
	);
	port(
			clk,rst,we : in  std_logic;			
			addr	  	  : in  std_logic_vector(ADDR_WIDTH - 1 downto 0);
		   din     	  : in  std_logic_vector(IN_WIDTH - 1 downto 0);
			dout       : out std_logic_vector(IN_WIDTH - 1 downto 0)
	);
end shift_reg;
	
architecture Behavioral of shift_reg is
	type reg_type is array (0 to 2 ** ADDR_WIDTH - 1) of std_logic_vector(IN_WIDTH - 1 downto 0);	
	signal regs : reg_type := ((others=> (others=>'0')));
begin		
	process(clk,rst)
	begin
		if(rst = '1') then
			regs <= ((others=> (others=>'0')));
		elsif(rising_edge(clk)) then
			if(we = '1') then
				regs(0) <= din;
				if(ADDR_WIDTH > 0) then
					for i in (2 ** ADDR_WIDTH) - 2 downto 0 loop
						regs(i + 1) <= regs(i);
					end loop;
				end if;
			end if;			
		end if;
	end process;
	dout <=  regs(conv_integer(addr));
end Behavioral;

