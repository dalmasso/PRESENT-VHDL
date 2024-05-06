------------------------------------------------------------------------
-- Engineer:	Dalmasso Loic
-- Create Date:	22/12/2017
-- Module Name:	PermBits - Behavioral
-- Description:
--		Generate permutation bit of PRESENT encryption
-- 		Input data - PermBits_in : 64bits of text
--		Output data - PermBits_out : 64bits permuted bits of text
------------------------------------------------------------------------

-- 0 LUT

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;

ENTITY PermBits is

PORT( PermBits_in : IN STD_LOGIC_VECTOR(63 DOWNTO 0);
	  PermBits_out: OUT STD_LOGIC_VECTOR(63 DOWNTO 0)
	);

-- No optimization	
attribute dont_touch : string;
attribute dont_touch of PermBits : entity is "true";

END PermBits;

ARCHITECTURE Behavioral of PermBits is

------------------------------------------------------------------------
-- Module Implementation
------------------------------------------------------------------------
begin

PermBits_out	<= PermBits_in(63) &	-- 63
				   PermBits_in(59) &	-- 62
				   PermBits_in(55) &	-- 61
				   PermBits_in(51) &	-- 60
				   PermBits_in(47) &	-- 59
				   PermBits_in(43) &	-- 58
				   PermBits_in(39) &	-- 57
				   PermBits_in(35) &	-- 56
				   PermBits_in(31) &	-- 55
				   PermBits_in(27) &	-- 54
				   PermBits_in(23) &	-- 53
				   PermBits_in(19) &	-- 52
				   PermBits_in(15) &	-- 51
				   PermBits_in(11) &	-- 50
				   PermBits_in(7)  &	-- 49
				   PermBits_in(3)  &	-- 48

				   PermBits_in(62) &	-- 47
				   PermBits_in(58) &	-- 46
				   PermBits_in(54) &	-- 45
				   PermBits_in(50) &	-- 44
				   PermBits_in(46) &	-- 43
				   PermBits_in(42) &	-- 42
				   PermBits_in(38) &	-- 41
				   PermBits_in(34) &	-- 40
				   PermBits_in(30) &	-- 39
				   PermBits_in(26) &	-- 38
				   PermBits_in(22) &	-- 37
				   PermBits_in(18) &	-- 36
				   PermBits_in(14) &	-- 35
				   PermBits_in(10) &	-- 34
				   PermBits_in(6)  &	-- 33
				   PermBits_in(2)  &	-- 32

				   PermBits_in(61) &	-- 31
				   PermBits_in(57) &	-- 30
				   PermBits_in(53) &	-- 29
				   PermBits_in(49) &	-- 28
				   PermBits_in(45) &	-- 27
				   PermBits_in(41) &	-- 26
				   PermBits_in(37) &	-- 25
				   PermBits_in(33) &	-- 24
				   PermBits_in(29) &	-- 23
				   PermBits_in(25) &	-- 22
				   PermBits_in(21) &	-- 21
				   PermBits_in(17) &	-- 20
				   PermBits_in(13) &	-- 19
				   PermBits_in(9)  &	-- 18
				   PermBits_in(5)  &	-- 17
				   PermBits_in(1)  &	-- 16

				   PermBits_in(60) &	-- 15
				   PermBits_in(56) &	-- 14
				   PermBits_in(52) &	-- 13
				   PermBits_in(48) &	-- 12
				   PermBits_in(44) &	-- 11
				   PermBits_in(40) &	-- 10
				   PermBits_in(36) &	-- 9
				   PermBits_in(32) &	-- 8
				   PermBits_in(28) &	-- 7
				   PermBits_in(24) &	-- 6
				   PermBits_in(20) &	-- 5
				   PermBits_in(16) &	-- 4
				   PermBits_in(12) &	-- 3
				   PermBits_in(8)  &	-- 2
				   PermBits_in(4)  &	-- 1
				   PermBits_in(0);		-- 0

end Behavioral;