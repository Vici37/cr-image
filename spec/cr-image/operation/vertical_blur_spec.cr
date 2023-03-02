require "../../spec_helper"

Spectator.describe CrImage::Operation::VerticalBlur do
  include SpecHelper

  specs_for_operator(vertical_blur(10),
    gray_hash: "3b6ebdd3da8daf97b28ff76755f99fda08237585",
    rgba_hash: "09fb58df58a8368b26dccc2078b8e31afeeaf512"
  )

  specs_for_operator(vertical_blur!(10),
    gray_hash: "3b6ebdd3da8daf97b28ff76755f99fda08237585",
    rgba_hash: "09fb58df58a8368b26dccc2078b8e31afeeaf512"
  )
end
