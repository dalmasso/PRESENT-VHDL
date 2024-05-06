------------------------------------------------------------------------
-- Engineer:    Dalmasso Loic
-- Create Date: 28/05/2020
-- Module Name: Clock Divider Controler - Behavioral
-- Description:
--      Clock Divider
--		Generic - 	DIVIDER: Clock Divider
--		Input 	-	Clock:	Clock
--		Input 	-	Reset:	Reset
--      Output	-	ClockEnableCTRL: Controler of the Clock Enable
------------------------------------------------------------------------

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;


ENTITY ClockEnableControler is

GENERIC( DIVIDER 	: INTEGER := 1);

PORT( 	Clock:	IN STD_LOGIC;
		Reset:	IN STD_LOGIC;
		ClockEnableCTRL	: OUT STD_LOGIC
    );

END ClockEnableControler;

ARCHITECTURE Behavioral of ClockEnableControler is


------------------------------------------------------------------------
-- Signal Declarations
------------------------------------------------------------------------
-- Counter divider
signal Counter : INTEGER range 0 to DIVIDER-1 := 0;

------------------------------------------------------------------------
-- Module Implementation
------------------------------------------------------------------------
begin

	process(Clock,Reset)
	begin
		if Reset = '0' then
			Counter <= 0;
			
		elsif rising_edge(Clock) then
			Counter <= Counter+1;
			
			if Counter = DIVIDER-1 then
				Counter <= 0;
			end if;
		end if;
	end process;

-- Clock Enable Controler
ClockEnableCTRL <= '1' when Counter = 0 else '0';

end Behavioral;