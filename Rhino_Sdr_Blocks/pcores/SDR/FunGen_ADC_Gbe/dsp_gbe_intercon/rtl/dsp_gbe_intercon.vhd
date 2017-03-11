----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    15:13:16 06/27/2015 
-- Design Name: 
-- Module Name:    adc_eth_bridge - Behavioral 
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
use IEEE.STD_LOGIC_ARITH.ALL;
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity dsp_gbe_intercon is
	generic(
		MEM_DATA_BYTES : natural;		
		MEM_DEPTH 		: natural
	);
	port(
		rst	  		 : in  std_logic;
		clk	  		 : in  std_logic;
		en      		 : in  std_logic;
		rd_en    	 : in  std_logic;
		vld	   	 : out std_logic;
		new_pkt_rcvd : out std_logic;
		din          : in  std_logic_vector(8 * MEM_DATA_BYTES - 1 downto 0);
		dout    		 : out std_logic_vector(8 * MEM_DATA_BYTES * MEM_DEPTH - 1 downto  0);
		-- debug signal
		count        : out std_logic_vector(6 downto 0)
	);
end dsp_gbe_intercon;

architecture Behavioral of dsp_gbe_intercon is
	constant DIN_WIDTH : natural := 8 * MEM_DATA_BYTES;
	constant DOUT_WIDTH : natural := DIN_WIDTH * MEM_DEPTH;
	type ram_type is array(0 to MEM_DEPTH-1) of std_logic_vector(DIN_WIDTH - 1 downto 0);
	signal ram    : ram_type := (others => (others => '0'));
	signal dout_r1 : std_logic_vector(DOUT_WIDTH - 1 downto  0);
	signal dout_r2: std_logic_vector(DOUT_WIDTH - 1 downto  0);
	signal cnt    : integer := 0;
	signal dbl_buf_sel : std_logic := '0';
	signal started : std_logic := '0';
begin

	process(clk,rst)
	begin
		if(rst = '1') then 
			dout_r1 <= (others => '0');
			dout_r2 <= (others => '0');
			dbl_buf_sel <= '0';
			cnt <= 0;
			vld <= '0';
			started <= '0';
			new_pkt_rcvd <= '0';
			ram  <= (others => (others => '0'));
		elsif(rising_edge(clk)) then
			if(en = '1') then
				ram(cnt) <= din;
				
				if(cnt = MEM_DEPTH - 1) then								
					cnt <= 0;
					started <= '1';
				else
				   if(rd_en = '1') then
						vld <= '0';
					end if;
					new_pkt_rcvd <= '0';
					cnt <= cnt + 1;
				end if;
				
				if(cnt = 0 and started = '1') then
					dbl_buf_sel <= not dbl_buf_sel;
					vld <= '1';
				   new_pkt_rcvd <= '1';		
					for i in 0 to MEM_DEPTH - 1 loop
						if(dbl_buf_sel = '0') then
							dout_r1(DOUT_WIDTH - (i * DIN_WIDTH) - 1 downto DOUT_WIDTH - (i * DIN_WIDTH) - DIN_WIDTH) <= ram(i);
						else
							dout_r2(DOUT_WIDTH - (i * DIN_WIDTH) - 1 downto DOUT_WIDTH - (i * DIN_WIDTH) - DIN_WIDTH) <= ram(i);
						end if;
					end loop;
				end if;
			end if;
		end if;
	end process;
	
	count <= conv_std_logic_vector(cnt,7);
	
	dout <= dout_r1 when dbl_buf_sel = '1' else
	        dout_r2;
end Behavioral;

