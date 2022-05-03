--
--  Custom slave programmable interface -- UART
--
--  This file contains a set of constants and defitions used in design files
--  as well as test benches.
--
--  Date: 27/11/2021
--  Authors: Alexis Rodriguez, Marcel Moran
--

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

package parallel_port_package is

  constant PP_AVMM_BUS_WIDTH : natural := 8;
  constant PP_WIDTH : natural := 8;
  -- constant COUNTER_AVMM_BUS_WIDTH : natural := 32;
  -- constant MAX_COUNT : std_logic_vector(COUNTER_AVMM_BUS_WIDTH-1 downto 0) := (others => '1');
  constant DIRECTION_REG_ADDR : std_logic_vector(2 downto 0) := "000";
  -- constant RESET_REG_ADDR : std_logic_vector(2 downto 0) := "000";
  -- constant START_REG_ADDR : std_logic_vector(2 downto 0) := "001";
  -- constant STOP_REG_ADDR : std_logic_vector(2 downto 0) := "010";
  constant INPUT_PORT_REG_ADDR : std_logic_vector(2 downto 0) := "001";
  constant OUTPUT_PORT_REG_ADDR : std_logic_vector(2 downto 0) := "010";
  constant SET_REG_ADDR : std_logic_vector(2 downto 0) := "011";
  constant CLR_REG_ADDR : std_logic_vector(2 downto 0) := "100";
  constant IRQ_REG_ADDR : std_logic_vector(2 downto 0) := "101";
  constant CLR_END_CYCLE_ADDR : std_logic_vector(2 downto 0) := "110";
  constant DEFAULT_IRQ : std_logic_vector(PP_AVMM_BUS_WIDTH - 1 downto 0) := ( others => '0');

  -- constant COMMAND_WIDTH : natural := 3;
  -- constant BAUD_RATE_START_BIT : natural := 2;
  -- constant RESET_COMMAND : std_logic_vector(COMMAND_WIDTH-1 downto 0) := "000";
  -- constant START_COMMAND : std_logic_vector(COMMAND_WIDTH-1 downto 0) := "001";
  -- constant STOP_COMMAND : std_logic_vector(COMMAND_WIDTH-1 downto 0) := "010";
  -- constant EN_IRQ_COMMAND : std_logic_vector(COMMAND_WIDTH-1 downto 0) := "011";
  -- constant DIS_IRQ_COMMAND : std_logic_vector(COMMAND_WIDTH-1 downto 0) := "100";
  -- constant CLR_END_CYCLE_COMMAND : std_logic_vector(COMMAND_WIDTH-1 downto 0) := "101";


end package parallel_port_package;