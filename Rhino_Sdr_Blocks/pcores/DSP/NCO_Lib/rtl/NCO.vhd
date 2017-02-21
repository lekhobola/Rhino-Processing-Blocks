----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    15:47:30 06/05/2014 
-- Design Name: 
-- Module Name:    nco - Behavioral 
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
use IEEE.STD_LOGIC_SIGNED.all;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity NCO is
	generic(
		FTW_WIDTH   : natural;
		PHASE_WIDTH : natural;
		PHASE_DITHER_WIDTH : natural
	);
	port(
		CLK  : in  std_logic;
		RST  : in  std_logic;
		FTW  : in  std_logic_vector(FTW_WIDTH - 1 downto 0);
		IOUT : out std_logic_vector(15 downto 0);
		QOUT : out std_logic_vector(15 downto 0)
	);
end NCO;

architecture Behavioral of NCO is
	-- Component Declaration for the Unit Under Test (UUT)
 
	component phase_acc
	generic(		
		FTW_WIDTH   : natural;
		PHASE_WIDTH : natural		
	);
	port(
		clk   : in  std_logic;
		rst	: in  std_logic;
		ftw   : in  std_logic_vector(FTW_WIDTH - 1 downto 0);
		phase : out std_logic_vector(PHASE_WIDTH - 1 downto 0)
	);
	end component;
	 
	component wav_gen
	port(
			clk,rst : in std_logic;
			phase	  : in std_logic_vector (9 downto 0);
			iout    : out std_logic_vector(15 downto 0);
			qout    : out std_logic_vector(15 downto 0)
	);
	end component;
	 
	component lfsr is
   generic (
		width : integer 
	);
	port (clk : in std_logic;
			set_seed : in std_logic; 
			seed : in std_logic_vector(width-1 downto 0);
			rand_out : out std_logic_vector(width-1 downto 0)  		
		 );
	end component;
	 
	constant AMPL_WIDTH   		  : natural := 10;

	--Outputs phase acc
	signal phase 	       : std_logic_vector(PHASE_WIDTH - 1 downto 0) := (others => '0');
	signal phase_trun 	 : std_logic_vector(AMPL_WIDTH - 1 downto 0) := (others => '0'); 
	signal dithered_phase : std_logic_vector(PHASE_WIDTH - 1 downto 0) := (others => '0'); 
	signal phase_dither   : std_logic_vector(PHASE_DITHER_WIDTH - 1 downto 0);
	signal ampl_i		    : std_logic_vector(15 downto 0);
	signal ampl_q		    : std_logic_vector(15 downto 0);
begin

	dithered_phase  <= phase_dither + phase;
	phase_trun <= dithered_phase(PHASE_WIDTH-1 downto PHASE_WIDTH-AMPL_WIDTH);
	
	PHASE_ACCUMULATOR : phase_acc
	GENERIC MAP(		
		FTW_WIDTH   => FTW_WIDTH,
		PHASE_WIDTH => PHASE_WIDTH
	)
	PORT MAP(
		clk   => CLK,
		rst	=> RST,
		ftw   => FTW,
		phase => phase
	);
	
	phase_lfsr : lfsr 
   generic map(
		width =>  PHASE_DITHER_WIDTH
	)
	port map (
		clk   => clk,
		set_seed => rst,
		seed 		=> (0 => '1',others => '0'),
		rand_out => phase_dither 		
	);
	 
	WAVE_GENERATOR : wav_gen
	PORT MAP(
			clk   => CLK,
			rst   => RST,
			phase => phase_trun,
			iout  => IOUT,
			qout  => QOUT
	);
	
end Behavioral;
