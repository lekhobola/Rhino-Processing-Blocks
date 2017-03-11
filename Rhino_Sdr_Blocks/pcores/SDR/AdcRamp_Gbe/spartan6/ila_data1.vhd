-------------------------------------------------------------------------------
-- Copyright (c) 2015 Xilinx, Inc.
-- All Rights Reserved
-------------------------------------------------------------------------------
--   ____  ____
--  /   /\/   /
-- /___/  \  /    Vendor     : Xilinx
-- \   \   \/     Version    : 14.7
--  \   \         Application: XILINX CORE Generator
--  /   /         Filename   : ila_data1.vhd
-- /___/   /\     Timestamp  : Mon May 11 20:34:53 SAST 2015
-- \   \  /  \
--  \___\/\___\
--
-- Design Name: VHDL Synthesis Wrapper
-------------------------------------------------------------------------------
-- This wrapper is used to integrate with Project Navigator and PlanAhead

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
ENTITY ila_data1 IS
  port (
    CONTROL: inout std_logic_vector(35 downto 0);
    CLK: in std_logic;
    DATA: in std_logic_vector(127 downto 0);
    TRIG0: in std_logic_vector(7 downto 0);
    TRIG1: in std_logic_vector(7 downto 0);
    TRIG2: in std_logic_vector(7 downto 0);
    TRIG3: in std_logic_vector(7 downto 0);
    TRIG4: in std_logic_vector(7 downto 0);
    TRIG5: in std_logic_vector(7 downto 0);
    TRIG6: in std_logic_vector(7 downto 0);
    TRIG7: in std_logic_vector(7 downto 0));
END ila_data1;

ARCHITECTURE ila_data1_a OF ila_data1 IS
BEGIN

END ila_data1_a;
