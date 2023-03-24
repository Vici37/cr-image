# An image with red, green, blue, and alpha color channels (i.e. a color image). This image type is likely the one read from and written to file (or `IO`).
class CrImage::RGBAImage < CrImage::Image
  property red : Array(UInt8)
  property green : Array(UInt8)
  property blue : Array(UInt8)
  property alpha : Array(UInt8)
  property width : Int32
  property height : Int32

  def initialize(@red, @green, @blue, @alpha, @width, @height)
  end

  # Create a copy of this image
  def clone : RGBAImage
    self.class.new(
      @red.clone,
      @green.clone,
      @blue.clone,
      @alpha.clone,
      @width,
      @height
    )
  end

  # Run provided block with the `ChannelType::Red`, `ChannelType::Green`, `ChannelType::Blue`, and `ChannelType::Alpha` channels.
  def each_channel(& : (Array(UInt8), ChannelType) -> Nil) : Nil
    yield @red, ChannelType::Red
    yield @green, ChannelType::Green
    yield @blue, ChannelType::Blue
    yield @alpha, ChannelType::Alpha
    nil
  end

  record Pixel,
    red : UInt8,
    green : UInt8,
    blue : UInt8,
    alpha : UInt8

  def [](x : Int32, y : Int32) : Pixel
    index = y * width + x
    Pixel.new(red[index], green[index], blue[index], alpha[index])
  end

  # Return the channel corresponding to `channel_type`
  def [](channel_type : ChannelType) : Array(UInt8)
    case channel_type
    when ChannelType::Red   then @red
    when ChannelType::Green then @green
    when ChannelType::Blue  then @blue
    when ChannelType::Alpha then @alpha
    else                         raise "Unknown channel type #{channel_type} for RGBAImage"
    end
  end

  # Set the corresponding `channel_type` with `channel`
  def []=(channel_type : ChannelType, channel : Array(UInt8)) : Array(UInt8)
    case channel_type
    when ChannelType::Red   then @red = channel
    when ChannelType::Green then @green = channel
    when ChannelType::Blue  then @blue = channel
    when ChannelType::Alpha then @alpha = channel
    else                         raise "Unknown channel type #{channel_type} for RGBAImage"
    end
  end

  # Convert color image to `GrayscaleImage`, using the NTSC formula as default values.
  #
  # <img src="https://raw.githubusercontent.com/Vici37/cr-image/master/docs/images/sample.jpg" alt="Woman with black turtleneck and white background"/>
  #
  # Becomes
  #
  # <img src="https://raw.githubusercontent.com/Vici37/cr-image/master/docs/images/gray_sample.jpg" alt="Woman in black turtleneck on white background in grayscale"/>
  def to_gray(red_multiplier : Float = 0.299, green_multiplier : Float = 0.587, blue_multiplier : Float = 0.114) : GrayscaleImage
    GrayscaleImage.new(
      red.map_with_index do |red_pix, i|
        Math.min(255, red_pix * red_multiplier + @green[i] * green_multiplier + @blue[i] * blue_multiplier).to_u8
      end,
      width,
      height
    )
  end

  # Return the number of pixels in this image
  def size : Int32
    @width * @height
  end
end
