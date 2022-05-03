library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.counter_package.all;

library work;
-- use ieee.math_real.all;

-- use work.lcd_controller_package.all;

entity Counter is
  port(
    clk : in std_logic;
    reset_n : in std_logic;

    -- Internal interface (i.e. Avalon slave).
    address : in std_logic_vector(2 downto 0);
    write : in std_logic;
    read : in std_logic;

    writedata : in std_logic_vector(COUNTER_AVMM_BUS_WIDTH-1 downto 0);
    readdata : out std_logic_vector(COUNTER_AVMM_BUS_WIDTH-1 downto 0);

    -- External conduit interface
    IRQ : out std_logic
  );
end Counter;


architecture RTL of Counter is
  -- Internal signals
  signal i_cnt_en         : std_logic;
  signal i_reset_cnt    : std_logic;
  signal i_IRQ_en     : std_logic;
  signal i_full_cycle        : std_logic; -- Means the counter has reached 0
  signal i_clr_full_cycle        : std_logic;

  -- signal i_counter    : unsigned(31 downto 0);
  signal i_counter    : unsigned(COUNTER_AVMM_BUS_WIDTH-1 downto 0);

begin
    pCounter:
      process (clk)
      begin
        if rising_edge(clk) then
          if i_reset_cnt = '1' then
            i_counter <= (others => '0');
          elsif i_cnt_en = '1' then
            i_counter <= i_counter + 1;
          end if;
        end if;
      end process pCounter;

    pRegWrite:
      process (clk, reset_n)
      begin
        if reset_n = '0' then
          i_cnt_en <= '0';
          i_reset_cnt <= '1';
          i_IRQ_en <= '0';
        elsif rising_edge(clk) then
          i_reset_cnt <= '0';
          i_clr_full_cycle <= '0';
          if write = '1' then
            case address(2 downto 0) is
              when "000" => null;

              when "001" =>
              -- begin
                case writedata(COMMAND_WIDTH-1 downto 0) is
                  when RESET_COMMAND   => i_reset_cnt <= '1';  -- Reset the counter
                  when START_COMMAND   => i_cnt_en <= '1';         -- Start the counter
                  when STOP_COMMAND    => i_cnt_en <= '0';         -- Stop the counter
                  when EN_IRQ_COMMAND  => i_IRQ_en <= '1'; -- Enable interrupts
                  when DIS_IRQ_COMMAND => i_IRQ_en <= '0'; -- Disable interrupts
                  when CLR_END_CYCLE_COMMAND => i_clr_full_cycle <= '1'; -- acknowledge interrupt
                  when others => null;
                end case;
              -- end


              -- when "001" => i_reset_cnt <= '1';  -- Reset the counter
              -- when "010" => i_cnt_en <= '1';         -- Start the counter
              -- -- when "011" => i_cnt_en <= '0';
              -- when "011" => i_cnt_en <= '0';         -- Stop the counter
              -- when "100" => i_IRQ_en <= writedata(0);    -- Enable interrupts
              -- when "101" => i_clr_full_cycle <= writedata(0); -- acknowledge interrupt
              when others => null;
            end case;
          end if;
        end if;
    end process pRegWrite;

    pRegRead:
      process (clk, reset_n)
      begin
        if rising_edge(clk) then
          if read = '1' then
            case address(2 downto 0) is
              when "000" => readdata <= std_logic_vector(i_counter);
              -- when "100" => readdata(0) <= i_IRQ_en;    -- Return if interrupts enabled
              when "010" => readdata(0) <= i_full_cycle;   -- return if interrupt was asserted ---> status register
                            readdata(1) <= i_cnt_en;    -- return if counter is running
                            readdata(2) <= i_IRQ_en;    -- Return if interrupts enabled
              when others => null;
            end case;
          end if;
        end if;
      end process pRegRead;

    pInterrupt:
      process (clk)
      begin
        if rising_edge(clk) then
          -- if i_counter = X"0000_0000"  then
          if i_counter = (i_counter'range => '0')  then
            i_full_cycle <= '1';
          elsif i_clr_full_cycle = '1' then
            i_full_cycle <= '0';
          end if;
        end if;
      end process pInterrupt;

      IRQ <= '1' when i_IRQ_en = '1' and i_full_cycle = '1' and i_cnt_en = '1' else '0';

end RTL;
