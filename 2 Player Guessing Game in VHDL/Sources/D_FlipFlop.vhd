 library IEEE;
 use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
entity cd is
 Port (Z_clk : in std_logic;
 
 z: out std_logic);
end cd;

architecture Behavioral of cd is
    signal c : std_logic_vector(1 downto 0);

begin 
process (Z_clk)
    variable count : STD_LOGIC_VECTOR (17 downto 0);
    

begin
if rising_edge(Z_clk)  then
   count := count + 1;
    end if;
    c <= count(17 downto 16);
    z<= c(0);
    end process;
    end Behavioral;