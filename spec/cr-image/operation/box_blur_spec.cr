require "../../spec_helper"

Spectator.describe CrImage::Operation::BoxBlur do
  include SpecHelper

  specs_for_operator(box_blur(10),
    gray_hash: "d5a6b066333c3faebb537ee4ce1f2d52d007199f",
    rgba_hash: "3aaf9468206eed637c78a27d09c99925dadd0aa4"
  )

  specs_for_operator(box_blur!(10),
    gray_hash: "d5a6b066333c3faebb537ee4ce1f2d52d007199f",
    rgba_hash: "3aaf9468206eed637c78a27d09c99925dadd0aa4"
  )
end
