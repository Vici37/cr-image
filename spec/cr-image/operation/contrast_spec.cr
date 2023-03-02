require "../../spec_helper"

Spectator.describe CrImage::Operation::Contrast do
  include SpecHelper

  specs_for_operator(contrast(128),
    gray_hash: "898e7e7c1a2c5e9eeb293d8bb64c92c39cc90ac5",
    rgba_hash: "acd1698e31c02ee5712c136ce0935b9881328232"
  )

  specs_for_operator(contrast(-128),
    gray_hash: "90a4106eb7b30b15120bffa48fd1758b885acdf2",
    rgba_hash: "09df6852a05ba64ed5507c6a4b8e9cd1455b0354"
  )

  specs_for_operator(contrast!(128),
    gray_hash: "898e7e7c1a2c5e9eeb293d8bb64c92c39cc90ac5",
    rgba_hash: "acd1698e31c02ee5712c136ce0935b9881328232"
  )

  specs_for_operator(contrast!(-128),
    gray_hash: "90a4106eb7b30b15120bffa48fd1758b885acdf2",
    rgba_hash: "09df6852a05ba64ed5507c6a4b8e9cd1455b0354"
  )
end
