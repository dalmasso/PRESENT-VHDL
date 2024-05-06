------------------------------------------------------------------------
-- Engineer:    Dalmasso Loic
-- Create Date: 06/12/2017
-- Module Name: Counter - Behavioral
-- Description:
--      Create new counter
--      Input data - RoundCounter : 5 bits Roundcounter
--      Output data - NewRC : 5 bits Roundcounter updated
------------------------------------------------------------------------

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;


ENTITY Counter is

PORT( RoundCounter: IN STD_LOGIC_VECTOR(4 downto 0);
	  NewRC       : OUT STD_LOGIC_VECTOR(4 downto 0)
    );

-- No optimization 
attribute dont_touch : string;
attribute dont_touch of Counter : entity is "true";

END Counter;

ARCHITECTURE Behavioral of Counter is

------------------------------------------------------------------------
-- Component Declarations
------------------------------------------------------------------------
COMPONENT SubCells is

PORT( SubCells_in  : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
      SubCells_out : OUT STD_LOGIC_VECTOR(3 DOWNTO 0)
    );

END COMPONENT;

------------------------------------------------------------------------
-- Module Implementation
------------------------------------------------------------------------
begin

-- New RoundCounter (Adder)
NewRC(4) <= RoundCounter(4) XOR ( RoundCounter(3) AND RoundCounter(2) AND RoundCounter(1) AND RoundCounter(0) );
NewRC(3) <= RoundCounter(3) XOR ( RoundCounter(2) AND RoundCounter(1) AND RoundCounter(0) );
NewRC(2) <= RoundCounter(2) XOR ( RoundCounter(1) AND RoundCounter(0) );
NewRC(1) <= RoundCounter(1) XOR RoundCounter(0);
NewRC(0) <= not RoundCounter(0);

end Behavioral;