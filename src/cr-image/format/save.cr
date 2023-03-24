# Provides a convenience method for saving image files to the filesystem.
# Currently supports:
# * PPM (`.ppm`)
# * WebP (`.webp`)
# * JPEG (`.jpeg`, `.jpg`)
# * PNG (`.png`)
#
# ```
# image.save("image.jpg")
# ```
# See `Open` for a convenience method to read images from the filesystem
module CrImage::Format
  SUPPORTED_FORMATS = [] of Nil

  module Save
    # Write this image to file using the provided filename.
    #
    # This method _will not_ create intermediate directory paths. This method will throw an
    # error if they don't exist.
    def save(filename : String) : self
      File.open(filename, "w") do |file|
        {% begin %}
        case filename
        {% for format in SUPPORTED_FORMATS %}
          when .ends_with?({{format[:extension]}}) then to_{{format[:method].id}}(file)
        {% end %}
          else raise Exception.new "Unknown file extension for filename #{filename}, cr-image only supports {{CrImage::Format::SUPPORTED_FORMATS.map(&.[:extension].id).join(", ").id}}"
        end
        {% end %}
      end

      self
    end
  end
end
