module CrImage
  abstract class Window(T)
    getter half_width : Int32
    getter half_height : Int32
    getter width : Int32
    getter height : Int32
    getter map : Map(T)
    getter map_x : Int32
    getter map_y : Int32

    def initialize(@width, @height, @map, @map_x, @map_y)
      @half_height = @height // 2
      @half_width = @width // 2
    end

    abstract def [](x : Int32, y : Int32) : T

    def sum : Float64
      sum(&.itself)
    end

    def sum(& : (T, Int32, Int32, self) -> (T)) : Float64
      values = [] of Float64
      height.times do |y|
        width.times do |x|
          values << (yield self[x, y], x, y, self).to_f64
        end
      end
      values.sum
    end

    def mean : Float64
      sum / size
    end

    def size : Int32
      @width * @height
    end
  end

  class RepeatView(T) < Window(T)
    def [](x : Int32, y : Int32) : T
      adjusted_x = (x - @half_width + @map_x).clamp(0, @map.width - 1)
      adjusted_y = (y - @half_height + @map_y).clamp(0, @map.height - 1)
      @map[adjusted_y * @map.width + adjusted_x]
    end
  end

  class ErrorView(T) < Window(T)
    def [](x : Int32, y : Int32) : T
      adjusted_x = x - @half_width + @map_x
      adjusted_y = y - @half_height + @map_y

      if (adjusted_x < 0 || adjusted_x >= @map.width) ||
         (adjusted_y < 0 || adjusted_y >= @map.height)
        raise Exception.new "Coordinates #{x}, #{y} correspond to #{adjusted_x}, #{adjusted_y} in sliding window sized #{width}x#{height} centered at #{@map_x}, #{@map_y}, which is outside"
      end

      @map[adjusted_y * @map.width + adjusted_x]
    end
  end

  class BlackView(T) < Window(T)
    def [](x : Int32, y : Int32) : T
      adjusted_x = x - @half_width + @map_x
      adjusted_y = y - @half_height + @map_y

      if (adjusted_x < 0 || adjusted_x >= @map.width) ||
         (adjusted_y < 0 || adjusted_y >= @map.height)
        return T.zero
      end

      @map[adjusted_y * @map.width + adjusted_x]
    end
  end
end
