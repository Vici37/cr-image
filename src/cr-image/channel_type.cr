# Enum representing different image channels supported by CrImage
#
# See `RGBAImage#each_channel` and `GrayscaleImage#each_channel`
enum CrImage::ChannelType
  Red
  Green
  Blue
  Gray
  Alpha
end
