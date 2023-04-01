# Blur an image along the vertical axis
#
# Taking sample `image`:
#
# <img src="https://raw.githubusercontent.com/Vici37/cr-image/master/docs/images/sample.jpg" alt="Woman with black turtleneck and white background"/>
#
# ```
# image.vertical_blur(1).save("vertical_1_sample.jpg")
# image.vertical_blur(5).save("vertical_5_sample.jpg")
# ```
# <img src="https://raw.githubusercontent.com/Vici37/cr-image/master/docs/images/vertical_1_sample.jpg" alt="Blurred sample image with value 1"/>
# <img src="https://raw.githubusercontent.com/Vici37/cr-image/master/docs/images/vertical_5_sample.jpg" alt="Blurred sample image with value 5"/>
module CrImage::Operation::VerticalBlur
  def vertical_blur(value : Int32) : self
    clone.vertical_blur!(value)
  end

  def vertical_blur!(value : Int32) : self
    buffer = Bytes.new(size, 0)
    multiplier = 1 / (value + value + 1)

    each_color_channel do |channel|
      @width.times do |x|
        c_index : Int32 = x
        l_index : Int32 = c_index
        r_index : Int32 = c_index + value * @width

        f_value : Int32 = channel.unsafe_fetch(c_index).to_i
        l_value : Int32 = channel.unsafe_fetch(c_index + @width * (@height - 1)).to_i
        c_value : Int32 = (value + 1) * f_value

        (0..value - 1).each do |i|
          c_value += channel.unsafe_fetch(c_index + i * @width)
        end

        (0..value).each do
          c_value += channel.unsafe_fetch(r_index).to_i - f_value
          buffer.unsafe_put(c_index, (c_value * multiplier).to_u8)

          r_index += @width
          c_index += @width
        end

        (value + 1..@height - value - 1).each do
          c_value += channel.unsafe_fetch(r_index).to_i - channel.unsafe_fetch(l_index).to_i
          buffer.unsafe_put(c_index, (c_value * multiplier).to_u8)

          l_index += @width
          r_index += @width
          c_index += @width
        end

        (@height - value..@height - 1).each do
          c_value += l_value - channel.unsafe_fetch(l_index).to_i
          buffer.unsafe_put(c_index, (c_value * multiplier).to_u8)

          l_index += @width
          c_index += @width
        end
      end

      channel.@buffer.copy_from(buffer.to_unsafe, buffer.size)
    end

    self
  end
end
