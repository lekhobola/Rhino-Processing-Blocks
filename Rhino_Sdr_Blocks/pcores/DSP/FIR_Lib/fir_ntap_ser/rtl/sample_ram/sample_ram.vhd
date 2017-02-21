----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    15:48:52 07/14/2014 
-- Design Name: 
-- Module Name:    sample_ram - Behavioral 
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

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity sample_ram is
	generic(
		IN_WIDTH  		: natural := 9;
		RAM_ADDR_WIDTH : natural := 2
	);
	port(
		clk,rst,en,we : in  std_logic;
		din			  : in  std_logic_vector(IN_WIDTH - 1 downto 0);
		dout			  : out std_logic_vector(IN_WIDTH - 1 downto 0)
	);
end sample_ram;

architecture Behavioral of sample_ram is
	
	COMPONENT counter 
		GENERIC(
			ADDR_WIDTH : natural
		);
		PORT(
			clk,rst,en : in  std_logic;
			dout		  : out std_logic_vector(ADDR_WIDTH - 1 downto 0)
		);
   END COMPONENT;
	
	COMPONENT shift_reg 
		GENERIC(
				IN_WIDTH   : natural;
				ADDR_WIDTH : natural
		);
		PORT(
				clk,rst,we : in  std_logic;			
				addr	  	  : in  std_logic_vector(ADDR_WIDTH - 1 downto 0);
				din     	  : in  std_logic_vector(IN_WIDTH - 1 downto 0);
				dout       : out std_logic_vector(IN_WIDTH - 1 downto 0)
		);
	END COMPONENT;	
	signal addr :  std_logic_vector(RAM_ADDR_WIDTH - 1 downto 0) := (others => '0');
begin

	counter_inst : counter 
	GENERIC MAP(
		ADDR_WIDTH => RAM_ADDR_WIDTH
	)
	PORT MAP(
		clk  => clk,
		rst  => rst,
		en   => en,
		dout => addr
	);
	
	shift_reg_inst : shift_reg 
	GENERIC MAP(
			IN_WIDTH   => IN_WIDTH,
			ADDR_WIDTH => RAM_ADDR_WIDTH
	)
	PORT MAP(
			clk  => clk,
			rst  => rst,
			we   => we,
			addr => addr,
			din  => din,
			dout => dout
	);
end Behavioral;

