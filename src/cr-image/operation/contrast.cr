# Increases contrast of an image
#
# Taking sample `image`:
#
# <img src="https://raw.githubusercontent.com/Vici37/cr-image/master/docs/images/sample.jpg" alt="Woman with black turtleneck and white background"/>
#
# ```
# image.contrast(10)
# ```
# <img src="https://raw.githubusercontent.com/Vici37/cr-image/master/docs/images/contrasted_10_sample.jpg" alt="Contrasted image with value of 10"/>
module CrImage::Operation::Contrast
  def contrast(value : Float64) : self
    clone.contrast!(value)
  end

  def contrast!(value : Float64) : self
    factor = (259 * (value + 255)) / (255 * (259 - value))
    each_channel do |channel|
      size.times do |index|
        channel.unsafe_put(index, Math.min(255, Math.max(0, factor * (channel.unsafe_fetch(index).to_i - 128) + 128)).to_u8)
      end
    end
    self
  end
end
