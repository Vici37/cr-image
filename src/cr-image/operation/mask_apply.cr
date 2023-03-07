module CrImage::Operation::MaskApply
  def apply(mask : Mask) : self
    clone.apply!(mask)
  end

  def apply(mask : Mask, &block : (Int32, Int32, UInt8, ChannelType) -> UInt8) : self
    clone.apply!(mask, &block)
  end

  def apply_color(mask : Mask, color : Color) : self
    clone.apply_color!(mask, color)
  end

  def apply!(mask : Mask) : self
    raise "Mask of #{mask.width}x#{mask.height} doesn't match image dimensions #{width}x#{height}" unless mask.width == width && mask.height == height

    each_channel do |channel|
      channel.map_with_index! { |pixel, i| mask.at(i) ? pixel : 0u8 }
    end
    self
  end

  def apply!(mask : Mask, &block : (Int32, Int32, UInt8, ChannelType) -> UInt8) : self
    raise "Mask of #{mask.width}x#{mask.height} doesn't match image dimensions #{width}x#{height}" unless mask.width == width && mask.height == height

    each_channel do |channel, channel_type|
      channel.map_with_index! do |pixel, i|
        mask.at(i) ? block.call(i % width, i // width, pixel, channel_type) : pixel
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
