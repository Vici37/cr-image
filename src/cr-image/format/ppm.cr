# Provides methods to read from and write to PPM.
#
# ```
# image = File.open("image.ppm") { |file| CrImage::RGBAImage.from_ppm(file) }
# File.open("other_image.ppm") { |file| image.to_ppm(file) }
# ```
# Alternatively, you can use the convenience methods in the `Open` and `Save` modules
# to acheive the same thing:
# ```
# image = CrImage::RGBAImage.open("image.ppm")
# image.save("other_image.ppm")
# ```
module CrImage::Format::PPM
  {% CrImage::Format::SUPPORTED_FORMATS << {extension: ".ppm", method: "ppm"} %}

  macro included
    # Read `image_data` as PPM encoded bytes
    def self.from_ppm(image_data : Bytes) : self
      from_ppm(IO::Memory.new(image_data))
    end

    # Read bytes from `io` as PPM encoded
    def self.from_ppm(io : IO) : self
      _magic_number = io.gets("\n", chomp: true)
      width = io.gets(" ", chomp: true).try &.to_i
      height = io.gets("\n", chomp: true).try &.to_i
      _maximum_color_value = io.gets("\n", chomp: true)

      if width && height
        red = Array.new(width * height) { 0u8 }
        green = Array.new(width * height) { 0u8 }
        blue = Array.new(width * height) { 0u8 }
        alpha = Array.new(width * height) { 255u8 }

        (width * height).times do |index|
          red_byte = io.read_byte
          green_byte = io.read_byte
          blue_byte = io.read_byte
          if red_byte && green_byte && blue_byte
            red.unsafe_put(index, red_byte)
            green.unsafe_put(index, green_byte)
            blue.unsafe_put(index, blue_byte)
          else
            raise "The image ends prematurely"
          end
        end

        new(red, green, blue, alpha, width, height)
      else
        raise "The image doesn't have width or height"
      end
    end
  end

  # Output this image to `io` using PPM image encoding
  def to_ppm(io : IO) : Nil
    io << "P6\n"
    io << @width << " " << @height << "\n"
    io << "255\n"
    size.times do |index|
      io.write_byte(red.unsafe_fetch(index))
      io.write_byte(green.unsafe_fetch(index))
      io.write_byte(blue.unsafe_fetch(index))
    end
  end
end
