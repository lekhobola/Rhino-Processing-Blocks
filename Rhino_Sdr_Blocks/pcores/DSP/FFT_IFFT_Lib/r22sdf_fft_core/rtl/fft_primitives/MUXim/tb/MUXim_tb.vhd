-- TestBench Template 

  LIBRARY ieee;
  USE ieee.std_logic_1164.ALL;
  USE ieee.numeric_std.ALL;

  ENTITY MUXim_tb IS
  END MUXim_tb;

  ARCHITECTURE behavior OF MUXim_tb IS 

  -- Component Declaration
          COMPONENT MUXim
          PORT(
                  cc : in std_logic;
						xr : in std_logic_vector(8 downto 0);
						xi : in std_logic_vector(8 downto 0);
						zr : out std_logic_vector(8 downto 0);
						zi : out std_logic_vector(8 downto 0)
                  );
          END COMPONENT;

          SIGNAL cc:  std_logic;
          SIGNAL xr : std_logic_vector(8 downto 0) := (others => '0');
			 SIGNAL xi : std_logic_vector(8 downto 0) := (others => '0');
			 SIGNAL zr : std_logic_vector(8 downto 0) := (others => '0');
			 SIGNAL zi : std_logic_vector(8 downto 0) := (others => '0');
          

  BEGIN

  -- Component Instantiation
          uut: MUXim PORT MAP(
                  cc => cc,
                  xr => xr,
						xi => xi,
						zr => zr,
						zi => zi
          );


  --  Test Bench Statements
     tb : PROCESS
     BEGIN

        wait for 100 ns; -- wait until global set/reset completes

        -- Add user defined stimulus here
		  wait for 80 ns;
		  cc <= '0';
		  wait for 80 ns;
		  xr <= "000000010";
		  xi <= "000000001";
		  wait for 80 ns;
		  xr <= "000010010";
		  xi <= "000100000";
		  cc <= '1';
		  wait for 80 ns;
		  xr <= "000100010";
		  xi <= "000001001";
		   wait for 80 ns;
		  xr <= "000000000";
		  xi <= "000000000";
		  cc <= '0';
        wait; -- will wait forever
     END PROCESS tb;
  --  End Test Bench 

  END;
