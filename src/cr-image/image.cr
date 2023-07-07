# Common base class for `GrayscaleImage` and `RGBAImage`. All `Image`s are readable and saveable
# to the filesystem or `IO` stream.
abstract class CrImage::Image
  macro subsclasses_include(mod)
    {% for sub in @type.subclasses %}
      class ::{{sub}}
        include {{mod}}
      end
    {% end %}
  end

  macro inherited
    include Format::PPM

    include Operation::BilinearResize
    include Operation::BoxBlur
    include Operation::Brightness
    include Operation::ChannelSwap
    include Operation::Contrast
    include Operation::GaussianBlur
    include Operation::HorizontalBlur
    include Operation::VerticalBlur
    include Operation::Crop
    include Operation::Pad
    include Operation::Draw
    include Operation::HistogramEqualize
    include Format::Save
    extend Format::Open

    include Operation::MaskApply
  end

  # Return the red channel
  abstract def red : Array(UInt8)
  # Return the green channel
  abstract def green : Array(UInt8)
  # Return the blue channel
  abstract def blue : Array(UInt8)
  # Return the alpha channel
  abstract def alpha : Array(UInt8)
  # Width of image
  abstract def width : Int32
  # Height of image
  abstract def height : Int32
  # Size (total pixels) in image (`width` * `height`)
  abstract def size : Int32

  # Run provided block on each channel supported by this image.
  abstract def each_color_channel(& : (Array(UInt8), ChannelType) -> Nil) : Nil

  # Get the `Array(UInt8)` corresponding to `channel_type`)
  abstract def [](channel_type : ChannelType) : Array(UInt8)
  # Set the `Array(UInt8)` corresponding to `channel_type`) to `channel`
  abstract def []=(channel_type : ChannelType, channel : Array(UInt8)) : Array(UInt8)

  private def index_of(x : Int, y : Int) : Int
    y * width + x
  end

  private def resolve_to_start_and_count(range, size) : Tuple(Int32, Int32)
    start, count = Indexable.range_to_index_and_count(range, size) || raise IndexError.new("Unable to resolve range #{range} for image dimension of #{size}")
    raise IndexError.new("Range #{range} exceeds bounds of #{size}") if (start + count) > size
    {start, count}
  end
end
