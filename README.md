# Flippy

Flippy is a simple 2d image and drawing library.

See api reference: https://treeform.github.io/flippy/

Basic ussage:

```nim
# load an image
var image = loadImage("tests/lenna.png")
# print it out
echo image
# get a color pixel
echo image.getRgba(100, 100)
# put a color pixel
image.putRgba(10, 10, rgba(255, 0, 0, 255))
# blit a rectangular part from one place to another
blit(image, image, rect(0, 0, 100, 100), rect(100, 100, 100, 100))
# draw a line
image.line(vec2(11, 11), vec2(100, 100), rgba(0, 0, 0, 255))
# minify image by 2 or 1/2 or scale by 50%
image = image.minify(2)
# save the image to a file
image.save("tests/lenna2.png")
```

Into

![Alt text](tests/lenna2.png?raw=true "Title")


# API: flippy

```nim
import flippy
```

## **type** Image

Main image object that holds the bitmap data.

```nim
Image = ref object
  filePath*: string
  width*: int
  height*: int
  channels*: int
  format*: int
  data*: seq[uint8]

```

## **proc** `$`

Display the image path, size and channels.

```nim
proc `$`(image: Image): string 
```

## **proc** newImage

Creates a new image with appropriate dimensions.

```nim
proc newImage(width, height, channels: int): Image 
```

## **proc** newImage

Creates a new image with a path.

```nim
proc newImage(filePath: string; width, height, channels: int): Image 
```

## **proc** loadImage

Loads a png image.

```nim
proc loadImage(filePath: string): Image {.raises: [STBIException].}
```

## **proc** save

Saves a png image.

```nim
proc save(image: Image) {.raises: [Exception].}
```

## **proc** save

Sets image path and save the image.

```nim
proc save(image: Image; filePath: string) {.raises: [Exception].}
```

## **proc** inside

Returns true if x,y is inside the image.

```nim
proc inside(image: Image; x, y: int): bool {.inline.}
```

## **proc** getRgba

Gets a color from (x, y) coordinates.

```nim
proc getRgba(image: Image; x, y: int): ColorRGBA {.inline.}
```

## **proc** getRgba

Gets a pixel as (x, y) floats.

```nim
proc getRgba(image: Image; x, y: float64): ColorRGBA {.inline.}
```

## **proc** getRgbaSafe

Gets a pixel as (x, y) but returns transparency if next sampled outside.

```nim
proc getRgbaSafe(image: Image; x, y: int): ColorRGBA {.inline.}
```

## **proc** putRgba

Puts a ColorRGBA pixel back.

```nim
proc putRgba(image: Image; x, y: int; rgba: ColorRGBA) {.inline.}
```

## **proc** putRgba

Puts a ColorRGBA pixel back  as x, y floats (does not do blending).

```nim
proc putRgba(image: Image; x, y: float64; rgba: ColorRGBA) {.inline.}
```

## **proc** putRgbaSafe

Puts pixel onto the image or safely ignores this command if pixel is outside the image.

```nim
proc putRgbaSafe(image: Image; x, y: int; rgba: ColorRGBA) {.inline.}
```

## **proc** blit

Blits rectangle from one image to the other image.

```nim
proc blit(destImage: Image; srcImage: Image; pos: Vec2) 
```

## **proc** blit

Blits rectangle from one image to the other image.

```nim
proc blit(destImage: Image; srcImage: Image; src, dest: Rect) 
```

## **proc** blitWithMask

Blits rectangle from one image to the other image with masking color.

```nim
proc blitWithMask(destImage: Image; srcImage: Image; src, dest: Rect; rgba: ColorRGBA) 
```

## **proc** blit

Blits one image onto another using matrix with alpha blending.

```nim
proc blit(destImage: Image; srcImage: Image; mat: Mat4) 
```

## **proc** blitWithAlpha

Blits one image onto another using matrix with alpha blending.

```nim
proc blitWithAlpha(destImage: Image; srcImage: Image; mat: Mat4) 
```

## **proc** blitWithMask

Blits one image onto another using matrix with masking color.

```nim
proc blitWithMask(destImage: Image; srcImage: Image; mat: Mat4; rgba: ColorRGBA) 
```

## **proc** line

Draws a line from one at vec to to vec.

```nim
proc line(image: Image; at, to: Vec2; rgba: ColorRGBA) 
```

## **proc** fillRect

Draws a filled rectangle.

```nim
proc fillRect(image: Image; rect: Rect; rgba: ColorRGBA) 
```

## **proc** strokeRect

Draws a rectangle borders only.

```nim
proc strokeRect(image: var Image; rect: Rect; rgba: ColorRGBA) 
```

## **proc** fillCirle

Draws a filled circle with antilaised edges.

```nim
proc fillCirle(image: Image; pos: Vec2; radius: float; rgba: ColorRGBA) 
```

## **proc** strokeCirle

Draws a border of circle with antilaised edges.

```nim
proc strokeCirle(image: Image; pos: Vec2; radius: float; border: float; rgba: ColorRGBA) 
```

## **proc** minifyBy2

Scales the image down by an integer scale.

```nim
proc minifyBy2(image: Image): Image 
```

## **proc** minify

Scales the image down by an integer scale.

```nim
proc minify(image: Image; scale: int): Image 
```

## **proc** magnify

Scales image image up by an integer scale.

```nim
proc magnify(image: Image; scale: int): Image 
```

## **proc** fill

Fills the image with a solid color.

```nim
proc fill(image: Image; rgba: ColorRGBA) {.raises: [Exception].}
```

## **proc** flipHorizontal

Flips the image around the Y axis

```nim
proc flipHorizontal(image: Image): Image 
```

## **proc** flipVertical

Flips the image around the X axis

```nim
proc flipVertical(image: Image): Image 
```

## **proc** rotate90Degrees

Rotates the image clockwize

```nim
proc rotate90Degrees(image: Image): Image 
```

## **proc** getSubImage

Gets a sub image of the main image

```nim
proc getSubImage(image: Image; x, y, w, h: int): Image 
```

## **proc** removeAlpha

Removes alpha channel from the images by: Setting it to 255 everywhere.

```nim
proc removeAlpha(image: Image) 
```

## **proc** alphaBleed

PNG saves space by encoding alpha = 0 areas as black. but scaling such images lets the black or gray come out. This bleeds the real colors into invisible space

```nim
proc alphaBleed(image: Image) 
```

