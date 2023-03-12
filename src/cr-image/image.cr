require "./bindings/*"
require "./format/*"
require "./operation/*"

abstract class CrImage::Image
  macro inherited
    include Format::JPEG
    include Format::PPM
    include Format::WebP
    include Format::PNG

    include Operation::BilinearResize
    include Operation::BoxBlur
    include Operation::Brightness
    include Operation::ChannelSwap
    include Operation::Contrast
    include Operation::GaussianBlur
    include Operation::HorizontalBlur
    include Operation::VerticalBlur
    include Operation::Crop
    include Operation::Draw
    include Format::Save
    extend Format::Open

    include Operation::MaskApply
  end

  abstract def red : Array(UInt8)
  abstract def green : Array(UInt8)
  abstract def blue : Array(UInt8)
  abstract def alpha : Array(UInt8)
  abstract def width : Int32
  abstract def height : Int32
  abstract def size : Int32

  abstract def each_channel(& : (Array(UInt8), ChannelType) -> Nil) : Nil
  abstract def [](channel_type : ChannelType) : Array(UInt8)
  abstract def []=(channel_type : ChannelType, channel : Array(UInt8)) : Array(UInt8)

  private def index_of(x : Int, y : Int) : Int
    y * width + x
  end
end
