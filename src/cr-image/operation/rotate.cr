# Rotates an image
#
# Taking sample `image`:
#
# <img src="https://raw.githubusercontent.com/Vici37/cr-image/master/docs/images/sample.jpg" alt="Woman with black turtleneck and white background"/>
#
# ```
# image.rotate(45)
# image.rotate(45, pad: true)
# ```
# <img src="https://raw.githubusercontent.com/Vici37/cr-image/master/docs/images/rotate_45.jpg" alt="Rotated image by 45 degrees"/>
# <img src="https://raw.githubusercontent.com/Vici37/cr-image/master/docs/images/rotate_45_pad.jpg" alt="Rotated image by 45 degrees, padded to show corners"/>
module CrImage::Operation::Rotate
  # Rotates an image by `degrees`
  #
  # `center_x` and `center_y` represents the point in the image that will be rotated around. Defaults to image center.
  # `radius` can be used to only rotate a smaller circular region in the image. Can't be used with `pad`
  # `pad` can be used to pad out the image so that corners that would normally be occluded, are visible.
  # `pad_type` behaves the same as `pad_type` in `Pad`
  def rotate(
    degrees : Float64,
    *,
    center_x : Int32 = width // 2,
    center_y : Int32 = height // 2,
    radius : Int32 = -1,
    pad : Bool = false,
    pad_type : EdgePolicy = EdgePolicy::Black
  ) : self
    clone.rotate!(degrees, center_x: center_x, center_y: center_y, radius: radius, pad: pad, pad_type: pad_type)
  end

  # Rotates an image by `degrees`. Modifies `self`
  #
  # `center_x` and `center_y` represents the point in the image that will be rotated around. Defaults to image center.
  # `radius` can be used to only rotate a smaller circular region in the image. Can't be used with `pad`
  # `pad` can be used to pad out the image so that corners that would normally be occluded, are visible.
  # `pad_type` behaves the same as `pad_type` in `Pad`
  def rotate!(
    degrees : Float64,
    *,
    center_x : Int32 = width // 2,
    center_y : Int32 = height // 2,
    radius : Int32 = -1,
    pad : Bool = false,
    pad_type : EdgePolicy = EdgePolicy::Black
  ) : self
    raise Exception.new("Edge policy None doesn't apply to rotation") if pad_type.none?
    raise Exception.new("Can't pad image and limit rotation by radius") if pad && radius >= 0

    # Rotate backwards, so that we can "look back" from the output pixel location into the input pixel location
    radians = -Math::PI * degrees / 180
    sin = Math.sin(radians)
    cos = Math.cos(radians)
    radius_sq = radius * radius

    new_width, new_size, out_center_x, out_center_y = output_dimensions(pad, degrees, center_x, center_y)

    each_channel do |channel, channel_type|
      new_x = -1
      new_y = 0
      self[channel_type] = Array.new(new_size) do |i|
        new_x += 1
        if new_x == new_width
          new_x = 0
          new_y += 1
        end

        next channel.unsafe_fetch(i) if radius >= 0 && ((new_x - center_x) ** 2 + (new_y - center_y) ** 2) > radius_sq

        orig_x = (cos * (new_x - out_center_x) - sin * (new_y - out_center_y) + center_x).round.to_i
        orig_y = (sin * (new_x - out_center_x) + cos * (new_y - out_center_y) + center_y).round.to_i

        if pad_type.black?
          next channel_type.default if orig_x < 0 || orig_x >= width || orig_y < 0 || orig_y >= height
        else
          orig_x = orig_x.clamp(0, width - 1)
          orig_y = orig_y.clamp(0, height - 1)
        end

        channel.unsafe_fetch(orig_y * width + orig_x)
      end
    end

    @width = new_width
    @height = new_size // new_width

    self
  end

  private def output_dimensions(pad, degrees, center_x, center_y) : Tuple(Int32, Int32, Int32, Int32)
    if pad
      mod_radians = Math::PI * (degrees % 180) / 180
      mod_cos = Math.cos(mod_radians)
      mod_sin = Math.sin(mod_radians)
      x_bounds = [
        (mod_cos * (-center_x) - mod_sin * (-center_y) + center_x).round.to_i,
        (mod_cos * (-center_x) - mod_sin * (height - 1 - center_y) + center_x).round.to_i,
        (mod_cos * (width - 1 - center_x) - mod_sin * (-center_y) + center_x).round.to_i,
        (mod_cos * (width - 1 - center_x) - mod_sin * (height - 1 - center_y) + center_x).round.to_i,
      ]

      y_bounds = [
        (mod_sin * (-center_x) + mod_cos * (-center_y) + center_y).round.to_i,
        (mod_sin * (-center_x) + mod_cos * (height - 1 - center_y) + center_y).round.to_i,
        (mod_sin * (width - 1 - center_x) + mod_cos * (-center_y) + center_y).round.to_i,
        (mod_sin * (width - 1 - center_x) + mod_cos * (height - 1 - center_y) + center_y).round.to_i,
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
    {new_width, new_size, out_center_x, out_center_y}
  end
end
