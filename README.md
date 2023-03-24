<h1 tabindex="-1" dir="auto"><a href="http://troy.sornson.io/cr-image" target="_blank">Crystal Image (Processing)</a></h1>

This shard aims to provide feature rich image processing abilities, both for the purpose of
image manipulation as well as feature / information extraction from those images.

The code here takes imense inspiration from [Pluto](https://github.com/phenopolis/pluto) and [Stumpy](https://github.com/stumpycr/stumpy_core), with
an eventual goal to be able to convert between images of this and those libraries.

All sample images used are from [Unsplash](https://unsplash.com/).

## Installation

1. Add the dependency to your `shard.yml`:

   ```yaml
   dependencies:
     cr-image:
       github: vici37/cr-image
   ```

2. Run `shards install`

## Usage

CrImage supports the formats:
* PPM
* JPEG (requires `libturbojpeg`)
* PNG (requirens `libspng`)
* WebP (requires `libwebp`)

For the formats that require a linked library, they must be `require`d explicitly:

```crystal
require "cr-image"
require "cr-image/jpeg"
require "cr-image/png"
require "cr-image/webp"

# Or, alternatively
require "cr-image/all_formats"
```

### Example

Assuming an image `moon.jpg` already exists

<img src="https://raw.githubusercontent.com/Vici37/cr-image/master/docs/images/moon.jpg" alt="Picture of moon"/>

```crystal
require "cr-image"

image = CrImage::RGBAImage.open("moon.jpg")

# create a mask identifying all pixels with light (i.e. the moon)
moon_mask = image
  .to_gray
  .threshold(8) # pixels are UInt8, with 0 as black and 255 as white

# Crop out the moon from the image, and save it to a new file
image.crop(
  moon_mask.region # smallest area that encompasses all true bits in mask
).save("moon_cropped.jpg")

```

Yields this image:

<img src="https://raw.githubusercontent.com/Vici37/cr-image/master/docs/images/moon_cropped.jpg" alt="Cropped example of moon"/>

[See documentation](http://troy.sornson.io/cr-image/) for more examples.

### [Pluto](https://github.com/phenopolis/pluto) and [Stumpy](https://github.com/stumpycr/stumpy_core) Conversion

If your library or application already uses Pluto or Stumpy and you want to use
some of the functionality of this library, CrImage also provides some optional
conversion methods:

```crystal
require "cr-image/pluto"
pluto_image # => Pluto::ImageRGBA
pluto_image_rgba.to_crimage # => CrImage::RGBAImage

cr_image # => CrImage::RGBAImage
cr_image.to_pluto # => Pluto::ImageRGBA
```

```crystal
require "cr-image/stumpy"
stumpy_canvas # => StumpyCore::Canvas
stumpy_canvas.to_crimage # => CrImage::RGBAImage

cr_image # => CrImage::RGBAImage
cr_image.to_stumpy # => StumpyCore::Canvas
```

*NOTE:* Stumpy uses `UInt16` for its underlying raw image storage per channel per pixel, while Pluto and
CrImage uses `UInt8`. Converting from a Stumpy `Canvas` object to `RGBAImage` may lose quality if the original
image used 16 bit color channels (i.e. 16-bit PNG). Most image formats tend to use 8-bit color channels.

## Development

This requires `libwebp`, `libspng`, and `libturbojpeg` to run. Then:

```
> make test
```

To ensure all tests run and pass.

## Contributing

1. [Fork it](https://github.com/Vici37/cr-image/fork)
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

## Contributors

- [Troy Sornson](https://github.com/Vici37) - creator and maintainer
