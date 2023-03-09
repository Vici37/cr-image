require "../../spec_helper"

Spectator.describe CrImage::Operation::Draw do
  include SpecHelper

  let(image) { rgba_moon_ppm }

  it "draws a blue box", :focus do
    mask = CrImage::Mask.new(image, false)
    mask[20..50, 20..50] = true
    mask.to_gray.save("contrived_mask.jpg")
    image.apply_color!(mask, CrImage::Color.of("#4")).save("new_moon.jpg")

    image
      .draw_box(
        image
          .to_gray
          .threshold(8)
          .region,
        CrImage::Color.of("#00f")
      ).save("blue_boxed_moon.jpg")

    image
      .to_gray
      .threshold(8)
      .segments
      .each_with_index do |m, i|
        # m.to_gray.save("mask_#{i}.jpg")
        image
          .draw_box(m.region, CrImage::Color.of("#0f0"))
          .save("moon_#{i}.jpg")
      end

    image
      .to_gray
      .threshold(8)
      .to_gray
      .save("threshold_8_mask.jpg")
  end
end
