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
    case filename
    when .ends_with?(".ppm")                       then File.open(filename) { |f| self.from_ppm(f) }
    when .ends_with?(".jpg"), .ends_with?(".jpeg") then File.open(filename) { |f| self.from_jpeg(f) }
    when .ends_with?(".webp")                      then File.open(filename) { |f| self.from_webp(f) }
    when .ends_with?(".png")                       then File.open(filename) { |f| self.from_png(f) }
    else                                                raise "Unknown file extension for filename #{filename}, only support .ppm, .jpg, and .jpeg"
    end
  end
end
