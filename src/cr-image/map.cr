module CrImage
  module Map(T)
    getter width
    getter raw : Array(T)
    @mean : Float64?

    def initialize(@width : Int32, @raw : Array(T))
    end

    def initialize(other : Array(Array(T)))
      raise "Can't create an empty map" if other.empty?
      raise "Can't create an empty map, first array is empty" if other[0].empty?
      raise "All sub arrays must be the same size" unless other.map(&.size).uniq!.size == 1

      @width = other[0].size
      @raw = other.flatten
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

    def size : Int32
      @raw.size
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
      @mean = nil
      @raw[index] = value
    end

    def mean : Float64
      @mean ||= @raw.sum.to_f / size
    end

    def mask_from(&block : (Int32, Int32, T) -> Bool) : Mask
      Mask.new(width, BitArray.new(size) do |i|
        block.call(i % width, i // width, @raw[i])
      end)
    end

    def >(num : Int | Float) : ReturnValue
      mask_from do |_, _, val|
        val > num
      end
    end

    def >=(num : Int | Float) : ReturnValue
      mask_from do |_, _, val|
        val >= num
      end
    end

    def <(num : Int | Float) : ReturnValue
      mask_from do |_, _, val|
        val < num
      end
    end

    def <=(num : Int | Float) : ReturnValue
      mask_from do |_, _, val|
        val <= num
      end
    end
  end

  class Float64Map
    include Map(Float64)
  end

  class Int32Map
    include Map(Int32)
  end
end
