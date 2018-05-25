library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
entity game is
Port (
anode: out std_logic_vector(3 downto 0);
segments: out std_logic_vector(6 downto 0);
switches: in std_logic_vector(3 downto 0);
LED16: out std_logic_vector(15 downto 0):="0000000000000000";
Center_btn: in std_logic;
Down_btn: in std_logic;
Left_btn: in std_logic;
Right_btn: in std_logic;
Up_btn: in std_logic;
sys_clk: in std_logic
);
end game;

architecture Behavioral of game is
signal S_clk: std_logic;
shared variable state:integer:=1;
shared variable temp_count: integer:=0;

-- Clock Divider Circuit --

begin
div: entity work.cd port map(Z_clk=>sys_clk,z=>S_clk);

process (S_clk, switches)
variable case_val:integer:=0;
variable PL_1: std_logic_vector(15 downto 0);
variable PL_2: std_logic_vector(15 downto 0);
variable guess_hits:integer:=0;
variable binary_hits:std_logic_vector(15 downto 0);

-- 7 SEGMENT DISPLAY SIGNALS: 


variable dig_0: std_logic_vector(3 downto 0);
variable dig_1: std_logic_vector(3 downto 0);
variable dig_2: std_logic_vector(3 downto 0);
variable dig_3: std_logic_vector(3 downto 0);
variable dig_val: std_logic_vector(15 downto 0);

variable initial_sw: std_logic_vector(15 downto 0);
variable i:integer:=0;
variable temp:integer:=0;

begin
if rising_edge(S_clk) then
temp_count := temp_count + 1;

-- Assigning 4 digit BCD equivalent values and latching them through the 4 buttons: 

if Down_btn = '1' then
dig_val(3 downto 0) := switches(3 downto 0);
end if;
if Right_btn = '1' then
dig_val(7 downto 4) := switches(3 downto 0);
end if;
if Up_btn = '1' then
dig_val(11 downto 8) := switches(3 downto 0);
end if;
if Left_btn = '1' then
dig_val(15 downto 12) := switches(3 downto 0);
end if;

-- Assign and store initial value of switches. 

if i=0 then initial_sw:=dig_val; end if;
i:=i+1;

if dig_val/= initial_sw then

-- Change LED16 value when switch has been changed

initial_sw:=dig_val;
dig_0 := dig_val(3 downto 0);
dig_1 := dig_val(7 downto 4);
dig_2 := dig_val(11 downto 8);
dig_3 := dig_val(15 downto 12);
if (state = 1 or state = 6) then
state:=1;
elsif state = 2 or state = 3 or state = 4 or state = 7 then
state:=2;
end if;
end if;




if Center_btn = '1' and temp_count>381 then

-- Copy the value entered in the switches to a new variable

if state = 1 or state = 6 then

PL_1 := dig_val;    -- Display "PL2" 


state := 2;

temp_count:=0;

case case_val is
when 0=> segments <= "0100100"; anode <= "1110"; case_val := case_val + 1; -- 2
when 1=> segments <= "0111111"; anode <= "1101"; case_val := case_val + 1;-- -
when 2=> segments <= "1000111"; anode <= "1011"; case_val := case_val + 1;-- L
when 3=> segments <= "0001100"; anode <= "0111"; case_val := 0;-- P
when others=>null;
end case;


elsif state = 2 or state = 3 or state = 4 or state = 7 then
-- Resume Comparison

guess_hits:=guess_hits + 1;
-- LED16 value <= "0000000000000000";

PL_2 := dig_val;

if PL_2 > PL_1 then
--        LED16 value <= "1111111100000000";

state:=3;   --Display  "2-HI" after the comparison

temp_count:=0;

elsif PL_2 < PL_1 then
--        LED16 value <= "0000000011111111";

state:=4;   -- Display  "2-LO" after the comparison

temp_count:=0;

else
state:=5;   -- Display the winning stage

temp_count:=0;

end if;

end if;

-- Change the state if none of the above conditions don't satisfy.

end if;

if state = 1 then
-- Display "PL 1" on screen

case case_val is
when 0=> segments <= "1111001"; anode <= "1110"; case_val := case_val + 1;  ----- "1" ------
when 1=> segments <= "0111111"; anode <= "1101"; case_val := case_val + 1;  ----- "-" ------
when 2=> segments <= "1000111"; anode <= "1011"; case_val := case_val + 1;  ----- "L" ------
when 3=> segments <= "0001100"; anode <= "0111"; case_val := 0;          ----- "P" ------
when others=>null;
end case;

-- The other conditions:


elsif state = 2 then

--  Display "PL 1" on screen

case case_val is
when 0=> segments <= "0100100"; anode <= "1110"; case_val := case_val + 1; ----- "2" ------
when 1=> segments <= "0111111"; anode <= "1101"; case_val := case_val + 1; ----- "-" ------
when 2=> segments <= "1000111"; anode <= "1011"; case_val := case_val + 1; ----- "L" ------
when 3=> segments <= "0001100"; anode <= "0111"; case_val := 0;		 ----- "P" ------
when others=>null;
end case;


elsif state = 3 then
--Display "2 HI"
case case_val is
when 0=> segments <= "1001111"; anode <= "1110"; case_val := case_val + 1; ----- "I" ------	
when 1=> segments <= "0001001"; anode <= "1101"; case_val := case_val + 1; ----- "H" ------   
when 2=> segments <= "1111111"; anode <= "1011"; case_val := case_val + 1; ----- " " ------   
when 3=> segments <= "0100100"; anode <= "0111"; case_val := 0;         ----- "2" ------   
when others=>null;
end case;

elsif state = 4 then
-- Display "2 LO"
case case_val is
when 0=> segments <= "1000000"; anode <= "1110"; case_val := case_val + 1;   ----- "O" ------
when 1=> segments <= "1000111"; anode <= "1101"; case_val := case_val + 1;   ----- "L" ------
when 2=> segments <= "1111111"; anode <= "1011"; case_val := case_val + 1;   ----- " " ------
when 3=> segments <= "0100100"; anode <= "0111"; case_val := 0;           ----- "2" ------
when others=>null;
end case;

elsif state = 5 then 
-- Display the Attempts taken and Blink all LEDs

binary_hits := std_logic_vector(to_unsigned(guess_hits, binary_hits'length));
dig_0 := binary_hits(3 downto 0);
dig_1 := binary_hits(7 downto 4);
dig_2 := binary_hits(11 downto 8);
dig_3 := binary_hits(15 downto 12);

case case_val is

when 0=>

-- Display digit 0

anode<="1110";
case dig_0 is
when "0000" => segments<="1000000";
when "0001" => segments<="1111001";
when "0010" => segments<="0100100";
when "0011" => segments<="0110000";
when "0100" => segments<="0011001";
when "0101" => segments<="0010010";
when "0110" => segments<="0000010";
when "0111" => segments<="1111000";
when "1000" => segments<="0000000";
when "1001" => segments<="0011000";
when "1010" => segments<="0001000";
when "1011" => segments<="0000011";
when "1100" => segments<="1000110";
when "1101" => segments<="0100001";
when "1110" => segments<="0000110";
when "1111" => segments<="0001110";

when others=>null;
end case;
case_val := case_val + 1; 

when 1=>
-- Display digit 1
anode<="1101";

case dig_1 is
when "0000" => segments<="1000000";
when "0001" => segments<="1111001";
when "0010" => segments<="0100100";
when "0011" => segments<="0110000";
when "0100" => segments<="0011001";
when "0101" => segments<="0010010";
when "0110" => segments<="0000010";
when "0111" => segments<="1111000";
when "1000" => segments<="0000000";
when "1001" => segments<="0011000";
when "1010" => segments<="0001000";
when "1011" => segments<="0000011";
when "1100" => segments<="1000110";
when "1101" => segments<="0100001";
when "1110" => segments<="0000110";
when "1111" => segments<="0001110";

when others=>null;
end case;
case_val := case_val + 1;

when 2=>
-- Display digit 2
anode<="1011";
case dig_2 is
when "0000" => segments<="1000000";
when "0001" => segments<="1111001";
when "0010" => segments<="0100100";
when "0011" => segments<="0110000";
when "0100" => segments<="0011001";
when "0101" => segments<="0010010";
when "0110" => segments<="0000010";
when "0111" => segments<="1111000";
when "1000" => segments<="0000000";
when "1001" => segments<="0011000";
when "1010" => segments<="0001000";
when "1011" => segments<="0000011";
when "1100" => segments<="1000110";
when "1101" => segments<="0100001";
when "1110" => segments<="0000110";
when "1111" => segments<="0001110";

when others=>null;
end case;
case_val := case_val + 1;

when 3=>
-- Display digit 3
anode<="0111";

case dig_3 is
when "0000" => segments<="1000000";
when "0001" => segments<="1111001";
when "0010" => segments<="0100100";
when "0011" => segments<="0110000";
when "0100" => segments<="0011001";
when "0101" => segments<="0010010";
when "0110" => segments<="0000010";
when "0111" => segments<="1111000";
when "1000" => segments<="0000000";
when "1001" => segments<="0011000";
when "1010" => segments<="0001000";
when "1011" => segments<="0000011";
when "1100" => segments<="1000110";
when "1101" => segments<="0100001";
when "1110" => segments<="0000110";
when "1111" => segments<="0001110";

when others=>null;
end case;
case_val := 0;
when others=>null;
end case;


elsif state = 6 then

-- Display at the same time as the count value
case case_val is

when 0=>

-- Display digit 0

anode<="1110";
case dig_0 is
when "0000" => segments<="1000000";
when "0001" => segments<="1111001";
when "0010" => segments<="0100100";
when "0011" => segments<="0110000";
when "0100" => segments<="0011001";
when "0101" => segments<="0010010";
when "0110" => segments<="0000010";
when "0111" => segments<="1111000";
when "1000" => segments<="0000000";
when "1001" => segments<="0011000";
when "1010" => segments<="0001000";
when "1011" => segments<="0000011";
when "1100" => segments<="1000110";
when "1101" => segments<="0100001";
when "1110" => segments<="0000110";
when "1111" => segments<="0001110";

when others=>null;
end case;
case_val := case_val + 1; -- (space)

when 1=>
-- Display digit 1
anode<="1101";

case dig_1 is
when "0000" => segments<="1000000";
when "0001" => segments<="1111001";
when "0010" => segments<="0100100";
when "0011" => segments<="0110000";
when "0100" => segments<="0011001";
when "0101" => segments<="0010010";
when "0110" => segments<="0000010";
when "0111" => segments<="1111000";
when "1000" => segments<="0000000";
when "1001" => segments<="0011000";
when "1010" => segments<="0001000";
when "1011" => segments<="0000011";
when "1100" => segments<="1000110";
when "1101" => segments<="0100001";
when "1110" => segments<="0000110";
when "1111" => segments<="0001110";

when others=>null;
end case;
case_val := case_val + 1;

when 2=>
-- Display digit 2
anode<="1011";
case dig_2 is
when "0000" => segments<="1000000";
when "0001" => segments<="1111001";
when "0010" => segments<="0100100";
when "0011" => segments<="0110000";
when "0100" => segments<="0011001";
when "0101" => segments<="0010010";
when "0110" => segments<="0000010";
when "0111" => segments<="1111000";
when "1000" => segments<="0000000";
when "1001" => segments<="0011000";
when "1010" => segments<="0001000";
when "1011" => segments<="0000011";
when "1100" => segments<="1000110";
when "1101" => segments<="0100001";
when "1110" => segments<="0000110";
when "1111" => segments<="0001110";

when others=>null;
end case;
case_val := case_val + 1;

when 3=>
--  Display digit 3
anode<="0111";

case dig_3 is
when "0000" => segments<="1000000";
when "0001" => segments<="1111001";
when "0010" => segments<="0100100";
when "0011" => segments<="0110000";
when "0100" => segments<="0011001";
when "0101" => segments<="0010010";
when "0110" => segments<="0000010";
when "0111" => segments<="1111000";
when "1000" => segments<="0000000";
when "1001" => segments<="0011000";
when "1010" => segments<="0001000";
when "1011" => segments<="0000011";
when "1100" => segments<="1000110";
when "1101" => segments<="0100001";
when "1110" => segments<="0000110";
when "1111" => segments<="0001110";

when others=>null;
end case;
case_val := 0;
when others=>null;
end case;

-- State #7

elsif state = 7 then


case case_val is

when 0=>
-- Display digit 0
anode<="1110";
case dig_0 is
when "0000" => segments<="1000000";
when "0001" => segments<="1111001";
when "0010" => segments<="0100100";
when "0011" => segments<="0110000";
when "0100" => segments<="0011001";
when "0101" => segments<="0010010";
when "0110" => segments<="0000010";
when "0111" => segments<="1111000";
when "1000" => segments<="0000000";
when "1001" => segments<="0011000";
when "1010" => segments<="0001000";
when "1011" => segments<="0000011";
when "1100" => segments<="1000110";
when "1101" => segments<="0100001";
when "1110" => segments<="0000110";
when "1111" => segments<="0001110";

when others=>null;
end case;
case_val := case_val + 1; 

when 1=>
-- Display digit 0
anode<="1101";

case dig_1 is
when "0000" => segments<="1000000";
when "0001" => segments<="1111001";
when "0010" => segments<="0100100";
when "0011" => segments<="0110000";
when "0100" => segments<="0011001";
when "0101" => segments<="0010010";
when "0110" => segments<="0000010";
when "0111" => segments<="1111000";
when "1000" => segments<="0000000";
when "1001" => segments<="0011000";
when "1010" => segments<="0001000";
when "1011" => segments<="0000011";
when "1100" => segments<="1000110";
when "1101" => segments<="0100001";
when "1110" => segments<="0000110";
when "1111" => segments<="0001110";

when others=>null;
end case;
case_val := case_val + 1;

when 2=>
-- Display digit 2
anode<="1011";
case dig_2 is
when "0000" => segments<="1000000";
when "0001" => segments<="1111001";
when "0010" => segments<="0100100";
when "0011" => segments<="0110000";
when "0100" => segments<="0011001";
when "0101" => segments<="0010010";
when "0110" => segments<="0000010";
when "0111" => segments<="1111000";
when "1000" => segments<="0000000";
when "1001" => segments<="0011000";
when "1010" => segments<="0001000";
when "1011" => segments<="0000011";
when "1100" => segments<="1000110";
when "1101" => segments<="0100001";
when "1110" => segments<="0000110";
when "1111" => segments<="0001110";

when others=>null;
end case;
case_val := case_val + 1;

when 3=>
-- Display digit 3
anode<="0111";

case dig_3 is
when "0000" => segments<="1000000";
when "0001" => segments<="1111001";
when "0010" => segments<="0100100";
when "0011" => segments<="0110000";
when "0100" => segments<="0011001";
when "0101" => segments<="0010010";
when "0110" => segments<="0000010";
when "0111" => segments<="1111000";
when "1000" => segments<="0000000";
when "1001" => segments<="0011000";
when "1010" => segments<="0001000";
when "1011" => segments<="0000011";
when "1100" => segments<="1000110";
when "1101" => segments<="0100001";
when "1110" => segments<="0000110";
when "1111" => segments<="0001110";

when others=>null;
end case;
case_val := 0;
when others=>null;
end case;

end if;
end if;
end process;

-- Blink all LEDs

process (S_clk)
variable LED_st:integer:=1;
variable temp_count: integer:=0;

begin
if rising_edge(S_clk) then
temp_count := temp_count + 1;

if state = 5 and temp_count>190 then
-- Copy the value entered in the switches to a new variable 
if LED_st = 1 then
LED16 <= "1111111111111111";
LED_st := 0;
else
LED16 <= "0000000000000000";
LED_st := 1;
end if;
temp_count:=0;


-- State Change

end if;

end if;
end process;

end Behavioral;
