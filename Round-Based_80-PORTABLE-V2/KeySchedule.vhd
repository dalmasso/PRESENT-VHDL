------------------------------------------------------------------------
-- Engineer:    Dalmasso Loic
-- Create Date: 15/05/2018
-- Module Name: KeySchedule - Behavioral
-- Description:
--      Create new round key
--      Input data - Reset : reset block
--      Input data - CipherKey : 80bits of CipherKey
--      Input data - KeyState : 80bits of KeyState
--      Input data - RoundCounter : 5bits +1 of Roundcounter
--      Output data - NewKey : 80bits of Keystate
--      Output data - NewRC : 5bits +1 of Roundcounter updated
--      Output data - RoundKey : 64bits of Roundkey
------------------------------------------------------------------------

-- 99 LUT

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;


ENTITY KeySchedule is

PORT( Reset 	  : IN STD_LOGIC;
      CipherKey   : IN STD_LOGIC_VECTOR(79 DOWNTO 0);
      KeyState    : IN STD_LOGIC_VECTOR(79 DOWNTO 0);
      RoundCounter: IN STD_LOGIC_VECTOR(5 downto 0);

      NewKey      : OUT STD_LOGIC_VECTOR(79 DOWNTO 0);
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

PORT( SubCells_in : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
      SubCells_out : OUT STD_LOGIC_VECTOR(3 DOWNTO 0)
    );

END COMPONENT;

------------------------------------------------------------------------
-- Signal Declarations
------------------------------------------------------------------------
signal KeySBOX_out : STD_LOGIC_VECTOR(3 downto 0)  := (others => '0');
signal MyKey 	   : STD_LOGIC_VECTOR(79 DOWNTO 0) := (others => '0');
signal MyRC		   : STD_LOGIC_VECTOR(5 DOWNTO 0)  := (others => '0');

-- No optimization  
attribute dont_touch of KeySBOX_out : signal is "true";
attribute dont_touch of MyKey 		: signal is "true";
attribute dont_touch of MyRC 		: signal is "true";
------------------------------------------------------------------------
-- Module Implementation
------------------------------------------------------------------------
begin

-- Select inputs : Cipherkey or Previous KeyState
MyKey <= CipherKey when Reset='0' else KeyState;

-- Select inputs : RoundConstant init or Previous RoundConstant
MyRC <= "000001" when Reset='0' else RoundCounter;

-- SBOX the new left-most 4 bits
SBOX : SubCells port map (MyKey(18 downto 15), KeySBOX_out);

-- New CipherKey
NewKey <= KeySBOX_out & MyKey(14 downto 0) & MyKey(79 downto 39) & (MyKey(38 downto 34) XOR MyRC(4 downto 0)) & MyKey(33 downto 19);

-- New RoundCounter
NewRC(5) <= MyRC(5) XOR ( MyRC(4) AND MyRC(3) AND MyRC(2) AND MyRC(1) AND MyRC(0) );
NewRC(4) <= MyRC(4) XOR ( MyRC(3) AND MyRC(2) AND MyRC(1) AND MyRC(0) );
NewRC(3) <= MyRC(3) XOR ( MyRC(2) AND MyRC(1) AND MyRC(0) );
NewRC(2) <= MyRC(2) XOR ( MyRC(1) AND MyRC(0) );
NewRC(1) <= MyRC(1) XOR MyRC(0);
NewRC(0) <= not MyRC(0);

-- Extraction of RoundKey BEFORE update
RoundKey <= MyKey(79 downto 16);

end Behavioral;