library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.accelerator_pkg.all;

entity Accelerator is
  port(
    clk : in std_logic ;
    reset_n : in std_logic ;

    -- Internal interface (i.e. Avalon slave).
    AS_address : in std_logic_vector(AS_ADDR_WIDTH-1 downto 0);
    AS_write : in std_logic;
    AS_read : in std_logic;

    AS_writedata : in std_logic_vector(AS_BUS_WIDTH-1 downto 0);
    AS_readdata : out std_logic_vector(AS_BUS_WIDTH-1 downto 0);


    -- Conduit interface
    drivers : out std_logic_vector(5 downto 0)
  );
end Accelerator;


architecture RTL of Accelerator is
    -- Registers signals
    -- signal status_reg      : status_reg_t;
    -- signal ctrl_reg        : ctrl_reg_t;
    -- signal src_buffer_addr_reg : buffer_addr_reg_t;
    -- signal dest_buffer_addr_reg : buffer_addr_reg_t;
    -- signal buffer_size_reg : buffer_size_reg_t;
    --
    -- signal swap_unit_in : std_logic_vector(AM_BUS_WIDTH-1 downto 0);
    -- signal dma_burst_cnt : std_logic_vector(AM_BURST_WIDTH-1 downto 0);

    -- signal seq_memory :

    -- constant RAM_SIZE : natural := 2**20;
    type mem_seq_t is array (MEM_SIZE-1 downto 0) of std_logic_vector(MEM_WIDTH-1 downto 0);

    type FSMStates is (IDLE, RUNNING);
    signal FSMState: FSMStates:= IDLE;


    -- signal mem_seq : mem_seq_t := load_ram;
    signal mem_seq : mem_seq_t;
    signal seq_data, seq_readdata_a, seq_readdata_b : std_logic_vector(MEM_WIDTH-1 downto 0);
    signal seq_we, seq_read : std_logic;

    -- signal seq_addr : integer range 0 to MEM_SIZE-1;


    -- signal write_address:  integer RANGE 0 to MEM_SIZE-1;

    signal free_running_counter, free_running_counter_latched:  integer;

    signal clk_en : std_logic;


    -- Registers signals
    signal status_reg   : status_reg_t;
    signal ctrl_reg     : ctrl_reg_t;
    signal seq_addr_a_reg : seq_addr_reg_t;
    signal seq_addr_b_reg : seq_addr_reg_t;
    signal seq_size_reg : seq_size_reg_t;
    signal clk_div_cnt_reg     : clk_div_cnt_reg_t;
    -- signal freq_reg     : freq_reg_t;
begin

    -- ----------------------------------------------------------------------------
    -- -- Instatiante the dma
    -- ----------------------------------------------------------------------------
    -- dma_inst : entity work.dma
    --   GENERIC MAP (
    --     BUS_WIDTH    => AM_BUS_WIDTH,
    --     BURST_WIDTH  => AM_BURST_WIDTH,
    --     ADDR_WIDTH   => AM_ADDR_WIDTH
    --   )
    --   PORT MAP (
    --     clk               => clk,
    --     reset_n           => reset_n,
    --
    --     start_dma         => ctrl_reg.start,
    --     words_cnt         => buffer_size_reg.buffer_size,
    --     -- burst_cnt         => (others  => '1'),
    --     burst_cnt         => dma_burst_cnt,
    --     rd_addr           => src_buffer_addr_reg.buffer_addr,
    --     wr_addr           => dest_buffer_addr_reg.buffer_addr,
    --     running           => status_reg.running,
    --
    --     -- Avalon Master
    --     AM_address        => AM_address,
    --     AM_read           => AM_read,
    --     AM_readdata       => AM_readdata,
    --     AM_wait_request   => AM_wait_request,
    --     AM_readdata_valid => AM_readdata_valid,
    --     AM_burstcount     => AM_burstcount,
    --
    --     AM_write          => AM_write,
    --     AM_writedata      => swap_unit_in
	-- );
    --
    -- dma_burst_cnt <= std_logic_vector(to_unsigned(AM_BURST_SIZE, dma_burst_cnt'length));
    --
    -- ----------------------------------------------------------------------------
    -- -- Instatiante the bit swapping unit
    -- ----------------------------------------------------------------------------
    -- swap_unit_inst : entity work.swapunit
    --   PORT MAP (
    --     dataa      => swap_unit_in,
    --     result     => AM_writedata
	-- );

    process(clk, reset_n)
    begin
        -- if reset_n = '0' then
            -- write_address <= 0;
        if rising_edge(clk) then
            if seq_we = '1' then
                mem_seq(seq_addr_a_reg.addr) <= seq_data;
            end if;
            seq_readdata_a <= mem_seq(seq_addr_a_reg.addr);
            -- write_address <= write_address + 1;
        end if;
        -- if reset_n = '0' then
        --     ctrl_reg.start <= '0';
        --     ctrl_reg.auto_increment <= '1';
        -- elsif rising_edge(clk) and seq_we = '1' then
        --     mem_seq(write_address) <= seq_data;
        --     write_address <= write_address + 1;
        -- end if;

    end process;
    ----------------------------------------------------------------------------
    process(clk, reset_n)
    begin
        if rising_edge(clk) then
            seq_readdata_b <= mem_seq(seq_addr_b_reg.addr);
        end if;
    end process;
    ----------------------------------------------------------------------------
    -- Avalon slave AS_write to registers.
    ----------------------------------------------------------------------------
    AS_WriteRegisters:
        process(clk, reset_n)
        begin
          if reset_n = '0' then
            ctrl_reg.run <= '0';
            ctrl_reg.auto_increment <= '1';
            -- ctrl_reg <= (others => '0');
          elsif rising_edge(clk) then


            -- ctrl_reg.run <= '0';
            seq_we <= '0';

            if AS_write = '1' then
              -- Ctrl can be updated all the time since it starts or stops the module from running
              if AS_address = CTRL_REG_ADDR then
                  ctrl_reg.run <= AS_writedata(0);
              -- end if;
              -- Allow writes only if system is not running
              elsif status_reg.running = '0' then
                case AS_address is

                   when SEQ_ADDR_REG_ADDR =>
                        seq_addr_a_reg.addr <= to_integer(unsigned(AS_writedata(SEQ_ADDR_WIDTH-1 downto 0)));

                   when SEQ_DATA_REG_ADDR =>
                        seq_we <= '1';
                        seq_data <= AS_writedata(MEM_WIDTH-1 downto 0);

                   when SEQ_SIZE_REG_ADDR =>
                        if to_integer(unsigned(AS_writedata)) > MEM_SIZE then
                            seq_size_reg.size <= std_logic_vector(to_unsigned(MEM_SIZE, SIZE_WIDTH));
                        else
                            seq_size_reg.size <= AS_writedata(4 downto 0);
                        end if;

                   when CLK_DIV_CNT_REG_ADDR  =>
                        clk_div_cnt_reg.count <= AS_writedata;

                  when others => null;
                end case;
              end if;
            end if;

            if (seq_we = '1' or seq_read = '1') and ctrl_reg.auto_increment = '1' then
                if seq_addr_a_reg.addr = MEM_SIZE-1 then
                    seq_addr_a_reg.addr <= 0;
                else
                    seq_addr_a_reg.addr <= seq_addr_a_reg.addr + 1;
                end if;
            end if;


          end if;
      end process AS_WriteRegisters;

      -- process(clk)
      -- begin
      --     if rising_edge(clk) then
      --         if (seq_we = '1' or seq_read = '1') and ctrl_reg.auto_increment = '1' then
      --             if seq_addr_a_reg.addr = MEM_SIZE-1 then
      --                 seq_addr_a_reg.addr <= 0;
      --             else
      --                 seq_addr_a_reg.addr <= seq_addr_a_reg.addr + 1;
      --             end if;
      --         end if;
      --         -- if seq_we = '1' or seq_read = '1' then
      --         --     if ctrl_reg.auto_increment = '1' then
      --         --         if seq_addr_a_reg.addr = MEM_SIZE-1 then
      --         --             seq_addr_a_reg.addr <= 0;
      --         --         else
      --         --             seq_addr_a_reg.addr <= seq_addr_a_reg.addr + 1;
      --         --         end if;
      --         --     end if;
      --         -- end if;
      --     end if;
      -- end process;

      ----------------------------------------------------------------------------
      -- Avalon slave AS_read to registers.
      ----------------------------------------------------------------------------
      AS_ReadRegisters:
          process(clk)
          begin
            if rising_edge(clk) then
              AS_readdata <= (others => '0');
              seq_read <= '0';
              if AS_read = '1' then
                case AS_address is
                  when STATUS_REG_ADDR =>
                    AS_readdata(0) <= status_reg.running;

                  when CTRL_REG_ADDR          =>
                    AS_readdata(1) <= ctrl_reg.auto_increment;
                    AS_readdata(0) <= ctrl_reg.run;

                  when SEQ_ADDR_REG_ADDR =>
                    AS_readdata(SEQ_ADDR_WIDTH-1 downto 0) <= std_logic_vector(to_unsigned(seq_addr_a_reg.addr, SEQ_ADDR_WIDTH));

                  when SEQ_DATA_REG_ADDR =>
                    AS_readdata(MEM_WIDTH-1 downto 0) <= seq_readdata_a;
                    seq_read <= '1';

                  when SEQ_SIZE_REG_ADDR =>
                      AS_readdata <= std_logic_vector(resize(unsigned(seq_size_reg.size), AS_readdata'length));

                  when CLK_DIV_CNT_REG_ADDR =>
                    AS_readdata <= clk_div_cnt_reg.count;

                  when others => null;

                end case;

                end if;
              end if;
          end process AS_ReadRegisters;

    status_reg.running <= '0' when FSMState = IDLE else '1';
    ----------------------------------------------------------------------------
    -- FSM
    ----------------------------------------------------------------------------
    FSM_CONFIGURATION:
        process(clk, reset_n)
        begin
          if reset_n = '0' then
            FSMState <= IDLE;
          elsif rising_edge(clk) then
            -- DMA_FSM
            CASE FSMState IS
                WHEN IDLE =>
                    if ctrl_reg.run = '1' then
                      FSMState <= RUNNING;
                    end if;
                WHEN RUNNING =>
                    if ctrl_reg.run = '0' then
                      FSMState <= IDLE;
                    -- else
                    --     -- if seq_addr_b_reg.addr = MEM_SIZE-1 then
                    --     if seq_addr_b_reg.addr = to_integer(unsigned(seq_size_reg.size)) - 1 then
                    --         seq_addr_b_reg.addr <= 0;
                    --     else
                    --         seq_addr_b_reg.addr <= seq_addr_b_reg.addr + 1;
                    --     end if;
                    end if;
                when others => null;
            END CASE;
          -- end if;
          end if;
        end process FSM_CONFIGURATION;

    process(clk, reset_n)
    begin
        if reset_n = '0' then
            free_running_counter <= 0;
        else
          if rising_edge(clk) then

            if FSMState = IDLE then
                free_running_counter <= 0;
            elsif FSMState = RUNNING then
                if free_running_counter = to_integer(unsigned(clk_div_cnt_reg.count)) - 1 then
                    free_running_counter <= 0;
                else
                    free_running_counter <= free_running_counter + 1;
                end if;
            end if;
            free_running_counter_latched <= free_running_counter;

          end if;
        end if;
    end process;

    clk_en <= '1' when free_running_counter = 0 and free_running_counter_latched /= 0 and FSMState = RUNNING else '0';

    process(clk, clk_en)
    begin
        if rising_edge(clk) then
          if FSMState = RUNNING then
            if clk_en = '1' then
              if seq_addr_b_reg.addr = to_integer(unsigned(seq_size_reg.size)) - 1 then
                seq_addr_b_reg.addr <= 0;
              else
                seq_addr_b_reg.addr <= seq_addr_b_reg.addr + 1;
              end if;
            end if;
          elsif  FSMState = IDLE then
            seq_addr_b_reg.addr <= 0;
          end if;
          -- if clk_en = '1' then
          -- end if;
          -- if rising_edge(clk_en) then
        end if;
        -- if rising_edge(clk) and clk_en = '1' then
        --   -- if rising_edge(clk_en) then
        --     if FSMState = RUNNING then
        --         if seq_addr_b_reg.addr = to_integer(unsigned(seq_size_reg.size)) - 1 then
        --             seq_addr_b_reg.addr <= 0;
        --         else
        --             seq_addr_b_reg.addr <= seq_addr_b_reg.addr + 1;
        --         end if;
        --     elsif  FSMState = IDLE then
        --             seq_addr_b_reg.addr <= 0;
        --     end if;
        --   end if;
        -- if FSMState = IDLE then
        --     seq_addr_b_reg.addr <= 0;
        -- end if;
    end process;


    -- running
    -- count reset to zero

    ----------------------------------------------------------------------------
    -- Outputs
    ----------------------------------------------------------------------------
    process(seq_readdata_b, FSMState)
    begin
        drivers <= (others => '0'); -- Default in idle
        if FSMState /= IDLE then
            case seq_readdata_b is
                when "001" => drivers <= "100001";
                when "010" => drivers <= "010001";
                when "011" => drivers <= "100010";
                when "100" => drivers <= "100100";
                when "101" => drivers <= "001010";
                when "110" => drivers <= "010100";
                when "111" => drivers <= "001100";
                when others => null;
            end case;
        end if;
    end process;
-- module lut(count_out, state);
--
-- input [2:0] count_out;
-- output [5:0] state;
-- reg [5:0] state;
--
-- always @(count_out)
-- case (count_out)
-- 3'b000: state=6'b000000; //S0==> Idle
-- 3'b001: state=6'b100001; //S1==> 0-2 = 2
-- 3'b010: state=6'b010001; //S2==> 1-2 = -1
-- 3'b011: state=6'b100010; //S3==> 0-1 = -1
-- 3'b100: state=6'b100100; //S4==> 0-0 = 0
-- 3'b101: state=6'b001010; //S5==> 1-0 = 1
-- 3'b110: state=6'b010100; //S6==> 2-1 = 1
-- 3'b111: state=6'b001100; //S7==> 2-0 = 2
-- default: state=6'b0000000; //default S0
-- endcase
--
-- endmodule
-- module lut(count_out, state);

-- input [2:0] count_out;
-- output [5:0] state;
-- reg [5:0] state;
--
-- always @(count_out)
-- case (count_out)
-- 3'b000: state=6'b000000; //S0==> Idle
-- 3'b001: state=6'b100001; //S1==> 0-2 = 2
-- 3'b010: state=6'b010001; //S2==> 1-2 = -1
-- 3'b011: state=6'b100010; //S3==> 0-1 = -1
-- 3'b100: state=6'b100100; //S4==> 0-0 = 0
-- 3'b101: state=6'b001010; //S5==> 1-0 = 1
-- 3'b110: state=6'b010100; //S6==> 2-1 = 1
-- 3'b111: state=6'b001100; //S7==> 2-0 = 2
-- default: state=6'b0000000; //default S0
-- endcase
--
-- endmodule


end RTL;
