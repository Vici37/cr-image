# Resize an image using a bilinear resizing algorithm.
#
# Taking sample `image`:
#
# <img src="https://raw.githubusercontent.com/Vici37/cr-image/master/docs/images/sample.jpg" alt="Woman with black turtleneck and white background"/>
#
# ```
# puts image.width, image.height # => 159x199
# image.bilinear_resize(40, 50).save("small_sample.jpg")
# image.bilinear_resize(200, 250).save("larger_sample.jpg")
# ```
# <img src="https://raw.githubusercontent.com/Vici37/cr-image/master/docs/images/small_sample.jpg" alt="Sample image reduced to 20% size"/>
# <img src="https://raw.githubusercontent.com/Vici37/cr-image/master/docs/images/larger_sample.jpg" alt="Sample image increased by 25% size"/>
module CrImage::Operation::BilinearResize
  # Resizes image to new dimensions
  def bilinear_resize(width : Int32, height : Int32) : self
    clone.bilinear_resize!(width, height)
  end

  # Resizes image to new dimensions. Modifies self.
  def bilinear_resize!(width : Int32, height : Int32) : self
    x_ratio = width > 1 ? (@width - 1) / (width - 1) : 0
    y_ratio = height > 1 ? (@height - 1) / (height - 1) : 0

    each_color_channel do |channel, channel_type|
      resized_channel = Array.new(width * height) { 0u8 }

      height.times do |h|
        width.times do |w|
          x = w * x_ratio
          y = h * y_ratio

          x_ceil = Math.min(@width - 1, x.ceil.to_i)
          x_floor = x.floor.to_i
          y_ceil = Math.min(@height - 1, y.ceil.to_i)
          y_floor = y.floor.to_i

          value =
            case
            when x_ceil == x_floor && y_ceil == y_floor
              x_index = x.to_i
              y_index = y.to_i
              channel.unsafe_fetch(@width * y_index + x_index)
            when x_ceil == x_floor
              x_index = x.to_i
              q_1 = channel.unsafe_fetch(@width * y_ceil + x_index)
              q_2 = channel.unsafe_fetch(@width * y_floor + x_index)
              (q_2 * (y_ceil - y) + q_1 * (y - y_floor)).to_u8
            when y_ceil == y_floor
              y_index = y.to_i
              q_1 = channel.unsafe_fetch(@width * y_index + x_ceil)
              q_2 = channel.unsafe_fetch(@width * y_index + x_floor)
              (q_2 * (x_ceil - x) + q_1 * (x - x_floor)).to_u8
            else
              v_1 = channel.unsafe_fetch(@width * y_floor + x_floor)
              v_2 = channel.unsafe_fetch(@width * y_floor + x_ceil)
              v_3 = channel.unsafe_fetch(@width * y_ceil + x_floor)
              v_4 = channel.unsafe_fetch(@width * y_ceil + x_ceil)
              q_1 = v_1 * (x_ceil - x) + v_2 * (x - x_floor)
              q_2 = v_3 * (x_ceil - x) + v_4 * (x - x_floor)
              (q_1 * (y_ceil - y) + q_2 * (y - y_floor)).to_u8
            end

          resized_channel.unsafe_put(width * h + w, value)
        end
      end

      self[channel_type] = resized_channel
    end

    @width = width
    @height = height

    self
  end
end
