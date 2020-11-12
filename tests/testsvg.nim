import flippy, flippy/paths, flippy/svg, os, strutils

when isMainModule:
  var img = readSvg(readFile("tests/Ghostscript_Tiger.svg"))
  img.save("tests/Ghostscript_Tiger.png")

  # for f in walkDirRec("/p/svgwg/specs/paths"):
  #   if f.endsWith(".svg"):
  #     echo f
  #     var img = readSvg(readFile(f))
  #     img.save(f & ".png")
