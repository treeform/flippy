import flippy, chroma, vmath

block:
  # load an image
  var image = loadImage("tests/lenna.png")
  # print it out
  echo image
  # get a color pixel
  echo image.getRgba(100, 100)
  # put a color pixel
  image.putRgba(10, 10, rgba(255, 0, 0, 255))
  # blit a rectangular part from one place to another
  blit(image, image, rect(0, 0, 100, 100), rect(100, 100, 100, 100))
  # draw a line
  image.line(vec2(11, 11), vec2(100, 100), rgba(0, 0, 0, 255))
  # minify image by 2 or 1/2 or scale by 50%
  image = image.minify(2)
  # save the image to a file
  image.save("tests/lenna2.png")

block:
  var main = newImage(255, 255, 4)
  var lenna = loadImage("tests/lenna.png")
  main.blitWithAlpha(
    lenna,
    scale(vec3(15, 15, 1)) * rotateZ(0.3)
  )
  main.blitWithAlpha(
    lenna,
    scale(vec3(0.1, 0.1, 1)) * rotateZ(-0.3)
  )

  var redSquare = loadImage("tests/redsquare.png")
  main.blitWithAlpha(
    redSquare,
    scale(vec3(1, 1, 1)) * rotateZ(-0.3) * translate(vec3(100, 100, 0))
  )

  var bluestar = loadImage("tests/bluestar.png")
  main.blitWithAlpha(
    bluestar,
    translate(vec3(-50, -50, 0)) *
    scale(vec3(2, 2, 1)) *
    rotateZ(-0.3) *
    translate(vec3(80, 20, 0))
  )

  var greencircle = loadImage("tests/greencircle.png")
  main.blitWithAlpha(
    greencircle,
    translate(vec3(200, -50, 0))
  )

  main.save("tests/composed.png")


block:
  var lenna = loadImage("tests/lenna.png")
  lenna.flipHorizontal.save("tests/lenna.flipHorizontal.png")
  lenna.flipVertical.save("tests/lenna.flipVertical.png")
  lenna.rotate90Degrees.save("tests/lenna.rotate90Degrees.png")

block:
  # test for issue: https://github.com/treeform/flippy/issues/2
  var img = newImage(64, 64, 4)

  img.fill(rgba(255, 255, 255, 255))
  img = img.minify(2)

  assert img.getRgba(0, 0) == rgba(255, 255, 255, 255)

block:
  var image = newImage(20, 20, 4)
  image.fillCirle(pos = vec2(10, 10), radius = 10, rgba = rgba(255, 0, 0, 255))
  var image10x = image.magnify(10)
  image10x.save("tests/fillCirle.png")


block:
  let image = newImage(20, 20, 4)
  image.strokeCirle(pos = vec2(10, 10), radius = 8,
    border = 2, rgba = rgba(255, 0, 0, 255))
  var image10x = image.magnify(10)
  image10x.save("tests/strokeCirle.png")


block:
  let image = newImage(100, 100, 4)
  image.fillRoundedRect(rect = rect(0, 0, 100, 100),
    radius = 8, rgba = rgba(255, 0, 0, 255))
  image.save("tests/fillRoundedRect.png")


block:
  let image = newImage(100, 100, 4)
  image.strokeRoundedRect(rect = rect(0, 0, 100, 100),
    radius = 8, border = 4, rgba = rgba(255, 255, 255, 255))
  image.save("tests/strokeRoundedRect.png")


block:
  let image = newImage(100, 100, 4)
  image.ninePatch(rect = rect(0, 0, 100-2, 100-2),
    radius = 8, border = 2,
    fill = rgba(0, 0, 0, 255), stroke = rgba(255, 255, 255, 255))
  image.save("tests/ninePatch.png")

block:
  var image = loadImage("tests/lenna.png")
  # rotate image by 45 degrees
  image = image.rotate(45)
  image.save("tests/lenna.rotate45Degrees.png")
