-- TestBench Template 

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
USE IEEE.MATH_REAL.ALL;

ENTITY CIC_tb IS
END CIC_tb;

ARCHITECTURE behavior OF CIC_tb IS 

	COMPONENT CIC is
		GENERIC(
			DIN_WIDTH	  			 : natural;
			NUMBER_OF_STAGES	 : natural;
			DIFFERENTIAL_DELAY : natural;
			SAMPLE_RATE_CHANGE : natural;
			FILTER_TYPE        : std_logic;
			CLKIN_PERIOD_NS    : real			
		);
		PORT(
			CLK  : in  std_logic;
			RST  : in  std_logic;
			EN   : in  std_logic;
			DIN  : in  std_logic_vector(DIN_WIDTH - 1 downto 0);
			VLD  : out std_logic;
			DOUT : out std_logic_vector(DIN_WIDTH + (NUMBER_OF_STAGES * integer(log2(real(DIFFERENTIAL_DELAY * SAMPLE_RATE_CHANGE)))) - 1 downto 0) -- out_width : N*log2(RM)+DIN_WIDTH
		);
	END COMPONENT CIC;

	SIGNAL CLK,RST,EN,VLD:  std_logic;
	SIGNAL DIN :    std_logic_vector(7 downto 0) := (others => '0');
	SIGNAL DOUT : std_logic_vector(9 downto 0);
   constant clk_period : time := 10 ns;
BEGIN

  CIC_INST : CIC 
	GENERIC MAP(
		DIN_WIDTH	  		 => 8,
		NUMBER_OF_STAGES	 => 1,
		DIFFERENTIAL_DELAY => 2,
		SAMPLE_RATE_CHANGE => 2,
		FILTER_TYPE        => '0',
		CLKIN_PERIOD_NS    => 10.0 	
	)
	PORT MAP(
		CLK  => CLK,
		RST  => RST,
		EN   => EN,
		DIN  => DIN,
		VLD  => VLD,
		DOUT => DOUT
	);

   clk_process :process		
	begin
		clk <= '0';
		wait for clk_period/2;
		clk <= '1';
		wait for clk_period/2;
	end process;
	
--  Test Bench Statements
  tb : PROCESS
  BEGIN
     RST <= '1';
	  EN  <= '0';
	  wait for 100 ns; -- wait until global set/reset completes

	  -- Add user defined stimulus here
		-- Add user defined stimulus here
	  RST <= '0';
	  EN  <= '1';
	  wait for clk_period;
	  din <= "00001010";
	  wait for clk_period;
	  EN  <= '0';
	  wait for clk_period*4;
	  EN  <= '1';
	  din <= "00010100";     
	  wait for clk_period;
	  EN  <= '0';
	  wait for clk_period*4;
	  EN  <= '1';
	  din <= "00011110";
	  wait for clk_period;
	   EN  <= '0';
	  wait for clk_period*4;
	  EN  <= '1';
	  din <= "00101000";
	  wait for clk_period;
	   EN  <= '0';
	  wait for clk_period*4;
	  EN  <= '1';
	  din <= "00110010";
	  wait for clk_period;
	   EN  <= '0';
	  wait for clk_period*4;
	  EN  <= '1';
	  din <= "00101000";
	  wait for clk_period;
	   EN  <= '0';
	  wait for clk_period*4;
	  EN  <= '1';
	  din <= "00011110";
	  wait for clk_period;
	   EN  <= '0';
	  wait for clk_period*4;
	  din <= "00010100";
	  wait for clk_period;
	   EN  <= '0';
	  wait for clk_period*4;
	  EN  <= '1';
	  din <= "00001010";
	  wait for clk_period;
	   EN  <= '0';
	  wait for clk_period*4;
	  EN  <= '1';
	  din <= "00000000";
	  wait; -- will wait forever
	  wait; -- will wait forever
  END PROCESS tb;
--  End Test Bench 

END;
