class CrImage::WindowView
  @half_width : Int32
  @half_height : Int32

  def initialize(
    @width : Int32,
    @height : Int32,
    @image : GrayscaleImage,
    @image_x : Int32,
    @image_y : Int32,
    *,
    @edge_policy : EdgePolicy = EdgePolicy::Repeat
  )
    @half_width = @width >> 1
    @half_height = @height >> 1
  end

  def each(& : (UInt8, Int32, Int32) -> Nil) : Nil
    @width.times do |x|
      @height.times do |y|
        yield self[x, y], x, y
      end
    end
  end

  def [](x : Int32, y : Int32) : UInt8
    # puts "\tIn self[] with parent dimensions #{@image.width}x#{@image.height}"
    adjusted_x = x - @half_width + @image_x
    adjusted_y = y - @half_height + @image_y

    # puts "\t\tInitial adjusted: #{adjusted_x}, #{adjusted_y}"
    if @edge_policy == EdgePolicy::None &&
       (adjusted_x < 0 || adjusted_x >= @image.width) &&
       (adjusted_y < 0 || adjusted_y >= @image.height)
      raise Exception.new "Coordinates #{x}, #{y} correspond to #{adjusted_x}, #{adjusted_y} in sliding window centered at #{@image_x}, #{@image_y}, which is outside"
    end

    return 0u8 if @edge_policy == EdgePolicy::Black && (adjusted_x < 0 || adjusted_x >= @image.width)
    return 0u8 if @edge_policy == EdgePolicy::Black && (adjusted_y < 0 || adjusted_y >= @image.height)

    adjusted_x = adjusted_x.clamp(0, @image.width - 1)
    adjusted_y = adjusted_y.clamp(0, @image.height - 1)
    # print "\t\tFinal adjusted: #{adjusted_x}, #{adjusted_y}, -> #{adjusted_y * @image.width + adjusted_x} in image "
    # puts @image.gray[adjusted_y * @image.width + adjusted_x]

    @image.gray[adjusted_y * @image.width + adjusted_x]
  end

  def sum(multiplier : Float64 = 1) : Float64
    values = [] of Float64
    @height.times do |y|
      @width.times do |x|
        values << self[x, y].to_f64
      end
    end
    multiplier * values.sum
  end

  def sum(multiplier : Float64 = 1, & : (UInt8, Int32, Int32) -> (Float64 | Int32)) : Float64
    values = [] of Float64
    # puts "Summing parent from coordinate #{@image_x}, #{@image_y} with edge policy #{@edge_policy}"
    @height.times do |y|
      @width.times do |x|
        values << (yield self[x, y], x, y).to_f64
        # puts "\tIn window #{x}, #{y}: #{values}"
      end
    end
    # puts "\tResolved values #{values}"
    multiplier * values.sum
  end
end
