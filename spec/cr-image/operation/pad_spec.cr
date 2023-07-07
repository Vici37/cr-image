require "../../spec_helper"

Spectator.describe CrImage::Operation::Pad do
  include SpecHelper

  specs_for_operator(pad(100),
    gray_hash: "3c3952fce212ba648b763242e7872aebd5af2b67",
    rgba_hash: "ee5c463780b5228e039e0fa85eda453f9cd4d8d8"
  )

  specs_for_operator(pad(top: 50, left: 30, right: 20, bottom: 10),
    gray_hash: "5bc17895d37a8c3e333974312742b2ca5b8db3d9",
    rgba_hash: "54eee3d3a255004bef25fd47e9f24e42757883a4"
  )

  specs_for_operator(pad(top: 50, left: 30, right: 20, bottom: 10, pad_type: CrImage::EdgePolicy::Repeat),
    gray_hash: "5bc17895d37a8c3e333974312742b2ca5b8db3d9",
    rgba_hash: "d3cd58dfb28215ac520069dc2aec7a6e9d1e6258"
  )
end
