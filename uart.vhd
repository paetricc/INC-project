-- uart.vhd: UART controller - receiving part
-- Author(s): 
--
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

-------------------------------------------------
entity UART_RX is
port(	
  CLK: 	    in std_logic;
	RST: 	    in std_logic;
	DIN: 	    in std_logic;
	DOUT: 	    out std_logic_vector(7 downto 0);
	DOUT_VLD: 	out std_logic
);
end UART_RX;  

-------------------------------------------------
architecture behavioral of UART_RX is
	signal cnt1    : std_logic_vector(4 downto 0);
	signal cnt2    : std_logic_vector(3 downto 0);
	signal cnt     : std_logic;
	signal cnt_bit : std_logic;
	signal read_en : std_logic;
	signal cnt_en  : std_logic;
	signal vldt    : std_logic;
begin
	FSM: entity work.UART_FSM(behavioral)
    port map (
      CLK 	   => CLK,
      RST 	   => RST,
      DIN 	   => DIN,
      CNT     => cnt,
      CNT_BIT => cnt_bit,
		  READ_EN	=> read_en,
		  CNT_EN  => cnt_en,
		  VLDT		  => vldt
    );
	process (CLK) begin
	  if rising_edge(CLK) then
	    
	    -- DATA IS VALID --
			if vldt = '1' then
				DOUT_VLD <= '1';
			else
				DOUT_VLD <= '0';
			end if;
			
			-- COUNTER OF RISING EDGES --
			if cnt_en = '1' then
				cnt1 <= cnt1 + 1;
			else
				cnt1 <= "00000";
			end if;
			
			-- CHANGE TO DATA STATE --
			if cnt1 = "10000" then
				  cnt <= '1';
			else
				  cnt <= '0'; 
			end if;
			
			-- RESET READ BIT COUNTER --
			if read_en = '0' then
				cnt2 <= "0000";
			end if;
			
			-- CHANGE TO STOP STATE --
			if cnt2 = "1000" then
			  cnt_bit <= '1';
			else 
			  cnt_bit <= '0';
			end if;
			
			-- READ BITS --
			if read_en = '1' then
				if cnt1 = "01111" or cnt1 = "10111" then
					cnt1 <= "00000";
					case cnt2 is
						when "0000" => DOUT(0) <= DIN;
						when "0001" => DOUT(1) <= DIN;
						when "0010" => DOUT(2) <= DIN;
						when "0011" => DOUT(3) <= DIN;
						when "0100" => DOUT(4) <= DIN;
						when "0101" => DOUT(5) <= DIN;
						when "0110" => DOUT(6) <= DIN;
						when "0111" => DOUT(7) <= DIN;
						when others => null;
					end case;
					cnt2 <= cnt2 + 1;
				end if;
			end if;
		end if;
	end process;
end behavioral;