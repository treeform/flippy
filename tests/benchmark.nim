import flippy, times, vmath, chroma, std/monotimes, strformat

proc getTicks*(): int =
  getMonoTime().ticks.int

proc echoNs(delta: int) =
  echo &"{delta:>16} ns"

template measure(body: untyped) =
  let before = getTicks()
  body
  let after = getTicks()
  echoNs(after - before)

proc main() =

  block:
    echo "blit with pos 16mb"
    var
      src = newImage(4000, 4000, 4)
      dst = newImage(4000, 4000, 4)
    for y in 0 ..< src.height:
      for x in 0 ..< src.width:
        let v = uint8((x xor y) and 0xff)
        src.putRgba(x, y, ColorRGBA(r: v, g: v, b: v, a: 255))
    measure:
      dst.blit(src, vec2(0.0, 0.0))

  block:
    echo "blit with rect 16mb"
    var
      src = newImage(4000, 4000, 4)
      dst = newImage(4000, 4000, 4)
    for y in 0 ..< src.height:
      for x in 0 ..< src.width:
        let v = uint8((x xor y) and 0xff)
        src.putRgba(x, y, ColorRGBA(r: v, g: v, b: v, a: 255))
    measure:
      dst.blit(
        src,
        rect(0.0, 0.0, src.height.float32, src.width.float32),
        rect(0.0, 0.0, src.height.float32, src.width.float32)
      )

  block:
    echo "blit unsafe 16mb"
    var
      src = newImage(4000, 4000, 4)
      dst = newImage(4000, 4000, 4)
    for y in 0 ..< src.height:
      for x in 0 ..< src.width:
        let v = uint8((x xor y) and 0xff)
        src.putRgba(x, y, ColorRGBA(r: v, g: v, b: v, a: 255))
    measure:
      dst.blitUnsafe(
        src,
        rect(0.0, 0.0, src.height.float32, src.width.float32),
        rect(0.0, 0.0, src.height.float32, src.width.float32)
      )

  block:
    echo "blit safe theoretical (non memCopy) 16mb"
    var
      src = newImage(4000, 4000, 4)
      dst = newImage(4000, 4000, 4)
    for y in 0 ..< src.height:
      for x in 0 ..< src.width:
        let v = uint8((x xor y) and 0xff)
        src.putRgba(x, y, ColorRGBA(r: v, g: v, b: v, a: 255))
    #changed inner loop and outer loop of flippy.blit for continuous memory access
    proc blit2(destImage: Image, srcImage: Image, pos: Vec2) =
      for y in 0..<int(srcImage.height):
        for x in 0..<int(srcImage.width):
          var rgba = srcImage.getRgba(x, y)
          destImage.putRgba(int(pos.x) + x, int(pos.y) + y, rgba)
    measure:
      dst.blit2(src, vec2(0.0, 0.0))

  block:
    echo "blit theoretical (non memCopy) 16mb"
    var
      src = newImage(4000, 4000, 4)
      dst = newImage(4000, 4000, 4)
    for y in 0 ..< src.height:
      for x in 0 ..< src.width:
        let v = uint8((x xor y) and 0xff)
        src.putRgba(x, y, ColorRGBA(r: v, g: v, b: v, a: 255))
    #changed inner loop and outer loop of flippy.blit for continuous memory access
    proc blit2(destImage: Image, srcImage: Image, pos: Vec2) =
      for y in 0..<int(srcImage.height):
        for x in 0..<int(srcImage.width):
          var rgba = srcImage.getRgba(x, y)
          destImage.putRgbaUnsafe(int(pos.x) + x, int(pos.y) + y, rgba)
    measure:
      dst.blit2(src, vec2(0.0, 0.0))

  block:
    echo "minify 2 16mb"
    var
      src = newImage(4000, 4000, 4)
    measure:
      let img = src.minify(2)

  block:
    echo "magnify 2 16mb"
    var
      src = newImage(4000, 4000, 4)
    measure:
      let img = src.magnify(2)

main()
