# Brightens an image (increases white value)
#
# Taking sample `image`:
#
# <img src="https://raw.githubusercontent.com/Vici37/cr-image/master/docs/images/sample.jpg" alt="Woman with black turtleneck and white background"/>
#
# ```
# image.brightness(2.0)
# ```
# <img src="https://raw.githubusercontent.com/Vici37/cr-image/master/docs/images/brightened_2.0_sample.jpg" alt="Brightened sample image with value 2.0"/>
module CrImage::Operation::Brightness
  def brightness(value : Float64) : self
    clone.brightness!(value)
  end

  def brightness!(value : Float64) : self
    each_channel do |channel|
      size.times do |index|
        channel.unsafe_put(index, Math.min(255, (channel.unsafe_fetch(index) * value)).to_u8)
      end
    end
    self
  end
end
