# Exception class for any errors thrown by CrImage
class CrImage::Exception < ::Exception
  getter error_code : Int32?

  def initialize(message : String)
    super(message)
  end

  def initialize(@error_code : Int32)
    super("Received `#{@error_code}` as the error code")
  end

  def initialize(handle : LibJPEGTurbo::Handle)
    super(String.new(LibJPEGTurbo.get_error_str(handle)))
    @error_code = LibJPEGTurbo.get_error_code(handle).to_i
  end
end
