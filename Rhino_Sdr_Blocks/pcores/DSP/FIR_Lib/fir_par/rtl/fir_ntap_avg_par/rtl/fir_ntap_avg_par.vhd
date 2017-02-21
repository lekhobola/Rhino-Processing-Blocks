library ieee;
use IEEE.std_logic_1164.all;
use IEEE.STD_LOGIC_ARITH.all;
use IEEE.STD_LOGIC_SIGNED.all;

entity fir_ntap_avg_par is
	generic(
		DIN_WIDTH	   : natural;
		DOUT_WIDTH     : natural;
		COEFF_WIDTH    : natural;
		NUMBER_OF_TAPS	: natural
	);
	port(
		clk  : in  std_logic;
		rst  : in  std_logic;									  
		en   : in  std_logic;
		vld  : out std_logic;
		din   : in  std_logic_vector(DIN_WIDTH  - 1 downto 0);
		dout  : out std_logic_vector(DOUT_WIDTH - 1 downto 0)	  -- output data
	);
end fir_ntap_avg_par;  

architecture behavioral of fir_ntap_avg_par is

   constant MULTIPLIER_WIDTH : natural := DIN_WIDTH + COEFF_WIDTH;
	constant coeff            : natural := (2 ** (COEFF_WIDTH-1))/NUMBER_OF_TAPS;
	
	type delay_type is array (0 to NUMBER_OF_TAPS - 1) of std_logic_vector(DIN_WIDTH - 1 downto 0);
	signal delays : delay_type := ((others=> (others=>'0')));
	signal cnt    : integer range 0 to NUMBER_OF_TAPS - 1 := 0;
begin

	process(clk,rst) 
		variable adder : std_logic_vector(DOUT_WIDTH - 1 downto 0) := (others => '0');
		variable mult  : std_logic_vector(MULTIPLIER_WIDTH - 1 downto 0)  := (others => '0');
	begin
		if(rst = '1') then
			for i in 0 to NUMBER_OF_TAPS - 1 loop
				delays(i) <= (others => '0');
			end loop;
		elsif(rising_edge(clk)) then
		   if(en = '1') then
				delays(0) <= din;
				for i in 1 to NUMBER_OF_TAPS - 1 loop
					delays(i) <=  delays(i - 1);
				end loop;
				
				adder := (DOUT_WIDTH - 1 downto DOUT_WIDTH - DIN_WIDTH => din(DIN_WIDTH - 1)) & din;
				for i in 0 to NUMBER_OF_TAPS - 1 loop
					adder := adder + delays(i);
				end loop;
				mult := adder * conv_std_logic_vector(coeff, COEFF_WIDTH);
			end if;
		end if;
	   dout <= mult(MULTIPLIER_WIDTH - 2 downto MULTIPLIER_WIDTH - DOUT_WIDTH - 1);
	end process;
end behavioral;