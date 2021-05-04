-- uart_fsm.vhd: UART controller - finite state machine
-- Author(s): xbartu11
--
library ieee;
use ieee.std_logic_1164.all;

-------------------------------------------------
entity UART_FSM is
port(
   CLK     : in std_logic;
   RST     : in std_logic;
   DIN     : in std_logic;
   CNT     : in std_logic;
   CNT_BIT : in std_logic;
   READ_EN : out std_logic;
   CNT_EN  : out std_logic;
   VLDT    : out std_logic
   );
end entity UART_FSM;

-------------------------------------------------
architecture behavioral of UART_FSM is
   type STATES is (START, FIRST, DATA, STOP, VALID);
   signal prev_state : STATES;
   signal next_state : STATES;
begin
   
   -- STATE REG --
   pstate_reg: process (RST, CLK) begin
    if RST = '1' then
      prev_state <= START;
    elsif rising_edge(CLK) then
      prev_state <= next_state;
    end if;  
  end process;
   
   -- NEXT STATE LOGIC --
   nstate_logic: process (prev_state, DIN, CNT, CNT_BIT) begin
    case prev_state is
      when START =>
        if DIN = '0' then
          next_state <= FIRST;
        end if;
      when FIRST =>
        if CNT = '1' then
          next_state <= DATA;
        end if;
      when DATA =>
        if CNT_BIT = '1' then
          next_state <= STOP;
        end if;
      when STOP =>
        if DIN = '1' then
          next_state <= VALID;
        end if;
      when VALID =>
        next_state <= START;
      when others => null;
    end case;
  end process;
   
  -- OUTPUT LOGIC --
  output_logic: process(prev_state) begin
    READ_EN <= '0';
    CNT_EN <= '0';
    VLDT <= '0';
    case prev_state is
      when FIRST =>
        CNT_EN <= '1';
      when DATA =>
        READ_EN <= '1';
        CNT_EN <= '1';
      when STOP =>
        CNT_EN <= '1';
      when VALID =>
        VLDT <= '1';
      when others => null;
      end case;
  end process;
end behavioral;