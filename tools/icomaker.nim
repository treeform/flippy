## Makes icon files used in windows and favicons.
import cligen, flatty/binny, flatty/hexPrint, flippy, os

var powersOf2 = [256, 128, 64, 32, 16]

proc main(filePath: string) =
  var image = loadImage(filePath)
  assert image.width in powersOf2
  var
    images = newSeq[Image]()
    datas = newSeq[string]()

  while image.width >= 16:
    image.save("tmp.png")
    datas.add(readFile("tmp.png"))
    images.add(image)
    image = image.minifyBy2()

  var
    offset = 6 + 16 * images.len
    offsets = newSeq[int]()
  for n in 0 ..< images.len:
    offsets.add(offset)
    offset += datas[n].len

  var ico = newString(6 + 16 * images.len)
  ico.writeUint16(0, 0) # Reserved. Must always be 0.
  ico.writeUint16(2, 1) # Specifies image type: 1 for icon (.ICO) image, 2 for cursor (.CUR) image. Other values are invalid.
  ico.writeUint16(4, images.len.uint16) # Specifies number of images in the file.

  var i = 6
  for n in 0 ..< images.len:
    ico.writeUint8(i+0, images[n].width.uint8) ## 0	1	Specifies image width in pixels. Can be any number between 0 and 255. Value 0 means image width is 256 pixels.
    ico.writeUint8(i+1, images[n].width.uint8) ## 1	1	Specifies image height in pixels. Can be any number between 0 and 255. Value 0 means image height is 256 pixels.
    ico.writeUint8(i+2, 0) ## 2	1	Specifies number of colors in the color palette. Should be 0 if the image does not use a color palette.
    ico.writeUint8(i+3, 0) ## 3	1	Reserved. Should be 0.
    ico.writeUint16(i+4, 1) ## 4	2	In ICO format: Specifies color planes. Should be 0 or 1. In CUR format: Specifies the horizontal coordinates of the hotspot in number of pixels from the left.
    ico.writeUint16(i+6, 32) ## 6	2	In ICO format: Specifies bits per pixel.In CUR format: Specifies the vertical coordinates of the hotspot in number of pixels from the top.
    ico.writeUint32(i+8, datas[n].len.uint32) ## 8	4	Specifies the size of the image's data in bytes
    ico.writeUint32(i+12, offsets[n].uint32) ## 12	4	Specifies the offset of BMP or PNG data from the beginning of the ICO/CUR file
    i += 16

  for data in datas:
    ico.add(data)

  var iconPath = filePath.changeFileExt(".ico")
  echo "written to ", iconPath
  writeFile(iconPath, ico)

dispatch(main)
