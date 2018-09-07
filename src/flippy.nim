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


proc getRgba*(image: Image, x, y: int): ColorRGBA =
  ## Gets a color with (x, y) cordinates.
  assert x >= 0 and x < image.width
  assert y >= 0 and y < image.height
  if image.channels == 1:
    result.r = image.data[(image.width * y + x)]
    result.g = image.data[(image.width * y + x)]
    result.b = image.data[(image.width * y + x)]
  elif image.channels == 3:
    result.r = image.data[(image.width * y + x) * 3 + 0]
    result.g = image.data[(image.width * y + x) * 3 + 1]
    result.b = image.data[(image.width * y + x) * 3 + 2]
  elif image.channels == 4:
    result.r = image.data[(image.width * y + x) * 4 + 0]
    result.g = image.data[(image.width * y + x) * 4 + 1]
    result.b = image.data[(image.width * y + x) * 4 + 2]
    result.a = image.data[(image.width * y + x) * 4 + 3]
  else:
    quit("not supported " & $image)


proc getRgba*(image: Image, x, y: float64): ColorRGBA =
  ## Gets a pixel as (x, y) floats (does not do blending)
  getRgba(image, int x, int y)


proc putRgba*(image: Image, x, y: int, rgb: ColorRGBA) =
  ## Puts a ColorRGBA pixel back.
  if not(x >= 0 and x < image.width): return
  if not(y >= 0 and y < image.height): return
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


proc putRgba*(image: Image, x, y: float64, rgb: ColorRGBA) =
  ## Puts a ColorRGBA pixel back  as x, y floats (does not do blending).
  putRgba(image, int x, int y, rgb)


proc blit*(destImage: var Image, srcImage: Image, src, dest: Rect) =
  ## Blits rectange from onge image to the other image.
  assert src.w == dest.w and src.h == dest.h
  for x in 0..<int(src.w):
    for y in 0..<int(src.h):
      var rgba = srcImage.getRgba(int(src.x) + x, int(src.y) + y)
      destImage.putRgba(int(dest.x) + x, int(dest.y) + y, rgba)


proc line*(image: var Image, at, to: Vec2, rgba: ColorRGBA) =
  ## Draws a line from one at vec to to vec.
  var dx = to.x - at.x
  var dy = to.y - at.y
  var x = at.x
  while true:
    if dx == 0:
      break
    var y = at.y + dy * (x - at.x) / dx
    image.putRgba(x, y, rgba)
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
    image.putRgba(x, y, rgba)
    if at.y < to.y:
      y += 1
      if y > to.y:
        break
    else:
      y -= 1
      if y < to.y:
        break


proc minifyBy2(image: Image): Image =
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
  for x in 0..<image.width:
    for y in 0..<image.height:
      if image.channels == 1:
         image.data[(image.width * y + x)] = rgb.a
      elif image.channels == 3:
        image.data[(image.width * y + x) * 3 + 0] = rgb.r
        image.data[(image.width * y + x) * 3 + 1] = rgb.g
        image.data[(image.width * y + x) * 3 + 2] = rgb.b
      elif image.channels == 4:
        image.data[(image.width * y + x) * 4 + 0] = rgb.r
        image.data[(image.width * y + x) * 4 + 1] = rgb.g
        image.data[(image.width * y + x) * 4 + 2] = rgb.b
        image.data[(image.width * y + x) * 4 + 3] = rgb.a
      else:
        raise newException(Exception, "File format not supported")