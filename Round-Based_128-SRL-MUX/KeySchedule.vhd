------------------------------------------------------------------------
-- Engineer:    Dalmasso Loic
-- Create Date: 06/12/2017
-- Module Name: KeySchedule - Behavioral
-- Description:
--      Create new round key
--      Input data - Cipherkey : 128bits of Cipherkey
--      Input data - RoundCounter : 5bits of Roundcounter
--      Output data - NewKey : 128bits of Keystate
------------------------------------------------------------------------

-- 12 LUT

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;


ENTITY KeySchedule is

PORT( KeyState    : IN STD_LOGIC_VECTOR(127 DOWNTO 0);
      RoundCounter: IN STD_LOGIC_VECTOR(4 downto 0);

      NewKey      : OUT STD_LOGIC_VECTOR(127 DOWNTO 0)
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

end Behavioral;