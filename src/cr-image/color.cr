# Utility class for parsing and representing colors that can be used for certain
# methods in CrImage.
#
# See `Operation::MaskApply#apply_color`, `Operation::Draw#draw_square`, or `Operation::Draw#draw_circle`
class CrImage::Color
  getter red, green, blue, alpha

  def initialize(@red : UInt8, @green : UInt8, @blue : UInt8, @alpha : UInt8 = ChannelType::Alpha.default)
  end

  def self.default : Color
    new(ChannelType::Red.default, ChannelType::Green.default, ChannelType::Blue.default, ChannelType::Alpha.default)
  end

  # Generate a random color with full (255) opacity
  def self.random : Color
    r = Random.new
    new(r.rand(UInt8), r.rand(UInt8), r.rand(UInt8), ChannelType::Alpha.default)
  end

  # Convert this Color to a single UInt8 gray value
  def gray(red_multiplier : Float = 0.299, green_multiplier : Float = 0.587, blue_multiplier : Float = 0.114) : UInt8
    Math.min(255u8,
      (red * red_multiplier + blue * blue_multiplier + green * green_multiplier).to_u8
    )
  end

  # Receive the UInt8 portion of this color corresponding to `channel_type`
  def [](channel_type : ChannelType) : UInt8
    case channel_type
    in ChannelType::Red   then red
    in ChannelType::Green then green
    in ChannelType::Blue  then blue
    in ChannelType::Alpha then alpha
    in ChannelType::Gray  then gray
    end
  end

  # Parse color from a hex string:
  #
  # ```
  # Color.of("#1")        # same as "#11" => Color.new(17, 17, 17, 255)
  # Color.of("#01")       # => Color.new(1, 1, 1, 255)
  # Color.of("#123")      # same as "#112233" => Color.new(17, 34, 51, 255)
  # Color.of("#1234")     # same as "#11223344" => Color.new(34, 51, 68, 17)
  # Color.of("#010203")   # => Color.new(1, 2, 3, 255)
  # Color.of("#01020304") # => Color.new(2, 3, 4, 1)
  # ```
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
