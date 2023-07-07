module CrImage::Operation::Pad
  def pad(all : Int32 = 0, *, top : Int32 = 0, bottom : Int32 = 0, left : Int32 = 0, right : Int32 = 0, pad_type : EdgePolicy = EdgePolicy::Black) : self
    pad!(all, top: top, bottom: bottom, left: left, right: right, pad_type: pad_type)
  end

  def pad!(all : Int32 = 0, *, top : Int32 = 0, bottom : Int32 = 0, left : Int32 = 0, right : Int32 = 0, pad_type : EdgePolicy = EdgePolicy::Black) : self
    # mem_start = GC.stats.total_bytes
    new_width = width
    new_height = height
    # puts "Memory start: #{GC.stats.total_bytes - mem_start}"
    each_color_channel do |channel, channel_type|
      padded = UInt8Map.new(width, channel).pad(all, top: top, bottom: bottom, left: left, right: right, pad_type: pad_type)
      self[channel_type] = padded.raw
      new_width = padded.width
      new_height = padded.height
      # puts "Memory after #{channel_type}: #{GC.stats.total_bytes - mem_start}"
    end

    # puts "Memory final: #{GC.stats.total_bytes - mem_start}"

    @width = new_width
    @height = new_height

    self
  end
end
