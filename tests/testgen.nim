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