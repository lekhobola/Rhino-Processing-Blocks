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
use IEEE.STD_LOGIC_UNSIGNED.all;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

ENTITY NCO_testbench IS
END NCO_testbench;

architecture Behavioral of NCO_testbench is
	-- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT phase_acc
		GENERIC(		
			FTW_WIDTH   : natural;
			PHASE_WIDTH : natural
		);
		PORT(
			clk   : in  std_logic;
			rst	: in  std_logic;
			ftw   : in  std_logic_vector(FTW_WIDTH - 1 downto 0);
			phase : out std_logic_vector(PHASE_WIDTH - 1 downto 0)
		);
    END COMPONENT;
	 
	COMPONENT wav_gen   
		PORT(
				clk,rst : in std_logic;
				phase	  : in std_logic_vector (9 downto 0);
				iout    : out std_logic_vector(15 downto 0);
				qout    : out std_logic_vector(15 downto 0)
		);
    END COMPONENT;
	 
	 component lfsr is
   generic (width : integer := 8);
	port (clk : in std_logic;
			set_seed : in std_logic; 
			seed : in std_logic_vector(width-1 downto 0);
			rand_out : out std_logic_vector(width-1 downto 0)  		
		 );
	end component;
	 
	 constant PHASE_DITHER_WIDTH : natural := 20;
	  constant PHASE_WIDTH : natural := 30;
	  	  constant FTW_WIDTH : natural := 30;
	 constant AMPL_WIDTH   : natural := 10;
	 
	 --Outputs phase acc
	 signal clk,rst	   : std_logic := '0';
	 signal iout,qout : std_logic_vector(15 downto 0);
	 signal ftw 	: std_logic_vector(FTW_WIDTH - 1 downto 0) := (others => '0');
	 signal phase 	: std_logic_vector(PHASE_WIDTH - 1 downto 0) := (others => '0');
    signal phase_trun 	: std_logic_vector(AMPL_WIDTH - 1 downto 0) := (others => '0'); 
	 signal dithered_phase 	: std_logic_vector(PHASE_WIDTH - 1 downto 0) := (others => '0'); 
	 signal phase_dither : std_logic_vector(PHASE_DITHER_WIDTH - 1 downto 0);
	 
	 constant clk_period : time := 8.138020833 ns;
begin

	dithered_phase  <= phase_dither + phase;
	phase_trun <= dithered_phase(PHASE_WIDTH-1 downto PHASE_WIDTH-AMPL_WIDTH);
	--phase_trun <= dithered_phase(AMPL_WIDTH-1 downto 0);
	
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
	
	
	lfsr_inst : lfsr 
   generic map(
		width =>  PHASE_DITHER_WIDTH
	)
	port map (clk   => clk,
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
	
	clk_process :process		
	begin
		CLK <= '0';
		wait for clk_period/2;
		CLK <= '1';
		wait for clk_period/2;
	end process;
	
	 tb : PROCESS
			-- open a file in read mode
		--file f_obj      : text open write_mode is "pcores/RHINO_SDR_BLOCKS_Lib/FMADPLL/tb/nco.out";
		--variable f_line : line;
  BEGIN
	  RST <= '1';
	  wait for clk_period;
	  RST <= '0';
	  FTW <= "001110110010000010111000000000";
	  
	  wait; -- will wait forever
	
  END PROCESS tb;
end Behavioral;
