------------------------------------------------------------------------
-- Engineer:    Dalmasso Loic
-- Create Date: 06/12/2017
-- Module Name: TOP_PRESENT - Behavioral
-- Description:
--    Implement PRESENT algorithm & UART to send/receive data
--    Block - PRESENT : crypto algorithm
--    Block - UART: use to communicate with user 
------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;


ENTITY TOP_PRESENT_128 is

PORT( Clk_100 : IN STD_LOGIC;
      Reset   : IN STD_LOGIC;
      RX      : IN STD_LOGIC;
      TX      : OUT STD_LOGIC

      -- For attack
      --trigger : OUT STD_LOGIC
    );

END TOP_PRESENT_128;


architecture Behavioral of TOP_PRESENT_128 is

------------------------------------------------------------------------
-- Component Declarations
------------------------------------------------------------------------
COMPONENT Uart IS
  GENERIC(
    clk_freq  : INTEGER   := 50_000_000;                  -- frequency of system clock in Hertz
    baud_rate : INTEGER   := 19_200;                      -- data link baud rate in bits/second
    os_rate   : INTEGER   := 16;                          -- oversampling rate to find center of receive bits (in samples per baud period)
    d_width   : INTEGER   := 8;                           -- data bus width
    parity    : INTEGER   := 1;                           -- 0 for no parity, 1 for parity
    parity_eo : STD_LOGIC := '0');                        -- '0' for even, '1' for odd parity

  PORT(
    clk       : IN STD_LOGIC;                             -- system clock
    reset_n   : IN STD_LOGIC;                             -- ascynchronous reset
    tx_ena    : IN STD_LOGIC;                             -- initiate transmission
    tx_data   : IN STD_LOGIC_VECTOR(d_width-1 DOWNTO 0);  -- data to transmit
    rx        : IN STD_LOGIC;                             -- receive pin
    rx_busy   : OUT STD_LOGIC;                            -- data reception in progress
    rx_error  : OUT STD_LOGIC;                            -- start, parity, or stop bit error detected
    rx_data   : OUT STD_LOGIC_VECTOR(d_width-1 DOWNTO 0); -- data received
    tx_busy   : OUT STD_LOGIC;                            -- transmission in progress
    tx        : OUT STD_LOGIC);                           -- transmit pin
END COMPONENT;


COMPONENT PRESENT is

PORT( Clk           : IN STD_LOGIC;
      Reset         : IN STD_LOGIC;
      Plaintext     : IN STD_LOGIC_VECTOR(63 DOWNTO 0);
      CipherKey     : IN STD_LOGIC_VECTOR(127 DOWNTO 0);
      Ciphertext    : OUT STD_LOGIC_VECTOR(63 DOWNTO 0);
      EndOfPRESENT  : OUT STD_LOGIC
    );

END COMPONENT;


COMPONENT clk_wiz_0 is

PORT ( clk_in1    : IN STD_ULOGIC;
       clk_out1_ce: IN STD_ULOGIC;
       clk_out1   : OUT STD_ULOGIC;
       resetn     : in std_ULOGIC
      );

END COMPONENT;


COMPONENT ClockEnableControler is

GENERIC( DIVIDER  : INTEGER := 1);

PORT( Clock:  IN STD_LOGIC;
      Reset:  IN STD_LOGIC;
      ClockEnableCTRL : OUT STD_LOGIC
    );

END COMPONENT;

------------------------------------------------------------------------
-- Type Declarations
------------------------------------------------------------------------
TYPE State_Machine is (INIT, WAIT_KEY, WAIT_PRESENT, WAIT_TX, TRANSMIT, NEXT_TX);

------------------------------------------------------------------------
-- Constant Declarations
------------------------------------------------------------------------
constant DATA_BYTE_LENGTH_RX      : INTEGER := 24;
constant DATA_BYTE_LENGTH_TX      : INTEGER := 8;

------------------------------------------------------------------------
-- Signal Declarations
------------------------------------------------------------------------
-- Control UART
signal tx_ena                  : STD_LOGIC := '0';                                 -- initiate transmission
signal tx_data                 : STD_LOGIC_VECTOR(7 DOWNTO 0) := (others=>'0');    -- data to transmit
signal rx_busy                 : STD_LOGIC := '0';                                 -- data reception in progress
signal rx_error                : STD_LOGIC := '0';                                 -- start, parity, or stop bit error detected
signal rx_data                 : STD_LOGIC_VECTOR(7 DOWNTO 0) := (others=>'0');    -- data received
signal tx_busy                 : STD_LOGIC := '0';                                 -- transmission in progress
signal reset_cntr              : INTEGER range 0 to 200000 := 0;                   -- this counter counts the amount of time paused in the UART reset state
signal uart_reset              : STD_LOGIC := '0';

-- Control TOP PRESENT
signal state, next_state : State_Machine;

-- Control data byte from/to UART : MSB first, LSB last
signal cpt_RX        : INTEGER range 0 to DATA_BYTE_LENGTH_RX := DATA_BYTE_LENGTH_RX;
signal reset_cpt_RX  : STD_LOGIC := '0';

signal cpt_TX        : INTEGER range 0 to DATA_BYTE_LENGTH_TX := DATA_BYTE_LENGTH_TX;
signal reset_cpt_TX  : STD_LOGIC := '0';

-- Control PRESENT
-- 192 bits : KEY = 128 bits (191 downto 64) + PTI = 64 bits (63 downto 0)
signal PTI_Key         : STD_LOGIC_VECTOR(191 DOWNTO 0); 
signal Ciphertext      : STD_LOGIC_VECTOR(63 DOWNTO 0);
signal triggerPRESENT  : STD_LOGIC;
signal synchro_PRESENT : STD_LOGIC;
signal reset_PRESENT   : STD_LOGIC;

-- Crypto Clock
signal CryptoClock       : STD_LOGIC :='0';
signal CryptoClock_RST   : STD_LOGIC :='0';
signal CryptoClockBUF_CE : STD_LOGIC :='0';

--constant test_key : std_logic_vector(127 downto 0) := X"00000000000000000000000000000000";
--constant test_pti : std_logic_vector(63 downto 0)  := X"0000000000000000";
--constant test_cto : std_logic_vector(63 downto 0)  := X"96DB702A2E6900AF";

------------------------------------------------------------------------
-- Module Implementation
------------------------------------------------------------------------
begin

-------------------
-- Reset control --
-------------------
uart_reset <= not(Reset);


------------------
-- UART control --
------------------
UART1 : Uart generic map(100000000,9600,16,8,0,'0')
        port map (Clk_100, uart_reset, tx_ena,tx_data,RX,rx_busy,rx_error,rx_data,tx_busy, TX);


------------------------------------------
-- TOP PRESENT control : State Register --
------------------------------------------

process (Clk_100, uart_reset)
begin
    if uart_reset = '0' then
        state <= INIT;

    elsif rising_edge(Clk_100) then
        state <= next_state;
      
    end if;
end process;


--------------------------------------
-- TOP PRESENT control : Next State --
--------------------------------------
process (state, tx_busy, cpt_RX, cpt_TX, triggerPRESENT)
begin
   case state is

    when INIT         =>   next_state <= WAIT_KEY;

    when WAIT_KEY     =>  if cpt_RX = 0 then     
                            next_state <= WAIT_PRESENT;
                          else
                            next_state <= WAIT_KEY;                   
                          end if; 

    when WAIT_PRESENT =>  if triggerPRESENT = '1' then
                            next_state <= WAIT_TX;
                          else
                            next_state <= WAIT_PRESENT;
                          end if;

    when WAIT_TX      =>  if tx_busy = '0' then
                            next_state <= TRANSMIT;
                          else
                            next_state <= WAIT_TX;                   
                          end if;   
                        
    when TRANSMIT     =>  if tx_busy = '1' then
                            next_state <= NEXT_TX;
                          else
                            next_state <= TRANSMIT;                   
                          end if;   
                                                                
    when NEXT_TX      =>  if cpt_TX = 0 then
                            next_state <= INIT;
                          else
                            next_state <= WAIT_TX;                   
                          end if; 
                            
    when others       =>  next_state <= INIT;
  end case;
end process;


------------------------------------
-- UART RX : Next byte to receive --
------------------------------------

reset_cpt_RX <= '0' when state = INIT else '1';
                
process (reset_cpt_RX, rx_busy)
begin
    if reset_cpt_RX = '0' then
      cpt_RX <= DATA_BYTE_LENGTH_RX;
        
    elsif falling_edge(rx_busy) then

      if cpt_RX > 0 then
        cpt_RX <= cpt_RX - 1;

      else
        cpt_RX <= cpt_RX;

      end if;
    end if;
end process;


process(uart_reset, rx_busy)
begin

  if uart_reset = '0' then
    PTI_Key <= (others => '0');
  
  elsif falling_edge(rx_busy) then
    PTI_Key <= PTI_Key(183 downto 0) & rx_data; -- Left Shift
    
  end if;
end process;


---------------------------------
-- UART TX : Next byte to send --
---------------------------------
reset_cpt_TX <= '0' when state = INIT else '1';

process (reset_cpt_TX, tx_busy)
begin
    if reset_cpt_TX = '0' then
      cpt_TX <= DATA_BYTE_LENGTH_TX;
        
    elsif rising_edge(tx_busy) then

      if cpt_TX > 0 then
        cpt_TX <= cpt_TX - 1;

      else
        cpt_TX <= cpt_TX;

      end if;
    end if;
end process;


process(Clk_100, uart_reset)
begin
  
  if uart_reset = '0' then
    tx_data <= (others => '0');
  
  elsif rising_edge(Clk_100) then

    case cpt_TX is
      when 8       =>  tx_data <= CipherText(63 downto 56);
      when 7       =>  tx_data <= CipherText(55 downto 48);
      when 6       =>  tx_data <= CipherText(47 downto 40);
      when 5       =>  tx_data <= CipherText(39 downto 32);
      when 4       =>  tx_data <= CipherText(31 downto 24);
      when 3       =>  tx_data <= CipherText(23 downto 16);
      when 2       =>  tx_data <= CipherText(15 downto 8);
      when 1       =>  tx_data <= CipherText(7 downto 0);
      when others  =>  tx_data <= (others => '0');
    end case;
    
  end if;
end process;

tx_ena <= '1' when state = TRANSMIT else '0';


---------------------
-- PRESENT control --
---------------------

-- Synchro Reset PRESENT
process(Clk_100)
begin

  if rising_edge(Clk_100) then

    if state = INIT or state = WAIT_KEY then
      synchro_PRESENT <= '0';
    else
      synchro_PRESENT <= '1';
  
    end if;  
  end if;
end process;


process(CryptoClock)
begin

  if rising_edge(CryptoClock) then
    reset_PRESENT <= synchro_PRESENT;

  end if;
end process;


CryptoClock_RST <= '1';
CLK_SYS : clk_wiz_0 port map (Clk_100, CryptoClockBUF_CE, CryptoClock, CryptoClock_RST);

CLOCKCTRL: ClockEnableControler generic map (1)
port map(Clk_100, CryptoClock_RST, CryptoClockBUF_CE);

CRYPTO : PRESENT port map (CryptoClock, reset_PRESENT, PTI_Key(63 downto 0), PTI_Key(191 downto 64), CipherText, triggerPRESENT);


------------------------
-- Trigger for attack --
------------------------
--process(Clk_100, reset_PRESENT)
--begin
--    if reset_PRESENT = '0' then
--      trigger <= '0';
    
--    elsif rising_edge(Clk_100) then
  
--      if state = WAIT_PRESENT and triggerPRESENT = '0' then
--        trigger <= '1';
--      else
--        trigger <= '0';
--      end if;
    
--    end if;
--end process;

end Behavioral;