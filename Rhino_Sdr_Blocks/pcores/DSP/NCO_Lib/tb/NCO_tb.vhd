-- TestBench Template 

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.all;
USE IEEE.STD_LOGIC_SIGNED.all;

USE STD.TEXTIO.all;
USE IEEE.STD_LOGIC_TEXTIO.ALL;

ENTITY NCO_tb IS
END NCO_tb;

ARCHITECTURE behavior OF NCO_tb IS 

-- Component Declaration
	COMPONENT NCO is
	GENERIC(
		FTW_WIDTH   : natural;
		PHASE_WIDTH : natural
	);
	PORT(
		CLK  : in  std_logic;
		RST  : in  std_logic;
		FTW  : in  std_logic_vector(FTW_WIDTH - 1 downto 0);
		IOUT : out std_logic_vector (15 downto 0);
		QOUT : out std_logic_vector (15 downto 0)
	);
	END COMPONENT NCO;

 SIGNAL CLK,RST 		:  std_logic := '0';
 SIGNAL FTW 	      :  std_logic_vector(9 downto 0);
 SIGNAL IOUT,QOUT    :  std_logic_vector(15 downto 0);
 SIGNAL phase			: std_logic_vector(9 downto 0);
 constant clk_period : time := 10 ns;
BEGIN

-- Component Instantiation
  NCO_inst : NCO 
	generic map(
		FTW_WIDTH   => 10,
		PHASE_WIDTH => 30
	)
	port map(
		CLK  => CLK,
		RST  => RST,
		FTW  => FTW,
		IOUT => IOUT,
		QOUT => QOUT
	);
	
	clk_process :process		
	begin
		CLK <= '0';
		wait for clk_period/2;
		CLK <= '1';
		wait for clk_period/2;
	end process;

--  Test Bench Statements
  tb : PROCESS
			-- open a file in read mode
		--file f_obj      : text open write_mode is "pcores/RHINO_SDR_BLOCKS_Lib/FMADPLL/tb/nco.out";
		--variable f_line : line;
  BEGIN
	  --RST <= '1';
	 -- wait for 100 ns; -- wait until global set/reset completes
	  RST <= '1';
	  wait for clk_period;
	  RST <= '0';
	  FTW <= "0011101101";
	  -- Add user defined stimulus here
	--  wait for clk_period;
	 -- for i in 0 to 1023 loop
			--- write data line by line from the file
	--		write(f_line,conv_integer(IOUT));
		--	writeline(f_obj,f_line);
	--		wait for clk_period;
		--end loop;  
	  wait; -- will wait forever
	
  END PROCESS tb;
--  End Test Bench 

END;
