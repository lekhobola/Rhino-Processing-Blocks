----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    14:42:16 08/13/2014 
-- Design Name: 
-- Module Name:    decimator - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: 
--
-- Dependencies: 
--
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: 
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
USE IEEE.MATH_REAL.ALL;
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
library UNISIM;
use UNISIM.VComponents.all;

entity interpolator is
	generic(
		DIN_WIDTH	  			 : natural;
		NUMBER_OF_STAGES	 : natural;
		DIFFERENTIAL_DELAY : natural;
		SAMPLE_RATE_CHANGE : natural;
		CLKIN_PERIOD_NS	 : real
	);
	port(
	   CLK  : in  std_logic;
		RST  : in  std_logic;
		DIN  : in  std_logic_vector(DIN_WIDTH - 1 downto 0);
		RDY  : out std_logic;
		VLD  : out std_logic;
		DOUT : out std_logic_vector(DIN_WIDTH + (NUMBER_OF_STAGES * integer(ceil(log2(real(DIFFERENTIAL_DELAY * SAMPLE_RATE_CHANGE))))) - 1 downto 0)
	);
end interpolator;

architecture Behavioral of interpolator is
	COMPONENT integrator IS
		GENERIC(
			DIN_WIDTH  : natural;
			OUT_WIDTH : natural
		);
		PORT(
			clk,rst  : in std_logic;
			din  		: in std_logic_vector(DIN_WIDTH - 1 downto 0);
			dout 		: out std_logic_vector(OUT_WIDTH -1  downto 0)
		);
	END COMPONENT integrator;
	
	COMPONENT comb IS
		GENERIC(
			DIN_WIDTH	  			 : natural;
			DIFFERENTIAL_DELAY : natural		
		);
		PORT(
			clk,rst  : in  std_logic;
			din  		: in  std_logic_vector(DIN_WIDTH - 1 downto 0);
			dout 		: out std_logic_vector(DIN_WIDTH - 1 downto 0)
		);
	END COMPONENT comb;
	
	constant out_width : natural := DIN_WIDTH + (NUMBER_OF_STAGES * integer(ceil(log2(real(DIFFERENTIAL_DELAY * SAMPLE_RATE_CHANGE)))));
	
	type integ_type is array(0 to NUMBER_OF_STAGES - 1) of std_logic_vector(out_width - 1 downto 0);
	type comb_type  is array(0 to NUMBER_OF_STAGES - 1) of std_logic_vector(DIN_WIDTH  - 1 downto 0);
	
	signal integ_wire : integ_type := (others => (others => '0'));
	signal comb_wire  : comb_type  := (others => (others => '0'));	
	signal combout    : std_logic_vector(DIN_WIDTH  - 1 downto 0);
	signal count		: integer range 0 to  SAMPLE_RATE_CHANGE - 1 := 0;
	signal sys_rst,clk2,pll_locked,data_vld : std_logic := '0';
begin
	RDY <= pll_locked;
	
	RESET_PROC : process(RST,pll_locked)
	begin
		if(pll_locked = '0') then
			sys_rst <= '1';
		elsif(RST = '1') then
			sys_rst <= '1';
		else
			sys_rst <= '0';
		end if;
	end process;
	
	INTERPOLATE_PROC : process(CLK2,sys_rst)
	begin
		if(sys_rst = '1') then
		   combout <= (others => '0');
			count <= 0;			
		elsif(rising_edge(CLK2)) then	
			if(count = 0) then
				combout <= comb_wire(NUMBER_OF_STAGES - 1);
				count   <= count + 1;				
			elsif(count = SAMPLE_RATE_CHANGE - 1) then
				combout <= (others => '0');
				count   <= 0;				
			else
				combout <= (others => '0');
				count   <= count + 1;
			end if;
		end if;
	end process;	
	
	DATA_VALID_PROC : process(clk)
	begin
		if(rising_edge(clk)) then
			if(pll_locked = '1') then
				data_vld <= '1';
			end if;
		end if;
		if(falling_edge(clk)) then
			if(pll_locked = '1') then
				data_vld <= '0';
			end if;
		end if;
	end process;	
	VLD <= data_vld;
	
	CombGen : for i in 0 to NUMBER_OF_STAGES - 1 generate
	begin
		FirstComb : if i = 0 generate
		FirstComb_inst : comb 
		generic map(
			DIN_WIDTH	  			 => DIN_WIDTH,
			DIFFERENTIAL_DELAY => DIFFERENTIAL_DELAY
		)
		port map(
			clk  => CLK,
			rst  => sys_rst,
			din  => DIN,
			dout => comb_wire(0)
		);
		end generate;
		
		MiddleComb : if i > 0 generate
		MiddleComb_inst : comb 
		generic map(
			DIN_WIDTH	  			 => DIN_WIDTH,
			DIFFERENTIAL_DELAY => DIFFERENTIAL_DELAY
		)
		port map(
			clk  => CLK,
			rst  => sys_rst,
			din  => comb_wire(i - 1),
			dout => comb_wire(i)
		);
		end generate;
	end generate CombGen;		
	
	IntegratorGen : for i in 0 to NUMBER_OF_STAGES - 1 generate
	begin
		FirstIntegrator : if i = 0 generate
		FirstIntegrator_inst : integrator 
		generic map(
			DIN_WIDTH  => DIN_WIDTH,
			OUT_WIDTH => out_width
		)
		port map(
			clk  => CLK2,
			rst  => sys_rst,
			din  => combout,
			dout => integ_wire(0)
		);
		end generate;
		
		MiddleIntegrator : if i > 0 generate
		MiddleIntegrator_inst : integrator 
		generic map(
			DIN_WIDTH  => out_width,
			OUT_WIDTH => out_width
		)
		port map(
			clk  => CLK2,
			rst  => sys_rst,
			din  => integ_wire(i - 1),
			dout => integ_wire(i)
		);
		end generate;
	end generate IntegratorGen;		
	--DOUT <= combout(7)&combout(7)& combout;
	--DOUT <= comb_wire(1)(7)&comb_wire(1)(7)& comb_wire(1);
	DOUT <= integ_wire(NUMBER_OF_STAGES - 1);
	
	-- DCM_SP: Digital Clock Manager
	-- Spartan-6
	-- Xilinx HDL Libraries Guide, version 12.4
	DCM_SP_inst : DCM_SP
	generic map (
		CLKDV_DIVIDE => 2.0, -- CLKDV divide value
		-- (1.5,2,2.5,3,3.5,4,4.5,5,5.5,6,6.5,7,7.5,8,9,10,11,12,13,14,15,16).
		CLKFX_DIVIDE => 1, -- Divide value on CLKFX outputs - D - (1-32)
		CLKFX_MULTIPLY => SAMPLE_RATE_CHANGE, -- Multiply value on CLKFX outputs - M - (2-32)
		CLKIN_DIVIDE_BY_2 => FALSE, -- CLKIN divide by two (TRUE/FALSE)
		CLKIN_PERIOD => CLKIN_PERIOD_NS, -- Input clock period specified in nS
		CLKOUT_PHASE_SHIFT => "NONE", -- Output phase shift (NONE, FIXED, VARIABLE)
		CLK_FEEDBACK => "1X", -- Feedback source (NONE, 1X, 2X)
		DESKEW_ADJUST => "SYSTEM_SYNCHRONOUS", -- SYSTEM_SYNCHRNOUS or SOURCE_SYNCHRONOUS
		DFS_FREQUENCY_MODE => "LOW", -- Unsupported - Do not change value
		DLL_FREQUENCY_MODE => "LOW", -- Unsupported - Do not change value
		DSS_MODE => "NONE", -- Unsupported - Do not change value
		DUTY_CYCLE_CORRECTION => TRUE, -- Unsupported - Do not change value
		FACTORY_JF => X"c080", -- Unsupported - Do not change value
		PHASE_SHIFT => 0, -- Amount of fixed phase shift (-255 to 255)
		STARTUP_WAIT => FALSE -- Delay config DONE until DCM_SP LOCKED (TRUE/FALSE)
	)
	port map (
		CLK0 => open, -- 1-bit output 0 degree clock output
		CLK180 => open, -- 1-bit output 180 degree clock output
		CLK270 => open, -- 1-bit output 270 degree clock output
		CLK2X => open, -- 1-bit output 2X clock frequency clock output
		CLK2X180 => open, -- 1-bit output 2X clock frequency, 180 degree clock output
		CLK90 => open, -- 1-bit output 90 degree clock output
		CLKDV => open, -- 1-bit output Divided clock output
		CLKFX => CLK2, -- 1-bit output Digital Frequency Synthesizer output (DFS)
		CLKFX180 => open, -- 1-bit output 180 degree CLKFX output
		LOCKED => pll_locked, -- 1-bit output DCM_SP Lock Output
		PSDONE => open, -- 1-bit output Phase shift done output
		STATUS => open, -- 8-bit output DCM_SP status output
		CLKFB => open, -- 1-bit input Clock feedback input
		CLKIN => CLK, -- 1-bit input Clock input
		DSSEN => open, -- 1-bit input Unsupported, specify to GND.
		PSCLK => open, -- 1-bit input Phase shift clock input
		PSEN => open, -- 1-bit input Phase shift enable
		PSINCDEC => open, -- 1-bit input Phase shift increment/decrement input
		RST => '0' -- 1-bit input Active high reset input
	);
	-- End of DCM_SP_inst instantiation
end Behavioral;



