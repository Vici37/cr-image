# Crystal Image (Processing)

This shard aims to provide feature rich image processing abilities, both for the purpose of
image manipulation as well as feature / information extraction from those images.

The code here takes imense inspiration from (Pluto)[https://github.com/phenopolis/pluto] and (Stumpy)[https://github.com/stumpycr/stumpy_core], with
an eventual goal to be able to convert between images of this and those libraries.

## Installation

1. Add the dependency to your `shard.yml`:

   ```yaml
   dependencies:
     cr-image:
       github: vici37/cr-image
   ```

2. Run `shards install`

## Usage

Assuming an image `moon.jpg` already exists:

```crystal
require "cr-image"

image = CrImage::RGBAImage.open("moon.jpg")

# create a mask identifying all pixels with light (i.e. the moon)
moon_mask = image
  .to_gray
  .threshold(8) # pixels ar UInt8, so 0 is blank, 255 is white

# Crop out the moon from the image, and save it to a new file
image.apply(moon_mask).save("moon_cropped.jpg")

```

See documentation (COMING SOON!) for more examples.

## Development

This requires `libwebp`, `libspng`, and `libturbojpeg` to run.

## Contributing

1. Fork it (<https://github.com/your-github-user/cr-image/fork>)
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

## Contributors

- [Troy Sornson](https://github.com/your-github-user) - creator and maintainer
