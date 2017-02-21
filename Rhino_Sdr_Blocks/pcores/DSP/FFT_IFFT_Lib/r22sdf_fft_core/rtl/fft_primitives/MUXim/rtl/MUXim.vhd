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

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity MUXim is
	generic(
		MUXim_data_w : integer
	);
	port(
		cc : in std_logic;
		xr : in std_logic_vector(MUXim_data_w - 1 downto 0);
		xi : in std_logic_vector(MUXim_data_w - 1 downto 0);
		zr : out std_logic_vector(MUXim_data_w - 1 downto 0);
		zi : out std_logic_vector(MUXim_data_w - 1 downto 0)
	);
end MUXim;

architecture Behavioral of MUXim is	
	COMPONENT mux2to1
	GENERIC(
		mux2to1_data_w : integer 
	);
	PORT(
		sel : in  std_logic;
		x1  : in  std_logic_vector (mux2to1_data_w - 1 downto 0);
		x2  : in  std_logic_vector (mux2to1_data_w - 1 downto 0);
		y	 : out std_logic_vector (mux2to1_data_w - 1 downto 0)
	);
	END COMPONENT;
begin
	mux2to1_inst1: mux2to1
	generic map(
		mux2to1_data_w => MUXim_data_w
	)
	port map(
		sel => cc,
		x1  => xr,
		x2  => xi,
		y   => zr
	);
	
	mux2to1_inst2: mux2to1
	generic map(
		mux2to1_data_w => MUXim_data_w
	)
	port map(
		sel => cc,
		x1  => xi,
		x2  => xr,
		y   => zi
	);
end Behavioral;

