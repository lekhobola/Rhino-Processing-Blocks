-- TestBench Template 
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.all;
USE IEEE.STD_LOGIC_SIGNED.all;
USE IEEE.MATH_REAL.ALL;
USE STD.TEXTIO.all;
USE IEEE.STD_LOGIC_TEXTIO.ALL;

Library FIR_Lib;
Use FIR_Lib.fir_pkg.all;

ENTITY downsampler_tb IS
END downsampler_tb;

ARCHITECTURE behavior OF downsampler_tb IS 
	component downsampler is
		generic(
			DIN_WIDTH 			 : natural;
			DOUT_WIDTH 			 : natural;
			-- CIC 1 configurations
			NUMBER_OF_STAGES 	  : natural;
			DIFFERENTIAL_DELAY  : natural;
			SAMPLE_RATE_CHANGE  : natural;
			-- Compensating FIR configuratons
			NUMBER_OF_TAPS   	  : natural;  													
			FIR_LATENCY         : natural;  
			COEFF_WIDTH  	     : natural;
			COEFFS		        : coeff_type
		);
		port(
			CLK  : in  std_logic;
			RST  : in  std_logic;
			EN	  : in  std_logic;
			DIN  : in  std_logic_vector(DIN_WIDTH - 1 downto 0);
			VLD  : out std_logic;
			DOUT : out std_logic_vector(DOUT_WIDTH - 1 downto 0)
		);
	end component;	
	
	constant N    : integer := 8192*4;--65536;
	constant outN : integer := 8192*4/256;--/128/2;
	constant inW  : integer := 16;
	constant outW : integer := 16;
	-- types definition
	
	-- Input complex number type
	type fileTypeIn is array(0 to N - 1) of integer;

	function ReadFile (f_name : in string) return fileTypeIn is
		-- open a file in read mode
		file f_obj      : text open read_mode is f_name;
		variable f_line : line;
		variable f_data : fileTypeIn;
		variable i		 : integer := 0;
		begin
			while not endfile(f_obj) loop
				--- read data line by line from the file
				readline(f_obj,f_line);
				read(f_line,f_data(i)); 
				i := i+1;
			end loop;
		return f_data;
	end function;		
	
		-- Stores input data samples
	SIGNAL datain : fileTypeIn := ReadFile("pcores/DSP/DDC_Lib/rtl/downsampler/tb/fpga.in");
	
	SIGNAL CLK,RST,VLD,EN :  std_logic;
	SIGNAL DIN  :  std_logic_vector(inW - 1 downto 0) := (others=>'0');
	SIGNAL DOUT : std_logic_vector (outW - 1 downto 0);
   constant clk_period : time  := 8.138020833 ns;-- 12.20703125 ns;		 
 
BEGIN

	downsampler_inst : downsampler 
	generic map(
		DIN_WIDTH 			  => inW,
		DOUT_WIDTH 			  => outW,
		-- CIC 1 configurations
		NUMBER_OF_STAGES 	  => 4,
		DIFFERENTIAL_DELAY  => 1,
		SAMPLE_RATE_CHANGE  => 32,
		-- Compensating FIR configuratons
		NUMBER_OF_TAPS   	  => 32,  													
		FIR_LATENCY         => 0,  
		COEFF_WIDTH  	     => 16,
		COEFFS		        => (-54,-63,-78,-90,-80,-29,88,288,579,957,1401,1878,2342,2746,3045,3204,3204,3045,2746,2342,1878,1401,957,579,288,88,-29,-80,-90,-78,-63,-54)
	)
	port map(
		CLK  => CLK,
		RST  => RST,
		EN	  => EN,
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
		wait for clk_period;
		wait until falling_edge(clk);		
		EN  <= '1';	  
		
		RST <= '0';
		for i in 0 to N - 1 loop
			wait until rising_edge(clk);
			din <= conv_std_logic_vector(datain(i),inW);
		end loop;  
		din <= (others => '0');
		  
	  wait; -- will wait forever 
  END PROCESS tb;

	write_results: process
		-- open a file in read mode
		file f_obj      : text open write_mode is "pcores/DSP/DDC_Lib/rtl/downsampler/tb/fpga.out";
		variable f_line : line;
		variable space  : character := ' ';
	begin	
		
		for i in 0 to outN-1 loop
			--- write data line by line from the file
			write(f_line,conv_integer(DOUT));
			writeline(f_obj,f_line);
			--wait for clk_period;
			wait until rising_edge(VLD);
		end loop;  
		wait;
	end process;
END;
