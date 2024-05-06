------------------------------------------------------------------------
-- Engineer:    Dalmasso Loic
-- Create Date: 09/03/2018
-- Module Name: Data_Key_RC_Store - Behavioral
-- Description:
--      Save all data / key / round counter
--      Input data - Clk : clock for KeySchedule
--      Input data - Reset : reset block
--      Input data - LastRound : Trigger for the last round
--      Input data - Cipherkey : 80bits of Cipherkey
--      Input data - Key_in : 80bits of Keystate
--      Input data - Plaintext : 64bits of Plaintext
--      Input data - Data_in : 64bits of Intermediate plaintext
--      Input data - RC_in : 5bit round counter state
--      Output data - Key_out : 80bits of Keystate
--      Output data - Data_out : 64bits of Intermediate plaintext
--      Output data - RC_out : 5bit round counter state
------------------------------------------------------------------------

-- 150 LUT (LUTRAM)

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;

Library UNISIM;
use UNISIM.vcomponents.all;

ENTITY Data_Key_RC_Store is

PORT( Clk      : IN STD_LOGIC;
      Reset    : IN STD_LOGIC;
      LastRound: IN STD_LOGIC;

      CipherKey: IN STD_LOGIC_VECTOR(79 DOWNTO 0);
      Key_in   : IN STD_LOGIC_VECTOR(79 DOWNTO 0);

      Plaintext: IN STD_LOGIC_VECTOR(63 DOWNTO 0);
      Data_in  : IN STD_LOGIC_VECTOR(63 DOWNTO 0);
  
      RC_in    : IN STD_LOGIC_VECTOR(4 downto 0);

      Key_out  : OUT STD_LOGIC_VECTOR(79 DOWNTO 0);
      Data_out : OUT STD_LOGIC_VECTOR(63 DOWNTO 0);
      RC_out   : OUT STD_LOGIC_VECTOR(4 downto 0)    
    );

-- No optimization 
attribute dont_touch : string;
attribute dont_touch of Data_Key_RC_Store : entity is "true";

END Data_Key_RC_Store;


ARCHITECTURE Behavioral of Data_Key_RC_Store is

------------------------------------------------------------------------
-- Signal Declarations
------------------------------------------------------------------------
signal MyKey      : STD_LOGIC_VECTOR(79 downto 0) := (others => '0');
signal MyFirstPTI : STD_LOGIC_VECTOR(63 downto 0) := (others => '0');
signal MyPTI      : STD_LOGIC_VECTOR(63 downto 0) := (others => '0');
signal MyRC       : STD_LOGIC_VECTOR(4 downto 0)  := (others => '0'); 
signal InvLastRound: STD_LOGIC := '0';

-- No optimization 
attribute dont_touch of MyKey      : signal is "true";
attribute dont_touch of MyFirstPTI : signal is "true";
attribute dont_touch of MyPTI      : signal is "true";
attribute dont_touch of MyRC       : signal is "true";
attribute dont_touch of InvLastRound : signal is "true";

------------------------------------------------------------------------
-- Module Implementation
------------------------------------------------------------------------
begin

-- Inv LastRound
InvLastRound <= not LastRound when Reset = '1' else '1';

------------------------
-- 80-bit Key storage --
------------------------
KEYSTORE: for i in 79 downto 0 generate
  MUXKEY: MUXF7 port map (MyKey(i), CipherKey(i), Key_in(i), Reset);

  KEYST : SRL16E generic map (INIT => X"0000")
                 port map (Key_out(i), '0', '0', '0', '0', InvLastRound, Clk, MyKey(i));
end generate;


-------------------------
-- 64-bit Data storage --
-------------------------

MyFirstPTI <= Plaintext XOR CipherKey(79 downto 16);

DATASTORE: for i in 63 downto 0 generate
  MUXDAT: MUXF7 port map (MyPTI(i), MyFirstPTI(i), Data_in(i), Reset);

  DATAST : SRL16E generic map (INIT => X"0000")
                  port map (Data_out(i), '0', '0', '0', '0', InvLastRound, Clk, MyPTI(i));
end generate;


------------------------------------------
-- 5-bit RoundCounter storage ("00000") --
------------------------------------------
MUXRC4: MUXF7 port map (MyRC(4), '0', RC_in(4), Reset);
MUXRC3: MUXF7 port map (MyRC(3), '0', RC_in(3), Reset);
MUXRC2: MUXF7 port map (MyRC(2), '0', RC_in(2), Reset);
MUXRC1: MUXF7 port map (MyRC(1), '0', RC_in(1), Reset);
MUXRC0: MUXF7 port map (MyRC(0), '0', RC_in(0), Reset);

RCSTORE: for i in 4 downto 0 generate
  RCST : SRL16E generic map (INIT => X"0000")
                port map (RC_out(i), '0', '0', '0', '0', InvLastRound, Clk, MyRC(i));
end generate;

end Behavioral;