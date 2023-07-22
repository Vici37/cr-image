# Draws shapes in the image
#
# Taking sample `image`:
#
# <img src="https://raw.githubusercontent.com/Vici37/cr-image/master/docs/images/sample.jpg" alt="Woman with black turtleneck and white background"/>
#
# ```
# image.draw_square(40, 30, 80, 80, CrImage::Color.of("#00f"))
# image.draw_circle(80, 70, 40, CrImage::Color.of("#00f"))
# image.draw_line(50, 50, 70, 90, CrImage::Color.of("#0f0"))
# ```
# <img src="https://raw.githubusercontent.com/Vici37/cr-image/master/docs/images/draw_square_40_30_80_80_sample.jpg" alt="Woman with blue box drawn around face"/>
# <img src="https://raw.githubusercontent.com/Vici37/cr-image/master/docs/images/draw_circle_80_70_40_sample.jpg" alt="Woman with blue circle drawn around face"/>
# <img src="https://raw.githubusercontent.com/Vici37/cr-image/master/docs/images/draw_line_50_50_70_90_sample.jpg" alt="Woman with green line across face"/>
#
# Can also use the `fill: true` parameter to fill in the drawn shapes
module CrImage::Operation::Draw
  def draw_square(region : Region, color : Color, *, fill : Bool = false) : self
    clone.draw_square!(region, color, fill: fill)
  end

  def draw_square(x : Int, y : Int, box_width : Int, box_height : Int, color : Color, *, fill : Bool = false) : self
    clone.draw_square!(x, y, box_width, box_height, color, fill: fill)
  end

  def draw_square!(region : Region, color : Color, *, fill : Bool = false) : self
    draw_square!(*region.to_tuple, color, fill: fill)
  end

  def draw_square!(x : Int, y : Int, box_width : Int, box_height : Int, color : Color, *, fill : Bool = false) : self
    raise "Box dimensions extend #{x + box_width - width} pixels beyond width of the image (#{width})" if (x + box_width) > width
    raise "Box dimensions extend #{y + box_height - height} pixels beyond height of the image (#{height})" if (y + box_height) > height

    x_i = x.to_i
    y_i = y.to_i
    each_color_channel do |channel, channel_type|
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

  # Draw a circle around the region's center (see `Region#center`)
  def draw_circle(region : Region, radius : Int, color : Color, *, fill : Bool = false) : self
    clone.draw_circle!(*region.center, radius, color, fill: fill)
  end

  def draw_circle(x : Int, y : Int, radius : Int, color : Color, *, fill : Bool = false) : self
    clone.draw_circle!(x, y, radius, color, fill: fill)
  end

  # Draw a circle around the region's center (see `Region#center`)
  def draw_circle!(region : Region, color : Color, *, fill : Bool = false, radius : Int32? = nil) : self
    draw_circle!(*region.center, radius, color, fill: fill)
  end

  # :nodoc:
  # ameba:disable Metrics/CyclomaticComplexity
  def draw_circle!(center_x : Int, center_y : Int, radius : Int, color : Color, *, fill : Bool = false) : self
    min_x = Math.max(0, center_x - radius)
    max_x = Math.min(width - 1, center_x + radius)
    max_y = Math.min(height - 1, center_y + radius)

    each_color_channel do |channel, channel_type|
      0.upto(radius) do |y|
        theta_0 = Math.asin(Math.max(0, (y - 1)) / radius.to_f)
        theta_1 = Math.asin(y / radius.to_f)

        # x_0 > x_1, as we're sticking to the first quadrant of the circle (0 <= theta_* <= 90 degrees, and theta_1 > theta_0)
        x_0 = (radius * Math.cos(theta_0)).round
        x_1 = (radius * Math.cos(theta_1)).round

        # A given horizontal line in the circle will look like:
        #    (outer_x)..(inner_x)     (center_x)     (inner_x)..(outer_x)
        lower_x_outer = Math.max(min_x, center_x - x_0).to_i
        lower_x_inner = Math.max(min_x, center_x - x_1).to_i
        upper_x_outer = Math.min(max_x, center_x + x_0).to_i
        upper_x_inner = Math.min(max_x, center_x + x_1).to_i

        lower_y = center_y - y
        upper_y = center_y + y

        lower_y_outside_of_image = (center_y - y) < 0 || (center_y - y) > max_y
        upper_y_outside_of_image = (center_y + y) < 0 || (center_y + y) > max_y
        left_outer_x_beyond_right_of_image = (center_x - x_0) > max_x
        right_outer_x_beyond_left_of_image = (center_x + x_0) < 0
        left_inner_x_beyond_left_of_image = (center_x - x_1) < 0
        right_inner_x_beyond_right_of_image = (center_x + x_1) > max_x

        if fill
          channel[index_of(lower_x_outer, lower_y), upper_x_outer - lower_x_outer + 1] =
            Array(UInt8).new(upper_x_outer - lower_x_outer + 1) { color[channel_type] } unless left_outer_x_beyond_right_of_image ||
                                                                                               right_outer_x_beyond_left_of_image ||
                                                                                               lower_y_outside_of_image
          channel[index_of(lower_x_outer, upper_y), upper_x_outer - lower_x_outer + 1] =
            Array(UInt8).new(upper_x_outer - lower_x_outer + 1) { color[channel_type] } unless left_outer_x_beyond_right_of_image ||
                                                                                               right_outer_x_beyond_left_of_image ||
                                                                                               upper_y_outside_of_image
        else
          channel[index_of(lower_x_outer, lower_y), lower_x_inner - lower_x_outer + 1] =
            Array(UInt8).new(lower_x_inner - lower_x_outer + 1) { color[channel_type] } unless left_inner_x_beyond_left_of_image ||
                                                                                               left_outer_x_beyond_right_of_image ||
                                                                                               lower_y_outside_of_image

          channel[index_of(upper_x_inner, lower_y), upper_x_outer - upper_x_inner + 1] =
            Array(UInt8).new(upper_x_outer - upper_x_inner + 1) { color[channel_type] } unless right_inner_x_beyond_right_of_image ||
                                                                                               right_outer_x_beyond_left_of_image ||
                                                                                               lower_y_outside_of_image

          channel[index_of(lower_x_outer, upper_y), lower_x_inner - lower_x_outer + 1] =
            Array(UInt8).new(lower_x_inner - lower_x_outer + 1) { color[channel_type] } unless left_inner_x_beyond_left_of_image ||
                                                                                               left_outer_x_beyond_right_of_image ||
                                                                                               upper_y_outside_of_image
          channel[index_of(upper_x_inner, upper_y), upper_x_outer - upper_x_inner + 1] =
            Array(UInt8).new(upper_x_outer - upper_x_inner + 1) { color[channel_type] } unless right_inner_x_beyond_right_of_image ||
                                                                                               right_outer_x_beyond_left_of_image ||
                                                                                               upper_y_outside_of_image
        end
      end
    end

    self
  end

  def draw_line(x1 : Int32, y1 : Int32, x2 : Int32, y2 : Int32, color : Color) : self
    clone.draw_line!(x1, y1, x2, y2, color)
  end

  # Implementation of http://www.edepot.com/linec.html
  def draw_line!(x1 : Int32, y1 : Int32, x2 : Int32, y2 : Int32, color : Color) : self
    raise Exception.new("First point (#{x1},#{y1}) lies outside of the available drawing window (#{width}x#{height})") unless 0 <= x1 < width && 0 <= y1 < height
    raise Exception.new("Second point (#{x2},#{y2}) lies outside of the available drawing window (#{width}x#{height})") unless 0 <= x2 < width && 0 <= y2 < height

    rise_by_height = false
    short = y2 - y1
    long = x2 - x1

    if short.abs > long.abs
      short, long = long, short
      rise_by_height = true
    end

    end_val = long

    gradient = long == 0 ? short : short / long.abs.to_f
    if rise_by_height
      each_color_channel do |channel, channel_type|
        jump = 0.0
        0.to(end_val) do |i|
          channel[index_of(x1 + jump.to_i, y1 + i)] = color[channel_type]
          jump += gradient
        end
      end
    else
      each_color_channel do |channel, channel_type|
        jump = 0.0
        0.to(end_val) do |i|
          channel[index_of(x1 + i, y1 + jump.to_i)] = color[channel_type]
          jump += gradient
        end
      end
    end

    self
  end
end
