import flippy, chroma, vmath

var main = newImage(255, 255, 4)
var lenna = loadImage("tests/lenna.png")
main.blitWithAlpha(
  lenna,
  scale(vec3(15,15,1)) * rotateZ(0.3)
)
main.blitWithAlpha(
  lenna,
  scale(vec3(0.1,0.1,1)) * rotateZ(-0.3)
)

var redSquare = loadImage("tests/redsquare.png")
main.blitWithAlpha(
  redSquare,
  scale(vec3(1,1,1)) * rotateZ(-0.3) * translate(vec3(100, 100, 0))
)

var bluestar = loadImage("tests/bluestar.png")
main.blitWithAlpha(
  bluestar,
  translate(vec3(-50, -50, 0)) * scale(vec3(2,2,1)) * rotateZ(-0.3) * translate(vec3(80, 20, 0))
)

var greencircle = loadImage("tests/greencircle.png")
main.blitWithAlpha(
  greencircle,
  translate(vec3(200, -50, 0))
)


main.save("tests/composed.png")