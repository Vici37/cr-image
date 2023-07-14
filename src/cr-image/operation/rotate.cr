module CrImage::Operation::Rotate
  def rotate(degrees : Float64, *, center_x : Int32 = width // 2, center_y : Int32 = height // 2, radius : Int32 = -1, pad : Bool = false, edge_policy : EdgePolicy = EdgePolicy::Black) : self
    clone.rotate!(degrees, center_x: center_x, center_y: center_y, radius: radius, pad: pad, edge_policy: edge_policy)
  end

  def rotate!(degrees : Float64, *, center_x : Int32 = width // 2, center_y : Int32 = height // 2, radius : Int32 = -1, pad : Bool = false, edge_policy : EdgePolicy = EdgePolicy::Black) : self
    # TODO: use pad

    # Rotate backwards, so that we can "look back" from the output pixel location into the input pixel location
    radians = -Math::PI * degrees / 180
    sin = Math.sin(radians)
    cos = Math.cos(radians)
    radius_sq = radius * radius

    if pad
      mod_radians = Math::PI * (degrees % 180) / 180
      x_bounds = [
        (Math.cos(mod_radians) * (-center_x) - Math.sin(mod_radians) * (-center_y) + center_x).round.to_i,
        (Math.cos(mod_radians) * (-center_x) - Math.sin(mod_radians) * (height - 1 - center_y) + center_x).round.to_i,
        (Math.cos(mod_radians) * (width - 1 - center_x) - Math.sin(mod_radians) * (-center_y) + center_x).round.to_i,
        (Math.cos(mod_radians) * (width - 1 - center_x) - Math.sin(mod_radians) * (height - 1 - center_y) + center_x).round.to_i,
      ]

      y_bounds = [
        (Math.sin(mod_radians) * (-center_x) + Math.cos(mod_radians) * (-center_y) + center_y).round.to_i,
        (Math.sin(mod_radians) * (-center_x) + Math.cos(mod_radians) * (height - 1 - center_y) + center_y).round.to_i,
        (Math.sin(mod_radians) * (width - 1 - center_x) + Math.cos(mod_radians) * (-center_y) + center_y).round.to_i,
        (Math.sin(mod_radians) * (width - 1 - center_x) + Math.cos(mod_radians) * (height - 1 - center_y) + center_y).round.to_i,
      ]

      new_width = x_bounds.max - x_bounds.min
      new_size = new_width * (y_bounds.max - y_bounds.min)
      out_center_x = center_x - x_bounds.min
      out_center_y = center_y - y_bounds.min
    else
      new_width = width
      new_size = size
      out_center_x = center_x
      out_center_y = center_y
    end

    each_channel do |channel, channel_type|
      new_x = -1
      new_y = -1
      new_channel = Array.new(new_size) do |i|
        new_x += 1
        new_x %= new_width
        new_y += 1 if new_x == 0

        if radius >= 0
          next channel[i] if ((new_x - center_x) ** 2 + (new_y - center_y) ** 2) > radius_sq
        end

        orig_x = (cos * (new_x - out_center_x) - sin * (new_y - out_center_y) + center_x).round.to_i
        orig_y = (sin * (new_x - out_center_x) + cos * (new_y - out_center_y) + center_y).round.to_i

        if edge_policy.black?
          next channel_type.default if orig_x < 0 || orig_x >= width || orig_y < 0 || orig_y >= height
        else
          orig_x = orig_x.clamp(0, width - 1)
          orig_y = orig_y.clamp(0, height - 1)
        end

        channel.unsafe_fetch(orig_y * width + orig_x)
      end

      self[channel_type] = new_channel
    end

    @width = new_width
    @height = new_size // new_width

    self
  end
end
