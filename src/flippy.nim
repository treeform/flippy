import math, os
import stb_image/read as stbi
import stb_image/write as stbiw
import vmath, chroma
#import print, strutils


type Image* = ref object
  ## Main image object that holds the bitmap data.
  filePath*: string
  width*: int
  height*: int
  channels*: int
  format*: int
  data*: seq[uint8]


proc `+`[T: ColorRGBA | Color](a, b: T): T =
  ## Adds two colors together.
  result.r = a.r + b.r
  result.g = a.g + b.g
  result.b = a.b + b.b
  result.a = a.a + b.a


proc `-`[T: ColorRGBA | Color](a, b: T): T =
  ## Subtracts two colors.
  result.r = a.r - b.r
  result.g = a.g - b.g
  result.b = a.b - b.b
  result.a = a.a - a.a


proc `+`[T: ColorRGBA | Color](a: T, b: uint8): T =
  ## Adds constant to color.
  result.r = a.r + b
  result.g = a.g + b
  result.b = a.b + b
  result.a = a.a + b


proc `-`[T: ColorRGBA | Color](a: T, b: uint8): T =
  ## Subtracts constant from color.
  result.r = a.r - b
  result.g = a.g - b
  result.b = a.b - b
  result.a = a.a - b


proc `*`[T: ColorRGBA | Color](rgba: T; i: float): T =
  ## Multiply color by constant.
  result.r = uint8(float(rgba.r) * i)
  result.g = uint8(float(rgba.g) * i)
  result.b = uint8(float(rgba.b) * i)
  result.a = uint8(float(rgba.a) * i)


proc `div`[T: ColorRGBA | Color](rgba: T; i: uint8): T =
  ## Integer divide a color by an integer amount.
  result.r = rgba.r div i
  result.g = rgba.g div i
  result.b = rgba.b div i
  result.a = rgba.a div i


proc `/`[T: ColorRGBA | Color](color: T; v: float): T =
  ## Divide a color by an float amount.
  result.r = color.r / v
  result.g = color.g / v
  result.b = color.b / v
  result.a = color.a / v


proc `$`*(image: Image): string =
  ## Display the image path, size and channels.
  if image.filePath.len > 0:
    return "<Image " & image.filePath & " " & $image.width & "x" & $image.height & ":" & $image.channels & ">"
  else:
    return "<Image " & $image.width & "x" & $image.height & ":" & $image.channels & ">"


proc newImage*(width, height, channels: int): Image =
  ## Creates a new image with appropriate dimensions.
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
  ## Returns true if x,y is inside the image.
  x >= 0 and x < image.width and y >= 0 and y < image.height


proc getRgba*(image: Image, x, y: int): ColorRGBA {.inline.} =
  ## Gets a color from (x, y) coordinates.
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
  ## Gets a pixel as (x, y) floats.
  getRgba(image, int x, int y)


proc getRgbaSafe*(image: Image, x, y: int): ColorRGBA {.inline.} =
  ## Gets a pixel as (x, y) but returns transparency if next sampled outside.
  if image.inside(x, y):
    return image.getRgba(x, y)


proc putRgba*(image: Image, x, y: int, rgba: ColorRGBA) {.inline.} =
  ## Puts a ColorRGBA pixel back.
  if image.channels == 3:
    image.data[(image.width * y + x) * 3 + 0] = rgba.r
    image.data[(image.width * y + x) * 3 + 1] = rgba.g
    image.data[(image.width * y + x) * 3 + 2] = rgba.b
  elif image.channels == 4:
    image.data[(image.width * y + x) * 4 + 0] = rgba.r
    image.data[(image.width * y + x) * 4 + 1] = rgba.g
    image.data[(image.width * y + x) * 4 + 2] = rgba.b
    image.data[(image.width * y + x) * 4 + 3] = rgba.a
  else:
    quit("not supported")


proc putRgba*(image: Image, x, y: float64, rgba: ColorRGBA) {.inline.} =
  ## Puts a ColorRGBA pixel back  as x, y floats (does not do blending).
  putRgba(image, int x, int y, rgba)


proc putRgbaSafe*(image: Image, x, y: int, rgba: ColorRGBA) {.inline.} =
  ## Puts pixel onto the image or safely ignores this command if pixel is outside the image.
  if image.inside(x, y):
    image.putRgba(x, y, rgba)


proc blit*(destImage: Image, srcImage: Image, pos: Vec2) =
  ## Blits rectangle from one image to the other image.
  for x in 0..<int(srcImage.width):
    for y in 0..<int(srcImage.height):
      var rgba = srcImage.getRgba(x, y)
      destImage.putRgbaSafe(int(pos.x) + x, int(pos.y) + y, rgba)


proc blit*(destImage: Image, srcImage: Image, src, dest: Rect) =
  ## Blits rectangle from one image to the other image.
  assert src.w == dest.w and src.h == dest.h
  for x in 0..<int(src.w):
    for y in 0..<int(src.h):
      var rgba = srcImage.getRgba(int(src.x) + x, int(src.y) + y)
      destImage.putRgbaSafe(int(dest.x) + x, int(dest.y) + y, rgba)


proc blitWithMask*(destImage: Image, srcImage: Image, src, dest: Rect, rgba: ColorRGBA) =
  ## Blits rectangle from one image to the other image with masking color.
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
          destImage.putRgba(xdest, ydest, rgba)
        elif rgba.a > uint8(0):
          let destRgba = destImage.getRgba(xdest, ydest)
          let a = float(rgba.a)/255.0
          rgba.r = uint8(float(destRgba.r) * (1-a) + float(rgba.r) * a)
          rgba.g = uint8(float(destRgba.g) * (1-a) + float(rgba.g) * a)
          rgba.b = uint8(float(destRgba.b) * (1-a) + float(rgba.b) * a)
          rgba.a = 255
          destImage.putRgba(xdest, ydest, rgba)

proc computeBounds(destImage: Image, srcImage: Image, mat: Mat4, matInv: Mat4): (int, int, int, int) =
  # Computes the bounds.
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
  ## Rounds vector to pixel center.
  vec2(round(v.x), round(v.y))


proc blit*(destImage: Image, srcImage: Image, mat: Mat4) =
  ## Blits one image onto another using matrix with alpha blending.
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
  ## Blits one image onto another using matrix with alpha blending.
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


proc blitWithMask*(destImage: Image, srcImage: Image, mat: Mat4, rgba: ColorRGBA) =
  ## Blits one image onto another using matrix with masking color.
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
          destImage.putRgba(x, y, rgba)


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
  ## Draws a filled rectangle.
  let
    minx = max(int(rect.x), 0)
    maxx = min(int(rect.x + rect.w), image.width)
    miny = max(int(rect.y), 0)
    maxy = min(int(rect.y + rect.h), image.height)
  for x in minx ..< maxx:
    for y in miny ..< maxy:
      image.putRgba(x, y, rgba)


proc strokeRect*(image: var Image, rect: Rect, rgba: ColorRGBA) =
  ## Draws a rectangle borders only.
  let
    at = rect.xy
    wh = rect.wh - vec2(1, 1) # line width
  image.line(at, at + vec2(wh.x, 0), rgba)
  image.line(at + vec2(wh.x, 0), at + vec2(wh.x, wh.y), rgba)
  image.line(at + vec2(0, wh.y), at + vec2(wh.x, wh.y), rgba)
  image.line(at + vec2(0, wh.y), at, rgba)


proc fillCirle*(image: Image, pos: Vec2, radius: float, rgba: ColorRGBA) =
  ## Draws a filled circle with antilaised edges.
  let
    minx = max(int(pos.x - radius), 0)
    maxx = min(int(pos.x + radius), image.width)
    miny = max(int(pos.y - radius), 0)
    maxy = min(int(pos.y + radius), image.height)
  for y in miny ..< maxy:
    for x in minx ..< maxx:
      let
        pixelPos = vec2(float x, float y) + vec2(0.5, 0.5)
        pixelDist = pixelPos.dist(pos)
      if pixelDist < radius - sqrt(0.5):
        image.putRgba(x, y, rgba)
      elif pixelDist < radius + sqrt(0.5):
        var touch = 0
        const n = 5
        const r = (n - 1) div 2
        for aay in -r .. r:
          for aax in -r .. r:
            if pos.dist(pixelPos + vec2(aay / n, aax / n)) < radius:
              inc touch
        var rgbaAA = rgba
        rgbaAA.a = uint8(float(touch) * 255.0 / (n * n))
        image.putRgba(x, y, rgbaAA)


proc strokeCirle*(image: Image, pos: Vec2, radius: float, border: float, rgba: ColorRGBA) =
  ## Draws a border of circle with antilaised edges.
  let
    minx = max(int(pos.x - radius - border), 0)
    maxx = min(int(pos.x + radius + border), image.width)
    miny = max(int(pos.y - radius - border), 0)
    maxy = min(int(pos.y + radius + border), image.height)
  for y in miny ..< maxy:
    for x in minx ..< maxx:
      let
        pixelPos = vec2(float x, float y) + vec2(0.5, 0.5)
        pixelDist = pixelPos.dist(pos)
      if pixelDist > radius - border/2 - sqrt(0.5) and pixelDist < radius + border/2 + sqrt(0.5):
        var touch = 0
        const n = 5
        const r = (n - 1) div 2
        for aay in -r .. r:
          for aax in -r .. r:
            let dist = pos.dist(pixelPos + vec2(aay / n, aax / n))
            if dist > radius - border/2 and dist < radius + border/2:
              inc touch
        var rgbaAA = rgba
        rgbaAA.a = uint8(float(touch) * 255.0 / (n * n))
        image.putRgba(x, y, rgbaAA)


proc minifyBy2*(image: Image): Image =
  ## Scales the image down by an integer scale.
  result = newImage(image.width div 2, image.height div 2, image.channels)
  for x in 0..<result.width:
    for y in 0..<result.height:
      var color =
          image.getRgba(x * 2 + 0, y * 2 + 0).color / 4.0 +
          image.getRgba(x * 2 + 1, y * 2 + 0).color / 4.0 +
          image.getRgba(x * 2 + 1, y * 2 + 1).color / 4.0 +
          image.getRgba(x * 2 + 0, y * 2 + 1).color / 4.0
      result.putRgba(x, y, color.rgba)


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


proc fill*(image: Image, rgba: ColorRgba) =
  ## Fills the image with a solid color.
  if image.channels == 1:
    var i = 0
    while i < image.data.len:
      image.data[i + 0] = rgba.a
      i += 1
  elif image.channels == 3:
    var i = 0
    while i < image.data.len:
      image.data[i + 0] = rgba.r
      image.data[i + 1] = rgba.g
      image.data[i + 2] = rgba.b
      i += 3
  elif image.channels == 4:
    var i = 0
    while i < image.data.len:
      image.data[i + 0] = rgba.r
      image.data[i + 1] = rgba.g
      image.data[i + 2] = rgba.b
      image.data[i + 3] = rgba.a
      i += 4
  else:
    raise newException(Exception, "File format not supported")


proc flipHorizontal*(image: Image): Image =
  ## Flips the image around the Y axis
  result = newImage(image.width, image.height, image.channels)
  for y in 0 ..< image.height:
    for x in 0 ..< image.width:
      var rgba = image.getRgba(x, y)
      #echo image.width - x
      result.putRgba(image.width - x - 1, y, rgba)


proc flipVertical*(image: Image): Image =
  ## Flips the image around the X axis
  result = newImage(image.width, image.height, image.channels)
  for y in 0 ..< image.height:
    for x in 0 ..< image.width:
      var rgba = image.getRgba(x, y)
      result.putRgba(x, image.height - y - 1, rgba)


proc getSubImage*(image: Image, x, y, w, h: int): Image =
  ## Gets a sub image of the main image
  result = newImage(w, h, image.channels)
  for x2 in 0..<w:
    for y2 in 0..<h:
      result.putRgba(x2, y2, image.getRgba(x2 + x, y2 + y))


proc rotate90Degrees*(image: Image): Image =
  ## Rotates the image clockwize
  result = newImage(image.height, image.width, image.channels)
  for y in 0 ..< image.height:
    for x in 0 ..< image.width:
      var rgba = image.getRgba(x, y)
      result.putRgba(image.height - y - 1, x, rgba)


proc shearX*(image: Image, shear: float): Image =
  ## Shears the image horizontally; resizes to fit
  let
    offset = int(abs(float(image.height) * shear))
    offsetAdd = if shear > 0: 0 else: offset
    newWidth = image.width + offset
  var sheared = newImage(newWidth, image.height, 4)
  for y in 0 ..< image.height:
    let
      skew = shear * float(y)
      iSkew = int(floor(skew))
      fSkew = skew - float(iSkew)
    var oLeft: ColorRGBA
    for x in 1 ..< image.width:
      var
        pixel = image.getRgba(x, y)
        pixelLeft = pixel * fSkew
      # for some reason this doesn't work w/ +- operators
      # pixel = pixel - pixelLeft + oLeft
      pixel.r = pixel.r - pixelLeft.r + oLeft.r
      pixel.g = pixel.g - pixelLeft.g + oLeft.g
      pixel.b = pixel.b - pixelLeft.b + oLeft.b
      pixel.a = pixel.a - pixelLeft.a + oLeft.a
      sheared.putRgba(offsetAdd + x + iSkew, y, pixel)
      oLeft = pixelLeft
    sheared.putRgba(offsetAdd + iSkew + 1, y, rgba(0, 0, 0, 0))
  return sheared
  

proc shearY*(image: Image, shear: float): Image =
  ## Shears the image vertically; resizes to fit
  let
    offset = int(abs(float(image.width) * shear))
    offsetAdd = if shear > 0: 0 else: offset
    newHeight = image.height + offset
  var sheared = newImage(image.width, newHeight, 4)
  for x in 0 ..< image.width:
    let
      skew = shear * float(x)
      iSkew = int(floor(skew))
      fSkew = skew - float(iSkew)
    var oLeft: ColorRGBA
    for y in 1 ..< image.height:
      var
        pixel = image.getRgba(x, y)
        pixelLeft = pixel * fSkew
      # for some reason this doesn't work w/ +- operators
      # pixel = pixel - pixelLeft + oLeft
      pixel.r = pixel.r - pixelLeft.r + oLeft.r
      pixel.g = pixel.g - pixelLeft.g + oLeft.g
      pixel.b = pixel.b - pixelLeft.b + oLeft.b
      pixel.a = pixel.a - pixelLeft.a + oLeft.a
      sheared.putRgba(x, offsetAdd + y + iSkew, pixel)
      oLeft = pixelLeft
    sheared.putRgba(x, offsetAdd + iSkew + 1, rgba(0, 0, 0, 0))
  return sheared


proc rotate*(image: Image, theta: float): Image =
  ## Rotates the image by given angle (in degrees)
  ## using the 3-shear method
  # Handle easy cases and avoid precision errors
  case theta.round
    of 360 or -360: return image
    of 180 or -180: return image.flipHorizontal.flipVertical
    of 90: return image.rotate90Degrees
    else: discard
  let
    radians = degToRad(theta)
    alpha = -tan(radians / 2)
    beta = sin(radians)
    newWidth = int(abs(float(image.width) * sin(radians)) +
                   abs(float(image.height) * cos(radians)))
    newHeight = int(abs(float(image.width) * cos(radians)) +
                    abs(float(image.height) * sin(radians)))
  result = image.shearX(alpha).shearY(beta).shearX(alpha)
  return result.getSubImage(
    int((result.width - newWidth)/2),
    int((result.height - newHeight)/2),
    newWidth,
    newHeight
  )


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
  ## This bleeds the real colors into invisible space

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

