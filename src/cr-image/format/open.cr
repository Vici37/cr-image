module CrImage::Format::Open
  def open(filename : String) : self
    case filename
    when .ends_with?(".ppm")                       then File.open(filename) { |f| self.from_ppm(f) }
    when .ends_with?(".jpg"), .ends_with?(".jpeg") then File.open(filename) { |f| self.from_jpeg(f) }
    else                                                raise "Unknown file extension for filename #{filename}, only support .ppm, .jpg, and .jpeg"
    end
  end
end
