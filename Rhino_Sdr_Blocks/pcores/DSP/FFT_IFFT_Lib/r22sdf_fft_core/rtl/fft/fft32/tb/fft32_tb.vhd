--********************************************************************************
--* Company:        University of Cape Town									   
--* Engineer:       Lekhobola Joachim Tsoeunyane, lekhobola@gmail.com		       
--********************************************************************************
--* Create Date:    02-July-2014 13:55:14  				 										   
--* Design Name:    Pipelined R2^2 DIF-SDF FFT								       
--* Module Name:    fft32_tb.vhd										   
--* Project Name:   RHINO SDR Processing Blocks								   
--* Target Devices: Xilinx - SPARTAN-6											   
--********************************************************************************
--* Dependencies: fft32.vhd
--********************************************************************************
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;
USE IEEE.MATH_REAL.ALL;
USE STD.TEXTIO.all;
USE IEEE.STD_LOGIC_TEXTIO.ALL;
--********************************************************************************
--* This is a testbench for the complex 32-point Radix 2^2 single-path delay 
--* feedback pipelined FFT core. 
--********************************************************************************
--* params:	none
--*									   
--* ports:  none																		   
--* 			
--********************************************************************************
--* Notes: none    
--********************************************************************************
ENTITY fft32_tb IS
END fft32_tb;

ARCHITECTURE behavior OF fft32_tb IS
	-- Component Declaration
	COMPONENT fft32
		PORT(
			clk,rst : std_logic;
			Xnr,Xni : in  std_logic_vector (7 downto 0);
			Xkr,Xki : out std_logic_vector(12 downto 0) 
		);
	END COMPONENT;

	-- constants definition
	
	-- Clock period definitions
	constant clk_period : time := 20 ns;
	-- FFT length
	constant N : integer := 32;
	-- Input bit width
	constant inW : integer := 8;
	-- Output bitwidth = inW + integer(log2(real(N))
	constant outW : integer := 13;
	
	-- types definition
	
	-- Input complex number type
	type in_complex is array(0 to 1) of std_logic_vector(inW - 1 downto 0);
	type fileTypeIn is array(0 to N - 1) of in_complex;
	-- Output complex number type
	type out_complex is array(0 to 1) of std_logic_vector(outW - 1 downto 0);
	type fileTypeOut is array(0 to N - 1) of out_complex;

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
				read(f_line,f_data(i)(0)); read(f_line,space); read(f_line,f_data(i)(1));
				i := i+1;
			end loop;
		return f_data;
	end function;			

   -- Reverses the bits of the integer value passed
	function bitReversedIndex(index : in integer) return integer is
		constant size : integer := integer(log2(real(N)));
		variable oldIndex : std_logic_vector(size - 1 downto 0) := std_logic_vector(to_unsigned(index, size));
		variable newIndex : std_logic_vector(size - 1 downto 0) := (others => '0');
		begin
			for i in 0 to size-1 loop
				newIndex(i) := oldIndex(size - i - 1);
			end loop;
		return to_integer(unsigned(newIndex));
	end function;

	SIGNAL clk,rst,flag :  std_logic := '0';
	SIGNAL xnr      : std_logic_vector (inW - 1 downto 0) := (others => '0');
	SIGNAL xni      : std_logic_vector (inW - 1 downto 0) := (others => '0');
	SIGNAL xkr      : std_logic_vector(inW + integer(log2(real(N))) - 1 downto 0) := (others => '0'); -- real fft output = w + log2(N)
	SIGNAL xki      : std_logic_vector(inW + integer(log2(real(N))) - 1 downto 0) := (others => '0');

	-- Stores input data samples
	SIGNAL datain : fileTypeIn := ReadFile("ipcore_dir/RHINO_FFT_CORE_Lib/fft/fft32/data/FFTDataIn.dat");
	-- Stores output data samples
	SIGNAL dataout : fileTypeOut;
	
BEGIN

	-- Component Instantiation
	fft32_inst : fft32
	PORT MAP(
		clk => clk,
		rst => rst,
		xnr => xnr,
		xni => xni,
		xkr => xkr,
		xki => xki
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
		file f_obj      : text open write_mode is "ipcore_dir/RHINO_FFT_CORE_Lib/fft/fft32/data/fpgaFFT.dat";
		variable f_line : line;
		variable space  : character := ' ';
	begin	
		-- Makes sure the inputs and system components are initially reset
		xnr <= "00000000";
		xni <= "00000000";		
		rst <= '1';	
		-- Wait for clock to settle
		wait for clk_period*4;	
		-- Feed input samples to a simulator / testbench
		for i in 0 to N - 1 loop
			wait until rising_edge(clk);
			xnr <= datain(i)(0);
			xni <= datain(i)(1);			
			rst <= '0';
			-- Set flag to indicate the first result sample is available 
			-- "read_result" process can now start
			if(i = N-1) then
				flag<='1';
			end if;
		end loop;  
		
		-- Reset input after feeding data to a simulator
		wait for clk_period;		
		xnr <= "00000000";
		xni <= "00000000"; 
		
		-- Wait for FFT operation to complete for duration of clk_perion*N
		wait for clk_period*(N);	
		-- "read_result" process stops
		flag<='0';
		
		-- Write all output samples to a file
		for i in 0 to N - 1 loop
			--- write data line by line from the file
			write(f_line,to_integer(signed(dataout(bitReversedIndex(i))(0))));
			write(f_line,space);
			write(f_line,to_integer(signed(dataout(bitReversedIndex(i))(1))));
			writeline(f_obj,f_line);
			wait for clk_period;
		end loop;  
		wait;
	end process;

	-- Read the fft ouput samples when flag is raised
	read_result: process(clk)
		variable count : integer range 0 to N-1 := 0;
	begin	
		if(rising_edge(clk)) then
			if(flag = '1') then
				dataout(count)(0) <= xkr;
				dataout(count)(1) <= xki;
				count := count + 1;
			end if;
		end if;
	end process;
END;
