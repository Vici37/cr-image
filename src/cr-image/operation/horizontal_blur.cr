# Blur an image along the horizontal axis
#
# Taking sample `image`:
#
# <img src="https://raw.githubusercontent.com/Vici37/cr-image/master/docs/images/sample.jpg" alt="Woman with black turtleneck and white background"/>
#
# ```
# image.horizontal_blur(1).save("horizontal_1_sample.jpg")
# image.horizontal_blur(5).save("horizontal_5_sample.jpg")
# ```
# <img src="https://raw.githubusercontent.com/Vici37/cr-image/master/docs/images/horizontal_1_sample.jpg" alt="Blurred sample image with k 1"/>
# <img src="https://raw.githubusercontent.com/Vici37/cr-image/master/docs/images/horizontal_5_sample.jpg" alt="Blurred sample image with k 5"/>
module CrImage::Operation::HorizontalBlur
  def horizontal_blur(k : Int32) : self
    clone.horizontal_blur!(k)
  end

  def horizontal_blur!(k : Int32) : self
    buffer = Bytes.new(size, 0)
    multiplier = 1 / (k + k + 1)

    each_channel do |channel|
      @height.times do |y|
        center_index : Int32 = y * @width
        left__bound : Int32 = center_index
        right_bound : Int32 = center_index + k

        first_value : Int32 = channel.unsafe_fetch(center_index).to_i
        last__value : Int32 = channel.unsafe_fetch(center_index + @width - 1).to_i
        current_sum : Int32 = (k + 1) * first_value

        (0..k - 1).each do |i|
          current_sum += channel.unsafe_fetch(center_index + i)
        end

        (0..k).each do
          current_sum += channel.unsafe_fetch(right_bound).to_i - first_value
          buffer.unsafe_put(center_index, (current_sum * multiplier).to_u8)

          right_bound += 1
          center_index += 1
        end

        (k + 1..@width - k - 1).each do
          current_sum += (channel.unsafe_fetch(right_bound).to_i - channel.unsafe_fetch(left__bound).to_i)
          buffer.unsafe_put(center_index, (current_sum * multiplier).to_u8)

          right_bound += 1
          left__bound += 1
          center_index += 1
        end

        (@width - k..@width - 1).each do
          current_sum += last__value - channel.unsafe_fetch(left__bound).to_i
          buffer.unsafe_put(center_index, (current_sum * multiplier).to_u8)

          left__bound += 1
          center_index += 1
        end
      end

      channel.@buffer.copy_from(buffer.to_unsafe, buffer.size)
    end

    self
  end
end
