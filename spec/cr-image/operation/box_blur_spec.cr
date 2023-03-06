require "../../spec_helper"

Spectator.describe CrImage::Operation::BoxBlur do
  include SpecHelper

  specs_for_operator(box_blur(10),
    gray_hash: "7b74743d1bd28a31a6cab72f07c1dc9435ae2d7c",
    rgba_hash: "1f2d64cef690126372a938b0d4e2f54512932c3e"
  )

  specs_for_operator(box_blur!(10),
    gray_hash: "7b74743d1bd28a31a6cab72f07c1dc9435ae2d7c",
    rgba_hash: "1f2d64cef690126372a938b0d4e2f54512932c3e"
  )
end
