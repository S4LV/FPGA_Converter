library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use std.textio.all;
use work.accelerator_pkg.all;

entity accelerator_tb is
end accelerator_tb;
architecture test of accelerator_tb is

  -- signal dut_input_data, dut_output_data : std_logic_vector(31 downto 0);

  signal dut_clk : std_logic := '0';
signal  dut_reset_n : std_logic := '1';

  -- signal dut_reset_n: std_logic := '1';


  signal dut_AS_address : std_logic_vector(AS_ADDR_WIDTH-1 downto 0);
  signal dut_AS_write :  std_logic;
  signal dut_AS_read :  std_logic;

  signal dut_AS_writedata : std_logic_vector(AS_BUS_WIDTH-1 downto 0);
  signal dut_AS_readdata : std_logic_vector(AS_BUS_WIDTH-1 downto 0);

  signal dut_drivers : std_logic_vector(5 downto 0);


  -- Booleans that define what the state of the test bench is
  -- signal sim_finished, all_done, rx_done, tx_done : boolean := false;
  signal sim_finished, all_done, checker_done, stimulus_done : boolean := false;

  -- signal dut_clk : std_logic := '0';


  constant CLK_PERIOD : time := 10 ns;

  constant MAX_SIM_TIME : time := 1000 ms;
  type SEQ_ARRAY is array(0 to 7) of std_logic_vector(31 downto 0);
  constant SEQ_TEST_ONE:SEQ_ARRAY := (
                                  "00000000000000000000000000000000",
                                  "00000000000000000000000000000001",
                                  "00000000000000000000000000000010",
                                  "00000000000000000000000000000011",
                                  "00000000000000000000000000000100",
                                  "00000000000000000000000000000101",
                                  "00000000000000000000000000000110",
                                  "00000000000000000000000000000111"
                                );

  constant SEQ_TEST_TWO:SEQ_ARRAY := (
                                      "00000000000000000000000000000111",
                                      "00000000000000000000000000000011",
                                      "00000000000000000000000000000010",
                                      "00000000000000000000000000000010",
                                      "00000000000000000000000000000111",
                                      "00000000000000000000000000000011",
                                      "00000000000000000000000000000001",
                                      "00000000000000000000000000000101"
                                      );

  type TEST_ARRAY is array (0 to 5) of std_logic_vector(31 downto 0);
  constant TEST_ARRAY_INPUT : TEST_ARRAY:= ("11111111000000000000000000000000",
                                        "10101010000000000000000001010101",
                                        "00000000000011110000111100000000",
                                        "00000000111100001111000000000000",
                                        "00000000000011110000111111111111",
                                        "10101010000101000100100001010101"
                                        );

  constant TEST_ARRAY_OUTPUT :TEST_ARRAY := ("00000000000000000000000011111111",
                                         "01010101000000000000000010101010",
                                         "00000000111100001111000000000000",
                                         "00000000000011110000111100000000",
                                         "11111111111100001111000000000000",
                                         "01010101000100100010100010101010"
                                         );


    -- Procedure that writes to the registers at the specified address of the dut
    procedure avmm_write(
             variable data : in std_logic_vector(AS_BUS_WIDTH-1 downto 0);
             constant address : in std_logic_vector(AS_ADDR_WIDTH-1 downto 0);
             -- variable address : in std_logic_vector(AS_ADDR_WIDTH-1 downto 0);
             signal dut_AS_write_data : out std_logic_vector(AS_BUS_WIDTH-1 downto 0);
             signal dut_AS_address : out std_logic_vector(AS_ADDR_WIDTH-1 downto 0);
             signal dut_AS_write : out std_logic;
             signal dut_clk : in std_logic
         ) is
    begin
     dut_AS_address <= address;
     dut_AS_write_data <= data;
     dut_AS_write <= '1';
     wait until rising_edge(dut_clk);
     dut_AS_write <= '0';
    end procedure;



    -- Procedure that reads from the register at the specified address of the
    -- dut and returns its result
    procedure avmm_read(
              variable data : out std_logic_vector(AS_BUS_WIDTH-1 downto 0);
              constant address : in std_logic_vector(AS_ADDR_WIDTH-1 downto 0);
              signal dut_AS_read_data : in std_logic_vector(AS_BUS_WIDTH-1 downto 0);
              signal dut_AS_address : out std_logic_vector(AS_ADDR_WIDTH-1 downto 0);
              signal dut_AS_read : out std_logic;
              signal dut_clk : in std_logic
          ) is
    begin
      wait until rising_edge(dut_clk);
      dut_AS_address <= address;
      dut_AS_read <= '1';
      wait until rising_edge(dut_clk);
      dut_AS_read <= '0';
      wait until rising_edge(dut_clk);
      data := dut_AS_read_data;
    end procedure;

    procedure waitNre(n: positive) is
    begin
      for i in 1 to n loop
        wait until rising_edge(dut_clk);
      end loop;
    end procedure waitNre;




  procedure echo (arg : in string := "") is
  begin
    std.textio.write(std.textio.output, arg & LF);
  end procedure echo;

begin

  dut_0: entity work.accelerator port map(
    clk => dut_clk,
    reset_n => dut_reset_n,

    -- Internal interface (i.e. Avalon slave).
    AS_address => dut_AS_address,
    AS_write => dut_AS_write,
    AS_read => dut_AS_read,

    AS_writedata => dut_AS_writedata,
    AS_readdata => dut_AS_readdata,

    -- Conduit interface
    drivers => dut_drivers
  );



  -- Generate CLK signal
  clk_generation : process
  begin
    if not sim_finished then
      dut_clk <= '1';
      wait for CLK_PERIOD / 2;
      dut_clk <= '0';
      wait for CLK_PERIOD / 2;
    else
        wait;
    end if;
  end process clk_generation;

  process (dut_clk)
  begin
    if rising_edge(dut_clk) then
      sim_finished <= (NOW > MAX_SIM_TIME) or all_done;
    end if;
  end process;

  all_done <= stimulus_done;


  stimulus : process
  variable var_input_data : std_logic_vector(31 downto 0);
  variable var_addr_data : std_logic_vector(AS_ADDR_WIDTH-1 downto 0);
  variable var_output_data : std_logic_vector(31 downto 0);
  begin
    echo("*****************************************************************");
    echo("*****************************************************************");
    echo("********* STARTED SIMULATION OF CUSTOM INSTRUCCTION ************");
    echo("*****************************************************************");
    echo("*****************************************************************");

    wait until rising_edge(dut_clk);
    echo("Execute a reset");
    -- Reset
    wait until rising_edge(dut_clk);
    wait until rising_edge(dut_clk);
    dut_reset_n <= '0';
    wait until rising_edge(dut_clk);
    dut_reset_n <= '1';

    echo("Set run");
    var_input_data := X"00000000";
    avmm_write(var_input_data, CTRL_REG_ADDR, dut_AS_writedata, dut_AS_address, dut_AS_write, dut_clk);

    echo("Set address");
    var_input_data := X"00000000";
    avmm_write(var_input_data, SEQ_ADDR_REG_ADDR, dut_AS_writedata, dut_AS_address, dut_AS_write, dut_clk);


    echo("Set Memory Size");
    var_input_data := X"00000008";
    avmm_write(var_input_data, SEQ_SIZE_REG_ADDR, dut_AS_writedata, dut_AS_address, dut_AS_write, dut_clk);


    echo("Set Sequence");
    for i in 0 to 7 loop
       var_input_data := SEQ_TEST_ONE(i);
       avmm_write(var_input_data, SEQ_DATA_REG_ADDR, dut_AS_writedata, dut_AS_address, dut_AS_write, dut_clk);
    end loop;


    echo("Set Ticks");
    var_input_data := X"0000007D";
    avmm_write(var_input_data, CLK_DIV_CNT_REG_ADDR, dut_AS_writedata, dut_AS_address, dut_AS_write, dut_clk);



    echo("Set run");
    var_input_data := X"00000001";
    avmm_write(var_input_data, CTRL_REG_ADDR, dut_AS_writedata, dut_AS_address, dut_AS_write, dut_clk);


waitNre(125);
waitNre(125);
waitNre(125);
waitNre(125);
waitNre(125);

waitNre(125);
waitNre(125);
waitNre(125);
waitNre(125);
waitNre(125);

    echo("Stop run");
    var_input_data := X"00000000";
    avmm_write(var_input_data, CTRL_REG_ADDR, dut_AS_writedata, dut_AS_address, dut_AS_write, dut_clk);




    -- second Sequence



    echo("Set run");
    var_input_data := X"00000000";
    avmm_write(var_input_data, CTRL_REG_ADDR, dut_AS_writedata, dut_AS_address, dut_AS_write, dut_clk);

    echo("Set address");
    var_input_data := X"00000000";
    avmm_write(var_input_data, SEQ_ADDR_REG_ADDR, dut_AS_writedata, dut_AS_address, dut_AS_write, dut_clk);


    echo("Set Memory Size");
    var_input_data := X"00000008";
    avmm_write(var_input_data, SEQ_SIZE_REG_ADDR, dut_AS_writedata, dut_AS_address, dut_AS_write, dut_clk);


    echo("Set Sequence");
    for i in 0 to 7 loop
       var_input_data := SEQ_TEST_TWO(i);
       avmm_write(var_input_data, SEQ_DATA_REG_ADDR, dut_AS_writedata, dut_AS_address, dut_AS_write, dut_clk);
    end loop;


    echo("Set Ticks");
    var_input_data := X"00032dcd";
    avmm_write(var_input_data, CLK_DIV_CNT_REG_ADDR, dut_AS_writedata, dut_AS_address, dut_AS_write, dut_clk);



    echo("Set run");
    var_input_data := X"00000001";
    avmm_write(var_input_data, CTRL_REG_ADDR, dut_AS_writedata, dut_AS_address, dut_AS_write, dut_clk);

    waitNre(208333);
    waitNre(208333);
    waitNre(208333);
    waitNre(208333);
    waitNre(208333);

    waitNre(208333);
    waitNre(208333);
    waitNre(208333);
    waitNre(208333);
    waitNre(208333);

    echo("Stop run");
    var_input_data := X"00000000";
    avmm_write(var_input_data, CTRL_REG_ADDR, dut_AS_writedata, dut_AS_address, dut_AS_write, dut_clk);



    -- for i in 0 to myVector'length loop
    --     if myVector(i) = '1' then
    --         Sum := Sum + 1;
    --     end if;
    -- end loop;


    -- var_input_data = x"0001"
    -- avmm_write(var_input_data, CTRL_REG_ADDR, dut_AS_write, dut_AS_address, dut_AS_write, dut_clk);



   -- var_input_data = x"0001"
   -- avmm_write(var_input_data, CTRL_REG_ADDR, dut_AS_write, dut_AS_address, dut_AS_write, dut_clk);


    -- for i in 0 to 5 loop
    --
    --   var_input_data := TEST_ARRAY_INPUT(i);
    --   avmm_write(var_output_data,var_input_data, dut_input_data,dut_output_data, dut_clk);
    --   assert var_output_data = TEST_ARRAY_OUTPUT(i)
    --   -- report "Error";
    --   report "Error for input " &to_hstring(var_input_data)  & " result was: " & to_hstring(var_output_data) & ", but expected was: " & to_hstring(TEST_ARRAY_OUTPUT(i));
    -- end loop;

    stimulus_done <= True;
    echo("All stimulus completed");

  wait;
  end process stimulus;

end architecture test;
