import math, os, strutils
import stb_image/read as stbi
import stb_image/write as stbiw
import vmath, print, chroma


type Image* = ref object
  ## Main image object that hold the bitmap data.
  filePath*: string
  width*: int
  height*: int
  channels*: int
  format*: int
  data*: seq[uint8]


proc `+`(a, b: ColorRGBA): ColorRGBA =
  ## Adds two ColorRGBA together.
  result.r = a.r + b.r
  result.g = a.g + b.g
  result.b = a.b + b.b
  result.a = a.a + b.a


proc `div`(rgba: ColorRGBA; i: uint8): ColorRGBA =
  ## Integer devide a ColorRGBA by an integer amount.
  result.r = rgba.r div i
  result.g = rgba.g div i
  result.b = rgba.b div i
  result.a = rgba.a div i


proc `$`*(image: Image): string =
  ## Display the image path, size and channels.
  if image.filePath.len > 0:
    return "<Image " & image.filePath & " " & $image.width & "x" & $image.height & ":" & $image.channels & ">"
  else:
    return "<Image " & $image.width & "x" & $image.height & ":" & $image.channels & ">"


proc newImage*(width, height, channels: int): Image =
  ## Create a new image with appropraite dimentions.
  var image = Image()
  image.width = width
  image.height = height
  image.channels = channels
  assert image.channels > 0 and image.channels <= 4
  image.data = newSeq[uint8](width * height * channels)
  return image


proc newImage*(filePath: string, width, height, channels: int): Image =
  ## Creates a new image with a path.
  var image = newImage(width, height, channels)
  image.filePath = filePath
  return image


proc loadImage*(filePath: string): Image =
  ## Loads a png image.
  var image = Image()
  image.filePath = filePath
  image.data = stbi.load(
    image.filePath,
    image.width,
    image.height,
    image.channels,
    stbi.Default)
  return image


proc save*(image: Image) =
  ## Saves a png image.
  var sucess = writePNG(
    image.filePath,
    image.width,
    image.height,
    image.channels,
    image.data)
  if not sucess:
    raise newException(Exception, "Failed to save Image: " & image.filePath)


proc save*(image: Image, filePath: string) =
  ## Sets image path and save the image.
  image.filePath = filePath
  image.save()


proc inside*(image: Image, x, y: int): bool {.inline.} =
  ## Returns true if x,y is inside the image
  x >= 0 and x < image.width and y >= 0 and y < image.height


proc getRgba*(image: Image, x, y: int): ColorRGBA {.inline.} =
  ## Gets a color with (x, y) cordinates.
  assert x >= 0 and x < image.width
  assert y >= 0 and y < image.height
  if image.channels == 1:
    result.r = image.data[(image.width * y + x)]
    result.g = image.data[(image.width * y + x)]
    result.b = image.data[(image.width * y + x)]
    result.a = 255
  elif image.channels == 3:
    result.r = image.data[(image.width * y + x) * 3 + 0]
    result.g = image.data[(image.width * y + x) * 3 + 1]
    result.b = image.data[(image.width * y + x) * 3 + 2]
    result.a = 255
  elif image.channels == 4:
    result.r = image.data[(image.width * y + x) * 4 + 0]
    result.g = image.data[(image.width * y + x) * 4 + 1]
    result.b = image.data[(image.width * y + x) * 4 + 2]
    result.a = image.data[(image.width * y + x) * 4 + 3]
  else:
    quit("not supported " & $image)


proc getRgba*(image: Image, x, y: float64): ColorRGBA {.inline.} =
  ## Gets a pixel as (x, y) floats
  getRgba(image, int x, int y)


proc getRgbaSafe*(image: Image, x, y: int): ColorRGBA {.inline.} =
  ## Gets a pixel as (x, y) but returns transperancy if next sampled outside
  if image.inside(x, y):
    return image.getRgba(x, y)


proc putRgba*(image: Image, x, y: int, rgb: ColorRGBA) {.inline.} =
  ## Puts a ColorRGBA pixel back.
  if image.channels == 3:
    image.data[(image.width * y + x) * 3 + 0] = rgb.r
    image.data[(image.width * y + x) * 3 + 1] = rgb.g
    image.data[(image.width * y + x) * 3 + 2] = rgb.b
  elif image.channels == 4:
    image.data[(image.width * y + x) * 4 + 0] = rgb.r
    image.data[(image.width * y + x) * 4 + 1] = rgb.g
    image.data[(image.width * y + x) * 4 + 2] = rgb.b
    image.data[(image.width * y + x) * 4 + 3] = rgb.a
  else:
    quit("not supported")


proc putRgba*(image: Image, x, y: float64, rgb: ColorRGBA) {.inline.} =
  ## Puts a ColorRGBA pixel back  as x, y floats (does not do blending).
  putRgba(image, int x, int y, rgb)


proc putRgbaSafe*(image: Image, x, y: int, rgba: ColorRGBA) {.inline.} =
  ## Puts pixel onto the image or safly ignores this command if pixel is outside the image
  if image.inside(x, y):
    image.putRgba(x, y, rgba)


proc blit*(destImage: Image, srcImage: Image, pos: Vec2) =
  ## Blits rectange from one image to the other image.
  for x in 0..<int(srcImage.width):
    for y in 0..<int(srcImage.height):
      var rgba = srcImage.getRgba(x, y)
      destImage.putRgbaSafe(int(pos.x) + x, int(pos.y) + y, rgba)


proc blit*(destImage: Image, srcImage: Image, src, dest: Rect) =
  ## Blits rectange from one image to the other image.
  assert src.w == dest.w and src.h == dest.h
  for x in 0..<int(src.w):
    for y in 0..<int(src.h):
      var rgba = srcImage.getRgba(int(src.x) + x, int(src.y) + y)
      destImage.putRgbaSafe(int(dest.x) + x, int(dest.y) + y, rgba)


proc blitWithMask*(destImage: Image, srcImage: Image, src, dest: Rect, color: ColorRGBA) =
  ## Blits rectange from one image to the other image with masking color
  assert src.w == dest.w and src.h == dest.h
  for x in 0..<int(src.w):
    for y in 0..<int(src.h):
      let
        xsrc = int(src.x) + x
        ysrc = int(src.y) + y
        xdest = int(dest.x) + x
        ydest = int(dest.y) + y
      if destImage.inside(xdest, ydest) and srcImage.inside(xsrc, ysrc):
        var rgba = srcImage.getRgba(xsrc, ysrc)
        if rgba.a == uint8(255):
          destImage.putRgba(xdest, ydest, color)
        elif rgba.a > uint8(0):
          let destRgba = destImage.getRgba(xdest, ydest)
          let a = float(rgba.a)/255.0
          rgba.r = uint8(float(destRgba.r) * (1-a) + float(color.r) * a)
          rgba.g = uint8(float(destRgba.g) * (1-a) + float(color.g) * a)
          rgba.b = uint8(float(destRgba.b) * (1-a) + float(color.b) * a)
          rgba.a = 255
          destImage.putRgba(xdest, ydest, rgba)

proc computeBounds(destImage: Image, srcImage: Image, mat: Mat4, matInv: Mat4): (int, int, int, int) =
  # compute the bounds
  let
    bounds = @[
      mat * vec3(-1, -1, 0),
      mat * vec3(-1, float32 srcImage.height + 1, 0),
      mat * vec3(float32 srcImage.width + 1, -1, 0),
      mat * vec3(float32 srcImage.width + 1, float32 srcImage.height + 1, 0)
    ]
  var
    boundsX = newSeq[float32](4)
    boundsY = newSeq[float32](4)
  for v in bounds:
    boundsX.add(v.x)
    boundsY.add(v.y)
  let
    xStart = max(int min(boundsX), 0)
    yStart = max(int min(boundsY), 0)
    xEnd = min(int max(boundsX), destImage.width)
    yEnd = min(int max(boundsY), destImage.height)
  return (xStart, yStart, xEnd, yEnd)


proc roundPixelVec(v: Vec3): Vec2 {.inline.} =
  ## Rounds vector to pixel center
  vec2(round(v.x), round(v.y))


proc blit*(destImage: Image, srcImage: Image, mat: Mat4) =
  ## Blits one image onto another using matrix with alpha blending
  let matInv = mat.inverse()
  let (xStart, yStart, xEnd, yEnd) = computeBounds(destImage, srcImage, mat, matInv)

  # fill the bounding rectangle
  for x in xStart..<xEnd:
    for y in yStart..<yEnd:
      let destV =  vec3(float32(x) + 0.5, float32(y) + 0.5, 0)
      let srcV = roundPixelVec(matInv * destV)
      if srcImage.inside(int srcV.x, int srcV.y):
        var rgba = srcImage.getRgba(int srcV.x, int srcV.y)
        destImage.putRgba(x, y, rgba)


proc blitWithAlpha*(destImage: Image, srcImage: Image, mat: Mat4) =
  ## Blits one image onto another using matrix with alpha blending
  let matInv = mat.inverse()
  let (xStart, yStart, xEnd, yEnd) = computeBounds(destImage, srcImage, mat, matInv)

  # compute movement vectors
  let start = matInv * vec3(0.5, 0.5, 0)
  let stepX = matInv * vec3(1.5, 0.5, 0) - start
  let stepY = matInv * vec3(0.5, 1.5, 0) - start

  # fill the bounding rectangle
  for x in xStart..<xEnd:
    for y in yStart..<yEnd:
      let srcV = roundPixelVec(start + stepX * float32(x) + stepY * float32(y))
      if srcImage.inside(int srcV.x, int srcV.y):
        var rgba = srcImage.getRgba(srcV.x, srcV.y)
        if rgba.a == uint8(255):
          destImage.putRgba(x, y, rgba)
        elif rgba.a > uint8(0):
          let destRgba = destImage.getRgba(x, y)
          let a = float(rgba.a)/255.0
          rgba.r = uint8(float(destRgba.r) * (1-a) + float(rgba.r) * a)
          rgba.g = uint8(float(destRgba.g) * (1-a) + float(rgba.g) * a)
          rgba.b = uint8(float(destRgba.b) * (1-a) + float(rgba.b) * a)
          rgba.a = 255
          destImage.putRgba(x, y, rgba)


proc blitWithMask*(destImage: Image, srcImage: Image, mat: Mat4, color: ColorRGBA) =
  ## Blits one image onto another using matrix with masking color
  let matInv = mat.inverse()
  let (xStart, yStart, xEnd, yEnd) = computeBounds(destImage, srcImage, mat, matInv)

  # compute movement vectors
  let start = matInv * vec3(0.5, 0.5, 0)
  let stepX = matInv * vec3(1.5, 0.5, 0) - start
  let stepY = matInv * vec3(0.5, 1.5, 0) - start

  # fill the bounding rectangle
  for x in xStart..<xEnd:
    for y in yStart..<yEnd:
      let srcV = roundPixelVec(start + stepX * float32(x) + stepY * float32(y))
      if srcImage.inside(int srcV.x, int srcV.y):
        let rgba = srcImage.getRgba(srcV.x, srcV.y)
        if rgba.a > uint8 0:
          destImage.putRgba(x, y, color)


proc line*(image: Image, at, to: Vec2, rgba: ColorRGBA) =
  ## Draws a line from one at vec to to vec.
  var dx = to.x - at.x
  var dy = to.y - at.y
  var x = at.x
  while true:
    if dx == 0:
      break
    var y = at.y + dy * (x - at.x) / dx
    image.putRgbaSafe(int x, int y, rgba)
    if at.x < to.x:
      x += 1
      if x > to.x:
        break
    else:
      x -= 1
      if x < to.x:
        break

  var y = at.y
  while true:
    if dy == 0:
      break
    var x = at.x + dx * (y - at.y) / dy
    image.putRgbaSafe(int x, int y, rgba)
    if at.y < to.y:
      y += 1
      if y > to.y:
        break
    else:
      y -= 1
      if y < to.y:
        break


proc fillRect*(image: Image, rect: Rect, rgba: ColorRGBA) =
  ## Draws a rectangle
  let
    minx = max(int(rect.x), 0)
    maxx = min(int(rect.x + rect.w), image.width)
    miny = max(int(rect.y), 0)
    maxy = min(int(rect.y + rect.h), image.height)
  for x in minx ..< maxx:
    for y in miny ..< maxy:
      image.putRgba(x, y, rgba)


proc strokeRect*(image: var Image, rect: Rect, color: ColorRGBA) =
  let
    at = rect.xy
    wh = rect.wh - vec2(1, 1) # line width
  image.line(at, at + vec2(wh.x, 0), color)
  image.line(at + vec2(wh.x, 0), at + vec2(wh.x, wh.y), color)
  image.line(at + vec2(0, wh.y), at + vec2(wh.x, wh.y), color)
  image.line(at + vec2(0, wh.y), at, color)


proc minifyBy2*(image: Image): Image =
  ## Scales the image down by an integer scale.
  result = newImage(image.width div 2, image.height div 2, image.channels)
  for x in 0..<result.width:
    for y in 0..<result.height:
      var rgba =
          image.getRgba(x * 2 + 0, y * 2 + 0) div 4 +
          image.getRgba(x * 2 + 1, y * 2 + 0) div 4 +
          image.getRgba(x * 2 + 1, y * 2 + 1) div 4 +
          image.getRgba(x * 2 + 0, y * 2 + 1) div 4
      result.putRgba(x, y, rgba)


proc minify*(image: Image, scale: int): Image =
  ## Scales the image down by an integer scale.
  result = image
  for i in 1..<scale:
    result = result.minifyBy2()


proc magnify*(image: Image, scale: int): Image =
  ## Scales image image up by an integer scale.
  result = newImage(image.filePath, image.width * scale, image.height * scale, image.channels)
  for x in 0..<result.width:
    for y in 0..<result.height:
      var rgba =
          image.getRgba(x div scale, y div scale)
      result.putRgba(x, y, rgba)


proc fill*(image: Image, rgb: ColorRgba) =
  ## Fills the image with a solid color.
  if image.channels == 1:
    var i = 0
    while i < image.data.len:
      image.data[i + 0] = rgb.a
      i += 1
  elif image.channels == 3:
    var i = 0
    while i < image.data.len:
      image.data[i + 0] = rgb.r
      image.data[i + 1] = rgb.g
      image.data[i + 2] = rgb.b
      i += 3
  elif image.channels == 4:
    var i = 0
    while i < image.data.len:
      image.data[i + 0] = rgb.r
      image.data[i + 1] = rgb.g
      image.data[i + 2] = rgb.b
      image.data[i + 3] = rgb.a
      i += 4
  else:
    raise newException(Exception, "File format not supported")


proc getSubImage*(image: Image, x, y, w, h: int): Image =
  ## Gets a sub image of the main image
  result = newImage(w, h, image.channels)
  for x2 in 0..<w:
    for y2 in 0..<h:
      result.putRgba(x2, y2, image.getRgba(x2 + x, y2 + y))


proc removeAlpha*(image: Image) =
  ## Removes alpha channel from the images by:
  ## Setting it to 255 everywhere.
  for y in 0 ..< image.height:
    for x in 0 ..< image.width:
      var rgba = image.getRgba(x, y)
      rgba.a = 255
      image.putRgba(x, y, rgba)


proc alphaBleed*(image: Image) =
  ## PNG saves space by encoding alpha = 0 areas as black.
  ## but scaling such images lets the black or gray come out.
  ## This bleeds the real colors into invisable space

  proc minifyBy2Alpha(image: Image): Image =
    ## Scales the image down by an integer scale.
    result = newImage(image.width div 2, image.height div 2, image.channels)
    for x in 0..<result.width:
      for y in 0..<result.height:
        var
          sumR = 0
          sumG = 0
          sumB = 0
          count = 0
        proc use(rgba: ColorRGBA) =
          if rgba.a > 0.uint8:
            sumR += int rgba.r
            sumG += int rgba.g
            sumB += int rgba.b
            count += 1
        use image.getRgba(x * 2 + 0, y * 2 + 0)
        use image.getRgba(x * 2 + 1, y * 2 + 0)
        use image.getRgba(x * 2 + 1, y * 2 + 1)
        use image.getRgba(x * 2 + 0, y * 2 + 1)
        if count > 0:
          var rgba: ColorRGBA
          rgba.r = uint8(sumR div count)
          rgba.g = uint8(sumG div count)
          rgba.b = uint8(sumB div count)
          rgba.a = 255
          result.putRgba(x, y, rgba)

  # scale image down in layers, only using opaque pixels
  var layers: seq[Image]
  var min = image.minifyBy2Alpha()
  while min.width >= 1 and min.height >= 1:
    layers.add min
    min = min.minifyBy2Alpha()

  # walk over all transparent pixels, going up layers to find best colors
  for x in 0 ..< image.width:
    for y in 0 ..< image.height:
      var rgba = image.getRgba(x, y)
      if rgba.a == 0:
        var
          xs = x
          ys = y
        for l in layers:
          xs = min(xs div 2, l.width - 1)
          ys = min(ys div 2, l.height - 1)
          rgba = l.getRgba(xs, ys)
          if rgba.a > 0.uint8:
            break
        rgba.a = 0
      image.putRgba(x, y, rgba)

