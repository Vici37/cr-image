module CrImage::Format::Save
  def save(filename : String) : Nil
    File.open(filename, "w") do |file|
      case filename
      when .ends_with?(".ppm")                       then to_ppm(file)
      when .ends_with?(".jpg"), .ends_with?(".jpeg") then to_jpeg(file)
      else                                                raise "Unknown file extension for filename #{filename}, only support .ppm, .jpg, and .jpeg"
      end
    end
  end
end
