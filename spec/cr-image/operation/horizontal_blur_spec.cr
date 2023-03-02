require "../../spec_helper"

Spectator.describe CrImage::Operation::HorizontalBlur do
  include SpecHelper

  specs_for_operator(horizontal_blur(10),
    gray_hash: "f8ef00c6475a4a10b1fca8e428dfb1c4590ca2a5",
    rgba_hash: "d2fa1509a3515af24ee4c21980a8ee224a1ab1b0"
  )

  specs_for_operator(horizontal_blur!(10),
    gray_hash: "f8ef00c6475a4a10b1fca8e428dfb1c4590ca2a5",
    rgba_hash: "d2fa1509a3515af24ee4c21980a8ee224a1ab1b0"
  )
end
