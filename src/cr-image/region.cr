module CrImage
  # Represents a rectangular area on an `Image` from its upper left corner `x` and `y` coordinates, and a `width` and `height`.
  #
  # See `Operation::Crop#crop` and `Operation::Draw#draw_square` for examples using it.
  record Region,
    x : UInt16,
    y : UInt16,
    width : UInt16,
    height : UInt16 do
    # Construct a new `Region` with `x` and `y` being the center of the region instead of the upper left corner.
    def self.center(x : UInt16, y : UInt16, width : UInt16, height : UInt16) : Region
      new(x - (width // 2), y - (height // 2), width, height)
    end

    # Crop a provided `Image` with this region, using `Operation::Crop#crop`
    def crop(image : Image) : Image
      image.crop(self)
    end

    # Return the `{x, y}` tuple of the center coordinates of this `Region`
    def center : Tuple(Int32, Int32)
      {(width.to_i // 2) + x.to_i, (height.to_i // 2) + y.to_i}
    end

    # Return this `Region` as a `x`, `y`, `width`, and `height` tuple
    def to_tuple : Tuple(Int32, Int32, Int32, Int32)
      {x.to_i, y.to_i, width.to_i, height.to_i}
    end
  end
end
