----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    00:08:04 07/15/2014 
-- Design Name: 
-- Module Name:    serial_fir - Behavioral 
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

--use work.fir_filter_pkg.all;
Library RHINO_FIR_CORE_Lib;
Use RHINO_FIR_CORE_Lib.fir_pkg.all;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity fir_ntap_ser is
	generic(
		IN_WIDTH        	: natural;
		COEFFICIENT_WIDTH : natural;
		NUMBER_OF_TAPS    : natural;
		COEFFS		      : coeff_type
	);
	port(
	   clk 		  : in std_logic;
		rst 		  : in std_logic;									  
		en  		  : in std_logic;
		vld 		  : out std_logic;
		sample_rdy : in  std_logic;
		x		     : in  std_logic_vector(IN_WIDTH  - 1 downto 0);
		y		     : out std_logic_vector(IN_WIDTH downto 0)
	);
end fir_ntap_ser;

architecture Behavioral of fir_ntap_ser is

	COMPONENT FSM 
		PORT(
			CLK,RST,SAMPLE_RDY,COEFF_CNT_ZERO 					     : in  std_logic;
			EN_SAMPLE_CNT,EN_COEFF_CNT,WE_RAM,CLR_ACC,EN_MAC_REG : out std_logic
		);
	END COMPONENT;

	COMPONENT coeff_rom
		GENERIC(
			ROM_COEFF_WIDTH : natural;
			ROM_ADDR_WIDTH  : natural;
			COEFFS			 : coeff_type(0 to NUMBER_OF_TAPS - 1)
		);
		PORT(
			clk,rst,en : in  std_logic;
			cnt_zero   : out std_logic;
			dout		  : out std_logic_vector(ROM_COEFF_WIDTH - 1 downto 0)
		);
	END COMPONENT;
	
	COMPONENT sample_ram 
		GENERIC(
			IN_WIDTH  		: natural;
			RAM_ADDR_WIDTH : natural
		);
		PORT(
			clk,rst,en,we : in  std_logic;
			din			  : in  std_logic_vector(IN_WIDTH - 1 downto 0);
			dout			  : out std_logic_vector(IN_WIDTH - 1 downto 0)
		);
	END COMPONENT;
	
	COMPONENT MAC 
		GENERIC(
			SAMPLE_WIDTH : natural;
			COEFF_WIDTH  : natural
		);
		PORT(
			clk,rst,clr,en : in  std_logic;
			coeff				: in  std_logic_vector(COEFF_WIDTH - 1 downto 0);
			x   				: in  std_logic_vector(SAMPLE_WIDTH - 1 downto 0);
			y					: out std_logic_vector(SAMPLE_WIDTH downto 0)
		);
	END COMPONENT;
	
	type state_type is (Idle,Proc);
	
	signal state  : state_type := Idle;
	signal EN_SAMPLE_CNT_WIRE,EN_COEFF_CNT_WIRE,WE_RAM_WIRE : std_logic := '0';
	signal EN_MAC_REG_WIRE : std_logic := '0';
	signal cnt_zero_wire						: std_logic := '0';
	signal sample_ram_out					: std_logic_vector(IN_WIDTH    - 1 downto 0);
	signal coeff_rom_out                : std_logic_vector(COEFFICIENT_WIDTH - 1 downto 0);
	signal sysclk : std_logic := '0';
	signal cnt    : integer range 0 to NUMBER_OF_TAPS - 1 := 0;
begin
	
	sysclk <= clk when (en = '1') else
		      '0';
				
	process(sysclk,rst)
	begin
		if(rst = '1') then			
		elsif(rising_edge(sysclk)) then
			case state is
				when Idle =>
				   vld <= '0';
					if(cnt < NUMBER_OF_TAPS) then
						cnt <= cnt + 1;
						state <= Idle;
					else
						cnt <= 0;
						state <= Proc;
					end if;
				when Proc =>
					vld <= '1';						
			end case;
		end if;
	end process;
	
	FSM_isnt : FSM 
	PORT MAP(
		CLK            => sysclk,
		RST            => rst,
		SAMPLE_RDY     => sample_rdy,
		COEFF_CNT_ZERO => cnt_zero_wire,
		EN_SAMPLE_CNT  => EN_SAMPLE_CNT_WIRE,
		EN_COEFF_CNT	=> EN_COEFF_CNT_WIRE,
		WE_RAM         => WE_RAM_WIRE,
		EN_MAC_REG     => EN_MAC_REG_WIRE
	);
	
	coeff_rom_inst : coeff_rom
	GENERIC MAP(
		ROM_COEFF_WIDTH  => COEFFICIENT_WIDTH,
		ROM_ADDR_WIDTH   => natural(integer(log2(real(NUMBER_OF_TAPS)))),
		COEFFS			  => COEFFS	  
	)
	PORT MAP(
		clk 		=> sysclk,
		rst 		=> rst,
		en  		=> EN_COEFF_CNT_WIRE,
		cnt_zero => cnt_zero_wire,
		dout		=> coeff_rom_out
	);
	
	sample_ram_inst : sample_ram 
	GENERIC MAP(
		IN_WIDTH  		=> IN_WIDTH,
		RAM_ADDR_WIDTH => natural(integer(log2(real(NUMBER_OF_TAPS))))
	)
	PORT MAP(
		clk  => sysclk,
		rst  => rst,
		en   => EN_SAMPLE_CNT_WIRE,
		we   => WE_RAM_WIRE,
		din  => x,
		dout =>	sample_ram_out
	);
	
	MAC_inst : MAC 
		GENERIC MAP(
			SAMPLE_WIDTH => IN_WIDTH,
			COEFF_WIDTH  => COEFFICIENT_WIDTH
		)
		PORT MAP(
			clk   => sysclk,
			rst   => rst,
			clr   => WE_RAM_WIRE,
			en    => EN_MAC_REG_WIRE,
			coeff => coeff_rom_out,
			x   	=> sample_ram_out,
			y		=> y
		);
end Behavioral;

