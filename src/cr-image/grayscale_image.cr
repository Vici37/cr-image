require "./image"

# An image in Grayscale. These image types are the easiest to perform feature and information extraction from, where
# there is only one channel to examine, and so has methods for constructing `Mask`s from (see `#threshold` below).
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

  # Create a GrayscaleImage with only an `Array(UInt8)` (alpha channel initialized as `255` throughout)
  def initialize(@gray, @width, @height)
    @alpha = Array(UInt8).new(@gray.size) { 255u8 }
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

  # Run provided block with the `ChannelType::Gray` and `ChannelType::Alpha` channels and channel types.
  def each_channel(& : (Array(UInt8), ChannelType) -> Nil) : Nil
    yield @gray, ChannelType::Gray
    yield @alpha, ChannelType::Alpha
    nil
  end

  # Return the `Array(UInt8)` corresponding to `channel_type`
  def [](channel_type : ChannelType) : Array(UInt8)
    return @alpha if channel_type == ChannelType::Gray
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
  # <img src="https://raw.githubusercontent.com/Vici37/cr-image/master/docs/images/gray_sample.jpg" alt="Woman in black turtleneck on white background"/>
  #
  # Becomes
  #
  # <img src="https://raw.githubusercontent.com/Vici37/cr-image/master/docs/images/gray_inverted_sample.jpg" alt="Woman in black turtleneck on white background"/>
  def invert
    clone.invert!
  end

  # Invert grayscale pixels (replace each pixel will `255 - p` for all `p` in `@gray`). Modifies self.
  #
  # <img src="https://raw.githubusercontent.com/Vici37/cr-image/master/docs/images/gray_sample.jpg" alt="Woman in black turtleneck on white background"/>
  #
  # Becomes
  #
  # <img src="https://raw.githubusercontent.com/Vici37/cr-image/master/docs/images/gray_inverted_sample.jpg" alt="Woman in black turtleneck on white background"/>
  def invert!
    @gray.map! { |pix| 255u8 - pix }
    self
  end

  # Construct a `Mask` from this `GrayscaleImage` using the passed in block to determine if a given pixel should be true or not
  #
  # ```
  # # Construct a mask identifying the bright pixels in the bottom left corner of image
  # image.to_gray.mask_from do |x, y, pixel|
  #   x < image.width // 2 &&      # left half of image
  #     y > (image.height // 2) && # bottom half of image
  #     pixel > 128                # only "bright" pixels
  # end
  # ```
  # <img src="https://raw.githubusercontent.com/Vici37/cr-image/master/docs/images/sample.jpg" alt="Woman in black turtleneck on white background"/>
  # ->
  # <img src="https://raw.githubusercontent.com/Vici37/cr-image/master/docs/images/gray_mask_from_example.jpg" alt="Mask identifying bright spots in lower left corner"/>
  def mask_from(&block : (Int32, Int32, UInt8) -> Bool) : Mask
    Mask.new(width, BitArray.new(size) do |i|
      block.call(i % width, i // width, @gray[i])
    end)
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
    mask_from do |_, _, pixel|
      pixel >= threshold
    end
  end
end
