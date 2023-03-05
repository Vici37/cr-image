require "../../spec_helper"

Spectator.describe CrImage::Operation::Crop do
  include SpecHelper

  specs_for_operator(crop(0, 0, 750, 500),
    gray_hash: "62d6101d60ee8da38d1b9d8e809091099cec5994",
    rgba_hash: "d764459f778b4839972367f78197bf9a96cd11fd"
  )

  specs_for_operator(crop(450, 200, 100, 100),
    gray_hash: "21506a4a0383736b41637e383f91373e7d0e781b",
    rgba_hash: "25237b6d0408e7eab6e167d5e4576630c30ce4f1"
  )

  specs_for_operator(crop!(450, 200, 100, 100),
    gray_hash: "21506a4a0383736b41637e383f91373e7d0e781b",
    rgba_hash: "25237b6d0408e7eab6e167d5e4576630c30ce4f1"
  )

  describe "#crop checks boundaries" do
    let(image) { gray_moon_ppm }

    it "for width" do
      expect_raises(Exception, "Crop dimensions extend 1 pixels beyond width of the image (750)") do
        image.crop(0, 0, image.width + 1, image.height)
      end
    end

    it "for height" do
      expect_raises(Exception, "Crop dimensions extend 1 pixels beyond height of the image (500)") do
        image.crop(0, 0, image.width, image.height + 1)
      end
    end
  end
end
