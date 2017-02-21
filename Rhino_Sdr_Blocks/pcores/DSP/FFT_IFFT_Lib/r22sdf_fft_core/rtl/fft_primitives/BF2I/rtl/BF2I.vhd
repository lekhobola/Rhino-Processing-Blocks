----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    02:13:48 06/21/2014 
-- Design Name: 
-- Module Name:    BF2I - Behavioral 
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

entity BF2I is
	generic(
		BF2I_data_w : natural
	);
	port(
		s			    : in std_logic;
		xpr			 : in std_logic_vector  (BF2I_data_w - 1 downto 0);
		xpi			 : in std_logic_vector  (BF2I_data_w - 1 downto 0);
		xfr 			 : in std_logic_vector  (BF2I_data_w downto 0);
		xfi 			 : in std_logic_vector  (BF2I_data_w downto 0);
		znr          : out std_logic_vector (BF2I_data_w downto 0);
		zni          : out std_logic_vector (BF2I_data_w downto 0);
		zfr          : out std_logic_vector (BF2I_data_w downto 0);
		zfi          : out std_logic_vector (BF2I_data_w downto 0)
	);
end BF2I;

architecture Behavioral of BF2I is
	COMPONENT mux2to1
	GENERIC(
		mux2to1_data_w : natural
	);
	PORT(
		sel : in  std_logic;
		x1  : in  std_logic_vector (mux2to1_data_w - 1 downto 0);
		x2  : in  std_logic_vector (mux2to1_data_w - 1 downto 0);
		y	 : out std_logic_vector (mux2to1_data_w - 1 downto 0)
	);
	END COMPONENT;
	
	signal xpr_reg      : std_logic_vector (BF2I_data_w downto 0) := (others => '0');
	signal xpi_reg      : std_logic_vector (BF2I_data_w downto 0) := (others => '0');
	signal xfr_xpr_sum  : std_logic_vector (BF2I_data_w downto 0) := (others => '0');
	signal xfi_xpi_sum  : std_logic_vector (BF2I_data_w downto 0) := (others => '0');
	signal xfr_xpr_diff : std_logic_vector (BF2I_data_w downto 0) := (others => '0');
	signal xfi_xpi_diff : std_logic_vector (BF2I_data_w downto 0) := (others => '0');
begin
   
	xpr_reg <= xpr(BF2I_data_w - 1) & xpr;
	xpi_reg <= xpi(BF2I_data_w - 1) & xpi;
	xfr_xpr_sum  <= xfr + xpr;
	xfi_xpi_sum  <= xfi + xpi;
	xfr_xpr_diff <= xfr - xpr;
	xfi_xpi_diff <= xfi - xpi;
	
	mux2to1_inst0: mux2to1
	generic map(
		mux2to1_data_w => BF2I_data_w + 1
	)
	port map(
		sel => s,
		x1  => xfr,
		x2  => xfr_xpr_sum,
		y   => znr
	);
	
	mux2to1_inst1: mux2to1
	generic map(
		mux2to1_data_w => BF2I_data_w + 1
	)
	port map(
		sel => s,
		x1  => xfi,
		x2  => xfi_xpi_sum,
		y   => zni
	);
	
	mux2to1_inst2: mux2to1
	generic map(
		mux2to1_data_w => BF2I_data_w + 1
	)
	port map(
		sel => s,
		x1  => xpr_reg,
		x2  => xfr_xpr_diff,
		y   => zfr
	);
	
	mux2to1_inst3: mux2to1
	generic map(
		mux2to1_data_w => BF2I_data_w + 1
	)
	port map(
		sel => s,
		x1  => xpi_reg,
		x2  => xfi_xpi_diff,
		y   => zfi
	);
end Behavioral;

