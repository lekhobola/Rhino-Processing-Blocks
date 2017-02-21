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

ENTITY ddc_tb IS
END ddc_tb;

ARCHITECTURE behavior OF ddc_tb IS 
	component ddc is
		generic(
			DIN_WIDTH 			 : natural;    --Input Data Width
			DOUT_WIDTH 			 : natural;    --Output Data Width
			-- NCO Configuration
			PHASE_WIDTH		    : natural;	   --NCO phase width    [ >= 8 ] 
			PHASE_DITHER_WIDTH : natural;    --Phase dither width [ 1 - PHASE_WIDTH ]
			-- CIC 1 configuration
			SELECT_CIC1  		  : std_logic; --Use CIC1 [ '1'-selected, '0'-not selected ]
			NUMBER_OF_STAGES1	  : natural;   --Number of CIC stages [ > 0 ]
			DIFFERENTIAL_DELAY1 : natural;   --Differential Dealy [ > 0 ]
			SAMPLE_RATE_CHANGE1 : natural;   --Decimation factor  [ > 0 ]
			-- Compensating FIR configuraton
			SELECT_CFIR		     : std_logic; --Use FIR filter [ '1'-selected, '0'-not selected ]
			NUMBER_OF_TAPS   	  : natural;  	--Number of FIR taps/coeffients [ > 0 ]									
			FIR_LATENCY         : natural;   --FIR latency [ 0=Generic tranpose order,1=Even symmetric,2=Odd symmetric,3=moving average]
			COEFF_WIDTH  	     : natural;   --Coefficient width [ >= 8 ] 
			COEFFS		        : coeff_type; --Array of quantized integer filter coeffients [array size > 0] 	
			-- CIC 2 configuration
			SELECT_CIC2  		  : std_logic; --Use CIC2 [ '1'-selected, '0'-not selected ]
			NUMBER_OF_STAGES2	  : natural;   --Number of CIC stages(N) [ > 0 ]
			DIFFERENTIAL_DELAY2 : natural;   --Differential Dealy(M)   [ > 0 ]
			SAMPLE_RATE_CHANGE2 : natural		--Decimation factor(R)    [ > 0 ]
		);
		port(
			CLK  : in  std_logic;			   --System Clock [active state : rising edge]
			RST  : in  std_logic;				--System reset [active state : high]
			EN	  : in  std_logic;
			DIN  : in  std_logic_vector(DIN_WIDTH - 1 downto 0);   --Real input data
			FTW  : in  std_logic_vector(PHASE_WIDTH - 1 downto 0); --phase increment word 		
			VLD  : out std_logic;  --Valid output data available		
			IOUT : out std_logic_vector(DOUT_WIDTH - 1 downto 0); --Real output Sample
			QOUT : out std_logic_vector(DOUT_WIDTH - 1 downto 0)	--Imaginary output Sample	
		);
	end component ddc;
	
	constant N    : integer := 8192*4;--65536;
	constant outN : integer := 8192*4/128;--8192*4/153/2;
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
	SIGNAL datain : fileTypeIn := ReadFile("pcores/DSP/DDC_Lib/tb/fpga.in");

	SIGNAL CLK,RST,VLD,EN :  std_logic;
	SIGNAL DIN  :  std_logic_vector(inW - 1 downto 0) := (others=>'0');
	SIGNAL FTW  :  std_logic_vector(31 downto 0) := (others=>'0');
	SIGNAL IOUT : std_logic_vector (outW - 1 downto 0);
	SIGNAL QOUT : std_logic_vector (outW - 1 downto 0);
   constant clk_period : time  := 8.138020833 ns;-- 12.20703125 ns;		 
 
BEGIN

	ddc_inst : ddc 
	GENERIC MAP(
		DIN_WIDTH 			 => inW,
		DOUT_WIDTH 			 => outW,
		-- NCO Configurations
		PHASE_WIDTH		    => 32,
		PHASE_DITHER_WIDTH => 22,
		-- CIC 1 configurations
		SELECT_CIC1  		  => '1',
		NUMBER_OF_STAGES1	  => 10,
		DIFFERENTIAL_DELAY1 => 1,
		SAMPLE_RATE_CHANGE1 => 128,
		-- Compensating FIR configuratons
		SELECT_CFIR		     => '1',
		NUMBER_OF_TAPS   	  => 21,												
		FIR_LATENCY         => 2, 
      COEFF_WIDTH  	     => 16,
		COEFFS		        => (-78,-132,-217,-247,-57,516,1534,2880,4261,5301,5689,5301,4261,2880,1534,516,-57,-247,-217,-132,-78),
      -- CIC 2 configurations
		SELECT_CIC2  		  => '0',
		NUMBER_OF_STAGES2	  => 1,
		DIFFERENTIAL_DELAY2 => 1,
		SAMPLE_RATE_CHANGE2 => 2
	)
	PORT MAP(
		CLK  => CLK,
		RST  => RST,
		EN	  => EN,
		DIN  => DIN,
		FTW  => FTW,
		VLD  => VLD,
		IOUT => IOUT,
		QOUT => QOUT
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
		FTW <= "00111011001000000000000000000000";
		--ftw <= x"204AAAAB";
		wait until rising_edge(clk);		
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
		file f_obj      : text open write_mode is "pcores/DSP/DDC_Lib/tb/fpga.out";
		variable f_line : line;
		variable space  : character := ' ';
	begin	
		
		--wait for clk_period*153*16;
		wait for clk_period*128*16;
		for i in 0 to outN-1 loop
			--- write data line by line from the file
			write(f_line,conv_integer(IOUT));
			write(f_line,space);
			write(f_line,conv_integer(QOUT));
			writeline(f_obj,f_line);
			wait until (rising_edge(clk) and vld ='1');
		end loop;  
		wait;
	end process;
END;
