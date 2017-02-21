----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    00:52:50 06/21/2014 
-- Design Name: 
-- Module Name:    MUXim - Behavioral 
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
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_SIGNED.ALL;
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity MUXsg is
	generic(
		MUXsg_data_w : integer
	);
	port(
		cc : in std_logic;
		a1 : in std_logic_vector(MUXsg_data_w - 1 downto 0);
		a2 : in std_logic_vector(MUXsg_data_w - 1  downto 0);
		b1 : out std_logic_vector(MUXsg_data_w - 1 downto 0);
		b2 : out std_logic_vector(MUXsg_data_w - 1 downto 0)
	);
end MUXsg;

architecture Behavioral of MUXsg is	
	COMPONENT MUXim
	GENERIC(
		MUXim_data_w : integer
	);
	PORT(
			cc : in std_logic;
			xr : in std_logic_vector(MUXim_data_w - 1 downto 0);
			xi : in std_logic_vector(MUXim_data_w - 1 downto 0);
			zr : out std_logic_vector(MUXim_data_w - 1 downto 0);
			zi : out std_logic_vector(MUXim_data_w - 1 downto 0)
		);
	END COMPONENT;
	
	signal sum  : std_logic_vector(MUXsg_data_w - 1 downto 0) := (others => '0');
	signal diff : std_logic_vector(MUXsg_data_w - 1 downto 0) := (others => '0');
begin
	sum  <= a1 + a2;
	diff <= a1 - a2;
	
	MUXim_inst: MUXim
	generic map(
		MUXim_data_w => MUXsg_data_w
	)
	port map(
		cc => cc,
		xr  => sum,
		xi  => diff,
		zr  => b1,
		zi  => b2
	);
end Behavioral;

