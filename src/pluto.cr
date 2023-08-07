require "./cr-image"
require "pluto"

# This project was initially a fork of [Pluto](https://github.com/phenopolis/pluto/), and so can very easily convert
# between the underlying format used by `CrImage` and `Pluto`. To easily convert a `Pluto` image to `CrImage`, simply:
#
# ```
# require "cr-image/pluto"
#
# image                     # => Pluto::ImageRGBA
# image.to_crimage          # => CrImage::RGBAImage
# image.to_crimage.to_pluto # => Pluto::ImageRGBA
# ```
# This also works with `Pluto::ImageGA` and `CrImage::GrayscaleImage`, respectively.
#
# > Why are `ImageRGBA` and `RGBAImage` names mirrored?
#
# The current `CrImage` names are a carry over from when originally forked from `Pluto`. However, after `Pluto` renamed `RGBAImage` to `ImageRGBA`, I noticed it became
# more difficult to visually distinguish between `ImageRGBA` and `ImageGA`, as opposed to `RGBAImage` and `GrayscaleImage`, so I kept the older names.
module Pluto
  class ImageRGBA
    # Con
    def to_crimage : CrImage::RGBAImage
      CrImage::RGBAImage.new(red.clone, green.clone, blue.clone, alpha.clone, width, height)
    end
  end

  class ImageGA
    def to_crimage : CrImage::GrayscaleImage
      new(gray.clone, alpha.clone, width, height)
    end
  end
end

module CrImage
  class RGBAImage
    def to_pluto : Pluto::ImageRGBA
      Pluto::ImageRGBA.new(red.clone, green.clone, blue.clone, alpha.clone, width, height)
    end
  end

  class GrayscaleImage
    def to_pluto : Pluto::ImageGA
      Pluto::ImageGA.new(gray.clone, alpha.clone, width, height)
    end
  end
end
