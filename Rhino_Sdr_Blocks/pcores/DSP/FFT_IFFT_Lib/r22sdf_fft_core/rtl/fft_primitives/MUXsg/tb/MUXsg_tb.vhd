-- TestBench Template 

  LIBRARY ieee;
  USE ieee.std_logic_1164.ALL;
  USE ieee.numeric_std.ALL;

  ENTITY MUXsg_tb IS
  END MUXsg_tb;

  ARCHITECTURE behavior OF MUXsg_tb IS 

  -- Component Declaration
          COMPONENT MUXsg
			 GENERIC(
				MUXsg_data_w : natural
			 );
          PORT(
                  cc : IN std_logic;
                  a1 : IN std_logic_vector(8 downto 0);       
                  a2 : IN std_logic_vector(8 downto 0);
						b1 : OUT std_logic_vector(8 downto 0);       
                  b2 : OUT std_logic_vector(8 downto 0)
                  );
          END COMPONENT;

          SIGNAL cc:  std_logic;
          SIGNAL a1 : std_logic_vector(8 downto 0) := (others => '0');
			 SIGNAL a2 : std_logic_vector(8 downto 0) := (others => '0');
			 SIGNAL b1 : std_logic_vector(8 downto 0) := (others => '0');
			 SIGNAL b2 : std_logic_vector(8 downto 0) := (others => '0');
          
          

  BEGIN

  -- Component Instantiation
		
          uut: MUXsg 
			 GENERIC MAP(
				MUXsg_data_w => 9
			 )
			 PORT MAP(
                  cc => cc,
                  a1 => a1,
						a2 => a2,
						b1 => b1,
						b2 => b2
          );


  --  Test Bench Statements
     tb : PROCESS
     BEGIN

        wait for 100 ns; -- wait until global set/reset completes

        -- Add user defined stimulus here
		  wait for 80 ns;
		  cc <= '0';
		  wait for 80 ns;
		  a1 <= "000000010";
		  a2 <= "000000001";
		  wait for 80 ns;
		  cc <= '1';
		  wait for 80 ns;
		  a1 <= "000000000";
		  a2 <= "000000000";
		  cc <= '0';
        wait; -- will wait forever
     END PROCESS tb;
  --  End Test Bench 

  END;
