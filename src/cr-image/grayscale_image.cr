require "./image"

# An image in Grayscale. These image types are the easiest to perform feature and information extraction from, where
# there is only one channel to examine, and so has methods for constructing `Mask`s from (see `#threshold` below).
#
# An `RGBAImage` would become a `GrayscaleImage` this way:
# ```
# image.to_gray
# ```
#
# <img src="https://raw.githubusercontent.com/Vici37/cr-image/master/docs/images/sample.jpg" alt="Woman with black turtleneck and white background"/>
# <img src="https://raw.githubusercontent.com/Vici37/cr-image/master/docs/images/gray_sample.jpg" alt="Woman in black turtleneck on white background in grayscale"/>
class CrImage::GrayscaleImage < CrImage::Image
  property gray : Array(UInt8)
  property alpha : Array(UInt8)
  property width : Int32
  property height : Int32

  # Create a GrayscaleImage from a set of color channels (delegates to `RGBAImage#to_gray`)
  def self.new(red : Array(UInt8), green : Array(UInt8), blue : Array(UInt8), alpha : Array(UInt8), width : Int32, height : Int32)
    RGBAImage.new(red, green, blue, alpha, width, height).to_gray
  end

  def initialize(@gray, @alpha, @width, @height)
  end

  def initialize(@width, @height)
    @gray = Array(UInt8).new(@width * @height) { ChannelType::Gray.default }
    @alpha = Array(UInt8).new(@width * @height) { ChannelType::Alpha.default }
  end

  # Create a GrayscaleImage with only an `Array(UInt8)` (alpha channel initialized as `255` throughout)
  def initialize(@gray, @width, @height)
    @alpha = Array(UInt8).new(@gray.size) { ChannelType::Alpha.default }
  end

  # Create a GrayscaleImage with only an `Array(UInt8)` (alpha channel initialized as `255` throughout)
  def initialize(@gray, @width)
    @height = @gray.size // @width
    @alpha = Array(UInt8).new(@gray.size) { ChannelType::Alpha.default }
  end

  # Create a new GrayscaleImage as a copy of this one
  def clone : GrayscaleImage
    self.class.new(
      @gray.clone,
      @alpha.clone,
      @width,
      @height
    )
  end

  # Return the "`red`" channel (returns `gray`)
  def red : Array(UInt8)
    @gray
  end

  # Return the "`green`" channel (returns `gray`)
  def green : Array(UInt8)
    @gray
  end

  # Return the "`blue`" channel (returns `gray`)
  def blue : Array(UInt8)
    @gray
  end

  # Return `alpha` channel
  def alpha : Array(UInt8)
    @alpha
  end

  # Run provided block with the `ChannelType::Gray` channels and channel types.
  def each_color_channel(& : (Array(UInt8), ChannelType) -> Nil) : Nil
    yield @gray, ChannelType::Gray
    nil
  end

  # Run provided block with the `ChannelType::Gray` channels and channel types.
  def each_channel(& : (Array(UInt8), ChannelType) -> Nil) : Nil
    yield @gray, ChannelType::Gray
    yield @alpha, ChannelType::Alpha
    nil
  end

  record Pixel,
    gray : UInt8,
    alpha : UInt8

  # Return a `Pixel` representing this cell in the image.
  def [](x : Int32, y : Int32) : Pixel
    index = y * width + x
    Pixel.new(gray[index], alpha[index])
  end

  # Return the `Array(UInt8)` corresponding to `channel_type`
  def [](channel_type : ChannelType) : Array(UInt8)
    return @alpha if channel_type == ChannelType::Alpha
    @gray
  end

  # Set the underlying `Array(UInt8)` of `channel_type` to the new `channel`.
  #
  # Warning: this method does not check the size of the incoming array, and if it's a different
  # size from what the current image represents, this could break it. We recommend against using
  # this method except for from other methods that will be updating the `width` and `height` immediately after.
  def []=(channel_type : ChannelType, channel : Array(UInt8)) : Array(UInt8)
    case channel_type
    when ChannelType::Gray  then self.gray = channel
    when ChannelType::Alpha then self.alpha = channel
    else                         raise "Unknown channel type #{channel_type} for GrayscaleImage"
    end
  end

  # Convert this `GrayscaleImage` to an `RGBAImage`.
  #
  # No color will be provided, all pixels will remain gray.
  def to_rgba : RGBAImage
    RGBAImage.new(@gray.clone, @gray.clone, @gray.clone, @alpha.clone, width, height)
  end

  # Convert this grayscale image to an RGBA one using the provided color map.
  #
  # The provided map should have a key for all 0-255 possible gray pixel values, otherwise the `default`
  # `Color` will be used instead (default is black).
  #
  # ```
  # colors = 256.times.to_a.map { |i| {i.to_u8, CrImage::Color.random} }.to_h
  # gray_image.to_rgba(colors).save("to_rgba_color_map_sample.jpg")
  # ```
  #
  # <img src="https://raw.githubusercontent.com/Vici37/cr-image/master/docs/images/gray_sample.jpg" alt="Woman in black turtleneck on white background in grayscale"/>
  #
  # Becomes
  #
  # <img src="https://raw.githubusercontent.com/Vici37/cr-image/master/docs/images/to_rgba_color_map_sample.jpg" alt="Random colored pixels in rough outline of woman"/>
  def to_rgba(color_map : Hash(UInt8, Color), *, default : Color = Color.default) : RGBAImage
    red = Array(UInt8).new(size)
    green = Array(UInt8).new(size)
    blue = Array(UInt8).new(size)
    alpha = Array(UInt8).new(size)

    gray.each do |pixel|
      color = color_map[pixel]? || default
      red << color.red
      green << color.green
      blue << color.blue
      alpha << color.alpha
    end

    RGBAImage.new(red, green, blue, alpha, width, height)
  end

  # Returns self
  def to_gray : GrayscaleImage
    self
  end

  # Return the number of pixels this image contains
  def size : Int32
    @width * @height
  end

  # Invert grayscale pixels (replace each pixel will `255 - p` for all `p` in `@gray`).
  #
  # <img src="https://raw.githubusercontent.com/Vici37/cr-image/master/docs/images/gray_sample.jpg" alt="Woman in black turtleneck on white background in grayscale"/>
  #
  # Becomes
  #
  # <img src="https://raw.githubusercontent.com/Vici37/cr-image/master/docs/images/gray_inverted_sample.jpg" alt="Woman in black turtleneck on white background in inverted grayscale"/>
  def invert
    clone.invert!
  end

  # Invert grayscale pixels (replace each pixel will `255 - p` for all `p` in `@gray`). Modifies self.
  #
  # <img src="https://raw.githubusercontent.com/Vici37/cr-image/master/docs/images/gray_sample.jpg" alt="Woman in black turtleneck on white background in grayscale"/>
  #
  # Becomes
  #
  # <img src="https://raw.githubusercontent.com/Vici37/cr-image/master/docs/images/gray_inverted_sample.jpg" alt="Woman in black turtleneck on white background in inverted grayscale"/>
  def invert!
    @gray.map! { |pix| 255u8 - pix }
    self
  end

  # Construct a simple threshold `Mask` containing all pixels with a `UInt8` value greater than `threshold`
  # Given sample image:
  #
  # <img src="https://raw.githubusercontent.com/Vici37/cr-image/master/docs/images/sample.jpg" alt="Woman with black turtleneck and white background"/>
  #
  # ```
  # image
  #   .to_gray                       # convert color image to grayscale one
  #   .threshold(128)                # generate a mask using threshold operator
  #   .to_gray                       # convert mask to grayscale image
  #   .save("threshold_example.jpg") # save mask as grayscale
  # ```
  # <img src="https://raw.githubusercontent.com/Vici37/cr-image/master/docs/images/gray_threshold_example.jpg" alt="Black and white silhouette with background and woman's face as white, hair and sweater black"/>
  def threshold(threshold : Int) : Mask
    self >= threshold
  end

  delegate ">", ">=", "<", "<=", "==", mean, mask_from, cross_correlate, to: to_map!

  # Convert this image into a `IntMap`
  def to_imap : IntMap
    IntMap.new(width, gray.map(&.to_i))
  end

  # Convert this image into a `UInt8Map`. Does not clone underlying `gray` channel, both this image and map share the same data.
  def to_map! : UInt8Map
    UInt8Map.new(width, @gray)
  end

  # Receive a copy of the underlying `Array(UInt8)` corresponding to the `ChannelType::Gray` channel
  def to_a : Array(UInt8)
    gray.dup
  end

  def cross_correlate(map : Map, *, edge_policy : EdgePolicy = EdgePolicy::Repeat) : FloatMap
    to_imap.cross_correlate(map, edge_policy: edge_policy)
  end

  def cross_correlate_fft(map : Map) # : FloatMap
    to_imap.cross_correlate_fft(map)
  end
end
