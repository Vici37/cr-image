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
module CrImage::Format::Save
  # Write this image to file using the provided filename.
  #
  # This method _will not_ create intermediate directory paths. This method will throw an
  # error if they don't exist.
  def save(filename : String) : self
    File.open(filename, "w") do |file|
      case filename
      when .ends_with?(".ppm")                       then to_ppm(file)
      when .ends_with?(".jpg"), .ends_with?(".jpeg") then to_jpeg(file)
      when .ends_with?(".webp")                      then to_webp(file)
      when .ends_with?(".png")                       then to_png(file)
      else                                                raise "Unknown file extension for filename #{filename}, only support .ppm, .jpg, and .jpeg"
      end
    end
    self
  end
end
