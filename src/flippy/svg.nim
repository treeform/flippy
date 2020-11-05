## Load and Save SVG files.

import chroma, flippy, flippy/paths, vmath, xmlparser, xmltree, strutils, print

proc draw(img: Image, xml: XmlNode) =
  print xml.tag

  var fillColor: ColorRGBA

  let id = xml.attr("id")

  case xml.tag:
    of "g":
      let fill = xml.attr("fill")
      let stroke = xml.attr("stroke")
      let strokeWidth = xml.attr("stroke-width")
      let transform = xml.attr("transform")
      print fill
      if fill != "none" and fill != "":
        fillColor = parseHtmlColor(fill).rgba
    of "path":
      let d = xml.attr("d")
      print d
      img.fillPolygon(d, fillColor)
    else:
      raise newException(ValueError, "Unsupported tag: " & xml.tag )

  for n in xml.items:
    img.draw(n)

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
  print w, h
  result = newImage(w, h, 4)

  for n in xml.items:
    result.draw(n)


when isMainModule:
  var img = readSvg(readFile("tests/Ghostscript_Tiger.svg"))
  img.save("tests/Ghostscript_Tiger.png")
