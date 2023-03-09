module CrImage::Operation::Draw
  def draw_box(region : Region, color : Color, *, fill : Bool = false) : self
    draw_box!(region, color, fill: fill)
  end

  def draw_box(x : Int, y : Int, box_width : Int, box_height : Int, color : Color, *, fill : Bool = false) : self
    clone.draw_box!(x, y, box_width, box_height, color, fill: fill)
  end

  def draw_box!(region : Region, color : Color, *, fill : Bool = false) : self
    clone.draw_box!(region.x, region.y, region.width, region.height, color, fill: fill)
  end

  def draw_box!(x : Int, y : Int, box_width : Int, box_height : Int, color : Color, *, fill : Bool = false) : self
    raise "Box dimensions extend #{x + box_width - width} pixels beyond width of the image (#{width})" if (x + box_width) > width
    raise "Box dimensions extend #{y + box_height - height} pixels beyond height of the image (#{height})" if (y + box_height) > height

    x_i = x.to_i
    y_i = y.to_i
    each_channel do |channel, channel_type|
      channel[(y_i * width + x_i), box_width] = Array(UInt8).new(box_width) { color[channel_type] }
      channel[(y_i + box_height) * width + x_i, box_width] = Array(UInt8).new(box_width) { color[channel_type] }
      box_height.times do |i|
        next if i == 0 # already drawn
        if fill
          channel[((y_i + i) * width + x_i), box_width] = Array(UInt8).new(box_width) { color[channel_type] }
        else
          channel.unsafe_put((y_i + i) * width + x_i, color[channel_type])
          channel.unsafe_put((y_i + i) * width + x_i + box_width, color[channel_type])
        end
      end
    end

    self
  end
end
