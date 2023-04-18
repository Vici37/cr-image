module CrImage
  # TODO: create abstract Map module with all methods
  # TODO: rename current Map to MapImpl that includes abstract map
  # TODO: add Map module to Mask / BoolMap so they all have same methods
  # Grayscale image SHOULD NOT be a Map, but have the to_map method to construct an IntMap around @gray

  module Map(T)
    macro included
      {% verbatim do %}
        macro method_missing(call)
          def {{call.name.id}} : self
            self.class.new(width, @raw.map(&.{{call.name.id}}))
          end
        end
      {% end %}
    end

    getter width
    getter raw : Array(T)

    def initialize(@width : Int32, @raw : Array(T))
      raise Exception.new "Passed in array's size must be even multiple of width, has modulus remainder of #{@raw.size % @width}" unless (@raw.size % @width) == 0
    end

    def initialize(other : Array(Array(T)))
      raise Exception.new "Can't create an empty map" if other.empty?
      raise Exception.new "Can't create an empty map, first array is empty" if other[0].empty?
      raise Exception.new "All sub arrays must be the same size" unless other.map(&.size).uniq!.size == 1

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
      raise Exception.new "X coordinate #{x} is outside of Map width #{width}" if x >= width || x < 0
      raise Exception.new "Y coordinate #{y} is outside of Map height #{height}" if y >= height || y < 0
      index = y * width + x
      self[index]
    end

    def []?(index : Int32) : T?
      @raw[index]?
    end

    def []?(x : Int32, y : Int32) : T?
      return nil if x < 0 || x >= width
      return nil if y < 0 || y >= height
      index = y * width + x
      @raw[index]?
    end

    def mean : Float64
      @raw.sum / size
    end

    def min : T
      @raw.min
    end

    def max : T
      @raw.max
    end

    def sum : T
      @raw.sum
    end

    # Construct a `Mask` from this `GrayscaleImage` using the passed in block to determine if a given pixel should be true or not
    #
    # ```
    # # Construct a mask identifying the bright pixels in the bottom left corner of image
    # image.to_gray.mask_from do |pixel, x, y|
    #   x < image.width // 2 &&      # left half of image
    #     y > (image.height // 2) && # bottom half of image
    #     pixel > 128                # only "bright" pixels
    # end
    # ```
    # <img src="https://raw.githubusercontent.com/Vici37/cr-image/master/docs/images/sample.jpg" alt="Woman in black turtleneck on white background"/>
    # ->
    # <img src="https://raw.githubusercontent.com/Vici37/cr-image/master/docs/images/gray_mask_from_example.jpg" alt="Mask identifying bright spots in lower left corner"/>
    def mask_from(&block : (T, Int32, Int32) -> Bool) : Mask
      Mask.new(width, BitArray.new(size) do |i|
        block.call(@raw[i], i % width, i // width)
      end)
    end

    # Construct a `Mask` identifying all pixels larger than `num`.
    #
    # <img src="https://raw.githubusercontent.com/Vici37/cr-image/master/docs/images/sample.jpg" alt="Woman with black turtleneck and white background"/>
    #
    # ```
    # gray = image.to_gray                          # Convert color image to grayscale
    # mask = gray > 128                             # Generate a threshold mask
    # mask.to_gray.save("greater_than_example.jpg") # Convert and save the mask as a black and white image
    # ```
    # <img src="https://raw.githubusercontent.com/Vici37/cr-image/master/docs/images/gray_threshold_example.jpg" alt="Black and white silhouette with background and woman's face as white, hair and sweater black"/>
    def >(num : Int | Float) : Mask
      mask_from { |val| val > num }
    end

    # Construct a `Mask` identify all pixels larger than or equal to `num`. See `#>` for near example.
    def >=(num : Int | Float) : Mask
      mask_from { |val| val >= num }
    end

    # Construct a `Mask` identifying all pixels smaller than `num`.
    #
    # <img src="https://raw.githubusercontent.com/Vici37/cr-image/master/docs/images/sample.jpg" alt="Woman with black turtleneck and white background"/>
    #
    # ```
    # gray = image.to_gray                          # Convert color image to grayscale
    # mask = gray < 128                             # Generate a threshold mask
    # mask.to_gray.save("greater_than_example.jpg") # Convert and save the mask as a black and white image
    # ```
    # <img src="https://raw.githubusercontent.com/Vici37/cr-image/master/docs/images/less_than_example.jpg" alt="Black and white silhouette with background and woman's face as white, hair and sweater black"/>
    def <(num : Int | Float) : Mask
      mask_from { |val| val < num }
    end

    # Construct a `Mask` identifying all pixels smaller than or equal to `num`. See `#<` for near example.
    def <=(num : Int | Float) : Mask
      mask_from { |val| val <= num }
    end

    def ==(num : Int | Float) : Mask
      mask_from { |val| val == num }
    end

    def ==(other : self) : Bool
      other.width == width && @raw == other.raw
    end

    def /(num : Int | Float) : FloatMap
      FloatMap.new(width, @raw.map { |i| i / num })
    end

    def *(num : Int | Float) : self
      self.class.new(width, @raw.map { |i| i * num })
    end

    def +(num : Int | Float) : self
      self.class.new(width, @raw.map { |i| i + num })
    end

    def -(num : Int) : self
      self.class.new(width, @raw.map { |i| i - num })
    end

    def -(num : Float) : FloatMap
      FloatMap.new(width, @raw.map { |i| i - num })
    end

    def to_gray(*, scale : Bool = false) : GrayscaleImage
      if scale
        max_val = max
        min_val = min
        multiplier = 255 / (max_val - min_val)
        GrayscaleImage.new(@raw.map { |v| ((v - min_val) * multiplier).to_u8 }, width)
      else
        GrayscaleImage.new(@raw.map(&.to_u8), width)
      end
    end

    def to_a : Array(T)
      @raw.dup
    end

    def cross_correlate(map : Map, *, edge_policy : EdgePolicy = EdgePolicy::Repeat) : FloatMap
      half_width = map.width >> 1
      half_height = map.height >> 1

      start_x, start_y = (edge_policy.none? ? {half_width, half_height} : {0, 0})
      end_x, end_y = (edge_policy.none? ? {width - half_width - 1, height - half_height - 1} : {width - 1, height - 1})

      ret = Array(Float64).new((end_x - start_x) * (end_y - start_y))

      start_y.upto(end_y).each do |y|
        start_x.upto(end_x).each do |x|
          view = case edge_policy
                 in EdgePolicy::Repeat then RepeatView(T).new(map.width, map.height, self, x, y)
                 in EdgePolicy::Black  then BlackView(T).new(map.width, map.height, self, x, y)
                 in EdgePolicy::None   then ErrorView(T).new(map.width, map.height, self, x, y)
                 end
          # ret << view.sum(1.0 / map.raw.sum) do |pixel, vx, vy|
          ret << view.sum do |pixel, vx, vy|
            map[vx, vy] * pixel
          end
        end
      end

      retf = FloatMap.new(end_x - start_x + 1, ret)
      retf
    end
  end

  class IntMap
    include Map(Int32)
  end

  class UInt8Map
    include Map(UInt8)
  end

  class FloatMap
    include Map(Float64)
  end
end

struct Float
  def *(map : CrImage::Map)
    map * self
  end

  def +(map : CrImage::Map)
    map + self
  end
end

struct Int
  def *(map : CrImage::Map)
    map * self
  end

  def +(map : CrImage::Map)
    map + self
  end
end
