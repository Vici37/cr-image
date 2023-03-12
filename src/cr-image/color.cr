module CrImage
  class Color
    getter red, green, blue, alpha

    def initialize(@red : UInt8, @green : UInt8, @blue : UInt8, @alpha : UInt8 = 255)
    end

    def self.random : Color
      r = Random.new
      new(r.rand(UInt8), r.rand(UInt8), r.rand(UInt8), 255u8)
    end

    def gray(red_multiplier : Float = 0.299, green_multiplier : Float = 0.587, blue_multiplier : Float = 0.114) : UInt8
      Math.min(255u8,
        (red * red_multiplier + blue * blue_multiplier + green * green_multiplier).to_u8
      )
    end

    def [](channel_type : ChannelType) : UInt8
      case channel_type
      in ChannelType::Red   then red
      in ChannelType::Green then green
      in ChannelType::Blue  then blue
      in ChannelType::Alpha then alpha
      in ChannelType::Gray  then gray
      end
    end

    def self.of(color : String) : Color
      if !color.starts_with?("#") ||
         !{2, 3, 4, 5, 7, 9}.includes?(color.size) ||
         color.match(/^#[^0-9a-f]/i)
        raise "Invalid hex color '#{color}': must start with '#' followed by 1, 2, 3, 4, 6, or 9 alphanumeric characters (0-9 or a-f)"
      end

      case color.size
      when 2
        gray = color[1].to_i(16).to_u8
        gray = (gray << 4) + gray
        self.new(gray, gray, gray)
      when 3
        gray = color[1, 2].to_i(16).to_u8
        self.new(gray, gray, gray)
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
