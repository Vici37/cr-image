module CrImage
  enum EdgePolicy
    Black  # Coordinates outside of image will resolve to black
    Repeat # Coordinates outside of image will resolve to edge of image
    None   # Window should not query outside of image
  end
end
