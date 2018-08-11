# Flippy

Flippy is a simple 2d image and drawing library.

See api reference: https://treeform.github.io/flippy/

Basic ussage:

```nim
import flippy, chroma, vmath

var image = loadImage("tests/lenna.png")
echo image
echo image.getRgba(100, 100)

image.putRgba(10, 10, rgba(255, 0, 0, 255))

blit(image, image, rect(0, 0, 100, 100), rect(100, 100, 100, 100))

image.line(vec2(11, 11), vec2(100, 100), rgba(0, 0, 0, 255))

var bigImage = image.magnify(2)

image.save("tests/lenna2.png")
```

Converts

![Alt text](tests/lenna.png?raw=true "Title")

Into

![Alt text](tests/lenna2.png?raw=true "Title")

