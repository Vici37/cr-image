require "./cr-image"
require "pluto"

module Pluto
  class ImageRGBA
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
