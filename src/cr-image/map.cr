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

    # Get a single dimensional `Map` representing the row at `y`
    def row(y : Int32) : self
      internal_crop(0, width, y, 1)
    end

    # Get a single dimensional `Map` representing teh column at `x`
    def column(x : Int32) : self
      internal_crop(x, 1, 0, height)
    end

    def [](xrange : Range, ystart : Int32) : self
      internal_crop(*resolve_to_start_and_count(xrange, width), ystart, 1)
    end

    def [](xstart : Int32, yrange : Range) : self
      internal_crop(xstart, 1, *resolve_to_start_and_count(yrange, height))
    end

    def [](xrange : Range, yrange : Range) : self
      internal_crop(*resolve_to_start_and_count(xrange, width), *resolve_to_start_and_count(yrange, height))
    end

    def [](xstart : Int32, xcount : Int32, ystart : Int32, ycount : Int32) : self
      internal_crop(xstart, xcount, ystart, ycount)
    end

    private def internal_crop(xstart : Int32, xcount : Int32, ystart : Int32, ycount : Int32) : self
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

    def +(other : self) : self
      raise Exception.new "Dimensions should match (caller: #{width}x#{height}, callee: #{other.width}x#{other.height})" unless width == other.width && height == other.height
      self.class.new(width, @raw.map_with_index { |val, i| val + other[i] })
    end

    def to_gray(*, scale : Bool = false) : GrayscaleImage
      if scale
        max_val = max
        min_val = min
        multiplier = 255 / (max_val - min_val)
        # Use clamp for floating point rounding errors
        GrayscaleImage.new(@raw.map { |v| ((v - min_val) * multiplier).clamp(0, 255).to_u8 }, width)
      else
        GrayscaleImage.new(@raw.map(&.to_u8), width)
      end
    end

    def to_a : Array(T)
      @raw.dup
    end

    def pad(all : Int32 = 0, *, top : Int32 = 0, bottom : Int32 = 0, left : Int32 = 0, right : Int32 = 0, pad_type : EdgePolicy = EdgePolicy::Black, pad_black_value : T = T.zero) : self
      top = top > 0 ? top : all
      bottom = bottom > 0 ? bottom : all
      left = left > 0 ? left : all
      right = right > 0 ? right : all

      new_width = left + width + right
      new_raw = initial_raw_pad(pad_type, new_width, top, bottom, left, right, pad_black_value)

      # Now copy the original values into the new raw array at the correct locations
      height.times do |y|
        adjusted_y = y + top
        (new_raw.to_unsafe + adjusted_y * new_width + left).copy_from(raw.to_unsafe + y * width, width)
      end

      # If the pad type is repeat, then repeat the top and bottom line of pixels, well, on the top and bottom of the image
      if pad_type.repeat?
        if top > 0
          copy = new_raw[new_width * top, new_width]
          top.times do |i|
            new_raw[i * new_width, new_width] = copy
          end
        end
        if bottom > 0
          copy = new_raw[new_width * (top + height - 1), new_width]
          bottom.times do |i|
            new_raw[(i + top + height) * new_width, new_width] = copy
          end
        end
      end

      self.class.new(new_width, new_raw)
    end

    private def initial_raw_pad(pad_type, new_width, top, bottom, left, right, pad_black_value) : Array(T)
      case pad_type
      in EdgePolicy::Black then Array(T).new((top + height + bottom) * new_width) { pad_black_value }
      in EdgePolicy::Repeat
        adjusted_x = -1
        current_y = 0
        Array(T).new((top + height + bottom) * new_width) do |i|
          adjusted_x += 1
          if adjusted_x == new_width
            adjusted_x = 0
            current_y += 1
          end
          next pad_black_value if (current_y) < top || current_y >= (top + height)

          adjusted_y = (current_y) - top

          adjusted_x <= left ? self[0, adjusted_y] : self[width - 1, adjusted_y]
        end
      in EdgePolicy::None then raise Exception.new("Pad method doesn't support edge policy None")
      end
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

    def cross_correlate_fft(map : Map, *, edge_policy : EdgePolicy = EdgePolicy::Black) : FloatMap
      max_width, max_height = Math.pw2ceil(width + map.width), Math.pw2ceil(height + map.height)
      pad_type = edge_policy.none? ? EdgePolicy::Black : edge_policy
      orig_pad_fft = pad(
        top: (map.height // 2) + (map.height % 2),
        bottom: max_height - height - (map.height // 2 + map.height % 2),
        right: max_width - width - (map.width // 2 + map.width % 2),
        left: (map.width // 2) + (map.width % 2),
        pad_type: pad_type).fft
      map_pad_fft = map.pad(bottom: max_height - map.height, right: max_width - map.width).fft

      width_range, height_range = case edge_policy
                                  in EdgePolicy::Black, EdgePolicy::Repeat
                                    {
                                      (map.width)...(width + map.width),
                                      (map.height)...(height + map.height),
                                    }
                                  in EdgePolicy::None
                                    {
                                      (map.width + map.width // 2)..(map.width + width - map.width + 1),
                                      (map.height + map.height // 2)..(map.height + height - map.height + 1),
                                    }
                                  end

      ComplexMap.new(orig_pad_fft.width, orig_pad_fft.raw.map_with_index { |v, i| v * map_pad_fft[i] }).ifft[
        width_range, height_range,
      ]
    end

    def fft : ComplexMap
      map = ComplexMap.new(width, Array(Complex).new(size) { |i| Complex.new(raw.unsafe_fetch(i)) })
        .pad(bottom: Math.pw2ceil(height) - height, right: Math.pw2ceil(width) - width)

      row_buffer = Array(Complex).new(width) { Complex.zero }
      height_buffer = Array(Complex).new(height) { Complex.zero }
      ret_raw = map.raw # Array(Complex).new(map.size) { |i| Complex.new(map.raw[i]) }

      beginning = -width
      height.times do
        beginning += width
        row_buffer.to_unsafe.copy_from(ret_raw.to_unsafe + beginning, width)
        row_buffer = fft1d_unsafe(row_buffer)
        (ret_raw.to_unsafe + beginning).copy_from(row_buffer.to_unsafe, width)
      end

      width.times do |x|
        spot = 0
        height.times do |i|
          height_buffer.unsafe_put(i, ret_raw.unsafe_fetch(spot + x))
          spot += width
        end
        fft1d_unsafe(height_buffer)
        spot = 0
        height.times do |i|
          ret_raw.unsafe_put(spot + x, height_buffer.unsafe_fetch(i))
          spot += width
        end
      end

      ComplexMap.new(map.width, ret_raw)
    end

    private def fft1d_unsafe(ret : Array(Complex)) : Array(Complex)
      # TODO: ensure `ret` size is a power of 2

      ret_copy = ret.dup

      shape = 1
      half = ret.size
      real_half = ret.size // 2

      while half > 1
        double_half = half
        half //= 2
        neg_i_pi_div_shape = -Math::PI.i / shape
        ret_copy.to_unsafe.copy_from(ret.to_unsafe, ret.size)

        half_offset = 0
        shape.times do |i|
          term = Math.exp(neg_i_pi_div_shape * i)
          half.times do |j|
            offset = half + j + (half_offset)
            ret_copy.unsafe_put(offset, ret_copy.unsafe_fetch(offset) * term)
          end
          half_offset += double_half
        end

        offset = -1
        counter = -1
        real_half.times do |i|
          offset += 1
          counter += 1
          if counter == half
            counter = 0
            offset += half
          end

          ret.unsafe_put(i,
            ret_copy.unsafe_fetch(offset) + ret_copy.unsafe_fetch(offset + half))
          ret.unsafe_put(i + real_half,
            ret_copy.unsafe_fetch(offset) - ret_copy.unsafe_fetch(offset + half))
        end

        shape *= 2
      end

      ret
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

    def to_i : IntMap
      IntMap.new(width, @raw.map(&.to_i))
    end
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

    def ifft : FloatMap
      row_buffer = Array(Complex).new(width) { Complex.zero }
      height_buffer = Array(Complex).new(height) { Complex.zero }
      complex_raw = Array(Complex).new(size) { Complex.zero }
      ret_raw = Array(Float64).new(size) { 0f64 }

      beginning = -width
      height.times do
        beginning += width
        row_buffer.to_unsafe.copy_from(raw.to_unsafe + beginning, width)
        ifft1d_unsafe(row_buffer)
        (complex_raw.to_unsafe + beginning).copy_from(row_buffer.to_unsafe, width)
      end

      width.times do |x|
        spot = 0
        height.times do |i|
          height_buffer.unsafe_put(i, complex_raw.unsafe_fetch(spot + x))
          spot += width
        end
        ifft1d_unsafe(height_buffer)
        spot = 0
        height.times do |i|
          ret_raw.unsafe_put(spot + x, height_buffer.unsafe_fetch(i).real)
          spot += width
        end
      end

      FloatMap.new(width, ret_raw)
    end

    private def ifft1d(inp : Array(Complex))
      ifft1d_unsafe(inp.dup)
    end

    private def ifft1d_unsafe(ret : Array(Complex)) : Array(Complex)
      #   ComplexMap.ifft1d(inp)
      # end

      # def self.ifft1d(inp : Array(Complex))
      ret_copy = ret.dup

      shape = 1
      half = ret.size
      real_half = ret.size // 2

      while half > 1
        double_half = half
        half //= 2
        neg_i_pi_div_shape = Math::PI.i / shape
        ret_copy.to_unsafe.copy_from(ret.to_unsafe, ret.size)

        shape.times do |i|
          term = Math.exp(neg_i_pi_div_shape * i)
          half.times do |j|
            offset = half + j + (i * double_half)
            ret_copy.unsafe_put(offset, ret_copy.unsafe_fetch(offset) * term)
          end
        end

        offset = -1
        counter = -1
        real_half.times do |i|
          offset += 1
          counter += 1
          if counter == half
            counter = 0
            offset += half
          end

          ret.unsafe_put(i,
            ret_copy.unsafe_fetch(offset) + ret_copy.unsafe_fetch(offset + half))
          ret.unsafe_put(i + real_half,
            ret_copy.unsafe_fetch(offset) - ret_copy.unsafe_fetch(offset + half))
        end

        shape *= 2
      end
      ret.map!(&./(ret.size))
    end
  end
end

# :nodoc:
struct Float
  def *(map : CrImage::Map)
    map * self
  end

  def +(map : CrImage::Map)
    map + self
  end
end

# :nodoc:
struct Int
  def *(map : CrImage::Map)
    map * self
  end

  def +(map : CrImage::Map)
    map + self
  end
end
