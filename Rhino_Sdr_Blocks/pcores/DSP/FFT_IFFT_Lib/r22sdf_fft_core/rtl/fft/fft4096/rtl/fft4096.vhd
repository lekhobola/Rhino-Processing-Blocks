--********************************************************************************
--* Company:        University of Cape Town									   
--* Engineer:       Lekhobola Joachim Tsoeunyane, lekhobola@gmail.com		       
--********************************************************************************
--* Create Date:    06-July-2014 00:57:34  				 										   
--* Design Name:    Pipelined R2^2 DIF-SDF FFT								       
--* Module Name:    fft4096.vhd										   
--* Project Name:   RHINO SDR Processing Blocks								   
--* Target Devices: Xilinx - SPARTAN-6											   
--********************************************************************************
--* Dependencies: r22sdf_stage.vhd,r22sdf_odd_last_stage.vhd,counter.vhd,	
--*					fft4096_tf_rom_s1.vhd,fft4096_tf_rom_s1.vhd,
--*					fft4096_tf_rom_s2.vhd,fft4096_tf_rom_s3.vhd,
--*					fft4096_tf_rom_s4.vhd
--********************************************************************************
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.MATH_REAL.ALL;
--********************************************************************************
--* This module implements a complex 4096-point Radix 2^2 single-path delay feedback   
--* pipelined FFT core with configurable I/O bit widths. The input samples are in 
--* natural order and ouput samples are in bit reversed order.
--********************************************************************************
--* params:																	   
--*        N	   	 - Number of fft points									       
--*        fft_data_w - Input data bit width	
--*		  tf_w		 - Twiddle factor bit width									   
--* ports:																		   
--* 			[in]  clk - System clock - active on the rising edge					   
--* 			[in]  rst - Active high asynchronous reset line
--* 			[in]  Xnr - Real input sample 
--*         [in]  Xni - Imaginary input sample
--*         [out] Xkr - Real output sample
--*			[out] Xki - Imaginary output sample
--********************************************************************************
--* Notes: Twiddle factor ROMs are auto-generated using Matlab    
--********************************************************************************
entity fft4096 is
	generic(
		N 				: natural := 4096;
		fft_data_w  : natural := 16;
		tf_w  		: natural := 16
	);
	port(
	   clk,rst,en  : in std_logic;
		Xnr,Xni 		: in  std_logic_vector (fft_data_w - 1 downto 0);
		Xkr,Xki 		: out std_logic_vector(fft_data_w + integer(log2(real(N))) - 1 downto 0) 
	);
end fft4096;

architecture Behavioral of fft4096 is

	COMPONENT r22sdf_stage 
		GENERIC(
			data_w : natural;
			tf_w   : natural;
			del1_w : natural;
			del2_w : natural
		);
		PORT(
			clk,rst,en,s1,s2 : in std_logic;
			tfr,tfi	        : in std_logic_vector(tf_w - 1 downto 0);
			dinr,dini        : in std_logic_vector(data_w - 1 downto 0);
			doutr,douti      : out std_logic_vector(data_w + 1 downto 0)
		);
	END COMPONENT;
		
	COMPONENT r22sdf_even_last_stage is
		GENERIC(
			data_w: natural;
			del1_w : natural;
			del2_w : natural
		);
		PORT(
			clk,rst,en,s1,s2 : in std_logic;
			dinr,dini  		  : in std_logic_vector(data_w - 1 downto 0);
			doutr,douti   	  : out std_logic_vector(data_w + 1    downto 0)
		);
	END COMPONENT;
	
	 COMPONENT counter
		 GENERIC(
			counter_data_w : natural
		 );
		 PORT(
				clk : IN  std_logic;
				rst : IN  std_logic;
				en	 : in  std_logic;
				c   : OUT  std_logic_vector(counter_data_w - 1 downto 0)
		 );
	 END COMPONENT;
	 
	 COMPONENT fft4096_tf_rom_s0
	 	GENERIC (
			addr_w : natural;
			data_w : natural
		);
		 PORT (
			  addr  : in  std_logic_vector (addr_w - 1 downto 0);
			  doutr : out std_logic_vector (data_w - 1 downto 0);
			  douti : out  std_logic_vector(data_w - 1 downto 0)
		);
	 END COMPONENT;
	 
	 COMPONENT fft4096_tf_rom_s1
	 	GENERIC (
			addr_w : natural;
			data_w : natural
		);
		 PORT (
			  addr  : in  std_logic_vector (addr_w - 1 downto 0);
			  doutr : out std_logic_vector (data_w - 1 downto 0);
			  douti : out  std_logic_vector(data_w - 1 downto 0)
		);
	 END COMPONENT;
	 
	 COMPONENT fft4096_tf_rom_s2
	 	GENERIC (
			addr_w : natural;
			data_w : natural
		);
		 PORT (
			  addr  : in  std_logic_vector (addr_w - 1 downto 0);
			  doutr : out std_logic_vector (data_w - 1 downto 0);
			  douti : out  std_logic_vector(data_w - 1 downto 0)
		);
	 END COMPONENT;
	 
	 COMPONENT fft4096_tf_rom_s3
	 	GENERIC (
			addr_w : natural;
			data_w : natural
		);
		 PORT (
			  addr  : in  std_logic_vector (addr_w - 1 downto 0);
			  doutr : out std_logic_vector (data_w - 1 downto 0);
			  douti : out  std_logic_vector(data_w - 1 downto 0)
		);
	 END COMPONENT;
	 
	 COMPONENT fft4096_tf_rom_s4
	 	GENERIC (
			addr_w : natural;
			data_w : natural
		);
		 PORT (
			  addr  : in  std_logic_vector (addr_w - 1 downto 0);
			  doutr : out std_logic_vector (data_w - 1 downto 0);
			  douti : out  std_logic_vector(data_w - 1 downto 0)
		);
	 END COMPONENT;
	 -- Number of fft stages
	 constant stages : natural := integer(floor(log10(real(N)) / log10(real(4))));
	 -- Total number of fft butterflies - includes both BF2I and BF2II butterflies
	 constant bfs    : natural := integer(log2(real(N)));
	 
	 -- Defines a stage output type 
	 type stage_type is array (0 to stages - 1) of std_logic_vector(fft_data_w + integer(log2(real(N))) - 1  downto 0);
	 -- Defines a rom output type
	 type rom_type is array (0 to stages - 2) of std_logic_vector(tf_w - 1 downto 0);
	 
	 -- Real part of stage output array
	 signal stager : stage_type := (others =>(others => '0'));
	 -- Imaginary part of stage output array
	 signal stagei : stage_type := (others =>(others => '0'));
	 -- Real part of twiddle factor output array
	 signal romr: rom_type := (others =>(others => '0'));
	 -- Imaginary part of twiddle factor output array
	 signal romi : rom_type := (others =>(others => '0'));
	 -- The counter ouput which acts as FFT controller
	 signal c : std_logic_vector(bfs - 1 downto 0) := (others => '0');
begin
   -- Instantiate the counter (i.e. fft controller). It drives the butterflies and ROMs.
	controller_inst : counter
	GENERIC MAP(
		counter_data_w => integer(log2(real(N)))
	)
	PORT MAP(
		clk => clk,
		rst => rst,
		en	 => en,
		c   => c
	);
	-- Instantiate twiddle factor ROMs of fft
	ROM0 : fft4096_tf_rom_s0
	GENERIC MAP (
			addr_w => 12,
			data_w => 16
	)
	PORT MAP(
		  addr  => c,
		  doutr => romr(0),
		  douti => romi(0)
	);
	
	ROM1 : fft4096_tf_rom_s1
	GENERIC MAP (
			addr_w => 10,
			data_w => 16
	)
	PORT MAP(
		  addr  => c(9 downto 0),
		  doutr => romr(1),
		  douti => romi(1)
	);
	
	ROM2 : fft4096_tf_rom_s2
	GENERIC MAP (
			addr_w => 8,
			data_w => 16
	)
	PORT MAP(
		  addr  => c(7 downto 0),
		  doutr => romr(2),
		  douti => romi(2)
	);
	
	ROM3 : fft4096_tf_rom_s3
	GENERIC MAP (
			addr_w => 6,
			data_w => 16
	)
	PORT MAP(
		  addr  => c(5 downto 0),
		  doutr => romr(3),
		  douti => romi(3)
	);
	
	ROM4 : fft4096_tf_rom_s4
	GENERIC MAP (
			addr_w => 4,
			data_w => 16
	)
	PORT MAP(
		  addr  => c(3 downto 0),
		  doutr => romr(4),
		  douti => romi(4)
	);
	
	-- Instantiate FFT stages
	StageGen : for i in 0 to stages - 1 GENERATE
	begin
		-- First FFT stage
		first: if i = 0 GENERATE
		StageFirst : r22sdf_stage
			GENERIC MAP(
				data_w  => fft_data_w + (2 * i),
				tf_w    => tf_w,
				del1_w  => N / 2 ** (i * 2 + 1),
				del2_w  => N / 2 ** (i * 2 + 2)
			)
			PORT MAP(
				clk   => clk,
				rst   => rst,
				en		=> en,
				s1    => c(bfs - (2 * i) - 1),
				s2    => c(bfs - (2 * i) - 2),
				tfr   => romr(i),
				tfi	=> romi(i),
				dinr  => Xnr,
				dini  => Xni,
				doutr => stager(i)(fft_data_w + ((1 + i) * 2) - 1 downto 0),
				douti => stagei(i)(fft_data_w + ((1 + i) * 2) - 1 downto 0)
			);
		END GENERATE;
		
		-- Intermidiate FFT stages
		middle: if (i > 0 and i < stages-1) GENERATE
		StageN : r22sdf_stage
			GENERIC MAP(
				data_w  => fft_data_w + (2 * i),
				tf_w    => tf_w,
				del1_w  => N / 2 ** (i * 2 + 1),
				del2_w  => N / 2 ** (i * 2 + 2)
			)
			PORT MAP(
				clk   => clk,
				rst   => rst,
				en	   => en,
				s1    => c(bfs - (2 * i) - 1),
				s2    => c(bfs - (2 * i) - 2),
				tfr   => romr(i),
				tfi	=> romi(i),
				dinr  => stager(i - 1)(fft_data_w + ((1 + ( i - 1 )) * 2) - 1 downto 0),
				dini  => stagei(i - 1)(fft_data_w + ((1 + (i - 1)) * 2) - 1 downto 0),
				doutr => stager(i)(fft_data_w + ((1 + i) * 2) - 1 downto 0),
				douti => stagei(i)(fft_data_w + ((1 + i) * 2) - 1 downto 0)
			);
		END GENERATE;
		
		-- Last FFT stage - when the
		last: if  i = stages-1 GENERATE
		StageLast : r22sdf_even_last_stage
			GENERIC MAP(
				data_w => fft_data_w + (2 * i),
				del1_w => N / 2 ** (i * 2 + 1),
				del2_w => N / 2 ** (i * 2 + 2)
			)
			PORT MAP(
				clk   => clk,
				rst   => rst,
				en		=> en,
				s1    => c(1),
				s2    => c(0),
				dinr  => stager(i - 1)(fft_data_w + ((1 + ( i - 1 )) * 2) - 1 downto 0),
				dini  => stagei(i - 1)(fft_data_w + ((1 + ( i - 1 )) * 2) - 1 downto 0),
				doutr => Xkr,
				douti => Xki
			);
		END GENERATE;
	END  GENERATE StageGen;
end Behavioral;
