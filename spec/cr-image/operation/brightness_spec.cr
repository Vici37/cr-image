require "../../spec_helper"

Spectator.describe CrImage::Operation::Brightness do
  include SpecHelper

  specs_for_operator(brightness(1.4),
    gray_hash: "bc097e57108462058e7ef137abf4127a173430e2",
    rgba_hash: "274960032af8505d1d29b3f12cff3bee3d64a535"
  )

  specs_for_operator(brightness(0.6),
    gray_hash: "d4f86794baac17191cbc15dfd8d4af185aca79c1",
    rgba_hash: "a57da73aafe18fb653ed90139f83a5d0038ac3fa"
  )

  specs_for_operator(brightness!(1.4),
    gray_hash: "bc097e57108462058e7ef137abf4127a173430e2",
    rgba_hash: "274960032af8505d1d29b3f12cff3bee3d64a535"
  )

  specs_for_operator(brightness!(0.6),
    gray_hash: "d4f86794baac17191cbc15dfd8d4af185aca79c1",
    rgba_hash: "a57da73aafe18fb653ed90139f83a5d0038ac3fa"
  )
end
