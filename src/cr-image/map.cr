module CrImage
  class Map(T)
    getter width
    getter raw : Array(T)

    def initialize(@width : Int32, @raw : Array(T))
    end

    def initialize(@width : Int32, height : Int32, & : Int32 -> T)
      @raw = Array(T).new(@width * height) do |i|
        yield i
      end
    end

    def initialize(@width : Int32, height : Int32, initial : T)
      @raw = Array(T).new(@width * height) { initial }
    end

    def height : Int32
      @raw.size // @width
    end

    def [](index : Int32) : T
      @raw[index]
    end

    def [](x : Int32, y : Int32) : T
      index = y * width + x
      @raw[index]
    end

    def []?(x : Int32, y : Int32) : T?
      index = y * width + x
      @raw[index]?
    end

    def []=(x : Int32, y : Int32, value : T) : T
      index = y * width + x
      @raw[index] = value
    end
  end

  class FloatMap < Map(Float64)
  end

  class IntMap < Map(Int32)
  end
end
