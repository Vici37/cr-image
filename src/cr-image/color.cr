module CrImage
  class Color
    getter red, green, blue, alpha

    def initialize(@red : UInt8, @green : UInt8, @blue : UInt8, @alpha : UInt8 = 255)
    end

    def [](channel_type : ChannelType) : UInt8
      case channel_type
      when ChannelType::Red   then red
      when ChannelType::Green then green
      when ChannelType::Blue  then blue
      when ChannelType::Alpha then alpha
      else                         raise "Color doesn't support channel type #{channel_type}"
      end
    end

    def self.of(color : String) : Color
      if !color.starts_with?("#") ||
         !{4, 5, 7, 9}.includes?(color.size) ||
         color.match(/^#[^0-9a-f]/i)
        raise "Invalid hex color '#{color}': must start with '#' followed by 3, 4, 6, or 9 alphanumeric characters (0-9 or a-f)"
      end

      case color.size
      when 4
        # #rgb
        red = color[1].to_i(16).to_u8
        green = color[2].to_i(16).to_u8
        blue = color[3].to_i(16).to_u8
        self.new((red << 4) + red, (green << 4) + green, (blue << 4) + blue)
      when 5
        # #argb
        alpha = color[1].to_i(16).to_u8
        red = color[2].to_i(16).to_u8
        green = color[3].to_i(16).to_u8
        blue = color[4].to_i(16).to_u8
        self.new((red << 4) + red, (green << 4) + green, (blue << 4) + blue, (alpha << 4) + alpha)
      when 7
        # #rrggbb
        red = color[1, 2].to_i(16).to_u8
        green = color[3, 2].to_i(16).to_u8
        blue = color[5, 2].to_i(16).to_u8
        self.new(red, green, blue)
      else
        # #aarrggbb
        alpha = color[1, 2].to_i(16).to_u8
        red = color[3, 2].to_i(16).to_u8
        green = color[5, 2].to_i(16).to_u8
        blue = color[7, 2].to_i(16).to_u8
        self.new(red, green, blue, alpha)
      end
    end

    def ==(other : Color) : Bool
      red == other.red &&
        green == other.green &&
        blue == other.blue &&
        alpha == other.alpha
    end
  end
end
