# Provides a convenience method for opening up image files from the filesystem.
# Currently supports:
# * PPM (`.ppm`)
# * WebP (`.webp`)
# * JPEG (`.jpeg`, `.jpg`)
# * PNG (`.png`)
#
# ```
# image = CrImage::RGBAImage.open("image.jpg")
# ```
# See `Save` for a convenience method to write to the filesystem.
module CrImage::Format::Open
  # Reads this image from file using the provided filename.
  def open(filename : String) : self
    {% begin %}
    case filename
    {% for format in SUPPORTED_FORMATS %}
      when .ends_with?({{format[:extension]}}) then File.open(filename) { |file| self.from_{{format[:method].id}}(file) }
    {% end %}
      else raise Exception.new "Unknown file extension for filename #{filename}, cr-image only supports {{CrImage::Format::SUPPORTED_FORMATS.map(&.[:extension].id).join(", ").id}}"
    end
    {% end %}
  end
end
