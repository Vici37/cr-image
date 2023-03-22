require "../../spec_helper"
require "benchmark"

Spectator.describe CrImage::Operation::Histogram do
  include SpecHelper

  specs_for_operator(histogram_equalize,
    gray_hash: "5109c626e06ad5704586ce0533e89d7e245f27f9",
    rgba_hash: "2e9f59da8d221654f4e1b4446539d1d6bb648c9b"
  )

  specs_for_operator(histogram_equalize!,
    gray_hash: "5109c626e06ad5704586ce0533e89d7e245f27f9",
    rgba_hash: "2e9f59da8d221654f4e1b4446539d1d6bb648c9b"
  )
end
