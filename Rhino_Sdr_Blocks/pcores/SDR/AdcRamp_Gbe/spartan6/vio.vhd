-------------------------------------------------------------------------------
-- Copyright (c) 2015 Xilinx, Inc.
-- All Rights Reserved
-------------------------------------------------------------------------------
--   ____  ____
--  /   /\/   /
-- /___/  \  /    Vendor     : Xilinx
-- \   \   \/     Version    : 14.7
--  \   \         Application: XILINX CORE Generator
--  /   /         Filename   : vio.vhd
-- /___/   /\     Timestamp  : Tue Sep 01 09:31:47 SAST 2015
-- \   \  /  \
--  \___\/\___\
--
-- Design Name: VHDL Synthesis Wrapper
-------------------------------------------------------------------------------
-- This wrapper is used to integrate with Project Navigator and PlanAhead

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
ENTITY vio IS
  port (
    CONTROL: inout std_logic_vector(35 downto 0);
    ASYNC_OUT: out std_logic_vector(31 downto 0));
END vio;

ARCHITECTURE vio_a OF vio IS
BEGIN

END vio_a;
