----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    22:53:51 07/14/2014 
-- Design Name: 
-- Module Name:    FSM - Behavioral 
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

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity FSM is
	port(
	   CLK,RST,SAMPLE_RDY,COEFF_CNT_ZERO 					     : in  std_logic;
		EN_SAMPLE_CNT,EN_COEFF_CNT,WE_RAM,CLR_ACC,EN_MAC_REG : out std_logic
	);
end FSM;

architecture Behavioral of FSM is
	--Enumerated type for a state machine
	type state_type is (s0,s1,s2);
	--registers to hold present and next states
	signal prs : state_type;
	signal nxt : state_type := s0; 	
begin
	---------------- present state section -----------------
	--this assigns the next state to present state at active clock edge
	present_state : process(CLK,RST)
	begin
		if(RST = '1') then			
			prs <= s0;
		elsif(rising_edge(CLK)) then
			prs <= nxt;
		end if;
	end process;
	
	---------------- output section -----------------
	--generates the output of the system based on the input and present state
		
	---------------- next state section -----------------
	--this establishes the next state logic of the system based on the input 
	--and present state
   next_state : process(prs,SAMPLE_RDY,COEFF_CNT_ZERO)		
	begin
		case prs is
			when s0 =>
				if(SAMPLE_RDY = '1') then
					WE_RAM <= '1';
					EN_MAC_REG <= '1';
					EN_SAMPLE_CNT <= '0';
					EN_COEFF_CNT <= '0';
					CLR_ACC <= '0';
					nxt <= s1;
				end if;
			when s1 =>
				if(SAMPLE_RDY = '0') then
					EN_SAMPLE_CNT <= '1';
					EN_COEFF_CNT <= '1';
					WE_RAM <= '0';
					EN_MAC_REG <= '0';
					CLR_ACC <= '1';
					nxt <= s2;		
				end if;
			when others =>	-- case s2
			   CLR_ACC <= '0';
				if(COEFF_CNT_ZERO = '1') then
					EN_MAC_REG <= '1';
					EN_SAMPLE_CNT <= '0';
					EN_COEFF_CNT <= '0';
					WE_RAM  <= '0';
					nxt <= s0;
				end if;
		end case;
	end process;
end Behavioral;

