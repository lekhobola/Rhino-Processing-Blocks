-- TestBench Template 

  LIBRARY ieee;
  USE ieee.std_logic_1164.ALL;
  USE ieee.numeric_std.ALL;

  ENTITY r22sdf_stage_tb IS
  END r22sdf_stage_tb;

  ARCHITECTURE behavior OF r22sdf_stage_tb IS 

  -- Component Declaration
          COMPONENT r22sdf_stage
				generic(
					data_w : natural;
					tf_w   : natural;
					del1_w : natural;
					del2_w : natural
					);
				port(
					clk,rst,s1,s2 : in std_logic;
					tfr,tfi	     : in std_logic_vector(8 downto 0);
					dinr,dini     : in std_logic_vector(8 downto 0);
					doutr,douti   : out std_logic_vector(10 downto 0)
				);
          END COMPONENT;
			 
			COMPONENT counter
				GENERIC(
				counter_data_w : natural
				);
				PORT(
					clk : IN  std_logic;
					rst : IN  std_logic;
					c   : OUT  std_logic_vector(counter_data_w - 1 downto 0)
				);
			END COMPONENT;

         signal clk,rst: std_logic;
			signal tfr,tfi	      : std_logic_vector(8 downto 0) := (others => '0');
			signal dinr,dini     : std_logic_vector(8 downto 0) := (others => '0');
			signal doutr,douti   : std_logic_vector(10 downto 0) := (others => '0');
         signal c : std_logic_vector(2 downto 0);
			
			signal stager : std_logic_vector(10 downto 0) := (others => '0');
			signal stagei : std_logic_vector(10 downto 0) := (others => '0');
			signal rom_xr : std_logic_vector(8 downto 0) := (others => '0');
			signal rom_xi : std_logic_vector(8 downto 0) := (others => '0');
			
			 -- Clock period definitions
			 constant clk_period : time := 20 ns;
  BEGIN

  -- Component Instantiation
         uut0 : r22sdf_stage
			GENERIC MAP(
				data_w  => 9,
				tf_w    => 9,
				del1_w  => 4,
				del2_w  => 2
			)
			PORT MAP(
				clk   => clk,
				rst   => rst,
				s1    => c(2),
				s2    => c(1),
				tfr   => rom_xr,
				tfi	=> rom_xi,
				dinr  => dinr,
				dini  => dinr,
				doutr => doutr,
				douti => stagei
			);
			
			controller_inst : counter
			GENERIC MAP(
				counter_data_w => 3
			)
			PORT MAP(
				clk => clk,
				rst => rst,
				c   => c
			);

	  -- Clock process definitions
		clk_process :process
		begin
			clk <= '0';
			wait for clk_period/2;
			clk <= '1';
			wait for clk_period/2;
		end process;
	
     tb : PROCESS
     BEGIN
      dinr <= "000000000";
		dini <= "000000000";		
		rst <= '1';	
      wait for clk_period*4;	
		wait until rising_edge(clk);
		dinr <= "000000001";
		dini <= "000000001";
		rst <= '0';
		wait for clk_period;
		dinr <= "000000010";
		dini <= "000000010";
		wait for clk_period;
		dinr <= "000000011";
		dini <= "000000011";
		wait for clk_period;
		dinr <= "000000100";
		dini <= "000000100";
		wait for clk_period;
		dinr <= "000000101";
		dini <= "000000101";
		wait for clk_period;
		dinr <= "000000110";
		dini <= "000000110";
		wait for clk_period;
		dinr <= "000000111";
		dini <= "000000111";
		wait for clk_period;
		dinr <= "000001000";
		dini <= "000001000";
		
		wait for clk_period;		
		dinr <= "000000000";
		dini <= "000000000";        
		wait; -- will wait forever
     END PROCESS tb;
  --  End Test Bench 

  END;
