-- TestBench Template 

  LIBRARY ieee;
  USE ieee.std_logic_1164.ALL;
  USE ieee.numeric_std.ALL;

  ENTITY integrator_tb IS
  END integrator_tb;

  ARCHITECTURE behavior OF integrator_tb IS 

  -- Component Declaration
          COMPONENT integrator IS
				GENERIC(
					DIN_WIDTH : natural;
					DOUT_WIDTH : natural
				);
				PORT(
					clk,rst  : in std_logic;
					din  		: in std_logic_vector(DIN_WIDTH- 1 downto 0);
					dout 		: out std_logic_vector(OUT_WIDTH - 1  downto 0)
				);
			END COMPONENT integrator;

          SIGNAL clk,rst:  std_logic := '0';
          SIGNAL din  :  std_logic_vector(7 downto 0) := (others => '0');
          SIGNAL dout :  std_logic_vector(7 downto 0);
			 constant clk_period : time := 10 ns;
  BEGIN

		clk_process :process		
		begin
			clk <= '0';
			wait for clk_period/2;
			clk <= '1';
			wait for clk_period/2;
		end process;
		
  -- Component Instantiation
     MiddleIntegrator_inst : integrator 
		generic map(
			DIN_WIDTH => 8,
			DOUT_WIDTH => 8
		)
		port map(
			clk  => clk,
			rst  => rst,
			din  => din,
			dout => dout
		);


  --  Test Bench Statements
     tb : PROCESS
     BEGIN
			
        wait for 100 ns; -- wait until global set/reset completes

        -- Add user defined stimulus here
		  wait until falling_edge(clk);
		  din <= "00001010";
		  wait until falling_edge(clk);
		  din <= "00010100";
		  wait until falling_edge(clk);
		  din <= "00011110";
		  wait until falling_edge(clk);
		  din <= "00101000";
		  wait until falling_edge(clk);
		  din <= "00110010";
		  wait until falling_edge(clk);
		  din <= "00101000";
		  wait until falling_edge(clk);
		  din <= "00011110";
		  wait until falling_edge(clk);
		  din <= "00010100";
		  wait until falling_edge(clk);
		  din <= "00001010";
        wait; -- will wait forever
     END PROCESS tb;
  --  End Test Bench 

  END;
