-- TestBench Template 

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE IEEE.STD_LOGIC_SIGNED.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.MATH_REAL.ALL;
USE STD.TEXTIO.all;
USE IEEE.STD_LOGIC_TEXTIO.ALL;

Library IIR_Lib;
Use IIR_Lib.iir_pkg.all;

ENTITY orderN_iir_tb IS
END orderN_iir_tb;

ARCHITECTURE behavior OF orderN_iir_tb IS 

	COMPONENT orderN_iir is
	generic(
		DIN_WIDTH   : natural := 8;
		DOUT_WIDTH  : natural := 8;
		COEFF_WIDTH : natural := 8;
		b				: sos_type(0 to 5);
		a				: sos_type(0 to 5);
		STAGES		: natural := 3
	);
	port(
		clk,rst : in  std_logic;
		din 		  : in  std_logic_vector(DIN_WIDTH - 1 downto 0);
		dout 		  : out std_logic_vector(DOUT_WIDTH - 1 downto 0)
	);
	end COMPONENT orderN_iir;

	SIGNAL clk,rst,flag :  std_logic := '0';
	SIGNAL din,dout :  std_logic_vector(15 downto 0) := (others => '0');
	signal counter : integer :=0;
	constant clk_period : time := 10 ns; 
	
	-- Data Samples Count
	constant Ndata  : integer   := 1024;
	-- Input bit width
	constant inW    : integer   := 16;
	-- Input bit width
	constant coeffW : integer   := 16;
	-- Output bitwidth 
	constant outW   : integer   := 16;
	
-- Input complex number type
	type fileTypeIn is array(0 to Ndata - 1) of integer;
	-- Output complex number type
	type fileTypeOut is array(0 to Ndata - 1) of std_logic_vector(outW - 1 downto 0);

	function ReadFile (f_name : in string) return fileTypeIn is
		-- open a file in read mode
		file f_obj      : text open read_mode is f_name;
		variable space  : character;
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
	signal datain : fileTypeIn := ReadFile("pcores/DSP/FIR_Lib/fir_par/tb/fpga.in");
	-- Stores output data samples  
	signal dataout : fileTypeOut;
	
BEGIN
orderN_iir_inst : orderN_iir 
generic map(
	DIN_WIDTH   => 16,
	DOUT_WIDTH  => 16,
	COEFF_WIDTH => 16,
	b => ((105,209,105),(116,-232,116),(102,204,102),(188,375,187),(157,-314,157),(418,-834,417)),
	a => ((32768,-12141,32592),(32768,-12356,32596),(32768,-12570,32635),(32768,-11939,32637),(32768,-11845,32722),(32768,-12699,32723)),
	STAGES		=> 6
)
port map(
	clk => clk,
	rst => rst,
	din 	 => din,
	dout 	 => dout
);

	 -- Clock process definitions
   clk_process :process		
   begin
		clk <= '0';
		wait for clk_period/2;
		clk <= '1';
		wait for clk_period/2;
   end process;
	
-- Stimulus process
   stim_proc: process
		-- open a file in read mode
		file f_obj      : text open write_mode is "pcores/DSP/FIR_Lib/fir_par/tb/fpga.out";
		variable f_line : line;
		variable space  : character := ' ';
   begin		
		din <= (others => '0');
		rst <= '1';
      -- hold reset state for 100 ns.
      wait for 100 ns;	
      --wait for clk_period*10;
		
      -- insert stimulus here 
		--en  <= '1';		
		wait until falling_edge(clk);
		rst <= '0';		
		--loadc <= '0';		
		wait until falling_edge(clk);
		for i in 0 to Ndata - 1 loop
			din <= conv_std_logic_vector(datain(i),inW);	
			if(counter = 8) then
				flag <= '1';
			else
				counter <= counter + 1;	
			end if;
			wait until falling_edge(clk);	
		end loop; 
		
		-- Wait for FFT operation to complete for duration of clk_perion*N
		wait for clk_period*(Ndata);	
		-- "read_result" process stops
		flag<='0';
		
		-- Write all output samples to a file
		for i in 0 to Ndata - 1 loop
			--- write data line by line from the file
			write(f_line,conv_integer(signed(dataout(i))));
			writeline(f_obj,f_line);
			wait for clk_period;
		end loop;  
		wait;
	end process;

	-- Read the fft ouput samples when flag is raised
	read_result: process(clk)
		variable count : integer range 0 to Ndata-1 := 0;
	begin	
		if(rising_edge(clk)) then
			if(flag='1' and count < Ndata) then
				dataout(count) <= dout;
				count := count + 1;
			end if;
		end if;
	end process;
end;