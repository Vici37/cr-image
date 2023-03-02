require "../../spec_helper"

Spectator.describe CrImage::Operation::BilinearResize do
  include SpecHelper

  specs_for_operator(bilinear_resize(480, 360),
    gray_hash: "ffaeadfd8690bf83dd8a557565f1e031855349ba",
    rgba_hash: "e5299ce3ac12a4cea61e8a3f9361f327e1f7bdbb"
  )

  specs_for_operator(bilinear_resize(1000, 750),
    gray_hash: "46da5366167223e5bf6733b34328026afffc6ae0",
    rgba_hash: "c1c35ae23467ee632568a3517ba73d7b00d99745"
  )

  specs_for_operator(bilinear_resize!(480, 360),
    gray_hash: "ffaeadfd8690bf83dd8a557565f1e031855349ba",
    rgba_hash: "e5299ce3ac12a4cea61e8a3f9361f327e1f7bdbb"
  )

  specs_for_operator(bilinear_resize!(1000, 750),
    gray_hash: "46da5366167223e5bf6733b34328026afffc6ae0",
    rgba_hash: "c1c35ae23467ee632568a3517ba73d7b00d99745"
  )
end
