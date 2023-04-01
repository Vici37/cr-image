require "../../spec_helper"

Spectator.describe CrImage::Operation::GaussianBlur do
  include SpecHelper

  specs_for_operator(gaussian_blur(10),
    gray_hash: "217debdaffab3be19504828b08adb09949f6e7c2",
    rgba_hash: "4dd809f57d29d40e9670d6267643b22befa491c2"
  )

  specs_for_operator(gaussian_blur!(10),
    gray_hash: "217debdaffab3be19504828b08adb09949f6e7c2",
    rgba_hash: "4dd809f57d29d40e9670d6267643b22befa491c2"
  )
end
