require "../../spec_helper"

Spectator.describe CrImage::Operation::BoxBlur do
  include SpecHelper

  specs_for_operator(box_blur(10),
    gray_hash: "d5a6b066333c3faebb537ee4ce1f2d52d007199f",
    rgba_hash: "2771277b946435f8b2bd4cb4494b68a109439160"
  )

  specs_for_operator(box_blur!(10),
    gray_hash: "d5a6b066333c3faebb537ee4ce1f2d52d007199f",
    rgba_hash: "2771277b946435f8b2bd4cb4494b68a109439160"
  )
end
