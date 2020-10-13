import chroma, flippy, flippy/paths, os, osproc, vmath

setCurrentDir(getCurrentDir() / "tests")

block:
  let image = newImage(100, 100, 4)
  let pathStr = "M 10 10 H 90 V 90 H 10 L 10 10"
  let path = parsePath(pathStr)
  let poly = commandsToPolygon(path.commands)
  let color = rgba(0, 0, 0, 255)
  image.fillPolygon(poly, color)
  image.save("pathBlackRectangle.png")

block:
  let image = newImage(100, 100, 4)
  image.fillPolygon(
    "M 10 10 H 90 V 90 H 10 L 10 10",
    rgba(255, 255, 0, 255)
  )
  image.save("pathYellowRectangle.png")

block:
  let image = newImage(100, 100, 4)
  var path = newPath()
  path.moveTo(10, 10)
  path.lineTo(10, 90)
  path.lineTo(90, 90)
  path.lineTo(90, 10)
  path.lineTo(10, 10)
  image.fillPolygon(
    path,
    rgba(255, 0, 0, 255)
  )
  image.save("pathRedRectangle.png")

block:
  let image = newImage(100, 100, 4)
  image.fillPolygon(
    "M30 60 A 20 20 0 0 0 90 60 L 30 60",
    parseHtmlColor("#FC427B").rgba
  )
  image.save("pathBottomArc.png")

block:
  let image = newImage(100, 100, 4)
  image.fillPolygon(
    """
      M 10,30
      A 20,20 0,0,1 50,30
      A 20,20 0,0,1 90,30
      Q 90,60 50,90
      Q 10,60 10,30 z
    """,
    parseHtmlColor("#FC427B").rgba
  )
  image.save("pathHeart.png")

block:
  let image = newImage(100, 100, 4)
  image.fillPolygon(
    "M 20 50 A 20 10 45 1 1 80 50 L 20 50",
    parseHtmlColor("#FC427B").rgba
  )
  image.save("pathRotatedArc.png")

block:
  let image = newImage(100, 100, 4)
  image.fillPolygon(
    "M 0 50 A 50 50 0 0 0 50 0 L 50 50 L 0 50",
    parseHtmlColor("#FC427B").rgba
  )
  image.save("pathInvertedCornerArc.png")

block:
  let image = newImage(100, 100, 4)
  image.fillPolygon(
    "M 0 50 A 50 50 0 0 1 50 0 L 50 50 L 0 50",
    parseHtmlColor("#FC427B").rgba
  )
  image.save("pathCornerArc.png")

block:
  let image = newImage(100, 100, 4)
  var path = newPath()
  let
    r = 10.0
    x = 10.0
    y = 10.0
    h = 80.0
    w = 80.0
  path.moveTo(x+r, y)
  path.arcTo(x+w, y,   x+w, y+h, r)
  path.arcTo(x+w, y+h, x,   y+h, r)
  path.arcTo(x,   y+h, x,   y,   r)
  path.arcTo(x,   y,   x+w, y,   r)
  echo "---"
  for p in path.commands:
    echo p
  echo path
  image.fillPolygon(
    path,
    rgba(255, 0, 0, 255)
  )
  image.save("pathRoundRect.png")
