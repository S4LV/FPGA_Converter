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

package accelerator_pkg is

  -- constant UART_AVMM_BUS_WIDTH    : natural := 8;
  constant AS_ADDR_WIDTH          : natural := 5;
  constant AS_BUS_WIDTH           : natural := 32;
  constant STATUS_REG_ADDR        : std_logic_vector(AS_ADDR_WIDTH-1 downto 0)    := std_logic_vector(to_unsigned(0, AS_ADDR_WIDTH));
  constant CTRL_REG_ADDR          : std_logic_vector(AS_ADDR_WIDTH-1 downto 0)    := std_logic_vector(to_unsigned(1, AS_ADDR_WIDTH));
  constant SEQ_ADDR_REG_ADDR : std_logic_vector(AS_ADDR_WIDTH-1 downto 0)  := std_logic_vector(to_unsigned(2, AS_ADDR_WIDTH));
  constant SEQ_DATA_REG_ADDR : std_logic_vector(AS_ADDR_WIDTH-1 downto 0)      := std_logic_vector(to_unsigned(3, AS_ADDR_WIDTH));
  constant SEQ_SIZE_REG_ADDR : std_logic_vector(AS_ADDR_WIDTH-1 downto 0) := std_logic_vector(to_unsigned(4, AS_ADDR_WIDTH));
  -- constant FREQ_HZ_REG_ADDR : std_logic_vector(AS_ADDR_WIDTH-1 downto 0) := std_logic_vector(to_unsigned(5, AS_ADDR_WIDTH));
  constant CLK_DIV_CNT_REG_ADDR : std_logic_vector(AS_ADDR_WIDTH-1 downto 0) := std_logic_vector(to_unsigned(5, AS_ADDR_WIDTH));

  -- AM constants for DMA
  -- constant AM_ADDR_WIDTH:   natural := 32;
  -- constant AM_BUS_WIDTH:    natural := 32;
  -- constant AM_BURST_SIZE : natural := 64;
  -- -- constant AM_BURST_WIDTH:  natural := integer(ceil(log2(real(AM_BURST_SIZE))));
  -- constant AM_BURST_WIDTH:  natural := integer(ceil(log2(real(AM_BURST_SIZE) + real(1))));
  -- constant DMA_BURST_BYTES : natural := AM_BUS_WIDTH/8;


  constant STATES_CNT : natural := 8;
  constant MEM_WIDTH : natural := integer(ceil(log2(real(STATES_CNT))));
  constant MEM_SIZE : natural := 16;
  -- constant SEQ_ADDR_WIDTH:  natural := integer(ceil(log2(real(MEM_SIZE) + real(1))));
  constant SEQ_ADDR_WIDTH:  natural := integer(ceil(log2(real(MEM_SIZE))));

-- The bits required to hold the number 16
  constant SIZE_WIDTH : natural := integer(ceil(log2(real(MEM_SIZE) + real(1))));

  type status_reg_t  is record
    -- fifo_empty : std_logic;
    -- fifo_full  : std_logic;
    running    : std_logic;
  end record status_reg_t;

  type ctrl_reg_t  is record
    auto_increment : std_logic;
    run          : std_logic;
  end record ctrl_reg_t;

  type seq_addr_reg_t  is record
    -- addr    : std_logic_vector(SEQ_ADDR_WIDTH-1 downto 0); -- Blocked
    addr : integer range 0 to MEM_SIZE-1; -- Blocked
  end record seq_addr_reg_t;

  type seq_size_reg_t  is record
    size    : std_logic_vector(SIZE_WIDTH-1 downto 0); -- Blocked
  end record seq_size_reg_t;

  type clk_div_cnt_reg_t  is record
    count    : std_logic_vector(31 downto 0); -- Blocked
end record clk_div_cnt_reg_t;

--   type freq_reg_t  is record
--     freq    : std_logic_vector(31 downto 0); -- Blocked
-- end record freq_reg_t;

--   type data_reg_t  is record
--     buffer_size    : std_logic_vector(31 downto 0); -- Blocked
-- end record data_reg_t;

end package accelerator_pkg;
