require "./bindings/lib_webp"

# Provides methods to read from and write to WebP. Requires `libwebp` to function.
#
# ```
# image = File.open("image.webp") { |file| CrImage::RGBAImage.from_webp(file) }
# File.open("other_image.webp") { |file| image.to_webp(file) }
# ```
# Alternatively, you can use the convenience methods in the `Open` and `Save` modules
# to acheive the same thing:
# ```
# image = CrImage::RGBAImage.open("image.webp")
# image.save("other_image.webp")
# ```
module CrImage::Format::WebP
  {% CrImage::Format::SUPPORTED_FORMATS << {extension: ".webp", method: "webp"} %}

  macro included
    # Read `image_data` as WebP encoded bytes
    def self.from_webp(image_data : Bytes) : self
      check_webp LibWebP.get_info(image_data, image_data.size, out width, out height)
      buffer = LibWebP.decode_rgba(
        image_data,
        image_data.size,
        pointerof(width),
        pointerof(height)
      )

      red = Array.new(width * height) { 0u8 }
      green = Array.new(width * height) { 0u8 }
      blue = Array.new(width * height) { 0u8 }
      alpha = Array.new(width * height) { 0u8 }

      (width * height).times do |index|
        red.unsafe_put(index, buffer[index * 4])
        green.unsafe_put(index, buffer[index * 4 + 1])
        blue.unsafe_put(index, buffer[index * 4 + 2])
        alpha.unsafe_put(index, buffer[index * 4 + 3])
      end

      LibWebP.free(buffer)

      new(red, green, blue, alpha, width, height)
    end

    # Read bytes from `io` as WebP encoded
    def self.from_webp(io : IO) : self
      from_webp(io.getb_to_end)
    end

    # :nodoc:
    protected def self.check_webp(code)
      raise ::CrImage::Exception.new(code.to_i) if code == 0
    end
  end

  # Write image to `io` using WebP encoding
  def to_webp(io : IO) : Nil
    image_data = String.build do |string|
      size.times do |index|
        string.write_byte(red.unsafe_fetch(index))
        string.write_byte(green.unsafe_fetch(index))
        string.write_byte(blue.unsafe_fetch(index))
        string.write_byte(alpha.unsafe_fetch(index))
      end
    end

    size = LibWebP.encode_lossless_rgba(
      image_data,
      @width,
      @height,
      @width * 4,
      out buffer
    )
    check_webp size

    bytes = Bytes.new(buffer, size)
    io.write(bytes)

    LibWebP.free(buffer)
  end

  # :nodoc:
  delegate check_webp, to: self.class
end
