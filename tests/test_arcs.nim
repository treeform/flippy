import flippy/paths, vmath

const Paths = [
  "M 20 50 A 50 40 45 0 1 80 50",
  "M 20 50 A 50 40 -45 0 1 80 50",
  "M 20 50 A 50 40 0 0 1 80 50"
]

echo "Testing rotated elliptical arc endpoints"
for pathString in Paths:
  let
    path = parsePath(pathString)
    polygons = commandsToPolygons(path.commands)
  doAssert polygons.len == 1
  doAssert polygons[0].len > 2
  doAssert length(polygons[0][0] - vec2(20, 50)) < 0.001
  doAssert length(polygons[0][^1] - vec2(80, 50)) < 0.001
