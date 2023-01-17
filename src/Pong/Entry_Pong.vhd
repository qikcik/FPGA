library ieee;

use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.Disp4x7Seg_Types.all;

entity Entry_Pong is
	port (
		-- core
		in_clk_50mhz			: in std_logic;
		-- simple input
		in_keys 					: in std_logic_vector(3 downto 0);
		-- simple output
		out_buzzer 				: out std_logic							:= '0';		
		out_leds 				: out std_logic_vector(3 downto 0) 	:= (others => '0');
		-- 7seg output
		out_7seg 				: out std_logic_vector(7 downto 0) 	:= (others => '0');
		out_7segDigitSelect 	: out std_logic_vector(3 downto 0)	:= (others => '0');
		-- vga output
		out_vgaHSync			: out std_logic	:= '0';
		out_vgaVSync			: out std_logic	:= '0';
		out_vgaRGB				: out std_logic_vector(2 downto 0) := (others => '0')
	);
end Entry_Pong;

architecture behaviour of Entry_Pong is

	component VgaController is
		generic (
			pixelFreq				: integer := 25_000_000;

			hSync_visibleArea	: integer := 640;
			hSync_frontPorch    : integer := 16;
			hSync_syncPulse		: integer := 96;
			hSync_backPorch     : integer := 48;

			vSync_visibleArea	: integer := 480;
			vSync_frontPorch    : integer := 10;
			vSync_syncPulse		: integer := 2;
			vSync_backPorch     : integer := 33
		);
		port (
			in_clk			: in  std_logic := '0';
			
			out_vgaRGB		: out std_logic_vector(2 downto 0) := (others => '0');
			out_vgaHSync	: out std_logic := '0';
			out_vgaVSync	: out std_logic := '0';

			out_isDisplaying	: out std_logic := '0';
			out_hPos				: out integer := 0;
			out_vPos				: out integer := 0;
			in_vgaRGB			: in  std_logic_vector(2 downto 0) := (others => '0')
		);
	end component;

	component Disp4x7Seg is
		port (
			in_clk					: in std_logic;
			
			in_7seg 					: in Array4x7Seg;
			
			out_7seg 				: out std_logic_vector(7 downto 0) 	:= (others => '0');
			out_7segDigitSelect 	: out std_logic_vector(3 downto 0) 	:= (others => '0')
		);
	end component;
		
	signal clk_divider 	: std_logic_vector(25 downto 0) := (others => '0'); -- 50mhz/(2^26) ~= 0.75hz
	
	signal isDisplaying	: std_logic := '0';
	signal pixel_y				: integer := 0;
	signal pixel_x				: integer := 0;
	signal pixel_rgb		   : std_logic_vector(2 downto 0) := (others => '0');
	
	constant screen_x    : integer := 620;
	constant screen_y    : integer := 480;
	constant player_size_y  : integer := 150;
	constant player_size_x  : integer := 20;
 	
	signal p1_position_y	: integer range 0 to  screen_y-player_size_y := 0;
	constant p1_speed_y	: integer := 1;
	
	signal p2_position_y	: integer range 0 to  screen_y-player_size_y := 0;
	constant p2_speed_y	: integer := 1;
	
	constant ball_size  : integer := 20;
	signal ball_position_x	: integer := screen_x/2;
	signal ball_position_y	: integer := screen_y/2;
	
	signal ball_dir_right	: std_logic := '1';
	signal ball_dir_up	: std_logic := '1';
	
	constant ball_speed	: integer := 1;
	
	constant max_score		: integer  := 3;
	
	signal p1_score		: integer  := 0;
	signal p2_score		: integer  := 0;
	
	signal pause			: std_logic  := '1';
	
	
	signal display7seg 	 	: Array4x7Seg := (CONST7SEG_EMPTY,CONST7SEG_EMPTY,CONST7SEG_EMPTY,CONST7SEG_EMPTY);
	

begin

	c_clk_divider: process(in_clk_50mhz) 
	begin
		if rising_edge(in_clk_50mhz) then
			clk_divider <= std_logic_vector(unsigned(clk_divider) + 1);
		end if;
	end process;
	
	c_disp4x7seg: Disp4x7Seg 
	port map
	(
		in_clk					=> clk_divider(15),
		
		in_7seg					=> display7seg,
		
		out_7seg 				=> out_7seg,
		out_7segDigitSelect 	=> out_7segDigitSelect
	);
	
	c_vgaController: VgaController 
	generic map
	(
		pixelFreq => 25_000_000,

		hSync_visibleArea	=> 640,
		hSync_frontPorch => 16,
		hSync_syncPulse => 96,
		hSync_backPorch => 48,

		vSync_visibleArea	=> 480,
		vSync_frontPorch => 10,
		vSync_syncPulse => 2,
		vSync_backPorch => 33	
	)
	port map
	(
		in_clk => clk_divider(0),
		
		out_vgaRGB 	 => out_vgaRGB,
		out_vgaHSync => out_vgaHSync,
		out_vgaVSync => out_vgaVSync,

		out_isDisplaying	=> isDisplaying,
		out_hPos				=> pixel_x,
		out_vPos				=> pixel_y,
		in_vgaRGB			=> pixel_rgb
	);
	
	p_logic: process(clk_divider)
	begin
		if rising_edge(clk_divider(17))  and pause = '1' then
			if in_keys = "1111" then
				pause <= '0';
				p1_score <= 0;
				p2_score <= 0;
				p1_position_y	<= (screen_y-player_size_y)/2;
				p2_position_y	<= (screen_y-player_size_y)/2;
			end if;
		end if;
		if rising_edge(clk_divider(17))  and pause = '0' then
				if in_keys(2) = '1' and p1_position_y-p1_speed_y >= 0 then
					p1_position_y <= p1_position_y-p1_speed_y;
				end if;
				if in_keys(3) = '1' and p1_position_y+p1_speed_y+player_size_y <= screen_y then
					p1_position_y <= p1_position_y+p1_speed_y;
				end if;
				
				if in_keys(0) = '1' and p2_position_y-p2_speed_y >= 0 then
					p2_position_y <= p2_position_y-p2_speed_y;
				end if;
				if in_keys(1) = '1' and p2_position_y+p2_speed_y+player_size_y <= screen_y then
					p2_position_y <= p2_position_y+p2_speed_y;
				end if;
				
				if ball_dir_right = '1' then
					ball_position_x <= ball_position_x+ball_speed;
				else
					ball_position_x <= ball_position_x-ball_speed;
				end if;
				
				if ball_dir_up = '1' then
					ball_position_y <= ball_position_y-ball_speed;
				else
					ball_position_y <= ball_position_y+ball_speed;
				end if;
				
				
				--ball bounce
				if ball_position_y <= 0 then
					ball_dir_up <= '0';
				end if;
				
				if ball_position_y >= screen_y-ball_size then
					ball_dir_up <= '1';
				end if;
				
				if ball_position_x <= player_size_x then
					if ball_position_y >= p1_position_y and ball_position_y <= p1_position_y+player_size_y  then 
						ball_dir_right <= '1';
					else 
						--p1_position_y	<= 0;
						--p2_position_y	<= 0;
						ball_position_x	<= screen_x/2;
						ball_position_y	<= screen_y/2;
						ball_dir_right <= not ball_dir_right;

						if p1_score >= max_score or p2_score+1 >= max_score then 
							pause <= '1';
						end if;
						p2_score	<=	p2_score+1;				
					end if;
				end if;
				
				if ball_position_x >= screen_x-ball_size-player_size_x then
					if ball_position_y >= p2_position_y and ball_position_y <= p2_position_y+player_size_y  then 
						ball_dir_right <= '0';
					else 
						--p1_position_y	<= 0;
						--p2_position_y	<= 0;
						ball_position_x	<= screen_x/2;
						ball_position_y	<= screen_y/2;	
					   ball_dir_right <= not ball_dir_right;	
		
						p1_score	<=	p1_score+1;
						if p1_score+1	>= max_score or p2_score >= max_score then 
							pause <= '1';
						end if;
						p1_score	<=	p1_score+1;		
					end if;
				end if;
			
				
				
		end if;
	end process;
	
	p_display: process(clk_divider)
	begin
		if rising_edge(clk_divider(0)) and isDisplaying = '1' and pause = '0' then
			-- draw
			if
				pixel_x > 0 and pixel_x < player_size_x and
				pixel_y > p1_position_y and pixel_y < p1_position_y+player_size_y
			then
				pixel_rgb <= "111";
			
			elsif
				pixel_x > screen_x-player_size_x and pixel_x < screen_x and
				pixel_y > p2_position_y and pixel_y < p2_position_y+player_size_y
			then
				pixel_rgb <= "111";
			
			elsif
				pixel_x > ball_position_x and pixel_x < ball_position_x+ball_size and
				pixel_y > ball_position_y and pixel_y < ball_position_y+ball_size 
			then
				pixel_rgb <= "100";
				
			else
				pixel_rgb <= "000";
			end if;
		end if;
	end process;
	
	display7seg(3) <=  BinTo7SegHex(std_logic_vector(to_unsigned(p1_score,4)));
	display7seg(0) <=  BinTo7SegHex(std_logic_vector(to_unsigned(p2_score,4)));

end behaviour;

