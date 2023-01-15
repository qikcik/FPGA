from PIL import Image

image = Image.open('color.jpg')
width, height = image.size
pixel_values = list(image.getdata())

r = ""
g = ""
b = ""

for i in range(0,width*height ):
    if(pixel_values[i][0] > 127):
        r += "1"
    else:
        r += "0"

    if(pixel_values[i][1] > 127):
        g += "1"
    else:
        g += "0"

    if(pixel_values[i][2] > 127):
        b += "1"
    else:
        b += "0"



print("constant imgR : std_logic_vector( ("+str(width)+"*"+str(height)+")-1 downto 0 ) :=  \""+r[::-1]+"\";")
print("constant imgG : std_logic_vector( ("+str(width)+"*"+str(height)+")-1 downto 0 ) :=  \""+g[::-1]+"\";")
print("constant imgB : std_logic_vector( ("+str(width)+"*"+str(height)+")-1 downto 0 ) :=  \""+b[::-1]+"\";")
