# Apply a mask to an image
#
# Taking sample `image`:
#
# <img src="https://raw.githubusercontent.com/Vici37/cr-image/master/docs/images/sample.jpg" alt="Woman with black turtleneck and white background"/>
#
# And mask
#
# <img src="https://raw.githubusercontent.com/Vici37/cr-image/master/docs/images/apply_mask_mask.jpg" alt="Black box with thin horizontal white box at eye level"/>
#
# ```
# mask = CrImage::Mask.new(image, false)
# mask[50..90, 65..75] = true
# mask.to_gray.save("apply_mask_mask.jpg")
# image.apply(mask).save("apply_mask.jpg")
# image.apply_color(mask, CrImage::Color.of("#00f")).save("apply_mask_color.jpg")
# image.apply(mask) do |x, y, pixel, channel_type|
#   Math.min(255, pixel + 50).to_u8 if channel_type == :blue
# end.save("apply_mask_block.jpg")
# ```
# <img src="https://raw.githubusercontent.com/Vici37/cr-image/master/docs/images/apply_mask.jpg" alt="Image is blacked out other than thin horizontal bar of the woman's eyes"/>
# <img src="https://raw.githubusercontent.com/Vici37/cr-image/master/docs/images/apply_mask_color.jpg" alt="Thin horizontal blue bar over woman's eyes"/>
# <img src="https://raw.githubusercontent.com/Vici37/cr-image/master/docs/images/apply_mask_block.jpg" alt="Thin horizantal transparent blue bar over woman's eyes"/>
module CrImage::Operation::MaskApply
  # Black out all pixels but those found in the mask
  def apply(mask : Mask) : self
    clone.apply!(mask)
  end

  # Apply block to all pixels that match mask, replacing pixel value if block returns non-nil value.
  #
  # Does not change values not matched by the mask
  def apply(mask : Mask, &block : (Int32, Int32, UInt8, ChannelType) -> UInt8?) : self
    clone.apply!(mask, &block)
  end

  # Change the color of all pixels that match the mask
  def apply_color(mask : Mask, color : Color) : self
    clone.apply_color!(mask, color)
  end

  # TODO: add apply version that accepts 1+ ChannelType that the mask should apply to (i.e. make a background completely transparent, not just transparent black)
  def apply!(mask : Mask) : self
    raise "Mask of #{mask.width}x#{mask.height} doesn't match image dimensions #{width}x#{height}" unless mask.width == width && mask.height == height

    each_channel do |channel|
      channel.map_with_index! { |pixel, i| mask.at(i) ? pixel : 0u8 }
    end
    self
  end

  def apply!(mask : Mask, &block : (Int32, Int32, UInt8, ChannelType) -> UInt8?) : self
    raise "Mask of #{mask.width}x#{mask.height} doesn't match image dimensions #{width}x#{height}" unless mask.width == width && mask.height == height

    each_channel do |channel, channel_type|
      channel.map_with_index! do |pixel, i|
        mask.at(i) ? block.call(i % width, i // width, pixel, channel_type) || pixel : pixel
      end
    end
    self
  end

  def apply_color!(mask : Mask, color : Color) : self
    apply!(mask) do |_, _, _, channel_type|
      color[channel_type]
    end
  end
end
