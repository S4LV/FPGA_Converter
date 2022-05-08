library ieee;
use ieee.std_logic_1164.all;

entity top_level_test is port(
CLOCK_50 : in std_logic;
SW : in  std_logic_vector(9 downto 0)
); end top_level_test;



 architecture main  of top_level_test is 
 
     component DEO_SALVA is
        port (
            clk_clk       : in std_logic := 'X'; -- clk
            reset_reset_n : in std_logic := 'X'  -- reset_n
        );
    end component DEO_SALVA;

begin
    u0 : component DEO_SALVA
        port map (
            clk_clk       => CLOCK_50,       --   clk.clk////////
            reset_reset_n => SW(1)  -- reset.reset_n
        );
 
 end main;
	 
