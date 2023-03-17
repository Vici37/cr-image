require "../../spec_helper"

Spectator.describe CrImage::Operation::GaussianBlur do
  include SpecHelper

  specs_for_operator(gaussian_blur(10),
    gray_hash: "217debdaffab3be19504828b08adb09949f6e7c2",
    rgba_hash: "dda2a00d6d3ef73021620ad7e0e2531d29e68425"
  )

  specs_for_operator(gaussian_blur!(10),
    gray_hash: "217debdaffab3be19504828b08adb09949f6e7c2",
    rgba_hash: "dda2a00d6d3ef73021620ad7e0e2531d29e68425"
  )
end
