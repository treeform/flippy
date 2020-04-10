# Flippy

![Flippy Logo](docs/flippyLogo.png)

Flippy is a simple 2d image and drawing library.

Basic usage:

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
proc `$`(image: Image): string {.raises: [], tags: [].}
```

## **proc** newImage

Creates a new image with appropriate dimensions.

```nim
proc newImage(width, height, channels: int): Image {.raises: [], tags: [].}
```

## **proc** newImage

Creates a new image with a path.

```nim
proc newImage(filePath: string; width, height, channels: int): Image {.raises: [],
    tags: [].}
```

## **proc** loadImage

Loads a png image.

```nim
proc loadImage(filePath: string): Image {.raises: [], tags: [ReadIOEffect, RootEffect,
    WriteIOEffect].}
```

## **proc** save

Saves a png image.

```nim
proc save(image: Image) {.raises: [Exception], tags: [RootEffect, WriteIOEffect].}
```

## **proc** save

Sets image path and save the image.

```nim
proc save(image: Image; filePath: string) {.raises: [Exception],
                                       tags: [RootEffect, WriteIOEffect].}
```

## **proc** inside

Returns true if (x, y) is inside the image.

```nim
proc inside(image: Image; x, y: int): bool {.inline, raises: [], tags: [].}
```

## **proc** getRgba

Gets a color from (x, y) coordinates.

```nim
proc getRgba(image: Image; x, y: int): ColorRGBA {.inline, raises: [], tags: [].}
```

## **proc** getRgba

Gets a pixel as (x, y) floats.

```nim
proc getRgba(image: Image; x, y: float64): ColorRGBA {.inline, raises: [], tags: [].}
```

## **proc** getRgbaSafe

Gets a pixel as (x, y) but returns transparency if next sampled outside.

```nim
proc getRgbaSafe(image: Image; x, y: int): ColorRGBA {.inline, raises: [], tags: [].}
```

## **proc** putRgba

Puts a ColorRGBA pixel back.

```nim
proc putRgba(image: Image; x, y: int; rgba: ColorRGBA) {.inline, raises: [], tags: [].}
```

## **proc** putRgba

Puts a ColorRGBA pixel back as x, y floats (does not do blending).

```nim
proc putRgba(image: Image; x, y: float64; rgba: ColorRGBA) {.inline, raises: [], tags: [].}
```

## **proc** putRgbaSafe

Puts pixel onto the image or safely ignores this command if pixel is outside the image.

```nim
proc putRgbaSafe(image: Image; x, y: int; rgba: ColorRGBA) {.inline, raises: [], tags: [].}
```

## **proc** blit

Blits rectangle from one image to the other image.

```nim
proc blit(destImage: Image; srcImage: Image; pos: Vec2) {.raises: [], tags: [].}
```

## **proc** blit

Blits rectangle from one image to the other image.

```nim
proc blit(destImage: Image; srcImage: Image; src, dest: Rect) {.raises: [], tags: [].}
```

## **proc** blitWithMask

Blits rectangle from one image to the other image with masking color.

```nim
proc blitWithMask(destImage: Image; srcImage: Image; src, dest: Rect; rgba: ColorRGBA) {.
    raises: [], tags: [].}
```

## **proc** blit

Blits one image onto another using matrix with alpha blending.

```nim
proc blit(destImage: Image; srcImage: Image; mat: Mat4) {.raises: [], tags: [].}
```

## **proc** blitWithAlpha

Blits one image onto another using matrix with alpha blending.

```nim
proc blitWithAlpha(destImage: Image; srcImage: Image; mat: Mat4) {.raises: [], tags: [].}
```

## **proc** blitWithMask

Blits one image onto another using matrix with masking color.

```nim
proc blitWithMask(destImage: Image; srcImage: Image; mat: Mat4; rgba: ColorRGBA) {.
    raises: [], tags: [].}
```

## **proc** line

Draws a line from one at vec to to vec.

```nim
proc line(image: Image; at, to: Vec2; rgba: ColorRGBA) {.raises: [], tags: [].}
```

## **proc** fillRect

Draws a filled rectangle.

```nim
proc fillRect(image: Image; rect: Rect; rgba: ColorRGBA) {.raises: [], tags: [].}
```

## **proc** strokeRect

Draws a rectangle borders only.

```nim
proc strokeRect(image: Image; rect: Rect; rgba: ColorRGBA) {.raises: [], tags: [].}
```

## **proc** fillCirle

Draws a filled circle with antialiased edges.

```nim
proc fillCirle(image: Image; pos: Vec2; radius: float; rgba: ColorRGBA) {.raises: [],
    tags: [].}
```

## **proc** strokeCirle

Draws a border of circle with antialiased edges.

```nim
proc strokeCirle(image: Image; pos: Vec2; radius: float; border: float; rgba: ColorRGBA) {.
    raises: [], tags: [].}
```

## **proc** ninePatch

Draws a 9-patch

```nim
proc ninePatch(image: Image; rect: Rect; radius, border: float; fill, stroke: ColorRGBA) {.
    raises: [], tags: [].}
```

## **proc** minifyBy2

Scales the image down by an integer scale.

```nim
proc minifyBy2(image: Image): Image {.raises: [], tags: [].}
```

## **proc** minify

Scales the image down by an integer scale.

```nim
proc minify(image: Image; scale: int): Image {.raises: [], tags: [].}
```

## **proc** magnify

Scales image image up by an integer scale.

```nim
proc magnify(image: Image; scale: int): Image {.raises: [], tags: [].}
```

## **proc** fill

Fills the image with a solid color.

```nim
proc fill(image: Image; rgba: ColorRGBA) {.raises: [Exception], tags: [].}
```

## **proc** flipHorizontal

Flips the image around the Y axis.

```nim
proc flipHorizontal(image: Image): Image {.raises: [], tags: [].}
```

## **proc** flipVertical

Flips the image around the X axis.

```nim
proc flipVertical(image: Image): Image {.raises: [], tags: [].}
```

## **proc** getSubImage

Gets a sub image of the main image.

```nim
proc getSubImage(image: Image; x, y, w, h: int): Image {.raises: [], tags: [].}
```

## **proc** rotate90Degrees

Rotates the image clockwise.

```nim
proc rotate90Degrees(image: Image): Image {.raises: [], tags: [].}
```

## **proc** rotateNeg90Degrees

Rotates the image anti-clockwise.

```nim
proc rotateNeg90Degrees(image: Image): Image {.raises: [], tags: [].}
```

## **proc** shearX

Shears the image horizontally; resizes to fit.

```nim
proc shearX(image: Image; shear: float): Image {.raises: [], tags: [].}
```

## **proc** shearY

Shears the image vertically; resizes to fit.

```nim
proc shearY(image: Image; shear: float): Image {.raises: [], tags: [].}
```

## **proc** rotate

Rotates the image by given angle (in degrees) using the 3-shear method (Paeth method)

```nim
proc rotate(image: Image; angle: float): Image {.raises: [], tags: [].}
```

## **proc** removeAlpha

Removes alpha channel from the images by: Setting it to 255 everywhere.

```nim
proc removeAlpha(image: Image) {.raises: [], tags: [].}
```

## **proc** alphaBleed

PNG saves space by encoding alpha = 0 areas as black however scaling such images lets the black or gray come out. This bleeds the real colors into invisible space.

```nim
proc alphaBleed(image: Image) {.raises: [], tags: [].}
```

## **proc** fillRoundedRect

Fills image with a rounded rectangle.

```nim
proc fillRoundedRect(image: Image; rect: Rect; radius: float; rgba: ColorRGBA) {.
    raises: [Exception], tags: [].}
```

## **proc** strokeRoundedRect

Fills image with a stroked rounded rectangle.

```nim
proc strokeRoundedRect(image: Image; rect: Rect; radius, border: float; rgba: ColorRGBA) {.
    raises: [], tags: [].}
```

## **proc** copy

Copies an image creating a new image.

```nim
proc copy(image: Image): Image {.raises: [], tags: [].}
```

## **proc** blur

Blurs the image by x and y directions.

```nim
proc blur(image: Image; xBlur: int; yBlur: int): Image {.raises: [], tags: [].}
```

