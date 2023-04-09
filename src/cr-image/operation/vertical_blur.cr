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
        center_index : Int32 = x
        left_bound : Int32 = center_index
        right_bound : Int32 = center_index + value * @width

        first_value : Int32 = channel.unsafe_fetch(center_index).to_i
        last_value : Int32 = channel.unsafe_fetch(center_index + @width * (@height - 1)).to_i
        current_sum : Int32 = (value + 1) * first_value

        (0..value - 1).each do |i|
          current_sum += channel.unsafe_fetch(center_index + i * @width)
        end

        (0..value).each do
          current_sum += channel.unsafe_fetch(right_bound).to_i - first_value
          buffer.unsafe_put(center_index, (current_sum * multiplier).to_u8)

          right_bound += @width
          center_index += @width
        end

        (value + 1..@height - value - 1).each do
          current_sum += channel.unsafe_fetch(right_bound).to_i - channel.unsafe_fetch(left_bound).to_i
          buffer.unsafe_put(center_index, (current_sum * multiplier).to_u8)

          left_bound += @width
          right_bound += @width
          center_index += @width
        end

        (@height - value..@height - 1).each do
          current_sum += last_value - channel.unsafe_fetch(left_bound).to_i
          buffer.unsafe_put(center_index, (current_sum * multiplier).to_u8)

          left_bound += @width
          center_index += @width
        end
      end

      channel.@buffer.copy_from(buffer.to_unsafe, buffer.size)
    end

    self
  end
end
