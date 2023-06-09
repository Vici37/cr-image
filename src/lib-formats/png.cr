require "./bindings/lib_spng"

# Provides methods to read from and write to PNG. Requires `libspng` to function.
#
# ```
# image = File.open("image.png") { |file| CrImage::RGBAImage.from_png(file) }
# File.open("other_image.png") { |file| image.to_png(file) }
# ```
# Alternatively, you can use the convenience methods in the `Open` and `Save` modules
# to acheive the same thing:
# ```
# image = CrImage::RGBAImage.open("image.png")
# image.save("other_image.png")
# ```
module CrImage::Format::PNG
  {% CrImage::Format::SUPPORTED_FORMATS << {extension: ".png", method: "png"} %}

  macro included
    # Read `image_data` and PNG encoded bytes
    def self.from_png(image_data : Bytes) : self
      ctx = LibSPNG.ctx_new(LibSPNG::CtxFlags::None)
      raise ::CrImage::Exception.new("Failed to create a context") unless ctx

      LibSPNG.set_png_buffer(ctx, image_data, image_data.size)

      check_png LibSPNG.get_ihdr(ctx, out ihdr)
      check_png LibSPNG.decoded_image_size(ctx, LibSPNG::Format::RGBA8, out image_size)

      image = Bytes.new(image_size.to_i, 0u8)
      check_png LibSPNG.decode_image(
        ctx,
        image,
        image_size,
        LibSPNG::Format::RGBA8,
        LibSPNG::DecodeFlags::None
      )

      LibSPNG.ctx_free(ctx)

      size = image_size // 4
      width = size // ihdr.height
      height = ihdr.height

      red = Array.new(size) { 0u8 }
      green = Array.new(size) { 0u8 }
      blue = Array.new(size) { 0u8 }
      alpha = Array.new(size) { 0u8 }

      size.times do |index|
        position = index * 4
        red.unsafe_put(index, image[position + 0])
        green.unsafe_put(index, image[position + 1])
        blue.unsafe_put(index, image[position + 2])
        alpha.unsafe_put(index, image[position + 3])
      end

      new(red, green, blue, alpha, width.to_i, height.to_i)
    end

    # Construct an Image by reading bytes from `io`
    def self.from_png(io : IO) : self
      from_png(io.getb_to_end)
    end

    # :nodoc:
    protected def self.check_png(code)
      raise ::CrImage::Exception.new(code) if code != 0
    end
  end

  # Output the image as PNG to `io`
  def to_png(io : IO) : Nil
    image_data = IO::Memory.new(size * 4)
    size.times do |index|
      image_data.write_byte(red.unsafe_fetch(index))
      image_data.write_byte(green.unsafe_fetch(index))
      image_data.write_byte(blue.unsafe_fetch(index))
      image_data.write_byte(alpha.unsafe_fetch(index))
    end

    ctx = LibSPNG.ctx_new(LibSPNG::CtxFlags::Encoder)
    raise ::CrImage::Exception.new("Failed to create a context") unless ctx

    LibSPNG.set_option(ctx, LibSPNG::Option::EncodeToBuffer, true)
    LibSPNG.set_png_buffer(ctx, image_data.buffer, image_data.size)

    ihdr = LibSPNG::IHDR.new
    ihdr.width = @width
    ihdr.height = @height
    ihdr.color_type = LibSPNG::ColorType::TrueColorAlpha
    ihdr.bit_depth = 8
    LibSPNG.set_ihdr(ctx, pointerof(ihdr))

    error = LibSPNG.encode_image(
      ctx,
      image_data.buffer,
      image_data.size,
      LibSPNG::Format::PNG,
      LibSPNG::EncodeFlags::Finalize
    )
    check_png error

    buffer = LibSPNG.get_png_buffer(ctx, out size, pointerof(error))
    raise ::CrImage::Exception.new("Failed to get a buffer") unless ctx

    bytes = Bytes.new(buffer, size)
    io.write(bytes)

    LibC.free(buffer)
  end

  # :nodoc:
  delegate check_png, to: self.class
end
