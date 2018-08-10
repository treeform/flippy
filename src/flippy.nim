import stb_image/read as stbi
import stb_image/write as stbiw
import math
import os
import strutils
import vmath
import print
import chroma


type Image* = ref object
  filePath*: string
  width*: int
  height*: int
  channels*: int
  format*: int
  data*: seq[uint8]


proc `+`(a, b: ColorRGBA): ColorRGBA =
  result.r = a.r + b.r
  result.g = a.g + b.g
  result.b = a.b + b.b
  result.a = a.a + b.a


proc `div`(rgba: ColorRGBA; i: uint8): ColorRGBA =
  result.r = rgba.r div i
  result.g = rgba.g div i
  result.b = rgba.b div i
  result.a = rgba.a div i


proc `$`*(image: Image): string =
  if image.filePath != nil:
    return "<Image " & image.filePath & " " & $image.width & "x" & $image.height & ":" & $image.channels & ">"
  else:
    return "<Image empty>"


proc newImage*(width, height, channels: int): Image =
  var image = new Image
  image.width = width
  image.height = height
  image.channels = channels
  image.data = newSeq[uint8](width*height*channels)
  return image


proc newImage*(filePath: string, width, height, channels: int): Image =
  var image = newImage(width, height, channels)
  image.filePath = filePath
  return image


proc loadImage*(filePath: string): Image =
  var image = new Image
  image.filePath = filePath
  image.data = stbi.load(
    image.filePath,
    image.width,
    image.height,
    image.channels,
    stbi.Default)
  return image


proc save*(image: Image) =
  var sucess = writePNG(
    image.filePath,
    image.width,
    image.height,
    image.channels,
    image.data)
  if not sucess:
    raise newException(Exception, "Failed to save Image: " & image.filePath)


proc save*(image: Image, filePath: string) =
  image.filePath = filePath
  image.save()


proc getRgba*(image: Image, x, y: int): ColorRGBA =
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
  getRgba(image, int x, int y)


proc putRgba*(image: Image, x, y: int, rgb: ColorRGBA) =
  if image.channels == 3:
    image.data[(image.width * y + x) * 3 + 0] = rgb.r
    image.data[(image.width * y + x) * 3 + 1] = rgb.g
    image.data[(image.width * y + x) * 3 + 2] = rgb.b
  if image.channels == 4:
    image.data[(image.width * y + x) * 4 + 0] = rgb.r
    image.data[(image.width * y + x) * 4 + 1] = rgb.g
    image.data[(image.width * y + x) * 4 + 2] = rgb.b
    image.data[(image.width * y + x) * 4 + 3] = rgb.a
  else:
    quit("not supported")


proc putRgba*(image: Image, x, y: float64, rgb: ColorRGBA) =
  putRgba(image, int x, int y, rgb)


proc blit*(destImage: var Image, srcImage: Image, src, dest: Rect) =
  assert src.w == dest.w and src.h == dest.h
  for x in 0..<src.w:
    for y in 0..<src.h:
      var rgba = srcImage.getRgba(src.x + x, src.y + y)
      destImage.putRgba(dest.x + x, dest.y + y, rgba)


proc drawLine*(image: var Image, at, to: Vec2, rgba: ColorRGBA) =
  #echo "draw line", at, " to ", to
  var dx = to.x - at.x
  var dy = to.y - at.y
  var x = at.x
  while true:
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


proc minifyBy2*(image: Image): Image =
  result = newImage(image.width div 2, image.height div 2, image.channels)
  for x in 0..<result.width:
    for y in 0..<result.height:
      var rgba =
          image.getRgba(x*2+0, y*2+0) div 4 +
          image.getRgba(x*2+1, y*2+0) div 4 +
          image.getRgba(x*2+1, y*2+1) div 4 +
          image.getRgba(x*2+0, y*2+1) div 4

      result.putRgba(x, y, rgba)


proc magnify*(image: Image, scale: int): Image =
  result = newImage(image.filePath, image.width * scale, image.height * scale, image.channels)
  for x in 0..<result.width:
    for y in 0..<result.height:
      var rgba =
          image.getRgba(x div scale, y div scale)
      result.putRgba(x, y, rgba)


proc fill*(image: Image, rgb: ColorRgba) =
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