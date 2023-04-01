require "../../spec_helper"

Spectator.describe CrImage::Operation::HorizontalBlur do
  include SpecHelper

  specs_for_operator(horizontal_blur(10),
    gray_hash: "f8ef00c6475a4a10b1fca8e428dfb1c4590ca2a5",
    rgba_hash: "3603d0904082a2a58dad8e66e19ee8791f85900f"
  )

  specs_for_operator(horizontal_blur!(10),
    gray_hash: "f8ef00c6475a4a10b1fca8e428dfb1c4590ca2a5",
    rgba_hash: "3603d0904082a2a58dad8e66e19ee8791f85900f"
  )
end
