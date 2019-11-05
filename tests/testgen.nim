import flippy, vmath, chroma

block:
  var image = newImage(20, 20, 4)
  image.fillCirle(pos=vec2(10, 10), radius = 10, rgba=rgba(255,0,0,255))
  var image10x = image.magnify(10)
  image10x.save("tests/fillCirle.png")


block:
  let image = newImage(20, 20, 4)
  image.strokeCirle(pos=vec2(10, 10), radius = 8, border = 2, rgba=rgba(255,0,0,255))
  var image10x = image.magnify(10)
  image10x.save("tests/strokeCirle.png")


block:
  let image = newImage(100, 100, 4)
  image.fillRoundedRect(rect=rect(0, 0, 100, 100), radius = 8, rgba=rgba(255,0,0,255))
  image.save("tests/fillRoundedRect.png")


block:
  let image = newImage(100, 100, 4)
  image.strokeRoundedRect(rect=rect(0, 0, 100, 100), radius = 8, border = 4, rgba=rgba(255,255,255,255))
  image.save("tests/strokeRoundedRect.png")


block:
  let image = newImage(100, 100, 4)
  image.ninePatch(rect=rect(0, 0, 100-2, 100-2), radius = 8, border = 2, fill=rgba(0,0,0,255), stroke=rgba(255,255,255,255))
  image.save("tests/ninePatch.png")