module CrImage
  # An interface for 2 dimensional data. Used for various masking and correlation methods.
  module Map(T)
    abstract def width : Int32
    abstract def height : Int32
    abstract def size : Int32
    abstract def shape : Tuple(Int32, Int32)
    abstract def [](index : Int32) : T
    abstract def [](x : Int32, y : Int32) : T
    abstract def []?(index : Int32) : T?
    abstract def []?(x : Int32, y : Int32) : T?

    private def resolve_to_start_and_count(range, size) : Tuple(Int32, Int32)
      start, count = Indexable.range_to_index_and_count(range, size) || raise IndexError.new("Unable to resolve range #{range} for mask dimension of #{size}")
      raise IndexError.new("Range #{range} exceeds bounds of #{size}") if (start + count) > size
      {start, count}
    end
  end

  # :nodoc:
  module MapImpl(T)
    include Map(T)

    macro included
      {% verbatim do %}
        macro method_missing(call)
          def {{call.name.id}}{% if call.args.size > 0 %}({{call.args.join(", ").id}}){% end %} : self
            self.class.new(width, @raw.map(&.{{call.name.id}}{% if call.args.size > 0 %}({{call.args.join(", ").id}}){% end %}))
          end
        end
      {% end %}
    end

    getter width : Int32

    # Return the raw array underlying the map
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

    # Return the shape of the map - `{width, height}`
    def shape : Tuple(Int32, Int32)
      {width, height}
    end

    # Size of the map - `width * height`
    def size : Int32
      @raw.size
    end

    # Get element at `index` from underlying `raw` Array.
    def [](index : Int32) : T
      @raw[index]
    end

    # Get element at coordinates `x` and `y`
    def [](x : Int32, y : Int32) : T
      raise Exception.new "X coordinate #{x} is outside of Map width #{width}" if x >= width || x < 0
      raise Exception.new "Y coordinate #{y} is outside of Map height #{height}" if y >= height || y < 0
      index = y * width + x
      self[index]
    end

    # Get element at `index`, or `nil` if out of bounds
    def []?(index : Int32) : T?
      @raw[index]?
    end

    # Get lement at coordinates `x` and `y`, or `nil` if coordinates are out of bounds
    def []?(x : Int32, y : Int32) : T?
      return nil if x < 0 || x >= width
      return nil if y < 0 || y >= height
      index = y * width + x
      @raw[index]?
    end

    def [](xrange : Range, yrange : Range) : self
      xstart, xcount = resolve_to_start_and_count(xrange, width)
      ystart, ycount = resolve_to_start_and_count(yrange, height)

      raise Exception.new "Can't crop to 0 #{xcount == 0 ? "width" : "height"}" if xcount == 0 || ycount == 0
      raise Exception.new "Crop dimensions extend #{xstart + xcount - width} pixels beyond width of the image (#{width})" if (xstart + xcount) > width
      raise Exception.new "Crop dimensions extend #{ystart + ycount - height} pixels beyond height of the image (#{height})" if (ystart + ycount) > height

      new_size = xcount * ycount
      height_offset = ystart * width
      new_raw = Array(T).new(new_size) { T.zero }

      ycount.times do |new_y|
        orig_index = height_offset + (new_y * width) + xstart
        new_raw[new_y * xcount, xcount] = raw[orig_index, xcount]
      end

      {{@type}}.new(xcount, new_raw)
    end

    # Return the average of the elements in this `Map`
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

    def zero_pad(*, top : Int32 = 0, bottom : Int32 = 0, left : Int32 = 0, right : Int32 = 0) : self
      top = Math.max(top, 0)
      bottom = Math.max(bottom, 0)
      left = Math.max(left, 0)
      right = Math.max(right, 0)

      new_width = left + width + right
      new_raw = Array(T).new((top + height + bottom) * new_width) { T.zero }

      0.upto(height - 1) do |y|
        adjusted_y = y + top
        new_raw[adjusted_y * new_width + left, width] = raw[y * width, width]
      end

      {{@type}}.new(new_width, new_raw)
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

    def cross_correlate_dft(map : Map, *, edge_policy : EdgePolicy = EdgePolicy::Black) : FloatMap
      raise Exception.new("Passed in map (#{map.width}x#{map.height}) must be smaller than this map (#{width}x#{height})") if map.width >= width || map.height >= height

      start = Time.monotonic
      pad_width, pad_height = map.width - 1, map.height - 1
      puts "#{Time.monotonic - start}: padding and getting dft of original"
      orig_pad_dft = zero_pad(bottom: pad_height, right: pad_width).dft
      puts "#{Time.monotonic - start}: padding and getting dft of map"
      map_pad_dft = map.zero_pad(bottom: height - 1, right: width - 1).dft
      puts "#{Time.monotonic - start}: done padding and dfting"

      width_range, height_range = case edge_policy
                                  in EdgePolicy::Black
                                    {
                                      (pad_width//2)...(width + (pad_width//2)),
                                      (pad_height//2)...(height + (pad_height//2)),
                                    }
                                  in EdgePolicy::Repeat
                                    {
                                      ((map.width - 1)//2)...(width + ((map.width - 1)//2)),
                                      ((map.height - 1)//2)...(height + ((map.height - 1)//2)),
                                    }
                                  in EdgePolicy::None
                                    {
                                      (pad_width)...(pad_width + width - (map.width//2)*2),
                                      (pad_height)...(pad_height + height - (map.height//2)*2),
                                    }
                                  end

      # pp! width_range, height_range
      # cm = ComplexMap.new(orig_pad_dft.width, orig_pad_dft.raw.map_with_index { |v, i| v * map_pad_dft[i] }).idft
      ComplexMap.new(orig_pad_dft.width, orig_pad_dft.raw.map_with_index { |v, i| v * map_pad_dft[i] }).idft[
        width_range, height_range,
      ]
    end

    def dft : ComplexMap
      self_to_f = to_f
      new_raw = Array(Complex).new(raw.size) { Complex.zero }
      sum_arr = new_raw.size.times.to_a

      last = Time.monotonic
      0.upto(width - 1) do |x|
        0.upto(height - 1) do |y|
          # TODO: https://mathcs.org/java/programs/FFT/FFTInfo/c12-4.pdf

          new_raw[y * width + x] = sum_arr.sum do |i|
            # puts "#{i}: #{x}x#{y} (#{x} / #{width - 1}" if y >= 501
            k1 = i % width
            k2 = i // width

            self_to_f[i] * Math.exp(2.i * Math::PI * x * k1 / width) * Math.exp(2.i * Math::PI * y * k2 / height)
          end
          puts "#{Time.monotonic - last}: #{x} / #{width - 1} x#{y} / #{height - 1}: #{new_raw[y * width + x]}"
          last = Time.monotonic
        end
      end
      puts "constructing complex map of width #{width} and size #{new_raw.size}"
      ComplexMap.new(width, new_raw)
    end

    def to_s
      raw.each_with_index do |val, i|
        print("#{val.round}\t")
        puts if (i + 1) % width == 0
      end
    end
  end

  class IntMap
    include MapImpl(Int32)

    def to_f64 : FloatMap
      FloatMap.new(width, @raw.map(&.to_f64))
    end

    def to_f
      to_f64
    end

    def to_i : self
      self
    end
  end

  class UInt8Map
    include MapImpl(UInt8)
  end

  class FloatMap
    include MapImpl(Float64)

    def to_f64 : self
      self
    end

    def to_i : IntMap
      IntMap.new(width, @raw.map(&.to_i))
    end
  end

  class OneMap
    include Map(Int32)

    getter width : Int32
    getter height : Int32

    def initialize(@width : Int32, @height : Int32)
    end

    def shape : Tuple(Int32, Int32)
      {width, height}
    end

    def size : Int32
      width * height
    end

    def [](index : Int32) : Int32
      1
    end

    def []?(index : Int32) : Int32
      1
    end

    def [](x : Int32, y : Int32) : Int32
      1
    end

    def []?(x : Int32, y : Int32) : Int32
      1
    end

    def to_intmap : IntMap
      IntMap.new(width, Array(Int32).new(size) { 1 })
    end
  end

  class ComplexMap
    include MapImpl(Complex)

    def idft : FloatMap
      new_raw = Array(Float64).new(raw.size) { Float64.zero }
      0.upto(width - 1) do |x|
        0.upto(height - 1) do |y|
          # TODO: https://mathcs.org/java/programs/FFT/FFTInfo/c12-4.pdf
          new_raw[y * width + x] = (new_raw.size.times.to_a.sum do |i|
            k1 = i % width
            k2 = i // width

            self[i] * Math.exp(-2.i * Math::PI * x * k1 / width) * Math.exp(-2.i * Math::PI * y * k2 / height)
          end / size).real
        end
      end
      FloatMap.new(width, new_raw)
    end
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
