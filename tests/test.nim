import chroma, flippy, os, osproc, vmath

setCurrentDir(getCurrentDir() / "tests")


block:
  echo "# Draw edge pos tests"

  var main = newImage(255, 255, 4)

  var redSquare = loadImage("redsquare.png")
  let
    w = redSquare.width
    h = redSquare.height
  redSquare.alphaBleed()

  main.draw(
    redSquare,
    pos = vec2(-32, -32)
  )

  main.draw(
    redSquare,
    pos = vec2(192, -32)
  )

  main.draw(
    redSquare,
    pos = vec2(192, 192)
  )

  main.draw(
    redSquare,
    pos = vec2(-32, 192)
  )

  main.draw(
    redSquare,
    pos = vec2(
      main.width/2 - redSquare.width/2,
      main.height/2 - redSquare.height/2)
  )

  main.save("edgesPos.png")

block:
  echo "# Draw edge matrix tests"

  var main = newImage(255, 255, 4)

  var redSquare = loadImage("redsquare.png")
  let
    w = redSquare.width
    h = redSquare.height
  redSquare.alphaBleed()

  main.draw(
    redSquare,
    translate(vec3(32, 32, 0)) * rotateZ(PI*0) * translate(vec3(-w/2, -h/2, 0))
  )

  main.draw(
    redSquare,
    translate(vec3(224, 32, 0)) * rotateZ(PI*0.5) * translate(vec3(-w/2, -h/2, 0))
  )

  main.draw(
    redSquare,
    translate(vec3(224, 224, 0)) * rotateZ(PI*1.0) * translate(vec3(-w/2, -h/2, 0))
  )

  main.draw(
    redSquare,
    translate(vec3(32, 224, 0)) * rotateZ(PI*1.5) * translate(vec3(-w/2, -h/2, 0))
  )

  main.save("edgesMatrix.png")

block:
  echo "# Test strokeRoundedRect 1px"
  let image = newImage(100, 100, 4)
  image.strokeRoundedRect(rect = rect(0, 0, 100, 100),
    radius = 8, border = 1, rgba = rgba(255, 255, 255, 255))
  image.save("strokeRoundedRect1px.png")

block:
  echo "# Simple blit around edges"

  var mainImage = newImage(60, 60, 4)

  block:
    var image = newImage(20, 20, 4)
    image.fillCircle(pos = vec2(10, 10), radius = 10, rgba = rgba(255, 0, 0, 255))
    mainImage.blit(
      image,
      rect(0, 0, 20, 20),
      rect(20, -10, 20, 20)
    )

  block:
    var image = newImage(20, 20, 4)
    image.fillCircle(pos = vec2(10, 10), radius = 10, rgba = rgba(0, 255, 0, 255))
    mainImage.blit(
      image,
      rect(0, 0, 20, 20),
      rect(20, 50, 20, 20)
    )

  block:
    var image = newImage(20, 20, 4)
    image.fillCircle(pos = vec2(10, 10), radius = 10, rgba = rgba(0, 0, 255, 255))
    mainImage.blit(
      image,
      rect(0, 0, 20, 20),
      rect(-10, 20, 20, 20)
    )

  block:
    var image = newImage(20, 20, 4)
    image.fillCircle(pos = vec2(10, 10), radius = 10, rgba = rgba(255, 255, 255, 255))
    mainImage.blit(
      image,
      rect(0, 0, 20, 20),
      rect(50, 20, 20, 20)
    )

  block:
    var image = newImage(20, 20, 4)
    image.fillCircle(pos = vec2(10, 10), radius = 10, rgba = rgba(255, 0, 255, 255))
    mainImage.blit(
      image,
      rect(0, 0, 20, 20),
      rect(-1000, 20, 20, 20)
    )

  mainImage.save("edgeBlits.png")

block:
  echo "# Test Blur"
  let image = newImage(100, 100, 4)
  image.fillRect(rect = rect(40, 40, 20, 20),
    rgba = rgba(255, 255, 255, 255))

  image.blur(0).save("blur0x0.png")
  image.blur(1).save("blur1x1.png")
  image.blur(2).save("blur2x2.png")
  image.blur(16).save("blur16x16.png")

block:
  echo "# Basic test"
  # load an image
  var image = loadImage("lenna.png")
  # echo it out
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
  image.save("lenna2.png")

block:
  echo "# Draw tests"

  var main = newImage(255, 255, 4)
  var lenna = loadImage("lenna.png")
  main.draw(
    lenna,
    scale(vec3(15, 15, 1)) * rotateZ(0.3)
  )
  main.draw(
    lenna,
    scale(vec3(0.1, 0.1, 1)) * rotateZ(-0.3)
  )

  var redSquare = loadImage("redsquare.png")
  redSquare.alphaBleed()
  main.draw(
    redSquare,
    scale(vec3(1, 1, 1)) * rotateZ(-0.3) * translate(vec3(100, 100, 0))
  )

  var bluestar = loadImage("bluestar.png")
  main.draw(
    bluestar,
    translate(vec3(-50, -50, 0)) *
    scale(vec3(2, 2, 1)) *
    rotateZ(-0.3) *
    translate(vec3(80, 20, 0))
  )

  var greencircle = loadImage("greencircle.png")
  main.draw(
    greencircle,
    translate(vec3(200, -50, 0))
  )

  main.save("composed.png")

block:
  echo "# Smooth Draw"

  var main = newImage(255, 255, 4)

  var redSquare = loadImage("redsquare.png")
  let
    w = redSquare.width
    h = redSquare.height
  redSquare.alphaBleed()

  main.draw(
    redSquare,
    translate(vec3(64, 64, 0)) * rotateZ(PI*0) * translate(vec3(-w/2, -h/2, 0))
  )

  main.draw(
    redSquare,
    translate(vec3(192, 64, 0)) * rotateZ(PI*0.5) * translate(vec3(-w/2, -h/2, 0))
  )

  main.draw(
    redSquare,
    translate(vec3(192, 192, 0)) * rotateZ(PI*1.0) * translate(vec3(-w/2, -h/2, 0))
  )

  main.draw(
    redSquare,
    translate(vec3(64, 192, 0)) * rotateZ(PI*1.5) * translate(vec3(-w/2, -h/2, 0))
  )

  main.save("blit1.png")

block:
  echo "# Flip tests"
  var lenna = loadImage("lenna.png")
  lenna.flipHorizontal.save("lenna.flipHorizontal.png")
  lenna.flipVertical.save("lenna.flipVertical.png")
  lenna.rotate90Degrees.save("lenna.rotate90Degrees.png")

block:
  echo "# Test for loosing colors when minifying"
  # test for issue: https://github.com/treeform/flippy/issues/2
  var img = newImage(64, 64, 4)

  img.fill(rgba(255, 255, 255, 255))
  img = img.minify(2)

  assert img.getRgba(0, 0) == rgba(255, 255, 255, 255)

block:
  echo "# Test fillCircle"
  var image = newImage(20, 20, 4)
  image.fillCircle(pos = vec2(10, 10), radius = 10, rgba = rgba(255, 0, 0, 255))
  var image10x = image.magnify(10)
  image10x.save("fillCircle.png")

block:
  echo "# Test strokeCircle"
  let image = newImage(20, 20, 4)
  image.strokeCircle(pos = vec2(10, 10), radius = 8,
    border = 2, rgba = rgba(255, 0, 0, 255))
  var image10x = image.magnify(10)
  image10x.save("strokeCircle.png")

block:
  echo "# Test fillRoundedRect"
  let image = newImage(100, 100, 4)
  image.fillRoundedRect(rect = rect(0, 0, 100, 100),
    radius = 8, rgba = rgba(255, 0, 0, 255))
  image.save("fillRoundedRect.png")

block:
  echo "# Test strokeRoundedRect"
  let image = newImage(100, 100, 4)
  image.strokeRoundedRect(rect = rect(0, 0, 100, 100),
    radius = 8, border = 4, rgba = rgba(255, 255, 255, 255))
  image.save("strokeRoundedRect.png")

block:
  echo "# Test ninePatch"
  let image = newImage(100, 100, 4)
  image.ninePatch(rect = rect(0, 0, 100-2, 100-2),
    radius = 8, border = 2,
    fill = rgba(0, 0, 0, 255), stroke = rgba(255, 255, 255, 255))
  image.save("ninePatch.png")

block:
  echo "# Test rotate"
  var image = loadImage("lenna.png")
  image = image.rotate(45)
  image.save("lenna.rotate45Degrees.png")

block:
  echo "# Test rotate 2 degrees"
  var image = loadImage("lenna.png")
  image = image.rotate(2)
  image.save("lenna.rotate2Degrees.png")

block:
  echo "# Test rotate 2 degrees with alpha padding"
  var image = loadImage("lenna.png")
  let
    top = rect(0, 0, image.width.float32, 20)
    bottom = rect(
      0, (image.height - 20).float32, image.width.float32, image.height.float32
    )
    left = rect(0, 0, 20, image.height.float32)
    right = rect(
      (image.width - 20).float32, 0, image.width.float32, image.height.float32
    )
    transparent = rgba(0, 0, 0, 0)
  image.fillRect(top, transparent)
  image.fillRect(bottom, transparent)
  image.fillRect(left, transparent)
  image.fillRect(right, transparent)
  image = image.rotate(2)
  image.save("lenna.rotate2Degrees.padded.png")

block:
  echo "# Test shearX"
  var image = loadImage("lenna.png")
  image = image.shearX(0.25)
  image.save("lenna.shearX.png")

block:
  echo "# Test shearY"
  var image = loadImage("lenna.png")
  image = image.shearY(0.25)
  image.save("lenna.shearY.png")

block:
  echo "# Test alphaBleed"
  var image = loadImage("tree.png")
  image.alphaBleed()
  image.removeAlpha()
  image.save("tree.bleed.png")

block:
  echo "# Test resize min"
  var image = loadImage("lenna.png")
  image = image.resize(100, 100)
  image.save("lenna.resized.100x100.png")

block:
  echo "# Test resize mag"
  var image = loadImage("lenna.png")
  image = image.resize(1000, 1000)
  image.save("lenna.resized.1000x1000.png")

block:
  echo "# Test resize min/mag"
  var image = loadImage("lenna.png")
  image = image.resize(1000, 100)
  image.save("lenna.resized.1000x100.png")

block:
  echo "# Unicode file name"
  var image = loadImage("树.png")
  assert image.width != 0
  assert image.height != 0

block:
  echo "# Test making Flippy from .png"
  pngToFlippy("lenna.png", "lenna.flippy")

block:
  echo "# Test Flippy load/save"
  let flippy = loadFlippy("lenna2.flippy")
  assert flippy.width() == 512
  assert flippy.height() == 512
  assert len(flippy.mipmaps) == 10
  flippy.save("lenna2.flippy")

let (outp, _) = execCmdEx("git diff tests/*.png")
if len(outp) != 0:
  echo outp
  quit("Output does not match")
