require "png"

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
      from_png(IO::Memory.new(image_data))
    end

    # Construct an Image by reading bytes from `io`
    def self.from_png(io : IO) : self
      png = ::PNG.read(io)

      width = png.width.to_i32
      height = png.height.to_i32

      red = Array.new(width * height) { ChannelType::Red.default }
      green = Array.new(width * height) { ChannelType::Green.default }
      blue = Array.new(width * height) { ChannelType::Blue.default }
      alpha = Array.new(width * height) { ChannelType::Alpha.default }

      red_offset = 0
      green_offset = 1
      blue_offset = 2
      alpha_offset = 3
      jump = png.color_type.channels

      case jump
      when 1
        red_offset = green_offset = blue_offset = 0
        alpha_offset = -1
      when 2
        red_offset = green_offset = blue_offset = 0
        alpha_offset = 1
      when 3
        alpha_offset = -1
      end

      (width * height).times do |index|
        png.data[index * jump]
        red.unsafe_put(index, png.data[index * jump + red_offset])
        green.unsafe_put(index, png.data[index * jump + green_offset])
        blue.unsafe_put(index, png.data[index * jump + blue_offset])
        if alpha_offset > -1
          alpha.unsafe_put(index, png.data[index * jump + alpha_offset])
        end
      end

      new(red, green, blue, alpha, width, height)
    end
  end

  # Output the image as PNG to `io`
  def to_png(io : IO) : Nil
    bytes = Bytes.new(size * 4)
    idx = 0
    (size * 4).times.step(4).each do |index|
      bytes.unsafe_put(index, red[idx])
      bytes.unsafe_put(index + 1, green[idx])
      bytes.unsafe_put(index + 2, blue[idx])
      bytes.unsafe_put(index + 3, alpha[idx])
      idx += 1
    end
    canvas = ::PNG::Canvas.new(::PNG::Header.new(width.to_u32, height.to_u32, color_type: ::PNG::ColorType::TrueColorAlpha), bytes)

    ::PNG.write(io, canvas)
  end
end
