library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity VgaController is
	generic (
		 pixelFreq				: integer := 50_000_000;
		 
		 hSync_visibleArea	: integer := 800;
		 hSync_frontPorch    : integer := 56;
		 hSync_syncPulse		: integer := 120;
		 hSync_backPorch     : integer := 64;
		 
		 vSync_visibleArea	: integer := 600;
		 vSync_frontPorch    : integer := 37;
		 vSync_syncPulse		: integer := 6;
		 vSync_backPorch     : integer := 23
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
end VgaController;

architecture behaviour of VgaController is
	constant wholeLine 	: integer := hSync_syncPulse + hSync_backPorch + hSync_visibleArea + hSync_frontPorch;
	constant wholeFrame 	: integer := vSync_syncPulse + vSync_backPorch + vSync_visibleArea + vSync_frontPorch;
  
	signal hCounter : integer range 0 to  wholeLine-1 		:= 0; 
	signal vCounter : integer range 0 to  wholeFrame-1 	:= 0;

	signal isDisplaying  : boolean := false; 	
  
begin

	out_vgaHSync <= '1' when hCounter >= hSync_visibleArea + hSync_frontPorch
							  and  hCounter <  hSync_visibleArea + hSync_frontPorch + hSync_syncPulse else '0';
							  
	out_vgaVSync <= '1' when vCounter >= vSync_visibleArea + vSync_frontPorch
							  and  vCounter <  vSync_visibleArea + vSync_frontPorch + vSync_syncPulse else '0';
		

	out_isDisplaying 	<= '1' when (hCounter < hSync_visibleArea) and (vCounter < vSync_visibleArea) else '0';
	out_vgaRGB 	<= in_vgaRGB when (hCounter < hSync_visibleArea) and (vCounter < vSync_visibleArea)  else (others => '0');
	
	out_hPos <= hCounter when hCounter < wholeLine 	else -1;
	out_vPos <= vCounter when vCounter < wholeFrame else -1;

	process(in_clk)
	begin 
		if rising_edge(in_clk) then
			if(hCounter < wholeLine-1) then    --horizontal counter (pixels)
				hCounter <= hCounter + 1;
			else
				hCounter <= 0;
				
				if(vCounter < wholeFrame-1) then  --veritcal counter (rows)
					vCounter <= vCounter + 1;
				else
					vCounter <= 0;
				end if;
				
			end if;
			
		end if;
	end process;

end behaviour;
