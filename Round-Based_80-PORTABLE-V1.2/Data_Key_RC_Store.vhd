------------------------------------------------------------------------
-- Engineer:    Dalmasso Loic
-- Create Date: 09/03/2018
-- Module Name: Data_Key_RC_Store - Behavioral
-- Description:
--      Save all data / key / round counter
--      Input data - Clk : clock for KeySchedule
--      Input data - Reset : reset block
--      Input data - Cipherkey : 80bits of Cipherkey
--      Input data - Key_in : 80bits of Keystate
--      Input data - Plaintext : 64bits of Plaintext
--      Input data - Data_in : 64bits of Intermediate plaintext
--      Input data - RC_in : 5bit round counter state + 1bit trig end
--      Output data - Key_out : 80bits of Keystate
--      Output data - Data_out : 64bits of Intermediate plaintext
--      Output data - RC_out : 5bit round counter state + 1bit trig end
------------------------------------------------------------------------

-- 73 LUT
-- 150 FF

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;

ENTITY Data_Key_RC_Store is

PORT( Clk      : IN STD_LOGIC;
      Reset    : IN STD_LOGIC;

      CipherKey: IN STD_LOGIC_VECTOR(79 DOWNTO 0);
      Key_in   : IN STD_LOGIC_VECTOR(79 DOWNTO 0);

      Plaintext: IN STD_LOGIC_VECTOR(63 DOWNTO 0);
      Data_in  : IN STD_LOGIC_VECTOR(63 DOWNTO 0);
  
      RC_in    : IN STD_LOGIC_VECTOR(5 downto 0);

      Key_out  : OUT STD_LOGIC_VECTOR(79 DOWNTO 0);
      Data_out : OUT STD_LOGIC_VECTOR(63 DOWNTO 0);
      RC_out   : OUT STD_LOGIC_VECTOR(5 downto 0)    
    );

-- No optimization 
attribute dont_touch : string;
attribute dont_touch of Data_Key_RC_Store : entity is "true";

END Data_Key_RC_Store;


ARCHITECTURE Behavioral of Data_Key_RC_Store is

------------------------------------------------------------------------
-- Module Implementation
------------------------------------------------------------------------
begin


------------------------
-- 80-bit Key storage --
------------------------
process(Clk)
begin

  if rising_edge(Clk) then
    
    if Reset = '0' then
      Key_out <= CipherKey;
    else
      Key_out <= Key_in;
    end if;

  end if;
end process;


-------------------------
-- 64-bit Data storage --
-------------------------
process(Clk)
begin

  if rising_edge(Clk) then
    
    if Reset = '0' then
      Data_out <= Plaintext;
    else
      Data_out <= Data_in;
    end if;

  end if;
end process;


--------------------------------------------------------------
-- 5-bit RoundCounter storage + 1-bit for round number (32) --
--------------------------------------------------------------
process(Clk)
begin

  if rising_edge(Clk) then
    
    if Reset = '0' then
      RC_out <= "000001";
    else
      RC_out <= RC_in;
    end if;

  end if;
end process;

end Behavioral;