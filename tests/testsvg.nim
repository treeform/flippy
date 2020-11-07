import flippy, flippy/paths, flippy/svg

when isMainModule:
  var img = readSvg(readFile("tests/Ghostscript_Tiger.svg"))
  img.save("tests/Ghostscript_Tiger.png")
