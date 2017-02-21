--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   12:27:09 06/12/2014
-- Design Name:   
-- Module Name:   /home/lekhobola/projects/rhino/rn_fir/gen_fir/gen_fir_tb.vhd
-- Project Name:  rn_fir
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: gen_fir
-- 
-- Dependencies:
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
--
-- Notes: 
-- This testbench has been automatically generated using types std_logic and
-- std_logic_vector for the ports of the unit under test.  Xilinx recommends
-- that these types always be used for the top-level I/O of a design in order
-- to guarantee that the testbench will bind correctly to the post-implementation 
-- simulation model.
--------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE IEEE.STD_LOGIC_SIGNED.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.MATH_REAL.ALL;
USE STD.TEXTIO.all;
USE IEEE.STD_LOGIC_TEXTIO.ALL;

Library FIR_Lib;
Use FIR_Lib.fircomponents.all;
Use FIR_Lib.fir_pkg.all;
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--USE ieee.numeric_std.ALL;
 
ENTITY fir_par_tb IS
END fir_par_tb;
 
ARCHITECTURE behavior OF fir_par_tb IS
   -- Clock period definitions
   constant clk_period : time  := 10 ns;
	-- Data Samples Count
	constant Ndata  : integer   := 1024;
	-- Input bit width
	constant inW    : integer   := 16;
	-- Input bit width
	constant coeffW : integer   := 16;
	-- Output bitwidth 
	constant outW   : integer   := 32;
	
	--Inputs
   signal clk : std_logic := '0';
   signal rst,en,vld,flag : std_logic := '0';
	signal loadc : std_logic;
	signal coeff : std_logic_vector(coeffW - 1 downto 0);
   signal din : std_logic_vector(inW - 1 downto 0) := (others => '0');
	--Outputs
   signal dout : std_logic_vector(outW - 1 downto 0);
	
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
 
	-- Instantiate the Unit Under Test (UUT)
   uut: fir_par 
		GENERIC MAP(
			DIN_WIDTH  		=> inW,  							-- input width of data and coefficients  	
			DOUT_WIDTH     => outW,
			COEFF_WIDTH 	=> coeffW,
			NUMBER_OF_TAPS => 95,  							-- filter length
			LATENCY	      => 0,  
			COEFFS		   => (-1,1,2,-1,-4,0,7,3,-9,-9,9,17,-5,-25,-4,32,18,-34,-38,28,59,-10,-76,-19,83,56,-76,-96,49,130,-5,-148,-53,144,114,-113,-168,58,202,16,-207,-95,180,166,-122,-215,43,233,43,-215,-122,166,180,-95,-207,16,202,58,-168,-113,114,144,-53,-148,-5,130,49,-96,-76,56,83,-19,-76,-10,59,28,-38,-34,18,32,-4,-25,-5,17,9,-9,-9,3,7,0,-4,-1,2,1,-1)
	   )
		PORT MAP (
          clk   => clk,
          rst   => rst,								  
			 en    => en,
			 loadc => loadc,
			 vld   => vld,
			 coeff => coeff,
          din   => din,
          dout  => dout
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
		en  <= '1';		
		wait until falling_edge(clk);
		rst <= '0';		
		loadc <= '0';		
		wait until falling_edge(clk);
		for i in 0 to Ndata - 1 loop
			din <= conv_std_logic_vector(datain(i),inW);				
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
			if(vld = '1' and count < Ndata) then
				dataout(count) <= dout;
				count := count + 1;
			end if;
		end if;
	end process;
END;
