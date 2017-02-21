----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    02:13:48 06/21/2014 
-- Design Name: 
-- Module Name:    BF2II - Behavioral 
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

entity BF2II is
	generic(
		BF2II_data_w : natural := 9
	);
	port(
		s			    : in std_logic;
		t			    : in std_logic;
		xpr			 : in std_logic_vector (BF2II_data_w - 1 downto 0);
		xpi			 : in std_logic_vector (BF2II_data_w - 1 downto 0);
		xfr 			 : in std_logic_vector (BF2II_data_w downto 0);
		xfi 			 : in std_logic_vector (BF2II_data_w downto 0);
		znr          : out std_logic_vector (BF2II_data_w downto 0);
		zni          : out std_logic_vector (BF2II_data_w downto 0);
		zfr          : out std_logic_vector (BF2II_data_w downto 0);
		zfi          : out std_logic_vector (BF2II_data_w downto 0)
	);
end BF2II;

architecture Behavioral of BF2II is
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
	
	COMPONENT MUXim
	GENERIC(
		MUXim_data_w : natural
	);
	PORT(
			cc : in std_logic;
			xr : in std_logic_vector(MUXim_data_w - 1 downto 0);
			xi : in std_logic_vector(MUXim_data_w - 1 downto 0);
			zr : out std_logic_vector(MUXim_data_w - 1 downto 0);
			zi : out std_logic_vector(MUXim_data_w - 1 downto 0)
		);
	END COMPONENT;
			 
	COMPONENT MUXsg
	GENERIC(
		MUXsg_data_w : natural
	);
	PORT(
			cc : IN std_logic;
			a1 : IN std_logic_vector(MUXsg_data_w - 1 downto 0);       
			a2 : IN std_logic_vector(MUXsg_data_w - 1 downto 0);
			b1 : OUT std_logic_vector(MUXsg_data_w - 1 downto 0);       
			b2 : OUT std_logic_vector(MUXsg_data_w - 1 downto 0)
		);
	END COMPONENT;
	
	signal cc			  : std_logic;
	signal xfr_xpr_sum  : std_logic_vector (BF2II_data_w downto 0) := (others => '0');
	signal xfr_xpr_diff : std_logic_vector (BF2II_data_w downto 0) := (others => '0');
	signal xpr_MUXim	  : std_logic_vector (BF2II_data_w - 1 downto 0) := (others => '0');
	signal xpi_MUXim 	  : std_logic_vector (BF2II_data_w - 1 downto 0) := (others => '0');
	signal xfi_MUXsg	  : std_logic_vector (BF2II_data_w downto 0) := (others => '0');
	signal xpi_MUXsg 	  : std_logic_vector (BF2II_data_w downto 0) := (others => '0');
	
	
	signal xpr_MUXim_reg : std_logic_vector (BF2II_data_w downto 0) := (others => '0');
	signal xpi_MUXim_reg : std_logic_vector (BF2II_data_w downto 0) := (others => '0');
begin

   cc <= s and (not t);	
	
	xfr_xpr_sum  <= xfr + xpr_MUXim;
	xfr_xpr_diff <= xfr - xpr_MUXim;
	
	xpr_MUXim_reg <= xpr_MUXim(BF2II_data_w - 1) & xpr_MUXim;
	xpi_MUXim_reg <= xpi_MUXim(BF2II_data_w - 1) & xpi_MUXim;
	
	MUXim_inst: MUXim 
	generic map(
		MUXim_data_w => BF2II_data_w
	)
	port map(
		cc => cc,
		xr => xpr,
		xi => xpi,
		zr => xpr_MUXim,
		zi => xpi_MUXim
	);	
	
	MUXsg_inst: MUXsg 
	generic map(
		MUXsg_data_w => BF2II_data_w + 1
	)
	port map(
		cc => cc,
		a1 => xfi,
		a2 => xpi_MUXim_reg,
		b1 => xfi_MUXsg,
		b2 => xpi_MUXsg
	);
	
	mux2to1_inst0: mux2to1
	generic map(
		mux2to1_data_w => BF2II_data_w + 1
	)
	port map(
		sel => s,
		x1  => xfr,
		x2  => xfr_xpr_sum,
		y   => znr
	);
	
	mux2to1_inst1: mux2to1
	generic map(
		mux2to1_data_w => BF2II_data_w + 1
	)
	port map(
		sel => s,
		x1  => xfi,
		x2  => xfi_MUXsg,
		y   => zni
	);
	
	mux2to1_inst2: mux2to1
	generic map(
		mux2to1_data_w => BF2II_data_w + 1
	)
	port map(
		sel => s,
		x1  => xpr_MUXim_reg,
		x2  => xfr_xpr_diff,
		y   => zfr
	);
	
	mux2to1_inst3: mux2to1
	generic map(
		mux2to1_data_w => BF2II_data_w + 1
	)
	port map(
		sel => s,
		x1  => xpi_MUXim_reg,
		x2  => xpi_MUXsg,
		y   => zfi
	);
end Behavioral;

