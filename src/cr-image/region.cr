module CrImage
  record Region,
    x : UInt16,
    y : UInt16,
    width : UInt16,
    height : UInt16 do
    def self.center(x : UInt16, y : UInt16, width : UInt16, height : UInt16) : Region
      new(x - (width // 2), y - (height // 2), width, height)
    end

    def crop(image : Image) : Image
      image.crop(self)
    end

    def center : Tuple(Int32, Int32)
      {(width.to_i // 2) + x.to_i, (height.to_i // 2) + y.to_i}
    end
  end
end
