------------------------------------------------------------------------
-- Engineer:	Dalmasso Loic
-- Create Date:	25/12/2017
-- Module Name:	Round - Behavioral
-- Description:
--		Implement one round of PRESENT encryption algorithm
--		Input data - Plaintext : 64 bits of plaintext
-- 		Input data - RoundKey  : 64 bits of round key
--		Output data - Ciphertext : 64 bits of ciphertext
------------------------------------------------------------------------

-- 96 LUT

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;

ENTITY Round is

PORT( LastRound  : IN STD_LOGIC;
	  Plaintext  : IN STD_LOGIC_VECTOR(63 DOWNTO 0);
	  RoundKey	 : IN STD_LOGIC_VECTOR(63 DOWNTO 0);
	  Ciphertext : OUT STD_LOGIC_VECTOR(63 DOWNTO 0)
	);

-- No optimization  
attribute dont_touch : string;
attribute dont_touch of Round : entity is "true";

END Round;

ARCHITECTURE Behavioral of Round is

------------------------------------------------------------------------
-- Component Declarations
------------------------------------------------------------------------
COMPONENT SubCells is

PORT( SubCells_in : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
	  SubCells_out : OUT STD_LOGIC_VECTOR(3 DOWNTO 0)
	);

END COMPONENT;


COMPONENT PermBits is

PORT( PermBits_in : IN STD_LOGIC_VECTOR(63 DOWNTO 0);
	  PermBits_out: OUT STD_LOGIC_VECTOR(63 DOWNTO 0)
	);

END COMPONENT;


------------------------------------------------------------------------
-- Signal Declarations
------------------------------------------------------------------------
signal AddRK_output 		: STD_LOGIC_VECTOR(63 DOWNTO 0) := (others => '0');		-- AddRoundKey result
signal SubCells_output 		: STD_LOGIC_VECTOR(63 DOWNTO 0) := (others => '0');		-- SBOX result
signal PermBit_output 		: STD_LOGIC_VECTOR(63 DOWNTO 0) := (others => '0');		-- SBOX result

-- No optimization  
attribute dont_touch of AddRK_output 	: signal is "true";
attribute dont_touch of SubCells_output : signal is "true";
attribute dont_touch of PermBit_output  : signal is "true";

----------------------------------------------------------------------
-- Module Implementation
------------------------------------------------------------------------
begin

-- 64 LUT
-----------------
-- AddRoundKey --
-----------------
AddRK_output <= Plaintext XOR RoundKey;


-- 16 * 2 LUT
--------------------------
-- 16 SBOXes generation --
--------------------------
SBOXS: for i in 15 downto 0 generate
	SBOX : SubCells port map (AddRK_output((4*i)+3 downto (4*i)), SubCells_output((4*i)+3 downto (4*i)));
end generate;


-- 0 LUT
--------------
-- PermBits --
--------------
PERMB : PermBits port map (SubCells_output, PermBit_output);

Ciphertext <= PermBit_output when LastRound = '0' else AddRK_output;

end Behavioral;