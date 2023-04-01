require "../../spec_helper"

Spectator.describe CrImage::Operation::VerticalBlur do
  include SpecHelper

  specs_for_operator(vertical_blur(10),
    gray_hash: "3b6ebdd3da8daf97b28ff76755f99fda08237585",
    rgba_hash: "622e8f4f758b40f832a70d79f0cc94a0d4e413e9"
  )

  specs_for_operator(vertical_blur!(10),
    gray_hash: "3b6ebdd3da8daf97b28ff76755f99fda08237585",
    rgba_hash: "622e8f4f758b40f832a70d79f0cc94a0d4e413e9"
  )
end
