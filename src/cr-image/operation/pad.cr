# Pads an image
#
# Taking sample `image`:
#
# <img src="https://raw.githubusercontent.com/Vici37/cr-image/master/docs/images/sample.jpg" alt="Woman with black turtleneck and white background"/>
#
# ```
# image.pad(left: 50, right: 50)
# image.pad(left: 50, right: 50, pad_type: CrImage::EdgePolicy::Repeat)
# ```
# <img src="https://raw.githubusercontent.com/Vici37/cr-image/master/docs/images/pad_black.jpg" alt="Picture with black padding on left and right"/>
# <img src="https://raw.githubusercontent.com/Vici37/cr-image/master/docs/images/pad_repeat.jpg" alt="Picture with repeated padding on left and right"/>
module CrImage::Operation::Pad
  def pad(all : Int32 = 0, *, top : Int32 = 0, bottom : Int32 = 0, left : Int32 = 0, right : Int32 = 0, pad_type : EdgePolicy = EdgePolicy::Black) : self
    clone.pad!(all, top: top, bottom: bottom, left: left, right: right, pad_type: pad_type)
  end

  def pad!(all : Int32 = 0, *, top : Int32 = 0, bottom : Int32 = 0, left : Int32 = 0, right : Int32 = 0, pad_type : EdgePolicy = EdgePolicy::Black) : self
    orig_width = width
    each_channel do |channel, channel_type|
      padded = UInt8Map.new(orig_width, channel).pad(all, top: top, bottom: bottom, left: left, right: right, pad_type: pad_type, pad_black_value: channel_type.default)
      self[channel_type] = padded.raw
      @width = padded.width
      @height = padded.height
    end

    self
  end
end
