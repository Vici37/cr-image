module CrImage::Operation::Rotate
  def rotate(degrees : Float64, *, center_x : Int32 = width // 2, center_y : Int32 = height // 2, radius : Int32 = -1, pad : Bool = false) : self
    clone.rotate!(degrees, center_x: center_x, center_y: center_y, radius: radius, pad: pad)
  end

  def rotate!(degrees : Float64, *, center_x : Int32 = width // 2, center_y : Int32 = height // 2, radius : Int32 = -1, pad : Bool = false) : self
    # TODO: use pad

    # Rotate backwards, so that we can "look back" from the output pixel location into the input pixel location
    radians = -Math::PI * degrees / 180
    sin = Math.sin(radians)
    cos = Math.cos(radians)
    radius_sq = radius * radius

    new_size = size
    out_center_x = center_x
    out_center_y = center_y
    each_channel do |channel, channel_type|
      new_x = -1
      new_y = -1
      new_channel = Array.new(new_size) do |i|
        new_x += 1
        new_x %= width
        new_y += 1 if new_x == 0

        if radius >= 0
          next channel[i] if ((new_x - center_x) ** 2 + (new_y - center_y) ** 2) > radius_sq
        end

        orig_x = (cos * (new_x - center_x) - sin * (new_y - center_y) + out_center_x).round.to_i
        orig_y = (sin * (new_x - center_x) + cos * (new_y - center_y) + out_center_y).round.to_i

        next channel_type.default if orig_x < 0 || orig_x >= width || orig_y < 0 || orig_y >= height

        channel.unsafe_fetch(orig_y * width + orig_x)
      end

      self[channel_type] = new_channel
    end

    self
  end
end
