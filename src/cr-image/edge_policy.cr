module CrImage
  # A general enum for determining behavior around edges of `Image` or `Map`s. See also `Operator::Pad`
  enum EdgePolicy
    Black  # Coordinates outside of image will resolve to black
    Repeat # Coordinates outside of image will resolve to edge of image
    None   # Window should not query outside of image
  end
end
