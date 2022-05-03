library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
-- use work.counter_package.all;

library work;
-- use ieee.math_real.all;
-- use work.lcd_controller_package.all;
use work.parallel_port_package.all;


entity ParallelPort is
  port(
    clk : in std_logic;
    reset_n : in std_logic;

    -- Internal interface (i.e. Avalon slave).
    address : in std_logic_vector(2 downto 0);
    write : in std_logic;
    read : in std_logic;

    writedata : in std_logic_vector(PP_AVMM_BUS_WIDTH-1 downto 0);
    readdata : out std_logic_vector(PP_AVMM_BUS_WIDTH-1 downto 0);

    -- External conduit interface
    par_port : inout std_logic_vector (PP_WIDTH-1 downto 0);

    -- External conduit interface
    IRQ : out std_logic
  );
end ParallelPort;

architecture RTL of ParallelPort is
  -- Internal signals
  signal iRegDir : std_logic_vector (PP_WIDTH-1 DOWNTO 0);
  signal iRegPort: std_logic_vector (PP_WIDTH-1 DOWNTO 0);
  signal lastReciRegPort: std_logic_vector (PP_WIDTH-1 DOWNTO 0);
  signal pinChangediRegPort: std_logic_vector (PP_WIDTH-1 DOWNTO 0)  :=  (others => '0');
  signal iRegPin : std_logic_vector (PP_WIDTH-1 DOWNTO 0);

  signal iRegIRQ : std_logic_vector (PP_WIDTH-1 DOWNTO 0 )  :=  (others => '0');

  -- signal i_IRQ_en     : std_logic;
  signal i_full_cycle        : std_logic; -- Means the counter has reached 0
  signal i_full_cycle_vector : std_logic_vector (PP_WIDTH-1 DOWNTO 0) :=  (others => '0');
  signal i_clr_full_cycle        : std_logic;
  signal i_clr_full_cycle_vector : std_logic_vector (PP_WIDTH-1 DOWNTO 0);

begin
    pPort:
      process(iRegDir, iRegPort)
      begin
        for i in 0 to 7 loop
          if iRegDir(i) = '1' then
            par_port(i) <= iRegPort(i);
          else
            par_port(i) <= 'Z';
          end if;
        end loop;
      end process pPort;

    pRegWr:
      process(clk, reset_n)
      begin
        if reset_n = '0' then
          iRegDir <= (others => '0'); -- Input by default
          iRegPort <= (others => '0');
          iRegIRQ <= (others => '0');
          lastReciRegPort <= (others => '0');


          -- i_IRQ_en <= '0';
        elsif rising_edge(clk) then
          -- i_clr_full_cycle <= '0';
          lastReciRegPort <= iRegPort;
          i_clr_full_cycle_vector <=(others => '0');
          if write = '1' then -- Write cycle
          case address(2 downto 0) is
            when DIRECTION_REG_ADDR => iRegDir  <= writedata; -- direction
            -- when OUTPUT_PORT_REG_ADDR => if iRegIRQ = DEFAULT_IRQ then pinChangediRegPort <= writedata; else  pinChangediRegPort <= iRegPort xor writedata; end if; iRegPort <= writedata; -- output port
            -- when SET_REG_ADDR => if iRegIRQ = DEFAULT_IRQ then pinChangediRegPort <= iRegPort or writedata; else  pinChangediRegPort <= iRegPort xor (iRegPort or writedata); end if; iRegPort <= iRegPort or writedata; -- set, indicate bits
            -- when CLR_REG_ADDR => if iRegIRQ = DEFAULT_IRQ then pinChangediRegPort <= iRegPort and not writedata; else  pinChangediRegPort <= iRegPort xor (iRegPort and not writedata); end if;  iRegPort <= iRegPort and not writedata; -- clr, indicate bits
            when OUTPUT_PORT_REG_ADDR => iRegPort <= writedata; -- output port
            when SET_REG_ADDR => iRegPort <= iRegPort or writedata; -- set, indicate bits
            when CLR_REG_ADDR => iRegPort <= iRegPort and not writedata; -- clr, indicate bits

            -- when OUTPUT_PORT_REG_ADDR => lastReciRegPort <= iRegPort;  iRegPort <= writedata; -- output port
            -- when SET_REG_ADDR => lastReciRegPort <=iRegPort;  iRegPort <= iRegPort or writedata; -- set, indicate bits
            -- when CLR_REG_ADDR => lastReciRegPort <=iRegPort; iRegPort <= iRegPort and not writedata; -- clr, indicate bits

            when IRQ_REG_ADDR =>  iRegIRQ <= writedata;
            when CLR_END_CYCLE_ADDR => i_clr_full_cycle_vector <= writedata;

            when others => null;
          end case;
        end if;
      end if;
    end process pRegWr;

    pRegRd:
      process(clk)
      begin
        if rising_edge(clk) then
          readdata <= (others => '0'); -- default value
          if read = '1' then -- Read cycle
            case address(2 downto 0) is
              when DIRECTION_REG_ADDR =>  readdata <= iRegDir;  -- reg dir
              when INPUT_PORT_REG_ADDR =>  readdata <= iRegPin;  -- input
              when OUTPUT_PORT_REG_ADDR =>  readdata <= iRegPort; -- output
              when others => null;
            end case;
        end if;
      end if;
    end process pRegRd;


    pInterrupt:
      process (clk, reset_n)
      begin
        if reset_n = '0' then
          i_full_cycle_vector <= (others => '0'); -- Input by default
          -- pinChangediRegPort <= (others => '0');
        elsif rising_edge(clk) then
          -- if i_counter = X"0000_0000"  then


          -- if iRegIRQ /= DEFAULT_IRQ then
          --   pinChangediRegPort <= lastReciRegPort xor iRegPort;
          -- end if;

          for i in 0 to 7 loop
            if iRegDir(i) = '1' then

              if pinChangediRegPort(i) = '1' and iRegIRQ(i) = '1' then
                i_full_cycle_vector(i) <= '1';
                exit;--- end loop
              elsif i_clr_full_cycle_vector(i) = '1' and i_full_cycle_vector(i) = '1' then
                  i_full_cycle_vector(i) <= '0';
                  exit;
              end if;
            end if;
          end loop;

        end if;
      end process pInterrupt;


      pinChangediRegPort <= lastReciRegPort xor iRegPort;
      IRQ <= '1' when iRegIRQ /= DEFAULT_IRQ and i_full_cycle_vector /= DEFAULT_IRQ else '0';

    -- Parallel Port Input value
    iRegPin <= par_port;

end RTL;
