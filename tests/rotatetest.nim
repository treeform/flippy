import flippy

# load an image
var image = loadImage("tests/lenna.png")
# rotate image by 45 degrees
image = image.rotate(45)
# save
image.save("tests/lenna.rotate45Degrees.png")
