--********************************************************************************
--* Company:        University of Cape Town									   
--* Engineer:       Lekhobola Joachim Tsoeunyane, lekhobola@gmail.com		       
--********************************************************************************
--* Create Date:    06-July-2014 11:19:56  				 										   
--* Design Name:    Pipelined R2^2 DIF-SDF FFT								       
--* Module Name:    rhino_r22sdf_fft_core.vhd										   
--* Project Name:   RHINO SDR Processing Blocks								   
--* Target Devices: Xilinx - SPARTAN-6											   
--********************************************************************************
--* Dependencies: fft8.vhd,fft16.vhd,fft32.vhd,fft64.vhd,fft128.vhd,fft256.vhd
--*					fft512.vhd,fft1024.vhdfft2048.vhd,fft4096.vhd
--********************************************************************************
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.MATH_REAL.ALL;
--********************************************************************************
--* This module implements a complex N-point Radix 2^2 single-path delay feedback   
--* pipelined FFT core with configurable Input bit widths where N is powers of 2. 
--* i.e. 8, 16, 32, 64, 128, 256, 512, 1024, 2048, 4096. The input samples are 
--* in  natural order and ouput samples are in bit reversed order.
--********************************************************************************
--* params:																	   
--*        N	   	 - Number of fft points, valid options are 8, 16, 32, 64, 
--*							128, 256, 512, 1024, 2048, 4096								       
--*        DIN_W      - Input data bit width, default option is 8
--*		  TFT_W		 - Twiddle factor bit width, default option is 16									   
--* ports:																		   
--* 			[in]  CLK - System clock - active on the rising edge					   
--* 			[in]  RST - Active high asynchronous reset line
--* 			[in]  XSr - Real-part input sample 
--*         [in]  XSi - Imaginary-part input sample
--*         [out] XKr - Real-part output sample
--*			[out] XKi - Imaginary-part output sample
--********************************************************************************
--* Notes: Only powers of 2 are valid for number of points option "N"    
--********************************************************************************
ENTITY r22sdf_fft_core IS
	GENERIC(
		N		 : NATURAL := 8;
		DIN_W  : NATURAL := 9;
		TF_W   : NATURAL := 16
	);
	PORT(
		CLK	  : IN  STD_LOGIC;
		RST 	  : IN  STD_LOGIC;
		EN 	  : IN  STD_LOGIC;
		XSr,XSi : IN  STD_LOGIC_VECTOR(DIN_W - 1 downto 0);
		VLD	  : OUT STD_LOGIC;
		DONE	  : OUT STD_LOGIC;
		XKr,XKi : OUT STD_LOGIC_VECTOR(DIN_W + INTEGER(LOG2(real(N))) - 1 downto 0)
	);
END r22sdf_fft_core;

architecture Behavioral of r22sdf_fft_core is	
	COMPONENT fft8
		generic(
			N 				: natural;
			fft_data_w  : natural;
			tf_w  		: natural
		);
		port(
			clk,rst,en  : std_logic;
			Xnr,Xni 		: in  std_logic_vector (fft_data_w - 1 downto 0);
			Xkr,Xki 	   : out std_logic_vector(fft_data_w + integer(log2(real(N))) - 1 downto 0) 
		);
	END COMPONENT;
	
	COMPONENT fft16
		generic(
			N 				: natural;
			fft_data_w  : natural;
			tf_w  		: natural
		);
		port(
			clk,rst,en  : std_logic;
			Xnr,Xni 		: in  std_logic_vector (fft_data_w - 1 downto 0);
			Xkr,Xki	   : out std_logic_vector(fft_data_w + integer(log2(real(N))) - 1 downto 0) 
		);
	END COMPONENT;
	
	COMPONENT fft32
		generic(
			N 				: natural;
			fft_data_w  : natural;
			tf_w  		: natural
		);
		port(
			clk,rst,en  : std_logic;
			Xnr,Xni : in  std_logic_vector (fft_data_w - 1 downto 0);
			Xkr,Xki : out std_logic_vector(fft_data_w + integer(log2(real(N))) - 1 downto 0) 
		);
	END COMPONENT;
	
	COMPONENT fft64
		generic(
			N 				: natural;
			fft_data_w  : natural;
			tf_w  		: natural
		);
		port(
			clk,rst,en  : std_logic;
			Xnr,Xni : in  std_logic_vector (fft_data_w - 1 downto 0);
			Xkr,Xki : out std_logic_vector(fft_data_w + integer(log2(real(N))) - 1 downto 0) 
		);
	END COMPONENT;
	
	COMPONENT fft128
		generic(
			N 				: natural;
			fft_data_w  : natural;
			tf_w  		: natural
		);
		port(
			clk,rst,en  : std_logic;
			Xnr,Xni : in  std_logic_vector (fft_data_w - 1 downto 0);
			Xkr,Xki : out std_logic_vector(fft_data_w + integer(log2(real(N))) - 1 downto 0) 
		);
	END COMPONENT;
	
	COMPONENT fft256
		generic(
			N 				: natural;
			fft_data_w  : natural;
			tf_w  		: natural
		);
		port(
			clk,rst,en  : std_logic;
			Xnr,Xni : in  std_logic_vector (fft_data_w - 1 downto 0);
			Xkr,Xki : out std_logic_vector(fft_data_w + integer(log2(real(N))) - 1 downto 0) 
		);
	END COMPONENT;
	
	COMPONENT fft512
		generic(
			N 				: natural;
			fft_data_w  : natural;
			tf_w  		: natural
		);
		port(
			clk,rst,en : std_logic;
			Xnr,Xni 	  : in  std_logic_vector (fft_data_w - 1 downto 0);
			Xkr,Xki    : out std_logic_vector(fft_data_w + integer(log2(real(N))) - 1 downto 0) 
		);
	END COMPONENT;
	
	COMPONENT fft1024
		generic(
			N 				: natural;
			fft_data_w  : natural;
			tf_w  		: natural
		);
		port(
			clk,rst,en  : std_logic;
			Xnr,Xni : in  std_logic_vector (fft_data_w - 1 downto 0);
			Xkr,Xki : out std_logic_vector(fft_data_w + integer(log2(real(N))) - 1 downto 0) 
		);
	END COMPONENT;
	
	COMPONENT fft2048
		generic(
			N 				: natural;
			fft_data_w  : natural;
			tf_w  		: natural
		);
		port(
			clk,rst,en  : std_logic;
			Xnr,Xni : in  std_logic_vector (fft_data_w - 1 downto 0);
			Xkr,Xki : out std_logic_vector(fft_data_w + integer(log2(real(N))) - 1 downto 0) 
		);
	END COMPONENT;
	
	COMPONENT fft4096
		generic(
			N 				: natural;
			fft_data_w  : natural;
			tf_w  		: natural
		);
		port(
			clk,rst,en  : std_logic;
			Xnr,Xni : in  std_logic_vector (fft_data_w - 1 downto 0);
			Xkr,Xki : out std_logic_vector(fft_data_w + integer(log2(real(N))) - 1 downto 0) 
		);
	END COMPONENT;
	
	type state_type is (IDLE,START,PROC);
	signal state   : state_type := IDLE;
	signal count   : integer range 0 to 2 * N - 2 := 0;
BEGIN
   				 
					  
	process(clk,rst) 
	begin
		if(rst = '1') then
			state <= IDLE;
			count <= 0;
			DONE  <= '0';
		elsif(rising_edge(clk)) then
			vld <= '0';
			if(en = '1') then
				case state is
					when IDLE =>					
						DONE <= '0';
						count <= 0;
						state <= START;
					when START =>
						count <= count + 1;
						if(count < N - 3) then
							state <= START;							
						else							
							vld <= '1';
							state <= PROC;
						end if;
					when PROC =>
						if(count < 2*N - 3) then
							state <= PROC;
							count <= count + 1;
							vld <= '1';				
						else							
							DONE  <= '1';
							vld <= '0';
							state <= PROC;
						end if;
				end case;
			end if;
		end if;
	end process;
	
	-- FFT-8 instantiation
	gen_fft8 : if N = 8 GENERATE
	fft8_inst : fft8
	generic map(
			N 				=> 8,
			fft_data_w  => DIN_W,
			tf_w  		=> TF_W
		)
		port map(
			clk => clk,
			rst => rst,
			en  => en,
			Xnr => XSr,
			Xni => XSi,
			Xkr => XKr,
			Xki => XKi
	);
	END GENERATE;
	
	-- FFT-16 instantiation
	gen_fft16 : if N = 16 GENERATE
	fft16_inst : fft16
	generic map(
			N 				=> 16,
			fft_data_w  => DIN_W,
			tf_w  		=> TF_W
		)
		port map(
			clk => clk,
			rst => rst,
			en  => en,
			Xnr => XSr,
			Xni => XSi,
			Xkr => XKr,
			Xki => XKi
	);
	END GENERATE;
	
	-- FFT-32 instantiation
	gen_fft32 : if N = 32 GENERATE
	fft32_inst : fft32
	generic map(
			N 				=> 32,
			fft_data_w  => DIN_W,
			tf_w  		=> TF_W
		)
		port map(
			clk => clk,
			rst => rst,
			en  => en,
			Xnr => XSr,
			Xni => XSi,
			Xkr => XKr,
			Xki => XKi
	);
	END GENERATE;
	
	-- FFT-64 instantiation
	gen_fft64 : if N = 64 GENERATE
	fft64_inst : fft64
	generic map(
			N 				=> 64,
			fft_data_w  => DIN_W,
			tf_w  		=> TF_W
		)
		port map(
			clk => clk,
			rst => rst,
			en  => en,
			Xnr => XSr,
			Xni => XSi,
			Xkr => XKr,
			Xki => XKi
	);
	END GENERATE;
	
	-- FFT-128 instantiation
	gen_fft128 : if N = 128 GENERATE
	fft128_inst : fft128
	generic map(
			N 				=> 128,
			fft_data_w  => DIN_W,
			tf_w  		=> TF_W
		)
		port map(
			clk => clk,
			rst => rst,
			en  => en,
			Xnr => XSr,
			Xni => XSi,
			Xkr => XKr,
			Xki => XKi
	);
	END GENERATE;
	
	-- FFT-256 instantiation
	gen_fft256 : if N = 256 GENERATE
	fft256_inst : fft256
	generic map(
			N 				=> 256,
			fft_data_w  => DIN_W,
			tf_w  		=> TF_W
		)
		port map(
			clk => clk,
			rst => rst,
			en  => en,
			Xnr => XSr,
			Xni => XSi,
			Xkr => XKr,
			Xki => XKi
	);
	END GENERATE;
	
	-- FFT-512 instantiation
	gen_fft512 : if N = 512 GENERATE
	fft512_inst : fft512
	generic map(
			N 				=> 512,
			fft_data_w  => DIN_W,
			tf_w  		=> TF_W
		)
		port map(
			clk => clk,
			rst => rst,
			en  => en,
			Xnr => XSr,
			Xni => XSi,
			Xkr => XKr,
			Xki => XKi
	);
	END GENERATE;
	
	-- FFT-1024 instantiation
	gen_fft1024 : if N = 1024 GENERATE
	fft1024_inst : fft1024
	generic map(
			N 				=> 1024,
			fft_data_w  => DIN_W,
			tf_w  		=> TF_W
		)
		port map(
			clk => clk,
			rst => rst,
			en  => en,
			Xnr => XSr,
			Xni => XSi,
			Xkr => XKr,
			Xki => XKi
	);
	END GENERATE;
	
	-- FFT-2048 instantiation
	gen_fft2048 : if N = 2048 GENERATE
	fft2048_inst : fft2048
	generic map(
			N 				=> 2048,
			fft_data_w  => DIN_W,
			tf_w  		=> TF_W
		)
		port map(
			clk => clk,
			rst => rst,
			en  => en,
			Xnr => XSr,
			Xni => XSi,
			Xkr => XKr,
			Xki => XKi
	);
	END GENERATE;
	
	-- FFT-4096 instantiation
	gen_fft4096 : if N = 4096 GENERATE
	fft4096_inst : fft4096
	generic map(
			N 				=> 4096,
			fft_data_w  => DIN_W,
			tf_w  		=> TF_W
		)
		port map(
			clk => clk,
			rst => rst,
			en  => en,
			Xnr => XSr,
			Xni => XSi,
			Xkr => XKr,
			Xki => XKi
	);
	END GENERATE;
END Behavioral;
