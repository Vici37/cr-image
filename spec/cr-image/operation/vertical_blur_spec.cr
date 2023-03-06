require "../../spec_helper"

Spectator.describe CrImage::Operation::VerticalBlur do
  include SpecHelper

  specs_for_operator(vertical_blur(10),
    gray_hash: "192ec915c4f111faba16fcb16de7cd615afaf970",
    rgba_hash: "fd658a5f7a2e815b493dcd30d04601a05da7609c"
  )

  specs_for_operator(vertical_blur!(10),
    gray_hash: "192ec915c4f111faba16fcb16de7cd615afaf970",
    rgba_hash: "fd658a5f7a2e815b493dcd30d04601a05da7609c"
  )
end
