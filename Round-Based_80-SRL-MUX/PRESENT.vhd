------------------------------------------------------------------------
-- Engineer:  Dalmasso Loic
-- Create Date: 25/12/2017
-- Module Name: PRESENT - Behavioral
-- Description:
--      Implement one round of PRESENT encryption algorithm
--      Input data - Clk : clock for PRESENT
--      Input data - Reset : reset PRESENT
--      Input data - Plaintext : 64 bits of plaintext
--      Input data - CipherKey : 80 bits of Cipher key (primary key)
--      Output data - Ciphertext : 64 bits of ciphertext
--      Output data - EndOfPRESENT : siganl to identify end of PRESENT algorithm
------------------------------------------------------------------------

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;

ENTITY PRESENT is

PORT( Clk           : IN STD_LOGIC;
      Reset         : IN STD_LOGIC;
      Plaintext     : IN STD_LOGIC_VECTOR(63 DOWNTO 0);
      CipherKey     : IN STD_LOGIC_VECTOR(79 DOWNTO 0);
      Ciphertext    : OUT STD_LOGIC_VECTOR(63 DOWNTO 0);
      EndOfPRESENT  : OUT STD_LOGIC
    );

-- No optimization  
attribute dont_touch : string;
attribute dont_touch of PRESENT : entity is "true";

END PRESENT;

ARCHITECTURE Behavioral of PRESENT is

------------------------------------------------------------------------
-- Component Declarations
------------------------------------------------------------------------
COMPONENT Round is

PORT( Plaintext  : IN STD_LOGIC_VECTOR(63 DOWNTO 0);
      RoundKey   : IN STD_LOGIC_VECTOR(63 DOWNTO 0);
      Ciphertext : OUT STD_LOGIC_VECTOR(63 DOWNTO 0)
    );

END COMPONENT;


COMPONENT KeySchedule is

PORT( KeyState    : IN STD_LOGIC_VECTOR(79 DOWNTO 0);
      RoundCounter: IN STD_LOGIC_VECTOR(4 DOWNTO 0);

      NewKey      : OUT STD_LOGIC_VECTOR(79 DOWNTO 0)
    );

END COMPONENT;


COMPONENT Counter is

PORT( RoundCounter: IN STD_LOGIC_VECTOR(4 downto 0);
      NewRC       : OUT STD_LOGIC_VECTOR(4 downto 0)
    );

END COMPONENT;


COMPONENT Data_Key_RC_Store is

PORT( Clk      : IN STD_LOGIC;
      Reset    : IN STD_LOGIC;
      LastRound: IN STD_LOGIC;

      CipherKey: IN STD_LOGIC_VECTOR(79 DOWNTO 0);
      Key_in   : IN STD_LOGIC_VECTOR(79 DOWNTO 0);

      Plaintext: IN STD_LOGIC_VECTOR(63 DOWNTO 0);
      Data_in  : IN STD_LOGIC_VECTOR(63 DOWNTO 0);
  
      RC_in    : IN STD_LOGIC_VECTOR(4 DOWNTO 0);

      Key_out  : OUT STD_LOGIC_VECTOR(79 DOWNTO 0);
      Data_out : OUT STD_LOGIC_VECTOR(63 DOWNTO 0);
      RC_out   : OUT STD_LOGIC_VECTOR(4 DOWNTO 0)    
    );

END COMPONENT;


------------------------------------------------------------------------
-- Signal Declarations
------------------------------------------------------------------------
signal Keystate : STD_LOGIC_VECTOR(79 DOWNTO 0) := (others => '0');
signal NewKey   : STD_LOGIC_VECTOR(79 DOWNTO 0) := (others => '0');

signal RCstate  : STD_LOGIC_VECTOR(4 DOWNTO 0)  := (others => '0');
signal NewRC    : STD_LOGIC_VECTOR(4 DOWNTO 0)  := (others => '0');

signal NewPlain : STD_LOGIC_VECTOR(63 DOWNTO 0) := (others => '0');
signal NewCipher: STD_LOGIC_VECTOR(63 DOWNTO 0) := (others => '0');
signal LastRound: STD_LOGIC := '0';

-- No optimization  
attribute dont_touch of Keystate : signal is "true";
attribute dont_touch of NewKey   : signal is "true";
attribute dont_touch of RCstate  : signal is "true";
attribute dont_touch of NewRC    : signal is "true";
attribute dont_touch of NewPlain : signal is "true";
attribute dont_touch of NewCipher: signal is "true";
attribute dont_touch of LastRound: signal is "true";

------------------------------------------------------------------------
-- Module Implementation
------------------------------------------------------------------------
begin

-----------------
-- KeySchedule --
-----------------
KEYSCH : KeySchedule port map (NewKey, RCstate, Keystate);

-------------
-- Counter --
-------------
CPT : Counter port map (NewRC, RCstate);

-----------
-- Round --
-----------
ROUNDS : Round port map (NewPlain, Keystate(79 downto 16), NewCipher);

-------------
-- Storage --
-------------
STORE : Data_Key_RC_Store port map (Clk, Reset, LastRound, CipherKey, Keystate, Plaintext, NewCipher, RCstate, NewKey, NewPlain, NewRC);

-------------------------
-- Final round trigger --
-------------------------
LastRound <= '1' when RCstate = "11111" else '0'; -- 31

---------------------------
-- Send final ciphertext --
---------------------------
Ciphertext <= NewCipher;
EndOfPRESENT <= LastRound;

end Behavioral;