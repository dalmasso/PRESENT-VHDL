----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 27.12.2017 19:02:02
-- Design Name: 
-- Module Name: testbench_PRESENT - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity testbench_PRESENT is
--  Port ( );
end testbench_PRESENT;

architecture Behavioral of testbench_PRESENT is

COMPONENT PRESENT is

PORT( Clk           : IN STD_LOGIC;
      Reset         : IN STD_LOGIC;
      Plaintext     : IN STD_LOGIC_VECTOR(63 DOWNTO 0);
      CipherKey     : IN STD_LOGIC_VECTOR(127 DOWNTO 0);
      Ciphertext    : OUT STD_LOGIC_VECTOR(63 DOWNTO 0);
      EndOfPRESENT  : OUT STD_LOGIC
    );

END COMPONENT;

signal clk, reset 	: STD_LOGIC := '0';
signal myplain 		: STD_LOGIC_VECTOR(63 DOWNTO 0) := (others => '0');
signal mykey 		: STD_LOGIC_VECTOR(127 DOWNTO 0):= (others => '0');
signal cipher 		: STD_LOGIC_VECTOR(63 DOWNTO 0) := (others => '0');
signal endofpre 	: STD_LOGIC := '0';

begin

uut : present port map (clk,reset,myplain,mykey,cipher,endofpre);

clk <= not clk after 5 ns;
reset <= '0', '1' after 203 ns, '0' after 600 ns, '1' after 650 ns;
myplain <= X"0123456789ABCDEF";
mykey <= X"0123456789ABCDEF0123456789ABCDEF";

end Behavioral;