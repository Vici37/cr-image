require "../../spec_helper"

Spectator.describe CrImage::Operation::HorizontalBlur do
  include SpecHelper

  specs_for_operator(horizontal_blur(10),
    gray_hash: "1d4edded3e030beba3527e9b5757b1407e3f75db",
    rgba_hash: "cf48769241b22392925cd62724a6cc631e618572"
  )

  specs_for_operator(horizontal_blur!(10),
    gray_hash: "1d4edded3e030beba3527e9b5757b1407e3f75db",
    rgba_hash: "cf48769241b22392925cd62724a6cc631e618572"
  )
end
