import chroma, flippy, flippy/paths, os, osproc, vmath

setCurrentDir(getCurrentDir() / "tests")

block:
  echo "pathNumbers"
  let pathStr = "M 0.1E-10 0.1e10 L2+2 L3-3 L0.1E+10-1"
  let path = parsePath(pathStr)

block:
  echo "pathStroke1"
  let image = newImage(100, 100, 4)
  let pathStr = "M 10 10 L 90 90"
  let path = parsePath(pathStr)
  let polys = commandsToPolygons(path.commands)
  let color = rgba(255, 0, 0, 255)
  let polys2 = strokePolygons(polys, 5, 5)
  image.fillPolygons(polys2, color)
  image.save("pathStroke1.png")

block:
  echo "pathStroke2"
  let image = newImage(100, 100, 4)
  let pathStr = "M 10 10 L 50 60 90 90"
  let path = parsePath(pathStr)
  let polys = commandsToPolygons(path.commands)
  let color = rgba(255, 0, 0, 255)
  let polys2 = strokePolygons(polys, 5, 5)
  image.fillPolygons(polys2, color)
  image.save("pathStroke2.png")

block:
  echo "pathStroke3"
  let image = newImage(100, 100, 4)
  let pathStr = "M 15 10 L 30 90 60 30 90 90"
  let path = parsePath(pathStr)
  let polys = commandsToPolygons(path.commands)
  let color = rgba(255, 0, 0, 255)
  let polys2 = strokePolygons(polys, 2, 5)
  image.fillPolygons(polys2, color)

  for p in polys:
    for (at, to) in p.zipline:
      image.line(at, to, rgba(0, 0, 0, 255))

  for p in polys2:
    for (at, to) in p.zipwise:
      image.line(at, to, rgba(255, 255, 255, 255))

  image.save("pathStroke3.png")

block:
  echo "pathStroke4"
  let image = newImage(100, 100, 4)
  image.strokePath(
    "M 15 10 L 30 90 60 30 90 90",
    rgba(255, 255, 0, 255),
    strokeWidth = 10
  )
  image.save("pathStroke4.png")

block:
  echo "pathBlackRectangle"
  let image = newImage(100, 100, 4)
  let pathStr = "M 10 10 H 90 V 90 H 10 L 10 10"
  let path = parsePath(pathStr)
  let polys = commandsToPolygons(path.commands)
  let color = rgba(0, 0, 0, 255)
  image.fillPolygons(polys, color)
  image.save("pathBlackRectangle.png")

block:
  echo "pathYellowRectangle"
  let image = newImage(100, 100, 4)
  image.fillPath(
    "M 10 10 H 90 V 90 H 10 L 10 10",
    rgba(255, 255, 0, 255)
  )
  image.save("pathYellowRectangle.png")

block:
  echo "pathRedRectangle"
  let image = newImage(100, 100, 4)
  var path = newPath()
  path.moveTo(10, 10)
  path.lineTo(10, 90)
  path.lineTo(90, 90)
  path.lineTo(90, 10)
  path.lineTo(10, 10)
  image.fillPath(
    path,
    rgba(255, 0, 0, 255)
  )
  image.save("pathRedRectangle.png")

block:
  echo "pathBottomArc"
  let image = newImage(100, 100, 4)
  image.fillPath(
    "M30 60 A 20 20 0 0 0 90 60 L 30 60",
    parseHtmlColor("#FC427B").rgba
  )
  image.save("pathBottomArc.png")

block:
  echo "pathHeart"
  let image = newImage(100, 100, 4)
  image.fillPath(
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
  echo "pathRotatedArc"
  let image = newImage(100, 100, 4)
  image.fillPath(
    "M 20 50 A 20 10 45 1 1 80 50 L 20 50",
    parseHtmlColor("#FC427B").rgba
  )
  image.save("pathRotatedArc.png")

block:
  echo "pathInvertedCornerArc"
  let image = newImage(100, 100, 4)
  image.fillPath(
    "M 0 50 A 50 50 0 0 0 50 0 L 50 50 L 0 50",
    parseHtmlColor("#FC427B").rgba
  )
  image.save("pathInvertedCornerArc.png")

block:
  echo "pathCornerArc"
  let image = newImage(100, 100, 4)
  image.fillPath(
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
  image.fillPath(
    path,
    rgba(255, 0, 0, 255)
  )
  image.save("pathRoundRect.png")
