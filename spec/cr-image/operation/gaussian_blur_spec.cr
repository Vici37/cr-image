require "../../spec_helper"

Spectator.describe CrImage::Operation::GaussianBlur do
  include SpecHelper

  specs_for_operator(gaussian_blur(10),
    gray_hash: "de22e6c2431632fb4feb0ad38366e51cb2a1c439",
    rgba_hash: "e564ef3cbc9c6cf11961d4d05aacf0a7046ce27f"
  )

  specs_for_operator(gaussian_blur!(10),
    gray_hash: "de22e6c2431632fb4feb0ad38366e51cb2a1c439",
    rgba_hash: "e564ef3cbc9c6cf11961d4d05aacf0a7046ce27f"
  )
end
