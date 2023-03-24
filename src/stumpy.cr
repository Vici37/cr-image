require "./cr-image"
require "stumpy_core"

# A module owned by [StumpyCr](https://github.com/stumpycr/stumpy_core)
module StumpyCore
  class Canvas
    def to_crimage : CrImage::RGBAImage
      size = width * height
      red = Array(UInt8).new(size)
      green = Array(UInt8).new(size)
      blue = Array(UInt8).new(size)
      alpha = Array(UInt8).new(size)

      each_row do |row|
        row.each do |rgba|
          red << (rgba.r >> 8).to_u8
          green << (rgba.g >> 8).to_u8
          blue << (rgba.b >> 8).to_u8
          alpha << (rgba.a >> 8).to_u8
        end
      end

      CrImage::RGBAImage.new(red, green, blue, alpha, width, height)
    end
  end
end

module CrImage
  class RGBAImage
    def to_stumpy : StumpyCore::Canvas
      StumpyCore::Canvas.new(width, height) do |x, y|
        color = self[x, y]
        StumpyCore::RGBA.new(color.red.to_u16 << 8, color.green.to_u16 << 8, color.blue.to_u16 << 8, color.alpha.to_u16 << 8)
      end
    end
  end

  class GrayscaleImage
    def to_stumpy : StumpyCore::Canvas
      StumpyCore::Canvas.new(width, height) do |x, y|
        color = self[x, y]
        StumpyCore::RGBA.new(color.gray.to_u16 << 8, color.gray.to_u16 << 8, color.gray.to_u16 << 8, color.alpha.to_u16 << 8)
      end
    end
  end
end
