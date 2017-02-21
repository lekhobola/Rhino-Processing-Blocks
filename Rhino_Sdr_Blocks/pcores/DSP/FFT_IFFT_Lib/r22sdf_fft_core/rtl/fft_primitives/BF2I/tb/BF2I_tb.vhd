-- TestBench Template 

  LIBRARY ieee;
  USE ieee.std_logic_1164.ALL;
  USE ieee.numeric_std.ALL;

  ENTITY BF2I_tb IS
  END BF2I_tb;

  ARCHITECTURE behavior OF BF2I_tb IS 

  -- Component Declaration
          COMPONENT BF2I
           generic(
					BF2I_data_w : natural
				);
				port(
					en_bf1_sum   : in std_logic;
					xpr			 : in std_logic_vector  (BF2I_data_w  - 1 downto 0);
					xpi			 : in std_logic_vector  (BF2I_data_w  - 1 downto 0);
					xfr 			 : in std_logic_vector  (BF2I_data_w  downto 0);
					xfi 			 : in std_logic_vector  (BF2I_data_w  downto 0);
					znr          : out std_logic_vector (BF2I_data_w  downto 0);
					zni          : out std_logic_vector (BF2I_data_w  downto 0);
					zfr          : out std_logic_vector (BF2I_data_w  downto 0);
					zfi          : out std_logic_vector (BF2I_data_w  downto 0)
				);
          END COMPONENT;

          		signal en_bf1_sum   : std_logic;
					signal xpr			 : std_logic_vector  (8 downto 0);
					signal xpi			 : std_logic_vector  (8 downto 0);
					signal xfr 			 : std_logic_vector  (9 downto 0);
					signal xfi 			 : std_logic_vector  (9 downto 0);
					signal znr          : std_logic_vector (9 downto 0);
					signal zni          : std_logic_vector (9 downto 0);
					signal zfr          : std_logic_vector (9 downto 0);
					signal zfi          : std_logic_vector (9 downto 0);
          
  BEGIN

  -- Component Instantiation
          uut: BF2I 
			 generic map(
					BF2I_data_w => 9
				)
				port map(
					en_bf1_sum => en_bf1_sum,
					xpr		  => xpr,
					xpi		  => xpr,
					xfr 		  => xfr,
					xfi 		  => xfi,
					znr        => znr,
					zni        => zni,
					zfr        => zfr,
					zfi        => zfi
				);


  --  Test Bench Statements
     tb : PROCESS
     BEGIN

      --  wait for 100 ns; -- wait until global set/reset completes

        -- Add user defined stimulus here
		  en_bf1_sum <= '0';
		  wait for 50 ns;
		  xpr <= "000000001";
		  xpi	<=	"000000001";
		  xfr <= "0000000010";
		  xfi <= "0000000100";
		  wait for 50 ns;
		  en_bf1_sum <= '1';
		  wait for 50 ns;
		  en_bf1_sum <= '0';
		  xpr <= (others => '0');
		  xpi	<=	(others => '0');
		  xfr <= (others => '0');
		  xfi <= (others => '0');

        wait; -- will wait forever
     END PROCESS tb;
  --  End Test Bench 

  END;
