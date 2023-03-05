module CrImage
  record Region,
    x : UInt16,
    y : UInt16,
    width : UInt16,
    height : UInt16 do
    def crop(image : Image) : Image
      image.crop(self)
    end
  end
end
