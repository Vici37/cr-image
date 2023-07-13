# Enum representing different image channels supported by CrImage
#
# See `RGBAImage#each_color_channel` and `GrayscaleImage#each_color_channel`
enum CrImage::ChannelType
  Red
  Green
  Blue
  Gray
  Alpha

  def default : UInt8
    alpha? ? 255u8 : 0u8
  end
end
