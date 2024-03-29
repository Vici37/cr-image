require "bit_array"
require "./region"

# Mask is a wrapper around BitArray, where each flag represents a boolean bit of information about a pixel
# from an image. This can include whether a particular pixel has a value within certain conditions, OR
# if that pixel should be zeroed out or not.
#
# See `[]=` methods below for examples of how to manually construct masks.
#
# (x,y) - coordinates. Represent these positions in a Mask of size 10x10:
#
# ```
# [
#   (0,0), (0,1), (0,2), (0,3), (0,4), (0,5), (0,6), (0,7), (0,8), (0,9),
#   (1,0), (1,1), (1,2), (1,3), (1,4), (1,5), (1,6), (1,7), (1,8), (1,9),
#   (2,0), (2,1), (2,2), (2,3), (2,4), (2,5), (2,6), (2,7), (2,8), (2,9),
#   (3,0), (3,1), (3,2), (3,3), (3,4), (3,5), (3,6), (3,7), (3,8), (3,9),
#   (4,0), (4,1), (4,2), (4,3), (4,4), (4,5), (4,6), (4,7), (4,8), (4,9),
#   (5,0), (5,1), (5,2), (5,3), (5,4), (5,5), (5,6), (5,7), (5,8), (5,9),
#   (6,0), (6,1), (6,2), (6,3), (6,4), (6,5), (6,6), (6,7), (6,8), (6,9),
#   (7,0), (7,1), (7,2), (7,3), (7,4), (7,5), (7,6), (7,7), (7,8), (7,9),
#   (8,0), (8,1), (8,2), (8,3), (8,4), (8,5), (8,6), (8,7), (8,8), (8,9),
#   (9,0), (9,1), (9,2), (9,3), (9,4), (9,5), (9,6), (9,7), (9,8), (9,9),
# ]
# ```
#
# And every position is a Bool value.
#
# Different ways to refer to coordinates:
# ```
# mask.at(0, 0)    # => (0,0)
# mask[0, 0]       # => (0,0), same as .at(0, 0)
# mask[0..1, 4]    # => (4,0), (4,1)
# mask[3, 3..5]    # => (3,3), (3,4), (3,5)
# mask[2..3, 4..5] # => (2,4), (2,5), (3,4), (3,5)
# ```
#
# See `Operation::Crop` and `Operation::MaskApply` for how this can be useful
class CrImage::Mask
  include Map(Bool)

  getter width : Int32
  getter bits : BitArray

  @segments_8_way : Array(Mask)? = nil
  @segments_4_way : Array(Mask)? = nil

  # Construct a new `Mask` with a set width and bits from `bits`
  def initialize(@width, @bits)
    raise "BitArray size #{@bits.size} must be an even number of #{@width}" unless (@bits.size % @width) == 0
  end

  # Construct a new `Mask` of width x height, preset to `initial`
  def initialize(@width, height : Int32, initial : Bool = true)
    @bits = BitArray.new(@width * height, initial)
  end

  # Construct a new `Mask` of width x height using `&block` to determine if a bit should be true or not (passed in `x` and `y` coordinates)
  def initialize(@width, height : Int32, &block : (Int32, Int32) -> Bool)
    @bits = BitArray.new(@width * height) do |i|
      block.call(i % @width, i // @width)
    end
  end

  # Construct a new `Mask` from an integer (useful for testing or small mask construction)
  def initialize(@width, height : Int32, int : Int)
    size = @width * height
    @bits = BitArray.new(size) { |i| int.bit(size - i - 1) > 0 }
  end

  # Construct a new `Mask` from the dimensions of passed in `image` with an initial bit
  def initialize(image : Image, initial : Bool = true)
    @width = image.width
    @bits = BitArray.new(image.size, initial)
  end

  # Construct a new `Mask` from an array of `BitArray`. See `#[](xs : Range, ys : Range) : Array(BitArray)`
  #
  # This assumes `other_bits[0]` corresponds to `x == 0` in the mask, and the corresponding
  # `BitArray` represents all bits for that row. All `BitArray`s must be of the same size in
  # `other_bits`.
  def initialize(other_bits : Array(BitArray))
    raise "Can't create an empty mask" if other_bits.empty?
    raise "Can't create an empty mask, first array is empty" if other_bits[0].empty?
    raise "All sub arrays must be the same size" unless other_bits.map(&.size).uniq!.size == 1

    @width = other_bits[0].size
    @bits = BitArray.new(other_bits.size * @width)
    other_bits.each_with_index do |arr, i|
      arr.each_with_index do |bool, j|
        @bits[i * @width + j] = bool
      end
    end
  end

  # How many bits are stored in this `Mask`
  def size : Int32
    bits.size
  end

  # Returns the dimension of this mask (width x height)
  def shape : Tuple(Int32, Int32)
    {width, height}
  end

  # Create a new `Mask` from this one without modifying it
  def clone
    Mask.new(width, bits.dup)
  end

  def height : Int32
    @bits.size // width
  end

  # Invert all bits in this instance of `Mask`. Modifies self.
  #
  # <img src="https://raw.githubusercontent.com/Vici37/cr-image/master/docs/images/mask_segments_example.jpg" alt="Black box with different regions colored white"/>
  #
  # Becomes
  #
  # <img src="https://raw.githubusercontent.com/Vici37/cr-image/master/docs/images/mask_inverted_example.jpg" alt="White box with opposite regions colored black"/>
  def invert!
    @bits.invert
    clear_caches
    self
  end

  # Return a new `Mask` that's a copy of this one with all bits inverted.
  def invert
    clone.invert!
  end

  # Return the bit at `index`
  def at(index : Int32) : Bool
    raise "Index #{index} exceeds mask size #{@bits.size}" if index >= size
    @bits[index]
  end

  # Return the bit at `index`
  def [](index : Int32) : Bool
    @bits[index]
  end

  def []?(index : Int32) : Bool?
    @bits[index]?
  end

  def []?(x : Int32, y : Int32) : Bool?
    @bits[y * width + x]?
  end

  # Return the bit at `x` and `y`
  def [](x : Int32, y : Int32) : Bool
    raise IndexError.new("Out of bounds: this mask is #{width}x#{height}, and (#{x},#{y}) is outside of that") if x >= width || y >= height
    @bits[y * width + x]
  end

  # Return a new `BitArray` corresponding to the partial row specified
  def [](xs : Range, y : Int32) : BitArray
    start, count = resolve_to_start_and_count(xs, width)
    BitArray.new(count) { |x| self[x + start, y] }
  end

  # Return a new `BitArray` corresponding to the partial column specified
  def [](x : Int32, ys : Range) : BitArray
    start, count = resolve_to_start_and_count(ys, height)
    BitArray.new(count) { |y| self[x, y + start] }
  end

  # Return an `Array(BitArray)` for the partial box (of partial rows and partial columns) of this mask.
  #
  # Can be used to construct another mask from.
  def [](xs : Range, ys : Range) : Array(BitArray)
    xstart, xcount = resolve_to_start_and_count(xs, width)
    ystart, ycount = resolve_to_start_and_count(ys, height)
    self[xstart, xcount, ystart, ycount]
  end

  # :ditto:
  def [](xstart : Int32, xcount : Int32, ystart : Int32, ycount : Int32) : Array(BitArray)
    ycount.times.to_a.map do |y|
      BitArray.new(xcount) do |x|
        self[x + xstart, y + ystart]
      end
    end
  end

  def ==(other : Mask)
    width == other.width &&
      bits == other.bits
  end

  # Set the bit for coordinate `x` and `y`
  def set(x : Int32, y : Int32, value : Bool) : Bool
    raise IndexError.new("Out of bounds: this mask is #{width}x#{height}, and (#{x},#{y}) is outside of that") if x >= width || y >= height
    clear_caches
    @bits[y * width + x] = value
  end

  # Set the bit for coordinate `x` and `y`
  #
  # ```
  # mask = CrImage::Mask.new(50, 50, false)
  # mask[20, 20] = true
  # mask.to_gray.save("mask_point.jpg")
  # ```
  # <img src="https://raw.githubusercontent.com/Vici37/cr-image/master/docs/images/mask_point.jpg" alt="Black box with single white point at 20, 20"/>
  def []=(x : Int32, y : Int32, value : Bool) : Bool
    self.set(x, y, value)
  end

  # Set the bits for partial row `xs` at column `y`
  #
  # ```
  # mask = CrImage::Mask.new(50, 50, false)
  # mask[20..40, 20] = true
  # mask.to_gray.save("mask_partial_row.jpg")
  # ```
  # <img src="https://raw.githubusercontent.com/Vici37/cr-image/master/docs/images/mask_partial_row.jpg" alt="Black box with partial white horizontal line from 20, 20 to 40, 20"/>
  def []=(xs : Range, y : Int32, value : Bool) : Bool
    raise IndexError.new("Out of bounds: #{y} is beyond the bounds of this mask's height of #{height}") if y >= height
    start_x, count_x = resolve_to_start_and_count(xs, width)
    @bits.fill(value, y * width + start_x, count_x)
    clear_caches
    value
  end

  # Set the bits for row `x` and partial columns `ys`
  #
  # ```
  # mask = CrImage::Mask.new(50, 50, false)
  # mask[20..40, 20] = true
  # mask.to_gray.save("mask_partial_column.jpg")
  # ```
  # <img src="https://raw.githubusercontent.com/Vici37/cr-image/master/docs/images/mask_partial_column.jpg" alt="Black box with partial white vertical line from 20, 20 to 20, 40"/>
  def []=(x : Int32, ys : Range, value : Bool) : Bool
    raise IndexError.new("Out of bounds: #{x} is beyond the bounds of this mask's width of #{width}") if x >= width
    start_y, count_y = resolve_to_start_and_count(ys, height)
    count_y.times.to_a.each do |y|
      set(x, y + start_y, value)
    end
    value
  end

  # Set the bits for partial rows `xs` and partial columns `ys`
  #
  # ```
  # mask = CrImage::Mask.new(50, 50, false)
  # mask[20..40, 20..40] = true
  # mask.to_gray.save("mask_partial_column.jpg")
  # ```
  # <img src="https://raw.githubusercontent.com/Vici37/cr-image/master/docs/images/mask_box.jpg" alt="Black box with smaller white box in it from 20, 20 to 40, 40"/>
  def []=(xs : Range, ys : Range, value : Bool) : Bool
    start_x, count_x = resolve_to_start_and_count(xs, width)
    start_y, count_y = resolve_to_start_and_count(ys, height)
    count_y.times.to_a.each do |y|
      @bits.fill(value, (y + start_y) * width + start_x, count_x)
    end
    clear_caches
    value
  end

  # Convert this `Mask` to a `GrayscaleImage`, with false bits becoming 0, and true bits becoming 255
  def to_gray : GrayscaleImage
    GrayscaleImage.new(bits.map { |b| b ? 255u8 : 0u8 }, width, height)
  end

  # Apply this mask to the provided image with `Operation::MaskApply#apply`
  def apply(image : Image) : Image
    image.apply(self)
  end

  # Apply this mask to the provided image with `Operation::MaskApply#apply`
  def apply(image : Image, &block : (UInt8, ChannelType, Int32, Int32) -> UInt8) : Image
    image.apply(self, &block)
  end

  private def clear_caches
    @region = nil
    @segments_8_way = nil
    @segments_4_way = nil
  end

  @region : Region? = nil

  # Returns the bounding box of the mask where all true bits are contained. Any pixels outside of the region are false
  #
  # ```
  # mask = CrImage::Mask.new(50, 50, false)
  # mask[20..40, 20] = true
  # mask[20, 20..40] = true
  # mask.region # => Region(x: 20, y: 20, width: 20, height: 20)
  # ```
  #
  # <img src="https://raw.githubusercontent.com/Vici37/cr-image/master/docs/images/mask_region_example.jpg" alt="Black box with white lines from 20, 20 going to 20, 40 and 40, 20"/>
  def region : Region
    @region ||= calculate_region
  end

  private def calculate_region : Region
    return Region.new((width - 1).to_u16, (height - 1).to_u16, 0u16, 0u16) unless bits.any?(&.itself)

    min_x, min_y = width.to_u16, height.to_u16
    max_x, max_y = 0_u16, 0_u16

    bits.each_with_index do |bit, index|
      next unless bit

      x = (index % width).to_u16
      y = (index // width).to_u16

      min_y = y if min_y > y

      min_x = Math.min(min_x, x)
      max_x = Math.max(max_x, x)

      max_y = y
    end

    Region.new(min_x, min_y, max_x - min_x + 1, max_y - min_y + 1)
  end

  # Return an array of `Mask`s, each one corresponding to an area of contiguous true bits (identified from flood fills).
  #
  # May specify `diagonal: false` for only 4-way (up, down, left, right) flood fill instead of default 8-way.
  # Starting with sample mask:
  # ```
  # mask = CrImage::Mask.new(50, 50, false)
  #
  # mask[5..45, 5..45] = true
  # mask[15..35, 15..35] = false
  # mask[21..25, 21..25] = true
  # mask[26..30, 26..30] = true
  # ```
  #
  # <img src="https://raw.githubusercontent.com/Vici37/cr-image/master/docs/images/mask_segments_example.jpg" alt="Black box with different regions colored white"/>
  #
  # Its segments look like:
  # ```
  # mask.segments.each_with_index do |segment, i|
  #   segment.to_gray.save("mask_8-way_segments_example_#{i}.jpg")
  # end
  # ```
  # Yields the images:
  #
  # <img src="https://raw.githubusercontent.com/Vici37/cr-image/master/docs/images/mask_8-way_segments_example_0.jpg" alt="Black box with hollow white box in it"/>
  # <img src="https://raw.githubusercontent.com/Vici37/cr-image/master/docs/images/mask_8-way_segments_example_1.jpg" alt="Black box with two diagonal white boxes touching in the corner"/>
  #
  # Using `diagonal: false` yields:
  # ```
  # mask.segments(diagonal: false).each_with_index do |segment, i|
  #   segment.to_gray.save("mask_4-way_segments_example_#{i}.jpg")
  # end
  # ```
  # Yields the images:
  #
  # <img src="https://raw.githubusercontent.com/Vici37/cr-image/master/docs/images/mask_4-way_segments_example_0.jpg" alt="Black box with hollow white box in it"/>
  # <img src="https://raw.githubusercontent.com/Vici37/cr-image/master/docs/images/mask_4-way_segments_example_1.jpg" alt="Black box with small white box in upper left center"/>
  # <img src="https://raw.githubusercontent.com/Vici37/cr-image/master/docs/images/mask_4-way_segments_example_2.jpg" alt="Black box with small white box in lower right center"/>
  def segments(*, diagonal : Bool = true) : Array(Mask)
    diagonal ? (@segments_8_way ||= calculate_segments(diagonal)) : (@segments_4_way ||= calculate_segments(diagonal))
  end

  private def calculate_segments(diagonal) : Array(Mask)
    return [] of Mask unless bits.any?(&.itself)

    ret = [] of Mask
    copy = clone

    outer_x = -1
    outer_y = 0
    # TODO: implement a scanline algo: http://www.adammil.net/blog/v126_A_More_Efficient_Flood_Fill.html
    size.times do
      outer_x += 1
      if outer_x == width
        outer_x = 0
        outer_y += 1
      end

      next unless copy[outer_x, outer_y]

      new_mask = Mask.new(width, height, false)
      queue = Deque(Tuple(Int32, Int32)).new([{outer_x, outer_y}])

      while coords = queue.shift?
        x, y = coords

        # has already been processed
        next if new_mask[x, y]

        new_mask[x, y] = true
        copy[x, y] = false

        lower_x = Math.max(x - 1, 0)
        upper_x = Math.min(x + 1, width - 1)
        lower_y = Math.max(y - 1, 0)
        upper_y = Math.min(y + 1, height - 1)

        queue << {lower_x, y} if copy[lower_x, y]
        queue << {x, lower_y} if copy[x, lower_y]
        queue << {x, upper_y} if copy[x, upper_y]
        queue << {upper_x, y} if copy[upper_x, y]

        next unless diagonal

        queue << {lower_x, lower_y} if copy[lower_x, lower_y]
        queue << {lower_x, upper_y} if copy[lower_x, upper_y]
        queue << {upper_x, lower_y} if copy[upper_x, lower_y]
        queue << {upper_x, upper_y} if copy[upper_x, upper_y]
      end

      ret << new_mask
    end

    ret
  end

  # [Dilation](https://en.wikipedia.org/wiki/Mathematical_morphology#Dilation) operator
  def dilate(*, diagonal : Bool = true) : Mask
    clone.dilate!(diagonal: diagonal)
  end

  # :ditto:
  def dilate!(*, diagonal : Bool = true) : self
    clear_caches

    new_bits = bits.dup

    x = -1
    y = 0
    bits.size.times do |i|
      x += 1
      if x == width
        x = 0
        y += 1
      end

      next if bits[i]

      new_bits[i] = (x != 0 && bits[i - 1]) ||
                    (x != (width - 1) && bits[i + 1]) ||
                    (y != 0 && bits[i - width]) ||
                    (y != (height - 1) && bits[i + width]) ||
                    (diagonal && (
                      (x != 0 && y != 0 && bits[i - width - 1]) ||
                      (x != (width - 1) && y != 0 && bits[i - width + 1]) ||
                      (x != 0 && y != (height - 1) && bits[i + width - 1]) ||
                      (x != (width - 1) && y != (height - 1) && bits[i + width + 1])
                    ))
    end

    @bits = new_bits

    self
  end

  # [Erosion](https://en.wikipedia.org/wiki/Mathematical_morphology#Erosion) operator
  def erode(*, diagonal : Bool = true) : Mask
    clone.erode!(diagonal: diagonal)
  end

  # :ditto:
  def erode!(*, diagonal : Bool = true) : Mask
    invert!.dilate!(diagonal: diagonal).invert!
  end

  # [Opening](https://en.wikipedia.org/wiki/Mathematical_morphology#Opening) operator
  def opening(*, diagonal : Bool = true) : Mask
    clone.opening!(diagonal: diagonal)
  end

  # :ditto:
  def opening!(*, diagonal : Bool = true) : Mask
    erode!(diagonal: diagonal).dilate!(diagonal: diagonal)
  end

  # [Closing](https://en.wikipedia.org/wiki/Mathematical_morphology#Closing) operator
  def closing(*, diagonal : Bool = true) : Mask
    clone.closing!(diagonal: diagonal)
  end

  # :ditto:
  def closing!(*, diagonal : Bool = true) : Mask
    dilate!(diagonal: diagonal).erode!(diagonal: diagonal)
  end

  def |(other : Mask) : Mask
    Mask.new(width, BitArray.new(size) { |i| bits[i] | other.bits[i] })
  end
end
