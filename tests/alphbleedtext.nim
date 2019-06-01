import flippy, chroma, vmath

# load an image
var image = loadImage("tests/tree.png")

image.alphaBleed()
image.removeAlpha()
image.save("tests/tree.bleed.png")