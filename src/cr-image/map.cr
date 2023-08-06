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

    # Commented out for now until `Mask` figures out if `Array(BitArray)` is correct or not
    # abstract def [](xstart : Int32, yrange : Range) : Map(T)
    # abstract def [](xrange : Range, ystart : Int32) : Map(T)
    # abstract def [](xrange : Range, yrange : Range) : Map(T)
    # abstract def [](xstart : Int32, xcount : Int32, ystart : Int32, ycount : Int32) : Map(T)

    private def resolve_to_start_and_count(range, size) : Tuple(Int32, Int32)
      start, count = Indexable.range_to_index_and_count(range, size) || raise IndexError.new("Unable to resolve range #{range} for mask dimension of #{size}")
      raise IndexError.new("Range #{range} exceeds bounds of #{size}") if (start + count) > size
      {start, count}
    end
  end

  # Additional methods for `Map` that assume `T` is a numeric type. See `MapImpl`
  module NumericMap(T)
    include Map(T)

    abstract def to_i : NumericMap(Int32)
    abstract def to_c : NumericMap(Complex)
    abstract def to_f : NumericMap(Float64)

    abstract def sum : T
    abstract def max : T
    abstract def min : T
  end

  # A collection of implementations of `NumericMap(T)`, intended to be included in base classes.
  #
  # See `IntMap`, `FloatMap`, and `ComplexMap`.
  module MapImpl(T)
    include NumericMap(T)

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

    # Crop the map, returning only the values in row at `ystart`
    def [](xrange : Range, ystart : Int32) : self
      internal_crop(*resolve_to_start_and_count(xrange, width), ystart, 1)
    end

    # Crop the map, returning only the values in column at `xstart`
    def [](xstart : Int32, yrange : Range) : self
      internal_crop(xstart, 1, *resolve_to_start_and_count(yrange, height))
    end

    # Crop the map to the values contained in `xrange` and `yrange`
    def [](xrange : Range, yrange : Range) : self
      internal_crop(*resolve_to_start_and_count(xrange, width), *resolve_to_start_and_count(yrange, height))
    end

    # Crop the map to the values contained from `xstart` out by `xcount`, and `ystart` out by `ycount`
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

      old_i = -width + height_offset + xstart
      new_i = -xcount
      ycount.times do
        old_i += width
        new_i += xcount
        new_raw[new_i, xcount] = raw[old_i, xcount]
      end

      {{@type}}.new(xcount, new_raw)
    end

    # Return the average of the elements in this `Map`
    def mean : Float64
      @raw.sum / size
    end

    # Return the minimum value in this `Map`
    def min : T
      @raw.min
    end

    # Return the maximum value in this `Map`
    def max : T
      @raw.max
    end

    # Return the sum of all values in this `Map`
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

    # Construct a `Mask` identifying all pixels smaller than or equal to `num`. See `#<` for example.
    def <=(num : Int | Float) : Mask
      mask_from { |val| val <= num }
    end

    # Construct a `Mask` identifying all pixels equal to `num`
    def ==(num : Int | Float) : Mask
      mask_from { |val| val == num }
    end

    # Check if this `Map` is equal to `other`
    def ==(other : self) : Bool
      other.width == width && @raw == other.raw
    end

    # Divides each point in this `Map` by `num`
    #
    # TODO: ComplexMap shouldn't return a FloatMap
    def /(num : Int | Float) : FloatMap
      FloatMap.new(width, @raw.map { |i| i / num })
    end

    # Multiply each point in this `Map` by `num`
    def *(num : Int | Float) : self
      self.class.new(width, @raw.map { |i| i * num })
    end

    # Add each point in this `Map` by `num`
    def +(num : Int | Float) : self
      self.class.new(width, @raw.map { |i| i + num })
    end

    # Subtract each point in this `Map` by `num`
    def -(num : Int) : self
      self.class.new(width, @raw.map { |i| i - num })
    end

    # :ditto:
    def -(num : Float) : FloatMap
      FloatMap.new(width, @raw.map { |i| i - num })
    end

    # Add each point of this `Map` with each point in `other`
    def +(other : self) : self
      raise Exception.new "Dimensions should match (caller: #{width}x#{height}, callee: #{other.width}x#{other.height})" unless width == other.width && height == other.height
      self.class.new(width, @raw.map_with_index { |val, i| val + other[i] })
    end

    # Convert this `Map` to a `GrayscaleImage`.
    #
    # Set `scale: true` so that all of the values will scale, such that `max` will become `255u8`, and `min` will become `0u8`. All other values will be
    # linearly scaled between those values.
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

    # Receive a copy of the underlying `raw` array.
    def to_a : Array(T)
      @raw.dup
    end

    # Convert this `Map` to a `ComplexMap`
    def to_c : ComplexMap
      ComplexMap.new(width, raw.map(&.to_c))
    end

    # Pad the borders of this `Map` corresponding to `pad_type`.
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

    # Perform a brute force cross correlation calculation with provided `template`.
    def cross_correlate(template : Map, *, edge_policy : EdgePolicy = EdgePolicy::Repeat) : FloatMap
      half_width = template.width >> 1
      half_height = template.height >> 1

      start_x, start_y = (edge_policy.none? ? {half_width, half_height} : {0, 0})
      end_x, end_y = (edge_policy.none? ? {width - half_width - 1, height - half_height - 1} : {width - 1, height - 1})

      ret = Array(Float64).new((end_x - start_x) * (end_y - start_y))

      start_y.upto(end_y).each do |y|
        start_x.upto(end_x).each do |x|
          view = case edge_policy
                 in EdgePolicy::Repeat then RepeatView(T).new(template.width, template.height, self, x, y)
                 in EdgePolicy::Black  then BlackView(T).new(template.width, template.height, self, x, y)
                 in EdgePolicy::None   then ErrorView(T).new(template.width, template.height, self, x, y)
                 end
          # ret << view.sum(1.0 / template.raw.sum) do |pixel, vx, vy|
          ret << view.sum do |pixel, vx, vy|
            template[vx, vy] * pixel
          end
        end
      end

      retf = FloatMap.new(end_x - start_x + 1, ret)
      retf
    end

    # Perform a Fast Fourier Transform cross correlation (convolution?) with provided `template`. See `FftUtil`
    def cross_correlate_fft(template : Map, *, edge_policy : EdgePolicy = EdgePolicy::Black) : FloatMap
      max_width, max_height = Math.pw2ceil(width + template.width), Math.pw2ceil(height + template.height)
      pad_type = edge_policy.none? ? EdgePolicy::Black : edge_policy

      width_range, height_range = case edge_policy
                                  in EdgePolicy::Black, EdgePolicy::Repeat
                                    {
                                      (template.width)...(width + template.width),
                                      (template.height)...(height + template.height),
                                    }
                                  in EdgePolicy::None
                                    {
                                      (template.width + template.width // 2)..(template.width + width - template.width + 1),
                                      (template.height + template.height // 2)..(template.height + height - template.height + 1),
                                    }
                                  end

      orig_pad_fft = pad(
        # These paddings "bumps" the original template down and to the right, for the sake of edge_policy Repeat
        top: (template.height // 2) + (template.height % 2),
        bottom: max_height - height - (template.height // 2 + template.height % 2),
        right: max_width - width - (template.width // 2 + template.width % 2),
        left: (template.width // 2) + (template.width % 2),
        pad_type: pad_type).to_c
      map_pad_fft = template.pad(bottom: max_height - template.height, right: max_width - template.width).to_c

      buffer = Array(Complex).new(Math.max(max_width, max_height)) { Complex.zero }
      FftUtil.fft2d_unsafe(max_width, orig_pad_fft.raw, buffer)
      FftUtil.fft2d_unsafe(max_width, map_pad_fft.raw, buffer)

      orig_pad_fft.raw.map_with_index! { |o, i| o * map_pad_fft[i] }

      FftUtil.ifft2d_unsafe(max_width, orig_pad_fft.raw, buffer)

      ret = FloatMap.new(max_width, orig_pad_fft.raw.map(&.real))[width_range, height_range]

      ret
    end

    # Performe a Fast Fourier Transform, padding out this `Map` so dimensions are a power of 2. See `FftUtil`
    def fft : ComplexMap
      map = pad(bottom: Math.pw2ceil(height) - height, right: Math.pw2ceil(width) - width).to_c

      buffer = Array(Complex).new(Math.max(map.height, map.width)) { Complex.zero }

      ComplexMap.new(map.width, FftUtil.fft2d_unsafe(map.width, map.raw, buffer))
    end

    # def to_s
    #   raw.each_with_index do |val, i|
    #     print("#{val.round}\t")
    #     puts if (i + 1) % width == 0
    #   end
    # end
  end

  # Implementation of `MapImpl` for `Int32` types.
  class IntMap
    include MapImpl(Int32)

    def to_f64 : FloatMap
      FloatMap.new(width, @raw.map(&.to_f64))
    end

    def to_f : FloatMap
      to_f64
    end

    def to_i : self
      self
    end
  end

  # Implementation of `MapImpl` for `UInt8` types. This type is useful for `MapImpl` operations around channels.
  class UInt8Map
    include MapImpl(UInt8)

    def to_i : IntMap
      IntMap.new(width, @raw.map(&.to_i))
    end

    def to_f : FloatMap
      FloatMap.new(width, @raw.map(&.to_f))
    end
  end

  # Implementation of `MapImpl` for `Float64` types.
  class FloatMap
    include MapImpl(Float64)

    def to_f64 : self
      self
    end

    def to_i : IntMap
      IntMap.new(width, @raw.map(&.to_i))
    end

    def to_f : FloatMap
      self
    end
  end

  # Memory efficient implementation of `MapImpl` when all values are equal to `1`
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

    def [](xstart : Int32, yrange : Range) : OneMap
      _, ycount = range_to_index_and_count(yrange)
      OneMap.new(1, ycount)
    end

    def [](xrange : Range, ystart : Int32) : OneMap
      _, xcount = range_to_index_and_count(xrange)
      OneMap.new(xcount, 1)
    end

    def [](xrange : Range, yrange : Range) : OneMap
      _, xcount = range_to_index_and_count(xrange)
      _, ycount = range_to_index_and_count(yrange)
      OneMap.new(xcount, ycount)
    end

    def [](xstart : Int32, xcount : Int32, ystart : Int32, ycount : Int32) : OneMap
      OneMap.new(xcount, ycount)
    end

    # def to_intmap : IntMap
    #   IntMap.new(width, Array(Int32).new(size) { 1 })
    # end

    def pad(all : Int32 = 0, *, top : Int32 = 0, bottom : Int32 = 0, left : Int32 = 0, right : Int32 = 0, pad_type : EdgePolicy = EdgePolicy::Black, pad_black_value : T = T.zero) : OneMap | IntMap
      case pad_type
      in EdgePolicy::Black then to_i.pad(all, top: top, bottom: bottom, left: left, right: right, pad_type: pad_type, pad_black_value: pad_black_value)
      in EdgePolicy::Repeat
        top = top > 0 ? top : all
        bottom = bottom > 0 ? bottom : all
        left = left > 0 ? left : all
        right = right > 0 ? right : all
        @width += left + right
        @height += top + bottom
        self
      in EdgePolicy::None then raise Exception.new("Pad method doesn't support edge policy None")
      end
    end

    def to_i : IntMap
      IntMap.new(width, Array(Int32).new(size) { 1 })
    end

    def to_c : ComplexMap
      ComplexMap.new(width, Array(Complex).new(size) { Complex.new(1) })
    end
  end

  class ComplexMap
    include MapImpl(Complex)

    def ifft : FloatMap
      FloatMap.new(width, FftUtil.ifft2d(width, raw).map(&.real))
    end

    def to_c : ComplexMap
      self
    end

    def to_i : IntMap
      raise Exception.new "Unable to convert ComplexMap to IntMap"
    end

    def to_f : FloatMap
      raise Exception.new "Unable to convert ComplexMap to FloatMap"
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
