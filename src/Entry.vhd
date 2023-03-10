library ieee;

use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity Entry is
	port (
		in_clk_50mhz			: in std_logic;
		
		in_keys 					: in std_logic_vector(3 downto 0);

		out_buzzer 				: out std_logic;		
		out_leds 				: out std_logic_vector(3 downto 0);
		
		out_7seg 				: out std_logic_vector(7 downto 0);
		out_7segDigitSelect 	: out std_logic_vector(3 downto 0);
		
		out_vgaHSync			: out std_logic;
		out_vgaVSync			: out std_logic;
		out_vgaRGB				: out std_logic_vector(2 downto 0)
	);
end Entry;

architecture behaviour of Entry is

component Entry_Pong
	port (
		in_clk_50mhz			: in std_logic;
		
		in_keys 					: in std_logic_vector(3 downto 0);

		out_buzzer 				: out std_logic							:= '0';		
		out_leds 				: out std_logic_vector(3 downto 0) 	:= (others => '0');
		
		out_7seg 				: out std_logic_vector(7 downto 0) 	:= (others => '0');
		out_7segDigitSelect 	: out std_logic_vector(3 downto 0) 	:= (others => '0');
		
		out_vgaHSync			: out std_logic	:= '0';
		out_vgaVSync			: out std_logic	:= '0';
		out_vgaRGB				: out std_logic_vector(2 downto 0) := (others => '0')
	);
end component;

	signal notBuzzer 				: std_logic								:= '0';	
	signal notLeds					: std_logic_vector(3 downto 0) 	:= (others => '0'); 
	signal not7seg 				: std_logic_vector(7 downto 0) 	:= (others => '0');
	signal not7segDigitSelect 	: std_logic_vector(3 downto 0) 	:= (others => '0');
	
begin 

	mainEntity: Entry_Pong 
	port map
	(
		in_clk_50mhz			=> in_clk_50mhz,
		
		in_keys 					=> not in_keys,
		
		out_leds 				=> notLeds,
		out_buzzer 				=> notBuzzer,
		
		out_7seg 				=> not7seg,
		out_7segDigitSelect 	=> not7segDigitSelect,
		
		out_vgaHSync			=> out_vgaHSync,
		out_vgaVSync			=> out_vgaVSync,
		out_vgaRGB				=> out_vgaRGB
	);
	
	out_leds <= not notLeds;
	out_7seg <= not not7seg;
	out_7segDigitSelect <= not not7segDigitSelect;
	out_buzzer <= not notBuzzer;
				
end behaviour;

