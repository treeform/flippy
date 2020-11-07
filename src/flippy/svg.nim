## Load and Save SVG files.

import chroma, flippy, flippy/paths, vmath, xmlparser, xmltree,
  strutils, strutils, chroma/blends

var nPaths = 0
var tmp: Image

proc draw(img: Image, matStack: var seq[Mat3], xml: XmlNode) =
  #if nPaths > 0: return

  #print xml.tag

  var fillColor: ColorRGBA

  let id = xml.attr("id")

  case xml.tag:
    of "g":
      let fill = xml.attr("fill")
      let stroke = xml.attr("stroke")
      let strokeWidth = xml.attr("stroke-width")
      let transform = xml.attr("transform")

      if transform != "":
        if transform.startsWith("matrix("):
          echo transform
          let arr = transform[7..^2].split(",")
          echo arr
          assert arr.len == 6
          var m = mat3()
          m[0] = parseFloat(arr[0])
          m[1] = parseFloat(arr[1])
          m[3] = parseFloat(arr[2])
          m[4] = parseFloat(arr[3])
          m[6] = parseFloat(arr[4])
          m[7] = parseFloat(arr[5])
          matStack.add(matStack[^1] * m)
        else:
          raise newException(ValueError, "Unsupported transform: " & transform)

      #print fill
      if fill != "none" and fill != "":
        fillColor = parseHtmlColor(fill).rgba
      for child in xml:
        if child.tag == "path":
          let d = child.attr("d")
          #print d
          tmp.fillPath(d, fillColor, mat = matStack[^1])
          img.blitWithBlendMode(tmp, Normal, vec2(0, 0))
          inc nPaths
        else:
          img.draw(matStack, child)

      if transform != "":
        discard matStack.pop()

    else:
      raise newException(ValueError, "Unsupported tag: " & xml.tag )

proc readSvg*(data: string): Image =
  ## Read an SVG font from a stream.
  var xml = parseXml(data)

  echo "here"
  assert xml.tag == "svg"
  var viewBox = xml.attr "viewBox"
  let box = viewBox.split(" ")
  assert parseInt(box[0]) == 0
  assert parseInt(box[1]) == 0
  let w = parseInt(box[2])
  let h = parseInt(box[3])
  #print w, h
  result = newImage(w, h, 4)
  tmp = result.copy()

  var matStack = @[mat3()]
  for n in xml:
    result.draw(matStack, n)
