Library ieee;
Use ieee.std_logic_1164.all;
Use IEEE.STD_LOGIC_ARITH.all;
Use IEEE.STD_LOGIC_SIGNED.all;


Library FIR_Lib;
Use FIR_Lib.fir_pkg.all;

entity fir_ntap_osym_par is
	generic(
		DIN_WIDTH	   		: natural;
		DOUT_WIDTH	   		: natural;
		COEFF_WIDTH : natural;
		NUMBER_OF_TAPS	   : natural;
		COEFFS		      : coeff_type
	);
	port(
		 clk : in std_logic;
		 rst : in std_logic;									  
		 en  : in std_logic;
		 loadc: in std_logic;
		 vld : out std_logic;
		 coeff: in  std_logic_vector(COEFF_WIDTH - 1 downto 0);
		 din	  : in  std_logic_vector(DIN_WIDTH - 1 downto 0);
		 dout	  : out std_logic_vector(DOUT_WIDTH - 1 downto 0)	  -- output data
	);
end fir_ntap_osym_par;

architecture behavioral of fir_ntap_osym_par is

	type state_type is (Idle,LoadCoeff,Proc);
	
	constant MULTIPLIER_WIDTH : natural := DIN_WIDTH + COEFF_WIDTH;
	constant alpha		        : natural := (NUMBER_OF_TAPS / 2);
		
   type del_type   is array(0 to NUMBER_OF_TAPS - 2) of std_logic_vector(DIN_WIDTH - 1 downto 0);
	type adder_type1 is array(0 to alpha - 1)  of std_logic_vector(DOUT_WIDTH - 1 downto 0);
	type adder_type2 is array(0 to alpha - 1)  of std_logic_vector(MULTIPLIER_WIDTH downto 0);
	type mult_type  is array(0 to  alpha)  of std_logic_vector(MULTIPLIER_WIDTH - 1 downto 0);
	
	signal coeff_regs : coeff_type(0 to alpha - 1) := coeffs;
	signal delays : del_type   := ((others=> (others=>'0')));
	signal enProc : std_logic := '0';
	signal state  : state_type := Idle;
	signal ldcnt  : integer range 0 to alpha - 1 := 0;
	signal cnt	  : integer range 0 to alpha - 2 := 0;
begin

	process(clk,en)
	begin		
		if(en = '0') then
			cnt <= 0;
			ldcnt <= 0;
			state <= Idle;
		elsif(rising_edge(clk)) then
			if(en = '1') then 
				case state is
					when Idle =>
						if(loadc = '1') then
							enProc <= '0';
							state <= LoadCoeff;
						else
							enProc <= '1';
							state  <= Proc;
						end if;
					when LoadCoeff =>
						if(ldcnt < NUMBER_OF_TAPS) then
							coeff_regs(ldcnt) <= conv_integer(coeff);	
							ldcnt <= ldcnt + 1;
							state <= LoadCoeff;
						else					
							enProc <= '1';
							state <= Proc;
						end if;
					when Proc =>
						if(cnt < NUMBER_OF_TAPS - 2) then
							vld <= '0';
							cnt <= cnt + 1;
						else
							vld <= '1';
						end if;
						state <= Proc;
				end case;
			end if;
		end if;
	end process;
	
	process(clk,rst)
		variable adders1 		  : adder_type1 := ((others=> (others=>'0')));
		variable adders2 		  : adder_type2 := ((others=> (others=>'0')));
		variable mults   		  : mult_type   := ((others=> (others=>'0')));		
		variable max_del_index : integer := NUMBER_OF_TAPS - 2;
	begin
		if(rst = '1') then
			for i in 0 to NUMBER_OF_TAPS - 1 loop
				delays(i) <= (others => '0');
			end loop;
		elsif(rising_edge(clk)) then
			if(en = '1') then
				if(enProc = '1') then
					delays(0) <= din;
					for i in 0 to alpha - 1 loop
						delays(i + 1) <= delays(i);
						if(i < (alpha - 1)) then
							delays(max_del_index - i) <= delays(max_del_index - i - 1);
						end if;
					end loop;

					adders1(0) := din + delays(max_del_index);
					for i in 1 to alpha - 1 loop
						adders1(i) := delays(i - 1) + delays(max_del_index - i);
					end loop;

					for i in 0 to alpha - 1 loop
						mults(i) := conv_std_logic_vector(coeffs(i), COEFF_WIDTH) * adders1(i);
					end loop;
					mults(alpha) := conv_std_logic_vector(coeffs(alpha), COEFF_WIDTH) * delays(alpha - 1);

					adders2(0) := mults(0) + mults(1);
					for i in 1 to alpha - 1 loop
						adders2(i) := adders2(i - 1) + mults(i + 1);
					end loop;
				end if;
			end if;
		end if;
		dout <= adders2(alpha - 1)(MULTIPLIER_WIDTH) & adders2(alpha - 1)(MULTIPLIER_WIDTH downto MULTIPLIER_WIDTH - DOUT_WIDTH + 2);	
	end process;
end behavioral;