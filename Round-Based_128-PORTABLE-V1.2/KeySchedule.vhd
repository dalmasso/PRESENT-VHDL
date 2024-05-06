------------------------------------------------------------------------
-- Engineer:    Dalmasso Loic
-- Create Date: 06/12/2017
-- Module Name: KeySchedule - Behavioral
-- Description:
--      Create new round key
--      Input data - Cipherkey : 128bits of Cipherkey
--      Input data - RoundCounter : 5bits +1 of Roundcounter
--      Output data - NewKey : 128bits of Keystate
--      Output data - NewRC : 5bits +1 of Roundcounter updated
--      Output data - RoundKey : 64bits of Roundkey
------------------------------------------------------------------------

-- 12 LUT

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;


ENTITY KeySchedule is

PORT( KeyState    : IN STD_LOGIC_VECTOR(127 DOWNTO 0);
      RoundCounter: IN STD_LOGIC_VECTOR(5 downto 0);

      NewKey      : OUT STD_LOGIC_VECTOR(127 DOWNTO 0);
      NewRC       : OUT STD_LOGIC_VECTOR(5 downto 0);
      RoundKey    : OUT STD_LOGIC_VECTOR(63 DOWNTO 0)
    );

-- No optimization 
attribute dont_touch : string;
attribute dont_touch of KeySchedule : entity is "true";

END KeySchedule;

ARCHITECTURE Behavioral of KeySchedule is

------------------------------------------------------------------------
-- Component Declarations
------------------------------------------------------------------------
COMPONENT SubCells is

PORT( SubCells_in  : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
      SubCells_out : OUT STD_LOGIC_VECTOR(3 DOWNTO 0)
    );

END COMPONENT;

------------------------------------------------------------------------
-- Signal Declarations
------------------------------------------------------------------------
signal KeySBOX_out1 : STD_LOGIC_VECTOR(3 downto 0)   := (others => '0');
signal KeySBOX_out2 : STD_LOGIC_VECTOR(3 downto 0)   := (others => '0');

-- No optimization 
attribute dont_touch of KeySBOX_out1 : signal is "true";
attribute dont_touch of KeySBOX_out2 : signal is "true";

------------------------------------------------------------------------
-- Module Implementation
------------------------------------------------------------------------
begin

-- SBOX the new left-most 8 bits
SBOX1 : SubCells port map (KeyState(66 downto 63), KeySBOX_out1);
SBOX2 : SubCells port map (KeyState(62 downto 59), KeySBOX_out2);

-- New CipherKey
NewKey <= KeySBOX_out1 & KeySBOX_out2 & KeyState(58 downto 6) & (KeyState(5 downto 1) XOR RoundCounter(4 downto 0)) & KeyState(0) & KeyState(127 downto 67);

-- New RoundCounter
NewRC(5) <= RoundCounter(5) XOR ( RoundCounter(4) AND RoundCounter(3) AND RoundCounter(2) AND RoundCounter(1) AND RoundCounter(0) );
NewRC(4) <= RoundCounter(4) XOR ( RoundCounter(3) AND RoundCounter(2) AND RoundCounter(1) AND RoundCounter(0) );
NewRC(3) <= RoundCounter(3) XOR ( RoundCounter(2) AND RoundCounter(1) AND RoundCounter(0) );
NewRC(2) <= RoundCounter(2) XOR ( RoundCounter(1) AND RoundCounter(0) );
NewRC(1) <= RoundCounter(1) XOR RoundCounter(0);
NewRC(0) <= not RoundCounter(0);

-- Extraction of RoundKey BEFORE update
RoundKey <= KeyState(127 DOWNTO 64);

end Behavioral;